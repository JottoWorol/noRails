------ GLOBAL Settings ------
_W = display.actualContentWidth  --ширина экрана
_H = display.actualContentHeight --высота экрана
display.fps = 30           

--левый нижний угол
local bottomY = display.contentCenterY+_H*0.5
local bottomX = display.contentCenterX-_W*0.5

local function intDiv(a,b) --функция для целочисленного деления, потмоу что в Lua 5.1 её нет
	local c = a/b
	c = c%1
	return (a/b - c)
end

local physics = require("physics")
physics.start()
physics.setGravity( 0, 0 )
local composer = require( "composer" )

--------- End of GLOBAL SETTINGS --------------------------------
--------- Displays and sprite setting Block----------------------

display.setStatusBar( display.HiddenStatusBar )
-- Set up display groups --сделал их не локальными, чтобы можно добавить индикатор топлива в uiGroup
backGroup = display.newGroup()  -- Display group for the background image
shadowGroup = display.newGroup()
railGroup = display.newGroup()
mainGroup = display.newGroup()  -- Display group for the Fuel, train, rails, etc.
uiGroup = display.newGroup()    -- Display group for UI objects like the score

local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
      background.x = display.contentCenterX
      background.y = display.contentCenterY

local sho = require("spritesheet")
local Osheet = graphics.newImageSheet( "BaseSpritesheet.png", sheetOptions)


--------- End of Displays Block ---------

--------- Grid Block --------------------

local GRID_WIDTH = 5
local CELL_WIDTH = (_W - 20 ) / 5

--------- End of Grid Block -------------



--------- Train Parametrs BLock -------------

local train = display.newImageRect( mainGroup, Osheet,  5, (_W)* 0.15, _H*0.13 )
      train.x = display.contentCenterX
      train.y = bottomY
			--train.anchorX = train.width/2
			train.anchorY = train.height*2/3
			train.myName = "player"
			physics.addBody( train, "dynamic", {isSensor = true, radius = train.width / 2 * 0.8} )
local moveSpeed = 70  --скорость поезда;

local function timePerCell()   --в миллисекундах
	return CELL_WIDTH*1000/moveSpeed
end

coal = require("coal")
function getCoalConsumption() --сколько единиц топлива из 100 потребляется за 0.1 секунду
	return 1
end

local function onLocalCollision( self, event )

    if ( event.phase == "began" ) then
			if (event.other.myName == "leftRail")then
				transition.to(train, {time = timePerCell()*0.8, x = train.x - CELL_WIDTH})
				print("leftRail")
			elseif (event.other.myName == "rightRail") then
				transition.to(train, {time = timePerCell()*0.8, x = train.x+CELL_WIDTH})
				print("rightRail")
			--elseif (event.myName != "tapRail") then
			--	physics.pause()
			elseif ( event.other.myName == "coal") then
				recoverCoal()
			elseif ( event.other.myName == "enemy") then
				diee()
			end
        print( self.myName .. ": collision began with " .. event.other.myName )

    elseif ( event.phase == "ended" ) then

        print( self.myName .. ": collision ended with " .. event.other.myName )
    end
end

train.collision = onLocalCollision
train:addEventListener("collision")
--------- End of Tranin Parametrs BLock ------


--------- Spawner BLock --------------
local cellsOnScreen = intDiv(_H,CELL_WIDTH) --целое количество ячеек, которое помещается на экран
local levelLength = 50 --линий на уровень
local levelMap = {} --таблица с линиями
local blockTable = {} --таблица с блоками препятствий
local linesCounter = 1 --счётчик линий уровня
local lastLine
local emptyLinesCount = cellsOnScreen - 1

