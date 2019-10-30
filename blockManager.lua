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
lastLine = nil  --последняя линия препятствий
lastRail = nil  --последняя рельса
local emptyLinesCount = cellsOnScreen + 1
local spriteEnemiesOffset = 5
railsTable = {}
railsAmount = 0
putRailUpperBound = _H/4 --выше этого уровня поставить рельсу нельзя
coinsMngr = require("coinsManager")

function getLastRail(
)	return lastRail
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

local function setBlock(spriteSheet, blockID, x,y, widht, height, name) --поставить блок blockID в точке (x,y) с myNamename
    newBlock = display.newImageRect(mainGroup, spriteSheet, blockID , widht, height)
    if(name=="enemy" or name=="coal") then
      table.insert(blockTable, newBlock)
    else
      table.insert(coinTable, newBlock)
    end
    physics.addBody( newBlock, "dynamic", { radius = CELL_WIDTH*0.3, isSensor = true})
    newBlock.myName = name
    newBlock.isUsed = false
    newBlock.x = x  --спавним в нужном ряду
    newBlock.y = y  --спавним чуть выше вернего края
    newBlock:setLinearVelocity(0, moveSpeed)
    return newBlock
end

function setBlockLine() --поставить линию блоков

  if(linesCounter>levelLength) then
      linesCounter = 1
  end

  local isChanged = false --есть ли что-то на линии
  local thisLine
  local blockName
  local sheet
  local size
  for i = 1, GRID_WIDTH do
  	local blockID = string.byte(levelMap[linesCounter],i)
    if(blockID>=48 and blockID<=57) then
      blockID = blockID - 48
      sheet = sheetBonus
    else
      blockID = blockID - 96 + spriteEnemiesOffset
    end
  	if(blockID~=0) then
  			if(sheet==sheetBonus and blockID==1) then
  				blockName = "coal"
          size = CELL_WIDTH*0.6
        elseif (sheet==sheetBonus and blockID == spriteCoinOffset) then
          blockName = "coin"
          size = coinSize
  			else
				  blockName = "enemy"
          sheet = sheetBasic
          size = CELL_WIDTH
			  end

      if(blockID == 5) then
      end
			thisLine = setBlock(sheet, blockID,bottomX + 5 + CELL_WIDTH*(0.5 + (i-1)), lastLine.y - (emptyLinesCount+1)*CELL_WIDTH, size, size, blockName)
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

function setTrain(x,y)
  train = display.newImageRect( mainGroup, sheetBasic,  1, _W* 0.13, _W* 0.13*(340/152))
  train.myName = "player"
  train.isTrain = true
  train.x = x
  train.y = y
end

--constants for rail fall animation
firstThree = 0
railInitialSize = 3
railAnimationDivisor  = 1.73205080

function railAnimation()
  for i, rail in pairs(railsTable) do
    if(rail.height>CELL_WIDTH) then
      rail.width = rail.width/railAnimationDivisor
      rail.height = rail.height/railAnimationDivisor
    end
  end
end

railAnimationTimer = timer.performWithDelay( 40, railAnimation, 0 )
timer.pause( railAnimationTimer )

isTrainScaled = false

function trainAnimation()
  if(isTrainScaled) then
    train.width = train.width*145/136
    isTrainScaled = false
  else
    train.width = train.width/145*136
    isTrainScaled = true
  end
end

trainAnimationTimer = timer.performWithDelay( 100, trainAnimation,0 )
timer.pause( trainAnimationTimer )

ghostsTable = {}

function createGhost()
  for i=2,4 do
    local newGhost = display.newImageRect(railGroup, sheetBasic, i , CELL_WIDTH *(math.abs( i - 3)+1)* railInitialSize, CELL_WIDTH * railInitialSize)
          newGhost.myName = i - 3
          physics.addBody( newGhost, "dynamic", {radius = CELL_WIDTH/2*1,isSensor = true} )
          table.insert( ghostsTable, newGhost )
          if (i == 3) then
            newGhost.x = lastRail.myName*CELL_WIDTH*0.5 + lastRail.x
          else
      			newGhost.x = lastRail.x + CELL_WIDTH*0.5*((1-math.abs(lastRail.myName))*(i - 3)+(lastRail.myName+(i - 3))*math.abs(lastRail.myName))
          end
          newGhost.width = newGhost.width/railInitialSize
          newGhost.height = newGhost.height/railInitialSize
          newGhost.y = lastRail.y - CELL_WIDTH
          newGhost:setLinearVelocity(0, moveSpeed)
          newGhost:setFillColor(0.3, 0.3, 0.3, 0.3)
  end
