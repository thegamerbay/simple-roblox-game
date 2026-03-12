--!strict
local modulesFolder = script.Parent:WaitForChild("Modules")
local MusicPlayer = require(modulesFolder:WaitForChild("MusicPlayer"))
MusicPlayer.init()
