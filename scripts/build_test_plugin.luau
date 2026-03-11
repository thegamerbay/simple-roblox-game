local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local scriptContent = fs.readFile("scripts/run_tests.lua")

local scriptInstance = roblox.Instance.new("Script")
scriptInstance.Name = "run_tests"
scriptInstance.Source = scriptContent

local modelFile = roblox.serializeModel({scriptInstance}, true) -- true means rbxmx (xml format)
fs.writeFile("run_tests.rbxmx", modelFile)
print("Successfully generated run_tests.rbxmx")
