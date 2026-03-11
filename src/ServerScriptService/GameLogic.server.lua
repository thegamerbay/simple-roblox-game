local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris") -- Service for automatic object removal

-- 1. Raise the platform to Y = 5 so it doesn't intersect with the default baseplate
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Size = Vector3.new(100, 1, 100)
baseplate.Position = Vector3.new(0, 5, 0) 
baseplate.Anchored = true
baseplate.BrickColor = BrickColor.new("Dark green")
baseplate.Parent = Workspace

-- 2. Setup the points system (Leaderstats)
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats
end)

-- Function to create a spark effect when a coin is collected
local function createCollectEffect(position, color)
    local attachment = Instance.new("Attachment")
    attachment.Position = position
    attachment.Parent = Workspace.Terrain

    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(color)
    particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
    particle.Speed = NumberRange.new(15, 25)
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.SpreadAngle = Vector2.new(180, 180)
    particle.Parent = attachment

    particle:Emit(30) -- Emit 30 particles at once
    Debris:AddItem(attachment, 1.5) -- Remove the effect from memory after 1.5 seconds
end

-- 3. Function to spawn a coin
local function spawnCoin()
    -- 20% chance for a rare coin to appear
    local isRare = math.random(1, 100) <= 20
    
    local coin = Instance.new("Part")
    coin.Name = isRare and "RareCoin" or "Coin"
    
    -- Change size and shape to look like a actual coin (thin cylinder)
    coin.Shape = Enum.PartType.Cylinder
    -- A cylinder's X axis is its length. We want it thin, so X is small, Y and Z are the diameter
    local diameter = isRare and 4 or 2.5
    local thickness = isRare and 0.4 or 0.2
    coin.Size = Vector3.new(thickness, diameter, diameter)
    
    -- Spawn the coin higher (at height 9), since we raised the platform
    local startY = 9 
    local startPos = Vector3.new(math.random(-20, 20), startY, math.random(-20, 20))
    coin.Position = startPos
    coin.BrickColor = isRare and BrickColor.new("Really red") or BrickColor.new("Bright yellow")
    coin.Material = Enum.Material.Neon
    coin.Anchored = true
    coin.CanCollide = false
    coin.Parent = Workspace
    
    -- How many points to give for the coin
    local coinValue = isRare and 5 or 1

    -- ANIMATION: Rotation and hovering
    local timePassed = 0
    local animationConnection
    animationConnection = RunService.Heartbeat:Connect(function(deltaTime)
        -- If the coin is gone, stop the animation
        if not coin or not coin.Parent then
            animationConnection:Disconnect()
            return
        end
        timePassed += deltaTime
        
        -- Rotate around the Y axis
        local rotation = CFrame.Angles(0, math.rad(100) * timePassed, 0)
        -- Make it hover smoothly up and down using sine
        local hoverOffset = Vector3.new(0, math.sin(timePassed * 3) * 0.5, 0)
        
        coin.CFrame = CFrame.new(startPos + hoverOffset) * rotation
    end)

    -- COLLECTION LOGIC
    local touchConnection
    touchConnection = coin.Touched:Connect(function(otherPart)
        local character = otherPart.Parent
        local humanoid = character:FindFirstChild("Humanoid")

        if humanoid then
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                -- Disconnect events to prevent counting the touch twice
                touchConnection:Disconnect()
                animationConnection:Disconnect()

                -- 1. Award points
                player.leaderstats.Coins.Value += coinValue
                
                -- 2. Play sound (create it in the player's head so they hear it better)
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://1347140027" -- ID of a standard pleasant coin sound
                sound.Volume = 0.8
                sound.Parent = character:FindFirstChild("Head") or Workspace
                sound:Play()
                Debris:AddItem(sound, 2) -- Remove sound after 2 seconds

                -- 3. Create a beautiful particle explosion
                createCollectEffect(coin.Position, coin.Color)

                -- 4. Destroy the coin itself
                coin:Destroy()
                
                -- 5. Wait 1 second and spawn a new one
                task.wait(1)
                spawnCoin()
            end
        end
    end)
end

-- Spawn the first coin
spawnCoin()