local function setBlock(blockID, x,y, name) --поставить блок blockID в точке (x,y) с myNamename
    newBlock = display.newImageRect(mainGroup, Osheet, blockID , CELL_WIDTH, CELL_WIDTH)
    table.insert(blockTable, newBlock)
    physics.addBody( newBlock, "dynamic", { radius = CELL_WIDTH/2*0.8, isSensor = true})
    newBlock.myName = name
    newBlock.x = x  --спавним в нужном ряду
    newBlock.y = y  --спавним чуть выше вернего края
    newBlock:setLinearVelocity(0, moveSpeed)
    return newBlock
    --transition.to(newBlock, {time = timePerCell()*(cellsOnScreen+3), y = bottomY+CELL_WIDTH})  --блоки едут до ([нижний край] минус [1 ячейка]) 
end

local function loadLevel(levelNumber) --загрузить уровень из файла level[levelNumber].txt
	local fileName = "level"..tostring(levelNumber)..".txt"
	local levelPath = system.pathForFile( fileName, system.ResourceDirectory ) --открываем файл уровня
	for line in io.lines(levelPath) do
  		table.insert(levelMap, line)           --считываем линии уровня
	end
end

loadLevel(0)  -- загружаем нулевой уровень

local function createBlock()
  if(linesCounter>levelLength) then  --временный КОСТЫЛЬ, чтобы зациклить уровень
      linesCounter = 1
  end
  local isChanged = false --есть ли что-то на линии
  local thisLine
  local blockName
  for i = 1, GRID_WIDTH do
  	local blockID = string.byte(levelMap[linesCounter],i)-48   --считываем номер блока из спрайтшита
  	if(blockID~=0) then
  			if(blockID==9) then
  				blockName = "coal"
  			else
				blockName = "enemy"
			end
			thisLine = setBlock(blockID,bottomX + 5 + CELL_WIDTH*(0.5 + (i-1)), lastLine.y - (emptyLinesCount+1)*CELL_WIDTH,blockName)
			isChanged = true
			print(isChanged)
	end
  end
  if(not isChanged) then
  	emptyLinesCount = emptyLinesCount + 1
  else
  	lastLine = thisLine
  	print("i was here")
  	emptyLinesCount = 0
  end 
  linesCounter = linesCounter + 1
end

--------- end of spawner -------


--------- Railroad block -------

local	railsTable = {}
local railsAmount = 0
lastObject = train

local firstRail = display.newImageRect(railGroup, Osheet, 6 , CELL_WIDTH , CELL_WIDTH )

firstRail.x = display.contentCenterX
firstRail.y = bottomY - CELL_WIDTH*0.5
physics.addBody( firstRail, "dynamic", {radius = CELL_WIDTH/2, isSensor = true} )
firstRail.myName = "tapRail"
table.insert( railsTable, firstRail )
railsAmount = railsAmount + 1
lastObject = firstRail
lastLine = lastObject --для синхронизаций объектов препятствий
createBlock() --ставим первое препятствие сразу после первой рельсы
--transition.to(firstRail, {time = timePerCell()*(bottomY+CELL_WIDTH - firstRail.y)/CELL_WIDTH, y = bottomY+CELL_WIDTH})
firstRail:setLinearVelocity(0, moveSpeed)
for i = 1, 2 do
  local newRail = display.newImageRect(railGroup, Osheet, 6 , CELL_WIDTH , CELL_WIDTH )
	newRail.x = lastObject.x
	newRail.y = lastObject.y - CELL_WIDTH
	physics.addBody( newRail, "dynamic", {radius = CELL_WIDTH/2, isSensor = true} )
	newRail.myName = "tapRail"
	table.insert( railsTable, newRail )
	railsAmount = railsAmount + 1
	lastObject = newRail
	newRail:setLinearVelocity(0, moveSpeed)
	--transition.to(newRail, {time = timePerCell()*(bottomY+CELL_WIDTH - newRail.y)/CELL_WIDTH, y = bottomY+CELL_WIDTH})
end

--- На старте создаются под нами + 3 впереди

