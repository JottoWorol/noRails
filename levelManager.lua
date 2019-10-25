score = 0

isDead = true
isPossibleToPlaceRail = false

local currentLevel = 0
currentColumn = 3 --текущая колонка (от 1 до 5)
columnDelta = 0


local turnTargetX = 0
local turnDir = 0
local accelerationMode = 0
local rotationState = -1
speedDelta = 0
rotationSpeed = 5  --how fast train rotates
local zeroDegreeDetection = 10
local xTurnTime = timePerCell()*0.1
local rotationTime = xTurnTime*3

local deletedRails

local composer = require( "composer" )

function gameLoop () --запускаем с периодом timePerCell()
  if(isDead)then
    return
  end
  print( currentColumn )
  setBlockLine()
	score = score + 1
	updateScore()
  updateCoinIndicator()
  if(getCoalPercentage()<=0)then
  	diee("Нет топлива!")
  end
  if(getLastRail().y>train.y) then
    diee("Нет рельс!")
  end
end

gameLoopTimer = timer.performWithDelay(timePerCell()/2, gameLoop, 0 )
cleanerTimer = timer.performWithDelay(10,collectGarbage,0)


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
   -- train:setLinearVelocity(0,0)
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
    --cameraResume()
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
 --train:setLinearVelocity(0, moveSpeed)
 timer.resume(checkRotationTimer)
 timer.pause(startTurn)
end

startTurn = timer.performWithDelay(timePerCell()*0.3, turnDelay,0)
timer.pause(startTurn)

function turn(dir)
  turnDir = dir
  timer.resume(startTurn)
 -- cameraStop()
   transition.to(train, {time = rotationTime, rotation = turnDir*90})

end

function deleteLast()

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
  initializeGrid(level)  -- add Levelgetter
  train.collision = onLocalCollision
  train:addEventListener("collision")
  recoverCoal()
  startConsumeCoal()
  startUpdateCoins()
  isDead = false;
  coinAmount = 0
  currentColumn = 3
  columnDelta = 0
  showCoinIndicator()
  showScore()
  showCoalIndicator()
  showPauseButton()
  startTimers()
end

function levelPause()
  killPauseButton()
  showContinueButton()
  isPossibleToPlaceRail = false
  deleteLastRail()
  pauseTimers()
  physics.pause()
  stopConsumeCoal()
  stopUpdateCoins()
  isDead=true
end

function levelContinue()
  showPauseButton()
  killContinueButton()
  isPossibleToPlaceRail = true
  startTimers()
  physics.start()
  startConsumeCoal()
  startUpdateCoins()
  isDead=false
end

function levelRestart()

  killCoinIndicator()
  killScore()
  killCoalIndicator()
  killRestartButton()

  levelStart(currentLevel)

end

function levelEnd()
  
  isPossibleToPlaceRail = false

  pauseTimers()
  physics.pause()
  stopConsumeCoal()
  stopUpdateCoins()

  showResults()

end

function diee(message) --умираем, высвечивается сообщение message
  killPauseButton()
  showRestartButton()
  if(isDead) then
    return
  end
  isDead = true
  isPossibleToPlaceRail = false
  pauseTimers()
  physics.pause()
  stopConsumeCoal()
  stopUpdateCoins()
  dieText = display.newText( uiGroup, message,
  display.contentCenterX,display.contentCenterY, native.systemFont, 48 )
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
      elseif ( event.other.myName == "coin") then
        coinPlus()
        event.other.isUsed = true
        useCoin(event.other)
      elseif ( event.other.myName == "enemy") then
        diee("Нет пути!")
      end
       -- print( self.myName .. ": collision began with " .. event.other.myName )

    elseif ( event.phase == "ended" ) then

        --print( self.myName .. ": collision ended with " .. event.other.myName )
    end
end
