--!strict
local modulesFolder = script.Parent:WaitForChild("Modules")
local ClientShop = require(modulesFolder:WaitForChild("ClientShop"))

ClientShop.init()
