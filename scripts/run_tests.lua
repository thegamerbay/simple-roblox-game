local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")

-- Wait for Wally packages to load (TestEZ)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local TestEZ = require(Packages:WaitForChild("TestEZ"))

print("====================================")
print("🧪 RUNNING TESTS IN HEADLESS STUDIO 🧪")
print("====================================")

-- Run tests in ServerScriptService and StarterPlayerScripts folders
local results = TestEZ.TestBootstrap:run(
    {
        ServerScriptService.Modules,
        StarterPlayer.StarterPlayerScripts.Modules
    },
    TestEZ.Reporters.TextReporter
)

-- If there are errors, terminate the script with an error, 
-- so that GitHub Actions marks the step as Failed
if results.failureCount > 0 then
    error("Tests failed! Number of errors: " .. tostring(results.failureCount))
end

print("All tests passed successfully!")
