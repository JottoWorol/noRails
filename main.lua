------ GLOBAL Settings ------
_W = display.actualContentWidth
_H = display.actualContentHeight
local physics = require("physics")
physics.start()

------ Swipe block ----------
local swipeDirection = ""

function dragDirection(dispObj, left, right, tap)
    local prevX
    local isFocus = false
    local dirFunc = nil
    local thisTimer = nil


    function repeatedly()
        if dirFunc ~= nil then dirFunc() end
    end

    function touchListener(event)
        if event.phase == "began" then
            prevX = event.x;
            dispObj:setFocus( self )
            isFocus = true
            thisTimer = timer.performWithDelay(100, repeatedly, 1)
        elseif isFocus then
            if event.phase == "ended" or event.phase == "cancelled" then
                timer.cancel(thisTimer)
                dispObj:setFocus( nil )
                isFocus = false
                dirFunc = nil
            end
                local deltaX = event.x - prevX
                prevX = event.x;
                if deltaX > -0.05 and deltaX < 0.05 then
                    dirFunc = tap
                elseif deltaX >= 0.05 then
                    dirFunc = right
                else
                    dirFunc = left
                end
            end
        return true
    end
    dispObj:addEventListener("touch", touchListener)
    -- dispObj:addEventListener("tap", onTap)

end


local function left()
  swipeDirection = "left"
  print("left")
end
local function right()
  swipeDirection = "right"
  print("right")
end
local function onTap()
  swipeDirection = "tap"
  print("tap")
end


dragDirection(display.getCurrentStage(), left, right, onTap)

---------End of Swipe Block--------------


--------- Displays and sprite setting Block----------------------

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the Fuel, train, rails, etc.
local uiGroup = display.newGroup()    -- Display group for UI objects like the score

local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
      background.x = display.contentCenterX
      background.y = display.contentCenterY

      local sheetOptions =
      {
          frames =
          {
              { ---1) Tree
                  x = 0,
                  y = 0,
                  width = 335,
                  height = 403
              },
              { ---2) Cow
                  x = 335,
                  y = 0,
                  width = 301,
                  height = 403
              },
              { ---3) train-1
                  x = 335+301,
                  y = 0,
                  width = 256,
                  height = 356
              },
              { ---4) train-2
                  x = 335+301,
                  y = 356,
                  width = 256,
                  height = 320
              },
              { ---5) Lake
                  x = 0,
                  y = 403,
                  width = 427,
                  height = 621
              },
              { ---6) rails
                  x = 904 - 222,
                  y = 1055 - 340,
                  width = 222,
                  height = 340
              }
          },
      }
local Osheet = graphics.newImageSheet( "BaseSpritesheet.png", sheetOptions)


--------- End of Displays Block ---------

--------- Grid Block --------------------

local GRID_WIDTH = 5
local CELL_WIDTH = (_W - 20 ) / 5
local grid = {}
for i = 1, GRID_WIDTH do
  grid[i] = 0
end


--------- End of Grid Block -------------

--------- Train Parametrs BLock -------------

local train = display.newImageRect( mainGroup, Osheet,  3, (_W)* 0.15, _H*0.225 )
      train.x = display.contentCenterX - train.width * 0.2
      train.y = display.contentCenterY * 2

local speedToTime = 10000 --миллисекудны

coal = require("coal")
function getCoalConsumption() --litres per 0.1 seconds of total 100 litres
	return 3
end
--------- End of Tranin Parametrs BLock ------

--------- Spawner BLock --------------

local blockTable = {}
local previousRow = 0
local function createBlock()
  for i = 1, GRID_WIDTH do
    local a = math.random(100)
    if (grid[i] < 3) and (previousRow ~= 1) and ( a < 90) and (a > 30) then

      local newBlock = display.newImageRect(mainGroup, Osheet, math.random(1, 2), CELL_WIDTH , 100)

      table.insert(blockTable, newBlock)
      physics.addBody( newBlock, "static", { radius = CELL_WIDTH-10,} )
      newBlock.myName = "enemy"

      newBlock.x = CELL_WIDTH * i - 15
      newBlock.y = -200
      transition.to(newBlock, {time = speedToTime, y = _H + 1000})

      grid[i] = grid [i] + 1

    elseif   a >= 90 then
      local newBlock = display.newImageRect(mainGroup, Osheet, 5, CELL_WIDTH , 60)

      table.insert(blockTable, newBlock)
      physics.addBody( newBlock, "static", { radius = CELL_WIDTH-10,} )
      newBlock.myName = "coal"

      newBlock.x = CELL_WIDTH * i - 15
      newBlock.y = -200
      transition.to(newBlock, {time = speedToTime, y = _H + 1000})

      grid[i] = grid [i] + 1
    end

    previousRow = (previousRow + 1) % 2

  end
end

--------- end of spawner -------

--------- gameLoop -------------

local function gameLoop ()
  -- body...

  createBlock()

  for i = #blockTable, 1 , -1 do
    local thisBlock = blockTable[i]

      if (thisBlock.y > _H + 100  )  then
          grid [(thisBlock.x + 15)/CELL_WIDTH] = grid [(thisBlock.x + 15)/CELL_WIDTH] - 1
          display.remove( thisBlock ) -- убрать с экрана
          table.remove( blockTable, i ) -- убрать из памяти, так как содержится в списке
      end
  end
end

gameLoopTimer = timer.performWithDelay( 1100, gameLoop, 0 )
--------- end of game loop -----
