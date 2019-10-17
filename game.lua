
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

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



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	display.setStatusBar( display.HiddenStatusBar )
	backGroup = display.newGroup()  -- Display group for the background image
	shadowGroup = display.newGroup()
	railGroup = display.newGroup()
	mainGroup = display.newGroup()  -- Display group for the Fuel, train, rails, etc.
	uiGroup = display.newGroup()    -- Display group for UI objects like the score

	sho = require("spritesheet")
	Osheet = graphics.newImageSheet( "BaseSpritesheet.png", sheetOptions)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		--вызываем манагеров # порядок не менять

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		startGame()

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		physics.stop()

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end

function startGame()
	local coal = require("coal")
	local blockManager = require("blockManager")
	local levelManager = require("levelManager")
	local controlManager = require("controlManager")
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