end

function deleteGhost ()
    for i = #ghostsTable, 1 , -1 do
      local thisGhost = ghostsTable[i]
        	  display.remove( thisGhost ) -- убрать с экрана
            table.remove( ghostsTable, i )
    end
end


function setRail(dir) --поставить одну рельсу и вернуть объект с ней
	--dir -1 == left   1 == right  0 == forward
	-- 3+dir == номер нужной рельсы в спрайтшите
  deleteGhost()
	if (lastRail.y > putRailUpperBound) then
    playSound("rail")
		local newRail = display.newImageRect(railGroup, sheetBasic, 3 + dir , CELL_WIDTH * (math.abs(dir)+1) * railInitialSize, CELL_WIDTH * railInitialSize)
		newRail.myName = dir
		physics.addBody( newRail, "dynamic", {radius = CELL_WIDTH/2*1,isSensor = true} )
		table.insert( railsTable, newRail )

		if(lastRail.isTrain) then
					newRail.x = lastRail.x
		elseif (dir == 0) then
			newRail.x = lastRail.x + lastRail.myName*CELL_WIDTH*0.5
		else
			newRail.x = lastRail.x + CELL_WIDTH*0.5*((1-math.abs(lastRail.myName))*dir+(lastRail.myName+dir)*math.abs(lastRail.myName))

		end

		railsAmount = railsAmount + 1
    if(firstThree<3) then
      firstThree = firstThree + 1
      newRail.y = lastRail.y - CELL_WIDTH
      newRail.width = newRail.width/railInitialSize
      newRail.height = newRail.height/railInitialSize
      newRail:setLinearVelocity(0, moveSpeed)
      newRail.column = 3
      lastRail = newRail
      createGhost()
		  return newRail
    else
      newRail.y = lastRail.y - CELL_WIDTH
      newRail:setLinearVelocity(0, moveSpeed)
      newRail.column = currentColumn
      lastRail = newRail
      currentRail = newRail
      --timer.resume( railAnimationTimer )
      createGhost()
    end
	end
end

function deleteLastRail()
  playSound("railDestroy")
  deleteGhost()
  local thisRail = railsTable[railsAmount]
  display.remove(thisRail)
  table.remove( railsTable, i )
  railsAmount = railsAmount - 1
  lastRail = railsTable[railsAmount]
  createGhost()
  currentColumn = lastRail.column
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

  collectGarbageCoins()

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
  for i, coin in pairs(coinTable) do
    coin:setLinearVelocity(0, moveSpeed)
  end
  for i, ghost in pairs(ghostsTable) do
    ghost:setLinearVelocity(0, moveSpeed)
  end
end

function clearScreen()

  --moveSpeed = 70
  emptyLinesCount = cellsOnScreen + 1
  linesCounter = 1
  score = 0
  currentRail = nil
  firstThree = 0
  currentColumn = 3

  display.remove( train )
  display.remove( dieText )
  display.remove( background )

  isDead = false

  for i = #blockTable, 1 , -1 do
    local thisBlock = blockTable[i]
      display.remove(thisBlock)
      table.remove( blockTable, i )
  end

  clearCoins()

  timer.pause( railAnimationTimer )
  timer.pause( trainAnimationTimer )

  for i = #railsTable, 1 , -1 do
      local thisRail = railsTable[i]
      display.remove(thisRail)
      table.remove( railsTable, i )
      railsAmount = railsAmount - 1
  end
end

function initializeGrid(level) --загрузить блоки уровня level
  --level = 0 -- временное решение, ибо придётся через левый геттер получать левел (и я понял в чём была ошибка со сценами, я дебил)
  setTrain(display.contentCenterX, bottomY + CELL_WIDTH*0.5)
	lastRail = train
	--train.anchorY = train.height*2/3
	physics.addBody( train, "dynamic", {isSensor = true, radius = train.width*0.3} )
	loadLevel(level)  -- загружаем карту уровня
	--первая рельса
  isPossibleToPlaceRail = true
	--теперь перемещаем поезд как будто он выезжает
	transition.to(train, {time = timePerCell(), y = bottomY - CELL_WIDTH})
	--ещё две рельсы
	setRail(0)
  lastLine = setRail(0) --для синхронизаций объектов препятствий
	setBlockLine() --ставим первое препятствие с привязкой к первой рельсе
	setRail(0)
  timer.resume( railAnimationTimer )
  timer.resume( trainAnimationTimer )
  --обнуление ништяков для рестарта
end
