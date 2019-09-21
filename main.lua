------ GLOBAL Settings ------
_W = display.actualContentWidth  --ширина экрана
_H = display.actualContentHeight --высота экрана

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

------ Swipe block ----------
local swipeDirection = ""

function dragDirection(dispObj, left, right, tap)
    local prevX
    local isFocus = false
    local dirFunc = nil
    local thisTimer = nil


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
                if deltaX > -0.05 and deltaX < 0.05 then
                    dirFunc = tap
                elseif deltaX >= 0.05 then
                    dirFunc = right
                else
                    dirFunc = left
                end
            end
        return true
    end
    dispObj:addEventListener("touch", touchListener)
    -- dispObj:addEventListener("tap", onTap)

end


local function left()
  swipeDirection = "left"
  print("left")
end
local function right()
  swipeDirection = "right"
  print("right")
end
local function onTap()
  swipeDirection = "tap"
  print("tap")
end


dragDirection(display.getCurrentStage(), left, right, onTap)

---------End of Swipe Block--------------


--------- Displays and sprite setting Block----------------------

-- Set up display groups --сделал их не локальными, чтобы можно добавить индикатор топлива в uiGroup
backGroup = display.newGroup()  -- Display group for the background image
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

local train = display.newImageRect( mainGroup, Osheet,  3, (_W)* 0.15, _H*0.225 )
      train.x = display.contentCenterX - train.width * 0.2
      train.y = display.contentCenterY * 2

local moveSpeed = 0.1  --скорость поезда; адекватная скорость - до 0.4

local function timePerCell()   --время, за которое преодолевается одна ячейка
	return CELL_WIDTH/moveSpeed
end

coal = require("coal")
function getCoalConsumption() --сколько единиц топлива из 100 потребляется за 0.1 секунду
	return 3
end
--------- End of Tranin Parametrs BLock ------


--------- Spawner BLock --------------
local cellsOnScreen = intDiv(_H,CELL_WIDTH) --целое количество ячеек, которое помещается на экран
local levelLength = 10 --линий на уровень
local levelMap = {} --таблица с линиями
local blockTable = {} --таблица с блоками препятствий

local levelPath = system.pathForFile( "level0.txt", system.ResourceDirectory ) --открываем файл уровня
for line in io.lines(levelPath) do
   	table.insert(levelMap, line)           --считываем линии уровня
end

local linesCounter = 1 --счётчик линий уровня

local function createBlock()
  for i = 1, GRID_WIDTH do

  	if(linesCounter>levelLength) then  --временный КОСТЫЛЬ, чтобы зациклить уровень
  		linesCounter = 1
  	end

  	local blockID = string.byte(levelMap[linesCounter],i)-48   --считываем номер блока из спрайтшита

  	if(blockID~=0) then
  		local newBlock = display.newImageRect(mainGroup, Osheet, blockID , CELL_WIDTH , CELL_WIDTH)
    	table.insert(blockTable, newBlock)
   		physics.addBody( newBlock, "static", { radius = CELL_WIDTH-10,} )
   		newBlock.myName = "enemy"

   	 	newBlock.x = bottomX + 5 + CELL_WIDTH*(0.5 + (i-1))  --спавним в нужном ряду
    	newBlock.y = bottomY - (cellsOnScreen+2)*CELL_WIDTH  --спавним чуть выше вернего края


    	transition.to(newBlock, {time = timePerCell()*(cellsOnScreen+3), y = bottomY+CELL_WIDTH})  --блоки едут до ([нижний край] минус [1 ячейка])
	end
  end
  linesCounter = linesCounter + 1
end

--------- end of spawner -------

--------- gameLoop -------------

local function gameLoop ()
  -- body...

  createBlock()

  for i = #blockTable, 1 , -1 do
    local thisBlock = blockTable[i]

      if (thisBlock.y > _H + CELL_WIDTH)  then
          display.remove( thisBlock ) -- убрать с экрана
          table.remove( blockTable, i ) -- убрать из памяти, так как содержится в списке
      end
  end
end

gameLoopTimer = timer.performWithDelay(timePerCell(), gameLoop, 0 )
--------- end of game loop -----
