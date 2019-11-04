local cellsOnScreen = intDiv(_H,CELL_WIDTH) --целое количество ячеек, которое помещается на экран
local levelLength = 50 --линий на уровень
local levelMap = {} --таблица с линиями
blockTable = {} --таблица с блоками препятствий
local linesCounter = 1 --счётчик линий уровня
lastLine = nil  --последняя линия препятствий
local emptyLinesCount = cellsOnScreen + 1
local spriteEnemiesOffset = 8
backLineTable = {}
coinsMngr = require("coinsManager")
coalMngr = require("coal")
railMngr = require("railManager")
trainMngr = require("trainManager")

local function loadLevel(levelNumber) --загрузить уровень из файла level[levelNumber].txt
	local fileName = "level"..tostring(levelNumber)..".txt"
	local levelPath = system.pathForFile( fileName, system.ResourceDirectory ) --открываем файл уровня
	for line in io.lines(levelPath) do
  		table.insert(levelMap, line)           --считываем линии уровня
	end
end

local function setBlock(spriteSheet, blockID, x,y, widht, height, name) --поставить блок blockID в точке (x,y) с myNamename
  newBlock = display.newImageRect(mainGroup, spriteSheet, blockID , widht, height)
  if(name == "enemy") then
    table.insert(blockTable, newBlock)
  elseif(name == "coin")then
    table.insert(coinTable, newBlock)
  elseif(name == "coal")then
    table.insert(coalTable, newBlock)
  elseif(name=="end")then
    table.insert(blockTable, newBlock )
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
      sheet = sheetUI
      sizeY = CELL_WIDTH
      sizeX = CELL_WIDTH * 12
    elseif(blockID == 49)then --coal
      blockName = "coal"
      blockID = spriteCoalOffset
      sheet = sheetBonus
      sizeY = coalSize
      sizeX = sizeY
    elseif(blockID == 50)then --coin
      blockName = "coin"
      blockID = spriteCoinOffset
      sheet = sheetBonus
      sizeY = coinSize
      sizeX = sizeY
    elseif(blockID>96 and blockID<123)then
      blockID = blockID - 96 + spriteEnemiesOffset
      blockName = "enemy"
      sheet = sheetBasic
      sizeY = CELL_WIDTH
      sizeX = sizeY
    end
  	
    if(blockID~=48)then
		  thisLine = setBlock(sheet, blockID,bottomX + CELL_WIDTH*(0.5 + (i-1)), lastLine.y - (emptyLinesCount+1)*CELL_WIDTH, sizeX, sizeY, blockName)
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
function setBackLine()  --фоновая трава
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

function collectGarbage() --убираем всё, что вышло за экран
  for i = #blockTable, 1 , -1 do
    local thisBlock = blockTable[i]
      if (thisBlock.y > _H + CELL_WIDTH)  then
        display.remove( thisBlock ) -- убрать с экрана
        table.remove( blockTable, i ) -- убрать из памяти, так как содержится в списке
      end
  end

   for i = #backLineTable, 1 , -1 do
    if (backLineTable[i].y > (_H + CELL_WIDTH))  then
        display.remove(backLineTable[i]) -- убрать с экрана
        table.remove( backLineTable, i ) -- убрать из памяти, так как содержится в списке
    end
  end

  collectGarbageCoins()
  collectGarbageCoal()
  collectGarbageRails()
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
  for i, coal in pairs(coalTable) do
    coal:setLinearVelocity(0, moveSpeed)
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

  display.remove( getTrain() )
  display.remove( dieText )
  display.remove( background )

  isDead = false

  for i = #blockTable, 1 , -1 do
      display.remove(blockTable[i])
      table.remove( blockTable, i )
  end

  clearCoins()
  clearCoal()
  clearRails()

  timer.pause( railAnimationTimer )
  timer.pause( trainAnimationTimer )

  for i = #backLineTable, 1 , -1 do
    display.remove(backLineTable[i])
    table.remove( backLineTable, i )
  end
end

function initializeGrid(level) --загрузить блоки уровня level
  lastBackLine = nil  --ставим фон
  for i=1,130 do
    setBackLine()
  end
  trainInitialzie()  --ставим поезд
	lastRail = getTrain()
	loadLevel(level)  -- загружаем карту уровня
  isPossibleToPlaceRail = true
  linesCounter = 1
  lastLine = setRail(0) --для синхронизаций объектов препятствий
	setBlockLine() --ставим первое препятствие с привязкой к первой рельсе
	setRail(0)
  setRail(0)
  timer.resume(railAnimationTimer)
  print(#coinTable, #railsTable,#railBackTable,#coalTable, #blockTable)
end
