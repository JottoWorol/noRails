coal = require("coal")

local background = display.newImageRect( backGroup, "Back.png" , _W, _H)
      background.x = display.contentCenterX
      background.y = display.contentCenterY

function showStartButton()
  startButton = display.newImageRect(uiGroup, sheetUI, 2, _W/2, _W/2)
  startButton.x = bottomX + _W*0.5
  startButton.y = bottomY - _H*0.5
  startButton:addEventListener( "tap" , startIt )
end

function killStartButton()
  display.remove(startButton)
end

function showScore()
  scoreText = display.newText( uiGroup, "Score: " .. score, display.contentCenterX, 20, native.systemFont, 36 )
end

function killScore()
  display.remove(scoreText)
end

function updateScore()
  scoreText.text = "Score: " .. score
end

function showCoinIndicator()
  coinImage = display.newImageRect(uiGroup, sheetBonus, spriteCoinOffset, coinIconSize, coinIconSize)
  coinImage.x = bottomX + coinIconSize
  coinImage.y = bottomY - _H + coinIconSize
  coinText = display.newText( uiGroup, "" .. coinAmount,
  coinImage.x + coinIconSize*2, coinImage.y, native.systemFont, 25 )
end

function killCoinIndicator()
  display.remove( coinText )
  display.remove( coinImage )
end

function updateCoinIndicator()
  coinText.text = "" .. coinAmount
end

function showCoalIndicator()
  --создаём два прямоугольника - для рамки и значения/заполнения
  indicatorBackground = display.newRect(indicatorPosX, indicatorPosY, indicatorWidth, indicatorHeight)
  indicatorValue = display.newRect(indicatorPosX, indicatorPosY, indicatorWidth - frameWidth*2, indicatorHeight - frameWidth*2)

  --Фон индикатора
  indicatorBackground:setStrokeColor( 0,0,0 )  --чёрная рамка
  indicatorBackground.strokeWidth = frameWidth
  indicatorBackground:setFillColor( 0.5,0.5,0.5) --заполняем прозрачностью | FrAzen: Фон - зелёная трава - так что бэк я заменил на чёрный
  --стартовый цвет индикатора
  indicatorValue:setFillColor( 0,1,0)
end

function killCoalIndicator()
  display.remove(indicatorBackground)
  display.remove(indicatorValue)
end

function updateCoalIndicator()
  --красиво меняем цвет
  indicatorValue:setFillColor((getCoalPercentage()>0.5) and (3*(1 - getCoalPercentage())) or (1), (getCoalPercentage()>0.5) and (1) or (getCoalPercentage()*2), 0 )
  --обновляем ширину
  indicatorValue.width = (indicatorWidth - frameWidth) * (getCoalPercentage())
  --обновляем позицию
  indicatorValue.x = indicatorPosX - ((indicatorWidth - frameWidth) - indicatorValue.width)*0.5
end

function showRestartButton()
  restartButton = display.newImageRect(uiGroup, sheetUI, 1, 604/2, (209/604)*(604/2))
  restartButton.x = _W/2
  restartButton.y = _H - restartButton.height*2
  restartButton:addEventListener( "tap" , levelRestart )
end

function killRestartButton()
  display.remove( restartButton )
end

function showPauseButton()
  startButton = display.newImageRect(uiGroup, sheetUI, 3, _W/5, _W/5)
  startButton.x = bottomX + _W/10
  startButton.y = bottomY - _W/10
  startButton:addEventListener( "tap" , levelPause)
end

function killPauseButton()
  display.remove(startButton)
end

function showContinueButton()
  continueButton = display.newImageRect(uiGroup, sheetUI, 4, 604/2, (209/604)*(604/2))
  continueButton.x = _W/2
  continueButton.y = _H - continueButton.height*2
  continueButton:addEventListener( "tap" , levelContinue )
end

function killContinueButton()
  display.remove( continueButton )
end