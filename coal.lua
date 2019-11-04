 -----Блок топлива---------
-- startConsumeCoal - чтобы начать потребление
-- stopConsumeCoal - чтобы прекратить потребление
-- recoverCoal - восстановить уровень топлива

coalAmount = 0 --from 0 to 100
maxCoalAmount = 100
coalPeriod = 100 --how frequently we consume coal, milliseconds
isConsuming = true
coalTable = {}
coalSize = CELL_WIDTH*0.6
spriteCoalOffset = 1 --позиция спрайта угля
coalState = 0
coalSize = CELL_WIDTH*0.6

function getCoalPercentage()
  return coalAmount/maxCoalAmount
end

local function consumeCoal()
  if(isConsuming) then
    coalAmount = coalAmount - getCoalConsumption()
    updateCoalIndicator()
  end
end

coalConsumeTimer = timer.performWithDelay(coalPeriod, consumeCoal, 0 )

function recoverCoal() --для восстановления до сотки
  coalAmount=maxCoalAmount --максимальное значение топлива
end

function clearCoal()
  for i = #coalTable, 1 , -1 do
      display.remove(coalTable[i])
      table.remove( coalTable, i )
  end
end

function collectGarbageCoal()
  for i = #coalTable, 1 , -1 do
      local coal = coalTable[i]
      if(coal.y > _H + CELL_WIDTH or coal.isUsed) then
        display.remove(coal)
        table.remove( coalTable, i )
      end
  end
end

local function updateSprite(spriteNumber)
  local newTable = {}
  for i = #coalTable, 1 , -1 do
    local coal = coalTable[i]
    local oldX = coal.x
    local oldY = coal.y
  
    newcoal = display.newImageRect(mainGroup, sheetBonus, spriteCoalOffset + spriteNumber, coalSize, coalSize)
    if(lastLine == coal) then
      lastLine = newcoal
    end
    display.remove(coal)
    table.remove( coalTable, i )
    table.insert(newTable, newcoal)
    physics.addBody( newcoal, "kinematic", { radius = CELL_WIDTH*0.3, isSensor = true})
    newcoal.myName = "coal"
    newcoal.isUsed = false
    newcoal.x = oldX  --спавним в нужном ряду
    newcoal.y = oldY  --спавним чуть выше вернего края
    newcoal:setLinearVelocity(0, moveSpeed)
  end
  return newTable
end

local function nextState()
  if(coalState<5) then
    coalState=coalState+1
  else
    coalState=0
  end
  coalTable = updateSprite(coalState)
  
end

coalUpdateTimer = timer.performWithDelay( 100, nextState, 0)
timer.pause(coalUpdateTimer)


function stopConsumeCoal()
  isConsuming = false
  timer.pause(coalUpdateTimer)
  timer.pause(coalConsumeTimer)
end

stopConsumeCoal()

function startConsumeCoal()
  isConsuming = true
  timer.resume(coalUpdateTimer )
  timer.resume(coalConsumeTimer)
end

