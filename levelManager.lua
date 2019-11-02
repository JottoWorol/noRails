score = 0

isDead = true
isPossibleToPlaceRail = false

currentLevel = 0
currentColumn = 3 --текущая колонка (от 1 до 5)
columnDelta = 0

local turnTargetX = 0
local turnDir = 0
local accelerationMode = 0
local rotationState = -1
speedDelta = 0
local zeroDegreeDetection = 10

local deletedRails

local composer = require( "composer" )

function gameLoop () --запускаем с периодом timePerCell()
  if(isDead)then
    return
  end
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

gameLoopTimer = timer.performWithDelay(100, gameLoop, 0 )
cleanerTimer = timer.performWithDelay(10,collectGarbage,0)


function updateSpeed() --обновляем скорость уровня
  if(railsAmount>3) then
    moveSpeed = levelSpeed(currentLevel)*railsAmount/2
  else
    moveSpeed = levelSpeed(currentLevel)
  end
  setBlockLine()
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

function xTurnTime()
  return timePerCell()*0.2
end

function rotationTime()
  return xTurnTime()
end

local function rotationControl()
  if(train==nil) then
    return
  end
  if(rotationState==0 and (train.rotation == 70 or train.rotation == -70)) then
    rotationState = 1
    transition.to(train, {time = rotationTime(), rotation = 0})
  elseif(rotationState == 1 and train.rotation == 0) then
    timer.pause(checkrotationTimer)
    rotationState = -1
  end
end

checkrotationTimer = timer.performWithDelay(34,rotationControl,0)
timer.pause(checkrotationTimer)

local function turnDelay()
 rotationState = 0
 transition.to(train, {time = xTurnTime(), x = train.x + turnDir*CELL_WIDTH})
 timer.resume(checkrotationTimer)
 timer.pause(startTurn)
end



function turn(dir)
  if (isDead == false) then
    turnDir = dir
    timer.resume(startTurn)
    transition.to(train, {time = rotationTime(), rotation = turnDir*70})
  end
end


function turnLeft()
  turn(-1)
end

function turnRight()
  turn(1)
end

function levelStart(level)  --запускаем уровень #level
  transition.cancel(train)
  clearScreen()
  physics.start()
  physics.setGravity( 0, 0 )
  currentLevel = level
  moveSpeed = levelSpeed(level)
  startTurn = timer.performWithDelay(timePerCell()*0.1, turnDelay,0)
  timer.pause(startTurn)
  currentColumn = 3
  columnDelta = 0
  initializeGrid(level)  -- add Levelgetter
  train.collision = onLocalCollision
  train:addEventListener("collision")
  recoverCoal()
  startConsumeCoal()
  startUpdateCoins()
  isDead = false;
  coinAmount = 0
  showCoinIndicator()
  showScore()
  showCoalIndicator()
  showPauseButton()
  startTimers()
  playSound("music0")
end

function levelPause()
  transition.pause(train)
  transition.pause(train)
  transition.pause(train)
  playSound("button0")
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
  transition.resume(train)
  transition.resume(train)
  transition.resume(train)
  playSound("button0")
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
  transition.pause(train)
  isPossibleToPlaceRail = false

  pauseTimers()
  physics.pause()
  stopConsumeCoal()
  stopUpdateCoins()

  showResults()


end

function diee(message) --умираем, высвечивается сообщение message
  transition.pause(train)
  transition.pause(train)
  transition.pause(train)
  killPauseButton()
  showRestartButton()
  if(isDead) then
    return
  end
  currentColumn = 3
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
      elseif (event.other.myName == 1 and not event.other.isUsed) then
        event.other.isUsed = true
        turnRight()
      elseif ( event.other.myName == "coal") then
        recoverCoal()
        playSound("coal")
        event.other.isUsed = true
      elseif ( event.other.myName == "coin") then
        coinPlus()
        event.other.isUsed = true
        useCoin(event.other)
      elseif ( event.other.myName == "enemy") then
        diee("Нет пути!")
      end
    elseif ( event.phase == "ended" ) then
    end
end
