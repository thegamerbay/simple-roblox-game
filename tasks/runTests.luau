local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Load TestEZ from Wally packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local TestEZ = require(Packages:WaitForChild("TestEZ"))

print("====================================")
print("🚀 RUNNING TESTS VIA OPEN CLOUD 🚀")
print("====================================")

local results = TestEZ.TestBootstrap:run(
    {
        ServerScriptService.Modules,
        StarterPlayer.StarterPlayerScripts.Modules
    },
    TestEZ.Reporters.TextReporter
)

-- Open Cloud will return an error to GitHub Actions if we call error()
if results.failureCount > 0 then
    error("❌ Tests failed! Errors: " .. tostring(results.failureCount))
end

print("✅ All tests passed successfully!")
