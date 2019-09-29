------ GLOBAL Settings ------
_W = display.actualContentWidth  --ширина экрана
_H = display.actualContentHeight --высота экрана
display.fps = 30           

--левый нижний угол
bottomY = display.contentCenterY+_H*0.5
bottomX = display.contentCenterX-_W*0.5

GRID_WIDTH = 5
CELL_WIDTH = (_W - 20 ) / 5

function intDiv(a,b) --функция для целочисленного деления, потмоу что в Lua 5.1 её нет
	local c = a/b
	c = c%1
	return (a/b - c)
end

physics = require("physics")
physics.start()
physics.setGravity( 0, 0 )
local composer = require( "composer" )

display.setStatusBar( display.HiddenStatusBar )
-- Set up display groups --сделал их не локальными, чтобы можно добавить индикатор топлива в uiGroup
backGroup = display.newGroup()  -- Display group for the background image
shadowGroup = display.newGroup()
railGroup = display.newGroup()
mainGroup = display.newGroup()  -- Display group for the Fuel, train, rails, etc.
uiGroup = display.newGroup()    -- Display group for UI objects like the score
sho = require("spritesheet")
Osheet = graphics.newImageSheet( "BaseSpritesheet.png", sheetOptions)

function timePerCell()   --в миллисекундах
	return CELL_WIDTH*1000/moveSpeed
end
--------- End of GLOBAL SETTINGS --------------------------------

blockManager = require("blockManager")

--------- Displays and sprite setting Block----------------------

local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
      background.x = display.contentCenterX
      background.y = display.contentCenterY


--------- End of Displays Block ---------




--------- Train Parametrs BLock -------------
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
			elseif ( event.other.myName == "coal") then
				recoverCoal()
				event.other.isUsed = true
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
  setRail(swipeDirection, "")
end
local function right()
  swipeDirection = "rightRail"
  setRail(swipeDirection, "")
end
local function onTap()
  swipeDirection = "tapRail"
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
  	setBlockLine()
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
          --print (i)
      end
  end
end


gameLoopTimer = timer.performWithDelay(timePerCell(), gameLoop, 0 )

cleanerTimer = timer.performWithDelay(500,collectGarbage,0)
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