function setRail(dir, turned)

	if (lastObject.y > 0) then

				newRail = display.newImageRect(railGroup, Osheet, 6 , CELL_WIDTH , CELL_WIDTH )
				newRail.myName = dir
				physics.addBody( newRail, "dynamic", {radius = CELL_WIDTH/2*0.8, isSensor = true} )
				table.insert( railsTable, newRail )
				if (turned == "") then
					newRail.y = lastObject.y - CELL_WIDTH
					newRail.x = lastObject.x
				elseif (turned == "left") then
					newRail.x = lastObject.x - CELL_WIDTH
					newRail.y = lastObject.y
				elseif (turned == "right") then
					newRail.x = lastObject.x + CELL_WIDTH
					newRail.y = lastObject.y
				end
				railsAmount = railsAmount + 1
				lastObject = newRail
				--transition.to(newRail, {time = timePerCell()*(bottomY+CELL_WIDTH - newRail.y)/CELL_WIDTH, y = bottomY+CELL_WIDTH})
				newRail:setLinearVelocity(0, moveSpeed)
				if (dir == "leftRail") then
					setRail("tapRail", "left")
				elseif (dir == "rightRail") then
					setRail("tapRail", "right")
				end
	end

end
--------- Railroad block -------

------ Swipe block ----------
swipeDirection = ""

function dragDirection(dispObj, left, right, tap)
    local prevX
    local isFocus = false
    local dirFunc = nil
    local thisTimer = nil
    local swipeDetectionDelta  = 0.7

    function repeatedly()
        if dirFunc ~= nil then dirFunc() end
    end

    function touchListener(event)
        if event.phase == "began" then
            prevX = event.x;
            dispObj:setFocus( self )
            isFocus = true
            thisTimer = timer.performWithDelay(100, repeatedly, 1)
        elseif isFocus then
            if event.phase == "ended" or event.phase == "cancelled" then
                timer.cancel(thisTimer)
                dispObj:setFocus( nil )
                isFocus = false
                dirFunc = nil
            end
                local deltaX = event.x - prevX
                prevX = event.x;
                if deltaX >= swipeDetectionDelta then
                    dirFunc = right
                elseif deltaX <= -swipeDetectionDelta then
                    dirFunc = left
                end
            end
        return true
    end
    dispObj:addEventListener("touch", touchListener)
		dispObj:addEventListener("tap", tap)
    -- dispObj:addEventListener("tap", onTap)
end

local function left()
  swipeDirection = "leftRail"
	--print("le")
  setRail(swipeDirection, "")
end
local function right()
  swipeDirection = "rightRail"
	--print("loggingr")
  setRail(swipeDirection, "")
end
local function onTap()
  swipeDirection = "tapRail"
--	print("tap")
  setRail(swipeDirection, "")
end


dragDirection(display.getCurrentStage(), left, right, onTap)

---------End of Swipe Block--------------

--------- gameLoop -------------
local core = 0
local scoreText = display.newText( uiGroup, "Score: " .. core,
display.contentCenterX, 20, native.systemFont, 36 )

local function gameLoop ()
  -- body...
  	createBlock()
	core = core + 1
	scoreText.text = "Score: " .. core
	print(getCoalPercentage())
  	if(getCoalPercentage()<=0)then
  		diee()
  	end
end

local function collectGarbage()
  for i = #blockTable, 1 , -1 do
    local thisBlock = blockTable[i]

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
          --print (i)
      end
  end
end


--gameLoopTimer = timer.performWithDelay(50, gameLoop, 0 )
gameLoopTimer = timer.performWithDelay(timePerCell(), gameLoop, 0 )

cleanerTimer = timer.performWithDelay(1000,collectGarbage,0)
--------- end of game loop -----


--------- DIE BLOCK ---------------------

function diee()
	local dieText = display.newText( uiGroup, "YOU DIED!!!",
	display.contentCenterX,display.contentCenterY, native.systemFont, 48 )
	timer.cancel(gameLoopTimer)
	timer.cancel(cleanerTimer)
	physics.pause()
	stopConsumeCoal()
end

--------- END OF DIE BLOCK --------------
