local audioTable = {}


  table.insert( audioTable, audio.loadSound("PlayButton.mp3")) --1
  table.insert( audioTable, audio.loadSound("newRail0(-2).mp3")) --2
  table.insert( audioTable, audio.loadSound("recoverCoal.mp3")) --3
  table.insert( audioTable, audio.loadSound("Pause-Cont.mp3")) --4
  table.insert( audioTable, audio.loadSound("coin.mp3")) --5


function playSound(id)
  audio.play(audioTable[id])
end

