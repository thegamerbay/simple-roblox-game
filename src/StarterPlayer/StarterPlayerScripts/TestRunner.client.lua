--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local RunService = game:GetService("RunService")

-- Check where we are running
if not RunService:IsStudio() then
    return
end

-- Wait for the Packages folder to appear
local Packages = ReplicatedStorage:WaitForChild("Packages")
local TestEZ = require(Packages:WaitForChild("TestEZ") :: ModuleScript)

print("====================================")
print("🧪 STARTING CLIENT TESTS (Studio Only) 🧪")
print("====================================")

local TestBootstrap = (TestEZ :: any).TestBootstrap
TestBootstrap:run({script.Parent.Modules})

print("====================================")
