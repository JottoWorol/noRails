--[[

Это код отвечает за генерацию уровня
initializeGrid - ставит первичные блоки и запускает движение
loadLevel - загрузить карту уровня
setBlock - поставить препятствие/бонус
setBlockLine - поставить линию блоков
setRail - поставить рельсу

]]
local cellsOnScreen = intDiv(_H,CELL_WIDTH) --целое количество ячеек, которое помещается на экран
local levelLength = 50 --линий на уровень
local levelMap = {} --таблица с линиями
 blockTable = {} --таблица с блоками препятствий
local linesCounter = 1 --счётчик линий уровня
local lastLine  --последняя линия препятствий
local lastRail  --последняя рельса
local emptyLinesCount = cellsOnScreen + 1
railsTable = {}
railsAmount = 0
putRailUpperBound = _H/10  --выше этого уровня поставить рельсу нельзя


function getLastRail()
	return lastRail
end

function getTrain()
	return train
end

local function loadLevel(levelNumber) --загрузить уровень из файла level[levelNumber].txt
	local fileName = "level"..tostring(levelNumber)..".txt"
	local levelPath = system.pathForFile( fileName, system.ResourceDirectory ) --открываем файл уровня
	for line in io.lines(levelPath) do
  		table.insert(levelMap, line)           --считываем линии уровня
	end
end

local function setBlock(blockID, x,y, name) --поставить блок blockID в точке (x,y) с myNamename
    newBlock = display.newImageRect(mainGroup, Osheet, blockID , CELL_WIDTH, CELL_WIDTH)
    table.insert(blockTable, newBlock)
    physics.addBody( newBlock, "dynamic", { radius = CELL_WIDTH*0.3, isSensor = true})
    newBlock.myName = name
    newBlock.isUsed = false
    newBlock.x = x  --спавним в нужном ряду
    newBlock.y = y  --спавним чуть выше вернего края
    newBlock:setLinearVelocity(0, moveSpeed)
    return newBlock
end

function setBlockLine() --поставить линию блоков
  if(linesCounter>levelLength) then  --временный КОСТЫЛЬ, чтобы зациклить уровень
      linesCounter = 1
  end
  local isChanged = false --есть ли что-то на линии
  local thisLine
  local blockName
  for i = 1, GRID_WIDTH do
  	local blockID = string.byte(levelMap[linesCounter],i)-48   --считываем номер блока из спрайтшита
  	if(blockID~=0) then
  			if(blockID==11) then
  				blockName = "coal"
  			else
				blockName = "enemy"
			end
			thisLine = setBlock(blockID,bottomX + 5 + CELL_WIDTH*(0.5 + (i-1)), lastLine.y - (emptyLinesCount+1)*CELL_WIDTH,blockName)
			isChanged = true
	end
  end
  if(not isChanged) then
  	emptyLinesCount = emptyLinesCount + 1
  else
  	lastLine = thisLine
  	emptyLinesCount = 0
  end 
  linesCounter = linesCounter + 1  --загрузить линию блоков
end

function setRail(dir) --поставить одну рельсу и вернуть объект с ней
	--dir -1 == left   1 == right  0 == forward
	-- 3+dir == номер нужной рельсы в спрайтшите
	if (lastRail.y > putRailUpperBound) then
				local newRail = display.newImageRect(railGroup, Osheet, 3 + dir , CELL_WIDTH * (math.abs(dir)+1) , CELL_WIDTH )
				newRail.myName = dir
				physics.addBody( newRail, "dynamic", {radius = CELL_WIDTH/2*0.7, isSensor = true} )
				table.insert( railsTable, newRail )
				newRail.y = lastRail.y - CELL_WIDTH
				if(lastRail.isTrain) then
					newRail.x = lastRail.x
				elseif (dir == 0) then	
					newRail.x = lastRail.x + lastRail.myName*CELL_WIDTH*0.5
				else
					newRail.x = lastRail.x + CELL_WIDTH*0.5*((1-math.abs(lastRail.myName))*dir+(lastRail.myName+dir)*math.abs(lastRail.myName))
				end
				
				railsAmount = railsAmount + 1
				lastRail = newRail
				newRail:setLinearVelocity(0, moveSpeed)
				return newRail
	end
end

function collectGarbage() --убираем всё, что вышло за экран
  for i = #blockTable, 1 , -1 do
    local thisBlock = blockTable[i]
      if(thisBlock.myName == "coal" and thisBlock.isUsed == true) then
      	  display.remove( thisBlock ) -- убрать с экрана
          table.remove( blockTable, i )
      end
      if (thisBlock.y > _H + CELL_WIDTH)  then
          display.remove( thisBlock ) -- убрать с экрана
          table.remove( blockTable, i ) -- убрать из памяти, так как содержится в списке

      end
  end
  for i = #railsTable, 1 , -1 do
    local thisRail = railsTable[i]

      if (thisRail.y > _H)  then
          display.remove( thisRail ) -- убрать с экрана
          table.remove( railsTable, i ) -- убрать из памяти, так как содержится в списке
          railsAmount = railsAmount - 1
      end
  end
end

function updateBlockSpeed()
  for i, block in pairs(blockTable) do
  	block:setLinearVelocity(0, moveSpeed)
  end
  for i, rail in pairs(railsTable) do
  	rail:setLinearVelocity(0, moveSpeed)
  end
end

function initializeGrid(level) --загрузить блоки уровня level
	train = display.newImageRect( mainGroup, Osheet,  1, (_W)* 0.15, _H*0.13 )
	train.x = display.contentCenterX
	train.y = bottomY + CELL_WIDTH*0.5  --ставим поезд, чтобы к нему прикрепить первую рельсу
	lastRail = train
	--train.anchorY = train.height*2/3
	train.myName = "player"
	train.isTrain = true
	physics.addBody( train, "dynamic", {isSensor = true, radius = train.width*0.3} )
	loadLevel(level)  -- загружаем карту уровня
	--первая рельса
	lastLine = setRail(0) --для синхронизаций объектов препятствий
	setBlockLine() --ставим первое препятствие с привязкой к первой рельсе
	--теперь перемещаем поезд как будто он выезжает
	transition.to(train, {time = timePerCell(), y = bottomY - CELL_WIDTH*0.5})
	--ещё две рельсы
	setRail(0)
	setRail(0)
end


