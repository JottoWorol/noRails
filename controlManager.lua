swipeDirection = ""

function dragDirection(dispObj, left, right, tap) --SWIPE HANDLING
    local prevX
    local isFocus = false
    local dirFunc = nil
    local thisTimer = nil
    local swipeDetectionDelta  = 0.4

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