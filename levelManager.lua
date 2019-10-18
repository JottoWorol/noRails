score = 0
local scoreText = display.newText( uiGroup, "Score: " .. score,
display.contentCenterX, 20, native.systemFont, 36 )
isDead = false
isPosibleToPlaceRail = true
local currentLevel = 0 
local rotationState = -1
local turnTargetX = 0
local turnDir = 0
local accelerationMode = 0
speedDelta = 0
rotationSpeed = 5  --how fast train rotates
local zeroDegreeDetection = 10
local xTurnTime = timePerCell()*0.3
local rotationTime = xTurnTime*2

local composer = require( "composer" )

function levelSpeed(leve)  --возвращает обычную скорость текущего уровня
  return 70
end

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
  if((accelerationMode==-1 and moveSpeed>10) or (accelerationMode==1 and moveSpeed<levelSpeed(currentLevel))) then
    moveSpeed = moveSpeed + speedDelta
  end

 --[[ if(rotationState>-1 and rotationState<2)then
    train:setLinearVelocity(0,moveSpeed)
  end
  ]]
  updateBlockSpeed()
end

function cameraStop()
  accelerationMode = -1
  speedDelta = -5
end

function cameraResume()
  accelerationMode = 1
  speedDelta = 5
end

updateSpeedTimer = timer.performWithDelay(50,updateSpeed,0)

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
  if(isDead)then
    train:setLinearVelocity(0,0)
  end
  if(train==nil) then
    return
  end
  if(rotationState==0 and (train.rotation == 90 or train.rotation == -90)) then
    rotationState = 1
    transition.to(train, {time = rotationTime, rotation = 0})
  elseif(rotationState == 1 and train.x == turnTargetX) then
    rotationState = 2
    
    train:setLinearVelocity(0, 0)
    cameraResume()
  elseif(rotationState == 2 and train.rotation == 0) then
    timer.pause(checkRotationTimer)
    rotationState = -1
  end
end

checkRotationTimer = timer.performWithDelay(34,rotationControl,0)
timer.pause(checkRotationTimer)

local function turnDelay()
 print("поворачиваем")
 rotationState = 0
 
 turnTargetX = train.x + turnDir*CELL_WIDTH
 transition.to(train, {time = xTurnTime, x = train.x + turnDir*CELL_WIDTH})
 train:setLinearVelocity(0, moveSpeed)
 timer.resume(checkRotationTimer)
 timer.pause(startTurn)
end

startTurn = timer.performWithDelay(timePerCell()*0.75, turnDelay,0)
timer.pause(startTurn)

function turn(dir)
  turnDir = dir
  timer.resume(startTurn)
  cameraStop()
   transition.to(train, {time = rotationTime, rotation = turnDir*90})

end

function turnLeft()
  turn(-1)
end

function turnRight()
  turn(1)
end

function levelStart(level)  --запускаем уровень #level
  clearScreen()
  physics.start()
  physics.setGravity( 0, 0 )
  currentLevel = level
  moveSpeed = levelSpeed(level)
  local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
        background.x = display.contentCenterX
        background.y = display.contentCenterY
  initializeGrid(level)  -- add Levelgetter
  startTimers()
  train.collision = onLocalCollision
  train:addEventListener("collision")
  recoverCoal()
  startConsumeCoal()
  isDead = false;
end

function levelRestart() 
  levelStart(currentLevel)
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
  restartButton = display.newImageRect(uiGroup, UIsheet, 0, 604/2, 209/2)
  restartButton.x = _W/2
  restartButton.y = _H - restartButton.height
  --restartButton:setFillColor(0, 0, 0)
  restartButton:addEventListener( "tap" , levelRestart )
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
