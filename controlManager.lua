swipeDirection = ""
local currentColumn = 3 --текущая колонка (от 1 до 5)

function dragDirection(dispObj, left, right, tap) --SWIPE HANDLING
    local prevX
    local isFocus = false
    local dirFunc = nil
    local thisTimer = nil
    local swipeDetectionDelta  = 0.1

    function touchListener(event)
        print("touch start")
        if (event.phase == "ended" or event.phase == "cancelled") and isPosibleToPlaceRail then
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
end

--с цифрами работать быстрее, чем со строками. и можно будет быстро получить номер рельсы в спрайтшите
local function left()
    if(currentColumn==1) then
        return
    end
    currentColumn = currentColumn - 1
    setRail(-1)
end
local function right()
    if(currentColumn == 5) then
        return
    end
    setRail(1)
    currentColumn = currentColumn + 1
end
local function onTap()
    setRail(0)
end

dragDirection(display.getCurrentStage(), left, right, onTap)