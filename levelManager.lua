score = 0

isDead = true
currentLevel = 0
currentColumn = 3 --текущая колонка (от 1 до 5)
columnDelta = 0
local accelerationMode = 0
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
  if(getLastRail().y>getTrain().y) then
    diee("Нет рельс!")
  end
end

gameLoopTimer = timer.performWithDelay(100, gameLoop, 0 )
cleanerTimer = timer.performWithDelay(50,collectGarbage,0)


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
  timer.pause(gameLoopTimer)
end

pauseTimers()

function startTimers()
  timer.resume(cleanerTimer)
  timer.resume(updateSpeedTimer)
  timer.resume(gameLoopTimer)
end

function levelStart(level)  --запускаем уровень #level
  clearScreen()
  physics.start()
  physics.setGravity( 0, 0 )
  currentLevel = level
  moveSpeed = levelSpeed(level)
  currentColumn = 3
  columnDelta = 0
  initializeGrid(level)  -- add Levelgetter
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
end

function levelPause()
  trainTransitionPause()
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
  trainTransitionResume()
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
  trainTransitionPause()
  trainTransitionCancel()
  isDead = true
  isPossibleToPlaceRail = false
  pauseTimers()
  physics.pause()
  stopConsumeCoal()
  stopUpdateCoins()
  showResults()
end

function diee(message) --умираем, высвечивается сообщение message
  rotationState = -1
  trainTransitionPause()
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
  timer.pause(blockAnimationTimer)
  dieText = display.newText( uiGroup, message,
  display.contentCenterX,display.contentCenterY, native.systemFont, 48 )
end

function onLocalCollision( self, event ) --когда происходит столкновение
    if ( event.phase == "began" ) then
      if (event.other.myName == -1 and not event.other.isUsed and not event.other.isGhost)then
        event.other.isUsed = true
        turnLeft()
      elseif (event.other.myName == 1 and not event.other.isUsed and not event.other.isGhost) then
        event.other.isUsed = true
        turnRight()
      elseif ( event.other.myName == "end") then
        levelEnd()
      elseif ( event.other.myName == "coal") then
        recoverCoal()
        playSound("coal")
        event.other.isUsed = true
      elseif ( event.other.myName == "coin") then
        coinPlus()
        event.other.isUsed = true
      elseif ( event.other.myName == "enemy") then
        diee("Нет пути!")
      end
    elseif ( event.phase == "ended" ) then
    end
end
