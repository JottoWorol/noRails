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
local spriteEnemiesOffset = 8
railsTable = {}
railBackTable = {}
backLineTable = {}
railsAmount = 0
putRailUpperBound = _H/4 --выше этого уровня поставить рельсу нельзя
coinsMngr = require("coinsManager")

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

local function setBlock(spriteSheet, blockID, x,y, widht, height, name) --поставить блок blockID в точке (x,y) с myNamename
  newBlock = display.newImageRect(mainGroup, spriteSheet, blockID , widht, height)
  if(name=="enemy" or name=="coal") then
    table.insert(blockTable, newBlock)
  elseif(name=="end")then
    table.insert(blockTable, newBlock )
  else
    table.insert(coinTable, newBlock)
  end
  if(name=="end")then
    physics.addBody( newBlock, "dynamic", {isSensor = true})
  else
    physics.addBody( newBlock, "dynamic", { radius = CELL_WIDTH*0.3, isSensor = true})
  end
  newBlock.myName = name
  newBlock.isUsed = false
  newBlock.x = x  --спавним в нужном ряду
  newBlock.y = y  --спавним чуть выше вернего края
  newBlock:setLinearVelocity(0, moveSpeed)
  return newBlock
end

function setBlockLine() --поставить линию блоков
  if(linesCounter > 120)then
    return
  end
  local isChanged = false --есть ли что-то на линии
  local thisLine
  local blockName
  local sheet
  local sizeX
  local sizeY
  for i = 1, GRID_WIDTH do
  	local blockID = string.byte(levelMap[linesCounter],i)
    if(blockID == 35)then
      blockName = "end"
      blockID = 9
      sizeY = CELL_WIDTH
      sizeX = CELL_WIDTH * 12
    elseif(blockID>=48 and blockID<=57) then
      blockID = blockID - 48
      sheet = sheetBonus
    else
      blockID = blockID - 96 + spriteEnemiesOffset
    end
  	if(blockID~=0) then
  			if(sheet==sheetBonus and blockID==1) then
  				blockName = "coal"
          sizeY = CELL_WIDTH*0.6
          sizeX = sizeY
        elseif (sheet==sheetBonus and blockID == spriteCoinOffset) then
          blockName = "coin"
          sizeY = coinSize
          sizeX = sizeY
        elseif(blockName=="end")then
          sheet = sheetUI
  			else
				  blockName = "enemy"
          sheet = sheetBasic
          sizeY = CELL_WIDTH
          sizeX = sizeY
			  end

      if(blockID == 5) then
      end
			thisLine = setBlock(sheet, blockID,bottomX + 5 + CELL_WIDTH*(0.5 + (i-1)), lastLine.y - (emptyLinesCount+1)*CELL_WIDTH, sizeX, sizeY, blockName)
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


local lastBackLine = nil
function setBackLine()
  local backLine = display.newImageRect(backGroup, "Grass.png", CELL_WIDTH*5 + 20, CELL_WIDTH*2)
  backLine.x = display.contentCenterX
  if(lastBackLine == nil) then
    backLine.y = bottomY - CELL_WIDTH
  else
    backLine.y = lastBackLine.y - CELL_WIDTH*2
  end
  physics.addBody(backLine, "kinematic", {isSensor = true})
  backLine:setLinearVelocity(0, moveSpeed)
  table.insert(backLineTable, backLine)
  lastBackLine = backLine
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
    local backRail = display.newImageRect(railBackGroup, sheetBasic, 6 + dir , CELL_WIDTH * (math.abs(dir)+1), CELL_WIDTH)
		local newRail = display.newImageRect(railGroup, sheetBasic, 3 + dir , CELL_WIDTH * (math.abs(dir)+1) * railInitialSize, CELL_WIDTH * railInitialSize)
		newRail.myName = dir
		physics.addBody( newRail, "kinematic", {radius = CELL_WIDTH/2*1,isSensor = true} )
    physics.addBody( backRail, "dynamic", {isSensor = true})
		table.insert( railsTable, newRail )
    table.insert( railBackTable, backRail )
		if(lastRail.isTrain) then
			newRail.x = lastRail.x
		elseif (dir == 0) then
			newRail.x = lastRail.x + lastRail.myName*CELL_WIDTH*0.5
		else
			newRail.x = lastRail.x + CELL_WIDTH*0.5*((1-math.abs(lastRail.myName))*dir+(lastRail.myName+dir)*math.abs(lastRail.myName))
		end

    newRail.y = lastRail.y - CELL_WIDTH
    backRail.x = newRail.x
    backRail.y = newRail.y

		railsAmount = railsAmount + 1
    if(firstThree<3) then
      firstThree = firstThree + 1
      newRail.width = newRail.width/railInitialSize
      newRail.height = newRail.height/railInitialSize
      newRail.column = 3
    else
      newRail.column = currentColumn
    end
    backRail:setLinearVelocity( 0, moveSpeed)
    newRail:setLinearVelocity(0, moveSpeed)
    lastRail = newRail
    createGhost()
    return newRail
	end
end

function deleteLastRail()
  playSound("railDestroy")
  deleteGhost()
  --local thisRail = railsTable[railsAmount]
  display.remove(railsTable[railsAmount])
  table.remove(railsTable)
  display.remove(railBackTable[#railBackTable])
  table.remove( railBackTable)
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

  for i = #railBackTable, 1 , -1 do
    local thisBack = railBackTable[i]
    if (thisBack.y > _H)  then
          display.remove( thisBack) -- убрать с экрана
          table.remove( railBackTable, i ) -- убрать из памяти, так как содержится в списке
      end
  end

  for i = #backLineTable, 1 , -1 do
    if (backLineTable[i].y > (_H + 2*CELL_WIDTH))  then
        display.remove(backLineTable[i]) -- убрать с экрана
        table.remove( backLineTable, i ) -- убрать из памяти, так как содержится в списке
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
  for i, railBack in pairs(railBackTable) do
    railBack:setLinearVelocity(0, moveSpeed)
  end
  for i, coin in pairs(coinTable) do
    coin:setLinearVelocity(0, moveSpeed)
  end
  for i, ghost in pairs(ghostsTable) do
    ghost:setLinearVelocity(0, moveSpeed)
  end
  for i, backLine in pairs(backLineTable) do
    backLine:setLinearVelocity(0,moveSpeed)
  end
end

function clearScreen()
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
      display.remove(blockTable[i])
      table.remove( blockTable, i )
  end

  clearCoins()

  timer.pause( railAnimationTimer )
  timer.pause( trainAnimationTimer )

  for i = #railsTable, 1 , -1 do
      display.remove(railsTable[i])
      table.remove( railsTable, i )
      railsAmount = railsAmount - 1
  end

  for i = #railBackTable, 1 , -1 do
      display.remove(railBackTable[i])
      table.remove( railBackTable, i )
  end

  for i = #backLineTable, 1 , -1 do
    display.remove(railBackTable[i])
    table.remove( railBackTable, i )
  end

end

function initializeGrid(level) --загрузить блоки уровня level
  --level = 0 -- временное решение, ибо придётся через левый геттер получать левел (и я понял в чём была ошибка со сценами, я дебил)
  for i=1,130 do
    setBackLine()
  end
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
  linesCounter = 1
  lastLine = setRail(0) --для синхронизаций объектов препятствий
	setBlockLine() --ставим первое препятствие с привязкой к первой рельсе
	setRail(0)
  timer.resume( railAnimationTimer )
  timer.resume( trainAnimationTimer )
  --обнуление ништяков для рестарта
end
