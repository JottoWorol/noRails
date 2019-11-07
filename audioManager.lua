local audioTable = {}
local railRoundRobin = 0
local coinRoundRobin = 0
local isMusicPlaying = 0

  table.insert( audioTable, audio.loadSound("PlayButton.mp3")) --1
  table.insert( audioTable, audio.loadSound("rail0.mp3")) --2
  table.insert( audioTable, audio.loadSound("rail1.mp3"))--3
  table.insert( audioTable, audio.loadSound("rail2.mp3"))--4
  table.insert( audioTable, audio.loadSound("rail3.mp3"))--5
  table.insert( audioTable, audio.loadSound("coin0.mp3"))--6
  table.insert( audioTable, audio.loadSound("coin1.mp3"))--7
  table.insert( audioTable, audio.loadSound("coin2.mp3"))--8
  table.insert( audioTable, audio.loadSound("coin3.mp3"))--9
  table.insert( audioTable, audio.loadSound("recoverCoal.mp3")) --10
  table.insert( audioTable, audio.loadSound("Pause-Cont.mp3")) --11
  table.insert( audioTable, audio.loadSound("railDestroy.mp3")) --12
  table.insert( audioTable, audio.loadSound("mainTheme.mp3")) --12

function playMainTheme()
  audio.play(audioTable[13])
end

mainThemeTimer = timer.performWithDelay( 118970, playMainTheme,0)
timer.pause(mainThemeTimer)


function playSound(soundName)
  --soundName = "rail" || "button0" || "coin" || coal || "playButton"
  if(soundName == "rail") then
    audio.play(audioTable[2+railRoundRobin])
    if(railRoundRobin<3) then
      railRoundRobin = railRoundRobin + 1
    else
      railRoundRobin = 0
    end
  elseif(soundName == "coin") then
    audio.play(audioTable[6+coinRoundRobin])
    if(coinRoundRobin<3) then
      coinRoundRobin = coinRoundRobin + 1
    else
      coinRoundRobin = 0
    end
  elseif(soundName == "coal") then
    audio.play( audioTable[10])
  elseif(soundName == "button0") then
    audio.play( audioTable[11])
  elseif(soundName == "railDestroy") then
    audio.play( audioTable[12])
  elseif(soundName == "playButton") then
    audio.play( audioTable[1])
  elseif(soundName == "music0")then
    audio.play(audioTable[13])
    timer.resume(mainThemeTimer)
  end
end


