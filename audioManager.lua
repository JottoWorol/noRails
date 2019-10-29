local audioTable = {}

function loadAudio()
  table.insert( audioTable, audio.loadSound("PlayButton.mp3")) --1
  table.insert( audioTable, audio.loadSound("newRail0(-2).mp3")) --2
  table.insert( audioTable, audio.loadSound("recoverCoal.mp3")) --3
  table.insert( audioTable, audio.loadSound("Pause_Cont.mp3")) --4
end

function playSound(id)
  audio.play(audioTable[id])
end

loadAudio()