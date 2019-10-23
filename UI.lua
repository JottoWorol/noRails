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
  scoreBack = display.newImageRect( uiGroup, sheetUI, 9, _H/16 * (227/119), _H/14 )
  --scoreBack.x = _H/14 * (281/140) + scoreBack.width*0.5
  scoreBack.x = (bottomX + coinImage.width * 0.5 + _W - (_H/14*(475/153))/2)/2
  scoreBack.y = bottomY - _H + scoreBack.height*0.5 
  scoreText = display.newText( uiGroup, score, scoreBack.x, scoreBack.y, native.systemFont, 36 )
end

function killScore()
  display.remove(scoreText)
  display.remove( scoreBack )
end

function updateScore()
  scoreText.text = score
end

function showCoinIndicator()
  coinIndicatorHeight = _H/14
  coinImage = display.newImageRect(uiGroup, sheetUI, 5, _H/14 * (281/140), _H/14)
  coinImage.x = bottomX + coinImage.width * 0.5
  coinImage.y = bottomY - _H + coinImage.height * 0.5
  coinText = display.newText( uiGroup, "" .. coinAmount, coinImage.x + coinImage.width*0.1, coinImage.y, native.systemFont, 25, left)
end

function killCoinIndicator()
  display.remove( coinText )
  display.remove( coinImage )
end

function updateCoinIndicator()
  coinText.text = "" .. coinAmount
end

function showCoalIndicator()
  indicatorIconHeight = _H/14
  indicatorIconWidth = indicatorIconHeight*(475/153)
  indicatorValueHeight = indicatorIconHeight*(71/153)
  indicatorValueWidth = indicatorIconWidth*(328/475)
 
  --иконка индикатора
  indicatorIcon = display.newImageRect(uiGroup, sheetUI, 6, indicatorIconWidth, indicatorIconHeight)
  indicatorIcon.x = _W - indicatorIconWidth/2
  indicatorIcon.y = bottomY - _H + indicatorIconHeight/2

  --индикатор
  indicatorValue = display.newImageRect(uiGroup, sheetUI, 7, indicatorValueWidth, indicatorValueHeight)
  --затемнитель
  indicatorValueDarker = display.newImageRect(uiGroup, sheetUI, 8, indicatorValueWidth, indicatorValueHeight)

  indicatorValuePosX = indicatorIcon.x + (125/475)*indicatorIconWidth*0.415

  indicatorValue.x = indicatorValuePosX
  indicatorValue.y = indicatorIcon.y - indicatorIconWidth*0.005
  indicatorValueDarker.x = indicatorValuePosX
  indicatorValueDarker.y = indicatorValue.y
  indicatorValue:setFillColor(0, 1, 0)
  --indicatorValue:setFillColor(0.522, 0.788, 0.078)
end

function killCoalIndicator()
  display.remove(indicatorIcon)
  display.remove(indicatorValue)
  display.remove(indicatorValueDarker)

end

function updateCoalIndicator()
  local function redColor()
    if(getCoalPercentage()>0.75) then
      return 4*(1 - getCoalPercentage())
    else
      return 1
    end
  end

  local function greenColor()
    if(getCoalPercentage()>0.75) then
      return 1
    else
      return getCoalPercentage()*(4/3)
    end
  end
  --красиво меняем цвет
  indicatorValue:setFillColor(redColor(), greenColor(), 0 )
  --обновляем ширину
  indicatorValue.width = (indicatorValueWidth) * (getCoalPercentage())
  indicatorValueDarker.width = indicatorValue.width
  --обновляем позицию
  indicatorValue.x = indicatorValuePosX - ((indicatorValueWidth) - indicatorValue.width)*0.5
  indicatorValueDarker.x = indicatorValue.x

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