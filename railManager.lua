lastRail = nil  --последняя рельса
railsTable = {}
railBackTable = {}
railsAmount = 0
putRailUpperBound = _H/4 --выше этого уровня поставить рельсу нельзя
isPossibleToPlaceRail = false

function getLastRail()
  return lastRail
end

--constants for rail fall animation
firstThree = 0
railInitialSize = 3
railAnimationDivisor  = 1.73205080

local function railAnimation() --анимация падения
  for i, rail in pairs(railsTable) do
    if(rail.height>CELL_WIDTH) then
      rail.width = rail.width/railAnimationDivisor
      rail.height = rail.height/railAnimationDivisor
    end
  end
end

railAnimationTimer = timer.performWithDelay( 40, railAnimation, 0 )
timer.pause( railAnimationTimer )

ghostsTable = {}

local function createGhost()
  for i=2,4 do
    local newGhost = display.newImageRect(railGroup, sheetBasic, i , CELL_WIDTH *(math.abs( i - 3)+1)* railInitialSize, CELL_WIDTH * railInitialSize)
    newGhost.myName = i - 3
    physics.addBody( newGhost, "dynamic", {radius = CELL_WIDTH/2*1,isSensor = true} )
    table.insert( ghostsTable, newGhost )
    if (i == 3) then
      newGhost.x = lastRail.myName*CELL_WIDTH*0.5 + lastRail.x
    else
      newGhost.x = lastRail.x + CELL_WIDTH*0.5*((1-math.abs(lastRail.myName))*(i - 3)+(lastRail.myName+(i - 3))*math.abs(lastRail.myName))
    end
    newGhost.width = newGhost.width/railInitialSize
    newGhost.height = newGhost.height/railInitialSize
    newGhost.y = lastRail.y - CELL_WIDTH
    newGhost:setLinearVelocity(0, moveSpeed)
    newGhost:setFillColor(0.3, 0.3, 0.3, 0.3)
  end
end

local function deleteGhost ()
  for i = #ghostsTable, 1 , -1 do
    local thisGhost = ghostsTable[i]
          display.remove( thisGhost ) -- убрать с экрана
          table.remove( ghostsTable, i )
  end
end

function setRail(dir) --поставить одну рельсу и вернуть объект с ней
  --dir -1 == left   1 == right  0 == forward
  -- 3+dir == номер нужной рельсы в спрайтшите
  deleteGhost()
  if (lastRail.y > putRailUpperBound) then
    playSound("rail")
    local backRail = display.newImageRect(railBackGroup, sheetBasic, 6 + dir , CELL_WIDTH * (math.abs(dir)+1), CELL_WIDTH*1.1)
    local newRail = display.newImageRect(railGroup, sheetBasic, 3 + dir , CELL_WIDTH * (math.abs(dir)+1) * railInitialSize, CELL_WIDTH * railInitialSize)
    newRail.myName = dir
    physics.addBody( newRail, "kinematic", {radius = CELL_WIDTH/2*1,isSensor = true} )
    physics.addBody( backRail, "dynamic", {isSensor = true})
    table.insert( railsTable, newRail )
    table.insert( railBackTable, backRail )
    if(lastRail.isTrain) then
      newRail.x = lastRail.x
    elseif (dir == 0) then
      newRail.x = lastRail.x + lastRail.myName*CELL_WIDTH*0.5
    else
      newRail.x = lastRail.x + CELL_WIDTH*0.5*((1-math.abs(lastRail.myName))*dir+(lastRail.myName+dir)*math.abs(lastRail.myName))
    end

    newRail.y = lastRail.y - CELL_WIDTH
    backRail.x = newRail.x
    backRail.y = newRail.y

    railsAmount = railsAmount + 1
    if(firstThree<3) then
      firstThree = firstThree + 1
      newRail.width = newRail.width/railInitialSize
      newRail.height = newRail.height/railInitialSize
      newRail.column = 3
    else
      newRail.column = currentColumn
    end
    backRail:setLinearVelocity( 0, moveSpeed)
    newRail:setLinearVelocity(0, moveSpeed)
    lastRail = newRail
    createGhost()
    return newRail
  end
end

function deleteLastRail()
  playSound("railDestroy")
  deleteGhost()
  display.remove(railsTable[railsAmount])
  table.remove(railsTable)
  display.remove(railBackTable[#railBackTable])
  table.remove( railBackTable)
  railsAmount = railsAmount - 1
  lastRail = railsTable[railsAmount]
  createGhost()
  currentColumn = lastRail.column
end

function clearRails()
  for i = #railsTable, 1 , -1 do
    display.remove(railsTable[i])
    table.remove( railsTable, i )
    railsAmount = railsAmount - 1
  end

  for i = #railBackTable, 1 , -1 do
    display.remove(railBackTable[i])
    table.remove( railBackTable, i )
  end
end

function collectGarbageRails()
  for i = #railsTable, 1 , -1 do
    local thisRail = railsTable[i]
    if (thisRail.y > _H)  then
      display.remove( thisRail ) -- убрать с экрана
      table.remove( railsTable, i ) -- убрать из памяти, так как содержится в списке
      railsAmount = railsAmount - 1
    end
  end
  for i = #railBackTable, 1 , -1 do
    local thisBack = railBackTable[i]
    if (thisBack.y > _H)  then
      display.remove( thisBack) -- убрать с экрана
      table.remove( railBackTable, i ) -- убрать из памяти, так как содержится в списке
    end
  end
end