swipeDirection = ""

function dragDirection(dispObj, left, right, tap, down) --SWIPE HANDLING
    local prevX
    local isFocus = false
    local dirFunc = nil
    local thisTimer = nil
    local swipeDetectionDelta  = 7.5


    function touchListener(event)
      --  print("touch start")
        if (event.phase == "ended" or event.phase == "cancelled") and isPossibleToPlaceRail then
                local deltaX = event.x - event.xStart
                local deltaY = event.y - event.yStart
                if(math.abs(deltaY)>swipeDetectionDelta or math.abs(deltaX)>swipeDetectionDelta)then
                    if(math.abs(deltaY)>math.abs(deltaX)) then
                        if(deltaY>0) then
                            down()
                        else
                            tap()
                        end
                    else
                        if(deltaX>0)then
                            right()
                        else
                            left()
                        end
                    end
                else
                    tap()
                end
        end
        return true
    end
    dispObj:addEventListener("touch", touchListener)
end

--с цифрами работать быстрее, чем со строками. и можно будет быстро получить номер рельсы в спрайтшите

local function onDown()
  deleteLastRail()
end

local function onLeft()
    if(currentColumn==1) then
        return
    end
    currentColumn = currentColumn - 1
    setRail(-1)
end

local function onRight()
    if(currentColumn == 5) then
        return
    end
    setRail(1)
    currentColumn = currentColumn + 1
end

local function onTap()
    setRail(0)
end

dragDirection(display.getCurrentStage(), onLeft, onRight, onTap, onDown)
