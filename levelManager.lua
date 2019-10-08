local score = 0
local scoreText = display.newText( uiGroup, "Score: " .. score,
display.contentCenterX, 20, native.systemFont, 36 )
isDead = false

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

gameLoopTimer = timer.performWithDelay(timePerCell(), gameLoop, 0 )
cleanerTimer = timer.performWithDelay(500,collectGarbage,0)


function updateSpeed()
  moveSpeed = moveSpeed + speedDelta
  updateBlockSpeed()
  gameLoopTimer = timer.performWithDelay(timePerCell(), gameLoop, 0 )
  print("loopstart")
end

updateSpeedTimer = timer.performWithDelay(500,updateSpeed,0)

function onLocalCollision( self, event ) --когда происходит столкновение
    if ( event.phase == "began" ) then
      if (event.other.myName == "leftRail")then
        transition.to(train, {time = timePerCell()*0.8, x = train.x - CELL_WIDTH})
        print("leftRail")
      elseif (event.other.myName == "rightRail") then
        transition.to(train, {time = timePerCell()*0.8, x = train.x+CELL_WIDTH})
        print("rightRail")
      elseif ( event.other.myName == "coal") then
        recoverCoal()
        event.other.isUsed = true
      elseif ( event.other.myName == "enemy") then
        diee("Wrong way!")
      end
        print( self.myName .. ": collision began with " .. event.other.myName )

    elseif ( event.phase == "ended" ) then

        print( self.myName .. ": collision ended with " .. event.other.myName )
    end
end

function pauseTimers()
  print("timerStop")
  timer.pause(updateSpeedTimer)
  timer.pause(cleanerTimer)
  timer.pause( gameLoopTimer )
end

pauseTimers()

function startTimers()
  timer.resume(cleanerTimer)
  timer.resume(updateSpeedTimer)
  print("started")
end

function levelStart(level)  --запускаем уровень #level
  physics.start()
  physics.setGravity( 0, 0 )
  local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
        background.x = display.contentCenterX
        background.y = display.contentCenterY
  initializeGrid(level)
  startTimers()
  train.collision = onLocalCollision
  train:addEventListener("collision")
  recoverCoal()
  startConsumeCoal()
  isDead = false;
end

function diee(message)
  if(isDead) then
    return
  end
  isDead = true
  pauseTimers()
  physics.pause()
  stopConsumeCoal()
  local dieText = display.newText( uiGroup, message,
  display.contentCenterX,display.contentCenterY, native.systemFont, 48 )
  
end