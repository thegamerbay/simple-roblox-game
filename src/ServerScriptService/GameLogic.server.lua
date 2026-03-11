local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- 1. Create a base platform (floor) so the player doesn't fall into the abyss
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Size = Vector3.new(100, 1, 100)
baseplate.Position = Vector3.new(0, -0.5, 0)
baseplate.Anchored = true
baseplate.BrickColor = BrickColor.new("Dark green")
baseplate.Parent = Workspace

-- 2. Set up the scoring system (Leaderstats) when a player joins
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats
end)

-- 3. Function to spawn a coin
local function spawnCoin()
    local coin = Instance.new("Part")
    coin.Name = "Coin"
    coin.Size = Vector3.new(2, 2, 2)
    coin.Position = Vector3.new(math.random(-20, 20), 3, math.random(-20, 20))
    coin.Shape = Enum.PartType.Ball
    coin.BrickColor = BrickColor.new("Bright yellow")
    coin.Material = Enum.Material.Neon
    coin.Anchored = true
    coin.CanCollide = false
    coin.Parent = Workspace

    -- Coin collection logic
    local connection
    connection = coin.Touched:Connect(function(otherPart)
        -- Check if the player's character touched the coin
        local character = otherPart.Parent
        local humanoid = character:FindFirstChild("Humanoid")

        if humanoid then
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                -- Add a point, remove the coin, and spawn a new one
                player.leaderstats.Coins.Value += 1
                connection:Disconnect() -- Disconnect the event to prevent double touches
                coin:Destroy()
                
                -- Wait a second and spawn a new coin
                task.wait(1)
                spawnCoin()
            end
        end
    end)
end

-- Spawn the first coin
spawnCoin()
