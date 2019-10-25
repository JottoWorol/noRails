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

function showTutorialButton()
  howToButton = display.newImageRect( uiGroup,sheetUI, 10, _W*0.6 , _W*0.6*(128/370))
  howToButton.x = bottomX + _W * 0.5
  howToButton.y = bottomY - _H * 0.2
  howToButton:addEventListener( "tap" , showTutorial )
end

function showTutorial ()
  killStartButton()
  killTutorialButton()
  tutorialBackground = display.newImageRect( uiGroup, "Tutorial0.png", _W, _H )
  tutorialBackground.x = display.contentCenterX
  tutorialBackground.y = display.contentCenterY
  --- text
  local text = [[> Tap to screen or swipe up to pave the way forward;

> Swipe left/right to avoid obstacles;

> Swipe down to delete installed rails;

> Collect the coal to keep moving forward;

> Good luck!]]

  tutorialText = display.newText({text = text , x=display.contentCenterX, y=display.contentCenterY,width=_W*0.75, height=0, font="Font_Russo_One/RussoOne_Regular.ttf", fontSize=15, align="center"})
  tutorialText:setFillColor( 0,0,0 )
  tutorialBackground:addEventListener("tap", tutorialToMenu)
end

function tutorialToMenu()
  killTutorial()
  showStartButton()
  showTutorialButton()
end

function killTutorial()
  display.remove(tutorialBackground)
  display.remove(tutorialText)
end

function killTutorialButton()
  display.remove(howToButton)
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

function showResults()

  killPauseButton()
  killScore()
  killCoalIndicator()
  killCoinIndicator()

  local resultScore = score
  local resultCoins = coinAmount
  local resultTotalScore = [[Total score
         ]] .. resultScore --Не трогай пробелы)
  local resultCoinsScore = [[Coins
    ]] .. resultCoins

  resultBackground = display.newRect(uiGroup, display.contentCenterX, display.contentCenterY, _W, _H)
  resultBackground:setFillColor(0.5, 0.5, 0.5, 0.6)

  resultTotalScoreText = display.newText( resultTotalScore, display.contentCenterX, display.contentCenterY/4 , "Font_Russo_One/RussoOne_Regular.ttf", 24, "center" )
  resultCoinsText = display.newText(resultCoinsScore, display.contentCenterX, display.contentCenterY/2 + display.contentCenterY/10 , "Font_Russo_One/RussoOne_Regular.ttf", 24, "center" )

  playNextButton = display.newImageRect(uiGroup, sheetUI, 2, _W/4, _W/4)
  playNextButton.x = _W/2
  playNextButton.y = _H * 0.6

  backToMenuButton = display.newImageRect(uiGroup, sheetUI, 4, 604/2/1.5, (209/604)*(604/2)/1.5 )
  backToMenuButton.x = _W/2
  backToMenuButton.y = _H * 0.8

  --playNextButton:addEventListener("tap", playNext)
  backToMenuButton:addEventListener("tap", backToMenu)

end



function backToMenu()
  display.remove( resultTotalScoreText )
  display.remove( resultCoinsText )
  display.remove( resultScoreText )
  display.remove( resultBackground )
  display.remove( backToMenuButton )
  clearScreen()

  showStartButton()
  showTutorialButton()

end
