 -----Блок топлива---------
-- startConsumeCoal - чтобы начать потребление
-- stopConsumeCoal - чтобы прекратить потребление
-- recoverCoal - восстановить уровень топлива


  coalAmount = 0 --from 0 to 100
  maxCoalAmount = 100
  coalPeriod = 100 --how frequently we consume coal, milliseconds
  isConsuming = true

  indicatorWidth = 100              --размер индикатора
  indicatorHeight = indicatorWidth/6

  --располагаем индикатор в правом верхнем
  indicatorPosX = display.contentCenterX+display.actualContentWidth*0.5 - indicatorWidth*0.5 - 10
  indicatorPosY = display.contentCenterY-display.actualContentHeight*0.5 + indicatorHeight*0.5 + 10
  frameWidth = 1.5

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

function stopConsumeCoal()
  isConsuming = false
  timer.pause(coalConsumeTimer);
end

stopConsumeCoal()

function startConsumeCoal()
  isConsuming = true
  timer.resume(coalConsumeTimer);
end
