coinTable = {}
coinSize = CELL_WIDTH*0.6
coinIconSize = 100/5
coinAmount = 0
spriteCoinOffset = 2 --номер ячейки с монетой в спрайтшите
local coinState = 0 -- from 0 to 5



function coinPlus() 
  coinAmount = coinAmount + 1
end

function useCoin(coin)
  for i = #coinTable, 1 , -1 do
      if(coin == coinTable[i])then
      display.remove(coin)
      table.remove( coinTable, i )
    end
  end
end

function clearCoins()
  for i = #coinTable, 1 , -1 do
      local coin = coinTable[i]
      display.remove(coin)
      table.remove( coinTable, i )
  end
end

function collectGarbageCoins()
  for i = #coinTable, 1 , -1 do
      local coin = coinTable[i]
      if(coin.y > _H + CELL_WIDTH) then
        display.remove(coin)
        table.remove( coinTable, i )
      end
  end
end

function updateSprite(spriteNumber)
  local newTable = {}
  for i = #coinTable, 1 , -1 do
      local coin = coinTable[i]
    local oldX = coin.x
    local oldY = coin.y
  
    newCoin = display.newImageRect(mainGroup, sheetBonus, spriteCoinOffset + spriteNumber, coinSize, coinSize)
    if(lastLine == coin) then
      lastLine = newCoin
    end
    display.remove(coin)
    table.remove( coinTable, i )
    table.insert(newTable, newCoin)
    physics.addBody( newCoin, "dynamic", { radius = CELL_WIDTH*0.3, isSensor = true})
    newCoin.myName = "coin"
    newCoin.isUsed = false
    newCoin.x = oldX  --спавним в нужном ряду
    newCoin.y = oldY  --спавним чуть выше вернего края
    newCoin:setLinearVelocity(0, moveSpeed)
  end
  return newTable
end

function nextState()
  if(coinState<5) then
    coinState=coinState+1
  else
    coinState=0
  end
  coinTable = updateSprite(coinState)
  
end

coinUpdateTimer = timer.performWithDelay( 100, nextState, 0)
timer.pause(coinUpdateTimer)

function startUpdateCoins()
  timer.resume( coinUpdateTimer )
end

function stopUpdateCoins()
  timer.pause( coinUpdateTimer )
end