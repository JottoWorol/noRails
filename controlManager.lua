swipeDirection = ""

function dragDirection(dispObj, left, right, tap) --SWIPE HANDLING
    local prevX
    local isFocus = false
    local dirFunc = nil
    local thisTimer = nil
    local swipeDetectionDelta  = 0.1

    function touchListener(event)  
        print("touch start")  
        if event.phase == "ended" or event.phase == "cancelled" then
                local deltaX = event.x - event.xStart
                if deltaX > swipeDetectionDelta then
                    --dirFunc = right
                    right()
                elseif deltaX < -swipeDetectionDelta then
                    --dirFunc = left
                    left()
                else
                    tap()
                end
        end
        return true
    end
    dispObj:addEventListener("touch", touchListener)
	--dispObj:addEventListener("tap", tap)
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