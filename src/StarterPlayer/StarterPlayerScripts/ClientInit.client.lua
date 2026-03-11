--!strict
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

print("====================================")
print("Welcome to the game, " .. localPlayer.Name .. "!")
print("Look for glowing yellow spheres to collect coins.")
print("====================================")

-- Example of tracking score changes on the client (e.g., for UI updates)
local function onLeaderstatsAdded(leaderstats: Instance)
    local coinsValue = leaderstats:WaitForChild("Coins") :: IntValue
    
    coinsValue.Changed:Connect(function(newValue: number)
        print("Ding! You now have " .. tostring(newValue) .. " coins")
    end)
end

-- Check if leaderstats already exist, or wait for them to appear
local leaderstats = localPlayer:FindFirstChild("leaderstats")
if leaderstats then
    onLeaderstatsAdded(leaderstats)
else
    localPlayer.ChildAdded:Connect(function(child: Instance)
        if child.Name == "leaderstats" then
            onLeaderstatsAdded(child)
        end
    end)
end
