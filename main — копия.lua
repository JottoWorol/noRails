------ GLOBAL Settings ------
_W = display.actualContentWidth  --ширина экрана
_H = display.actualContentHeight --высота экрана
display.fps = 30

--левый нижний угол
bottomY = display.contentCenterY+_H*0.5
bottomX = display.contentCenterX-_W*0.5

function intDiv(a,b) --функция для целочисленного деления, потмоу что в Lua 5.1 её нет
	local c = a/b
	c = c%1
	return (a/b - c)
end

--грид
GRID_WIDTH = 5
CELL_WIDTH = (_W - 20 ) / 5

--параметры поезда
moveSpeed = 70
speedDelta = 1;  --moveSpeed = moveSpeed + speedDelta
rotationSpeed = 5  --how fast train rotates
function getCoalConsumption() --сколько единиц топлива из 100 потребляется за 0.1 секунду
  return 1
end

function timePerCell()   --время прохождения одной ячейки в миллисекундах
  return CELL_WIDTH*1000/moveSpeed
end

--подрубаем физику
physics = require("physics")

local composer = require( "composer" )

--подрубаем графон
display.setStatusBar( display.HiddenStatusBar )
backGroup = display.newGroup()  -- Display group for the background image
shadowGroup = display.newGroup()
railGroup = display.newGroup()
mainGroup = display.newGroup()  -- Display group for the Fuel, train, rails, etc.
uiGroup = display.newGroup()    -- Display group for UI objects like the score

sho = require("spritesheet")
Osheet = graphics.newImageSheet( "BaseSpritesheet.png", sheetOptions)

--вызываем манагеров # порядок не менять
local coal = require("coal")
local blockManager = require("blockManager")
local levelManager = require("levelManager")
local controlManager = require("controlManager")

--начинаем нулевой уровень
levelStart(0)
