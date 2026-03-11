local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

-- Check where we are running
if not RunService:IsStudio() then
    -- If this is a real game with users, simply exit the script without running tests
    return
end

-- Wait for the Packages folder to appear in the game
local Packages = ReplicatedStorage:WaitForChild("Packages")
local TestEZ = require(Packages:WaitForChild("TestEZ"))

print("====================================")
print("🧪 STARTING AUTOMATIC TESTS (Studio Only) 🧪")
print("====================================")

TestEZ.TestBootstrap:run({ServerScriptService.Modules})

print("====================================")
