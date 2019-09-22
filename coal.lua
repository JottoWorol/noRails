-----Блок топлива---------


  local coalAmount = 0 --from 0 to 100
  local maxCoalAmount = 100
  local coalPeriod = 100 --how frequently we consume coal, milliseconds
  local isConsuming = true

  local indicatorWidth = 100              --размер индикатора
  local indicatorHeight = indicatorWidth/6

  --располагаем индикатор в правом верхнем
  local indicatorPosX = display.contentCenterX+display.actualContentWidth*0.5 - indicatorWidth*0.5 - 10
  local indicatorPosY = display.contentCenterY-display.actualContentHeight*0.5 + indicatorHeight*0.5 + 10
  local frameWidth = 1.5

  --создаём два прямоугольника - для рамки и значения/заполнения
  local indicatorBackground = display.newRect(indicatorPosX, indicatorPosY, indicatorWidth, indicatorHeight)
  local indicatorValue = display.newRect(indicatorPosX, indicatorPosY, indicatorWidth - frameWidth*2, indicatorHeight - frameWidth*2)

  --Фон индикатора
  indicatorBackground:setStrokeColor( 0,0,0 )  --чёрная рамка
  indicatorBackground.strokeWidth = frameWidth
  indicatorBackground:setFillColor( 0.5,0.5,0.5) --заполняем прозрачностью | FrAzen: Фон - зелёная трава - так что бэк я заменил на чёрный
  --стартовый цвет индикатора
  indicatorValue:setFillColor( 0,1,0)

  local function recoverCoal() --для восстановления до сотки
    coalAmount=maxCoalAmount --максимальное значение топлива
  end

  local function stopConsume()
      isConsuming = false
  end

  local function startConsume()
      isConsuming = true
  end

  local function getCoalPercentage()
    return coalAmount/maxCoalAmount
  end

  local function updateCoalIndicator()
    --красиво меняем цвет
    indicatorValue:setFillColor((getCoalPercentage()>0.5) and (3*(1 - getCoalPercentage())) or (1), (getCoalPercentage()>0.5) and (1) or (getCoalPercentage()*2), 0 )
    --обновляем ширину
    indicatorValue.width = (indicatorWidth - frameWidth) * (getCoalPercentage())
    --обновляем позицию
    indicatorValue.x = indicatorPosX - ((indicatorWidth - frameWidth) - indicatorValue.width)*0.5
  end

  local function consumeCoal()
    if(isConsuming) then
      coalAmount = coalAmount - getCoalConsumption()
      if(coalAmount<=0) then
        recoverCoal()
      end
      updateCoalIndicator()
    end
  end


coalConsumeTimer = timer.performWithDelay(coalPeriod, consumeCoal, 0 )

