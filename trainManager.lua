trainTransitions = {}
local turnTargetX = 0
local turnDir = 0
local rotationState = -1
local train


local function xTurnTime() --время сдвига
  return timePerCell()*0.2
end

local function rotationTime()  --время для поворота на 45
  return xTurnTime()
end

local function rotationControl() --контроль поворота
  if(train==nil) then
    return
  end
  if(rotationState==0 and (train.rotation == 70 or train.rotation == -70)) then
    rotationState = 1
    local transition = transition.to(train, {time = rotationTime(), rotation = 0})
    table.insert( trainTransitions, transition)
  elseif(rotationState == 1 and train.rotation == 0) then
    timer.pause(checkrotationTimer)
    rotationState = -1
  end 
end

local isTrainScaled = false

local function trainAnimation() --idle
  if(isTrainScaled) then
    train.width = train.width*145/136
    isTrainScaled = false
  else
    train.width = train.width/145*136
    isTrainScaled = true
  end  
end

checkrotationTimer = timer.performWithDelay(34,rotationControl,0)
timer.pause(checkrotationTimer)

local function turnDelay() --отложенный поворот после триггера
  if(isDead)then
    return
  end
  rotationState = 0
  local transition = transition.to(train, {time = xTurnTime(), x = train.x + turnDir*CELL_WIDTH})
  table.insert(trainTransitions, transition)
  timer.resume(checkrotationTimer)
  timer.pause(startTurn)  
end

local function turn(dir) --функция для поворота
  if (isDead == false) then
    turnDir = dir
    timer.resume(startTurn)
    local transition = transition.to(train, {time = rotationTime(), rotation = turnDir*70})
    table.insert( trainTransitions, transition)
  end  
end

trainAnimationTimer = timer.performWithDelay( 100, trainAnimation,0 )
timer.pause( trainAnimationTimer )

function trainInitialzie() --инициализация поезда
  train = display.newImageRect( mainGroup, sheetBasic,  1, _W* 0.13, _W* 0.13*(340/152))
  train.myName = "player"
  train.isTrain = true
  train.x = display.contentCenterX
  train.y = bottomY + CELL_WIDTH*0.5

  startTurn = timer.performWithDelay(timePerCell()*0.1, turnDelay,0)
  timer.pause(startTurn)
  transition.cancel(train)
  train.collision = onLocalCollision
  train:addEventListener("collision")
  physics.addBody( train, "dynamic", {isSensor = true, radius = train.width*0.3} )
  transition.to(train, {time = timePerCell(), y = bottomY - CELL_WIDTH})
  timer.resume( trainAnimationTimer )
end

function getTrain()
  return train
end

function turnLeft()
  turn(-1)
end

function turnRight()
  turn(1)
end

function trainTransitionPause()
  for i, transit in pairs(trainTransitions) do
      transition.pause(transit)
  end
end

function trainTransitionCancel()
  for i, transit in pairs(trainTransitions) do
      transition.cancel(transit)
  end
end

function trainTransitionResume()
  for i, transit in pairs(trainTransitions) do
      transition.resume(transit)
  end
end