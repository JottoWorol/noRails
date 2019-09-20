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



--------- Grid Block --------------------

local GRID_WIDTH = 9
local GRID_HEIGHT = 20
local CELL_WIDTH = 128
local CELL_HEIGHT = 128

local grid = {}
for i = 1, GRID_HEIGHT do
  grid[i] = {}
end





--------- End of Grid Block -------------


--------- Displays and sprite setting Block----------------------
_W = display.actualContentWidth
_H = display.actualContentHeight
-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the Fuel, train, rails, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
      background.x = display.contentCenterX
      background.y = display.contentCenterY

--------- End of Displays Block ---------


--------- Train Parameters Block ---------
coal = require("coal")
function getCoalConsumption() --litres per 0.1 seconds of total 100 litres
	return 3
end


--------- End of Train Parameters Block --------- 