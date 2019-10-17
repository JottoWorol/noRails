score = 0
local scoreText = display.newText( uiGroup, "Score: " .. score,
display.contentCenterX, 20, native.systemFont, 36 )
isDead = false
isPosibleToPlaceRail = true
local rotationState = 0
local zeroDegreeDetection = 10
local xTurnTime = timePerCell()*0.5

local composer = require( "composer" )

function gameLoop () --запускаем с периодом timePerCell()
  if(isDead)then
    return
  end
  setBlockLine()
	score = score + 1
	scoreText.text = "Score: " .. score
  if(getCoalPercentage()<=0)then
  	diee("No fuel!")
  end
  if(getLastRail().y>train.y) then
    diee("No rails!")
  end
end

gameLoopTimer = timer.performWithDelay(timePerCell()/2, gameLoop, 0 )
cleanerTimer = timer.performWithDelay(500,collectGarbage,0)


function updateSpeed() --обновляем скорость уровня
  moveSpeed = moveSpeed + speedDelta
  updateBlockSpeed()
end

updateSpeedTimer = timer.performWithDelay(500,updateSpeed,0)

function pauseTimers()
  timer.pause(updateSpeedTimer)
  timer.pause(cleanerTimer)
  timer.pause( gameLoopTimer )
end

pauseTimers()

function startTimers()
  timer.resume(cleanerTimer)
  timer.resume(updateSpeedTimer)
  timer.resume(gameLoopTimer)
end


local function rotationControl()
  if(train==nil) then
    return
  end
  if(rotationState==0) then
    if(train.rotation <= -45 or train.rotation >= 45)then
        train.angularVelocity = -train.angularVelocity
        rotationState = 1
    end
  elseif(rotationState == 1) then
    if(train.rotation<zeroDegreeDetection and train.rotation>-zeroDegreeDetection)then
        timer.pause(checkRotationTimer)
        print( "paused" )
        train.angularVelocity = -train.angularVelocity
        train.angularVelocity = 0
        train.rotation = 0
        rotationState = -1
    end
  end
end

checkRotationTimer = timer.performWithDelay(34,rotationControl,0)
timer.pause(checkRotationTimer)




function levelStart()  --запускаем уровень #level
  clearScreen()
  physics.start()
  physics.setGravity( 0, 0 )
  local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
        background.x = display.contentCenterX
        background.y = display.contentCenterY
  initializeGrid(0)  -- add Levelgetter
  startTimers()
  train.collision = onLocalCollision
  train:addEventListener("collision")
  recoverCoal()
  startConsumeCoal()
  isDead = false;
end




function diee(message) --умираем, высвечивается сообщение message
  if(isDead) then
    return
  end
  isDead = true
  isPosibleToPlaceRail = false
  pauseTimers()
  physics.pause()
  stopConsumeCoal()
  dieText = display.newText( uiGroup, message,
  display.contentCenterX,display.contentCenterY, native.systemFont, 48 )
  restartButton = display.newText( uiGroup, "Restart?)", display.contentCenterX,
                                display.contentCenterY * 1.5, native.systemFont,50)
        restartButton:setFillColor(0, 0, 0)
  restartButton:addEventListener( "tap" , levelStart )
end

function turnLeft()
  transition.to(train, {time = xTurnTime, x = train.x - CELL_WIDTH})
  train.angularVelocity = - moveSpeed*rotationSpeed
  rotationState = 0
  timer.resume(checkRotationTimer)
end

function turnRight()
  transition.to(train, {time = xTurnTime, x = train.x + CELL_WIDTH})
  train.angularVelocity = moveSpeed*rotationSpeed
  rotationState = 0
  timer.resume(checkRotationTimer)
end



function onLocalCollision( self, event ) --когда происходит столкновение
    if ( event.phase == "began" ) then
      if (event.other.myName == -1 and not event.other.isUsed)then
        event.other.isUsed = true
        turnLeft()
        print("left")
      elseif (event.other.myName == 1 and not event.other.isUsed) then
        event.other.isUsed = true
        turnRight()
        print("right")
      elseif ( event.other.myName == "coal") then
        recoverCoal()
        event.other.isUsed = true
      elseif ( event.other.myName == "enemy") then
        diee("Wrong way!")
      end
       -- print( self.myName .. ": collision began with " .. event.other.myName )

    elseif ( event.phase == "ended" ) then

        --print( self.myName .. ": collision ended with " .. event.other.myName )
    end
end
