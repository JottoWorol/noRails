score = 0
local scoreText = display.newText( uiGroup, "Score: " .. score,
display.contentCenterX, 20, native.systemFont, 36 )
isDead = false
isPosibleToPlaceRail = true
local rotationState = 0
local turnTargetX = 0
local zeroDegreeDetection = 10
local xTurnTime = timePerCell()*0.1
local rotationTime = xTurnTime*0.8

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
  if(rotationState==0 and (train.rotation == 90 or train.rotation == -90)) then
    rotationState = 1
  elseif(rotationState == 1 and train.x == turnTargetX) then
    rotationState = 2
    transition.to(train, {time = rotationTime, rotation = 0})
   -- train:setLinearVelocity(0, 0)
  elseif(rotationState == 2 and train.rotation == 0) then
    timer.pause(checkRotationTimer)
    rotationState = -1
  end
end

checkRotationTimer = timer.performWithDelay(34,rotationControl,0)
timer.pause(checkRotationTimer)

local function turnDelay()
 timer.resume(checkRotationTimer)
 timer.pause(startTurn)
 print(3)
end

startTurn = timer.performWithDelay(timePerCell()*0.2, turnDelay)
timer.pause(startTurn)

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
  turnTargetX = train.x - CELL_WIDTH
  transition.to(train, {time = xTurnTime, x = train.x - CELL_WIDTH})
  transition.to(train, {time = rotationTime, rotation = -90})
  --train:setLinearVelocity(0, moveSpeed)
  rotationState = 0
  timer.resume(startTurn)
  print(1)
end

function turnRight()
  turnTargetX = train.x + CELL_WIDTH
  transition.to(train, {time = xTurnTime, x = train.x + CELL_WIDTH})
  transition.to(train, {time = rotationTime, rotation = 90})
 -- train:setLinearVelocity(0, moveSpeed)
  rotationState = 0
  timer.resume(startTurn)
  print(1)
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
