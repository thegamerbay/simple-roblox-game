--!strict
local modulesFolder = script.Parent:WaitForChild("Modules")
local animatorModule = modulesFolder:WaitForChild("ClientCoinAnimator")

local ClientCoinAnimator = require(animatorModule)
ClientCoinAnimator.init()