local CoinManager = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- ==========================================
-- 1. PURE LOGIC (Ideal for testing)
-- ==========================================
CoinManager.Logic = {}

-- Check if a rare coin should drop (20% chance)
function CoinManager.Logic.isRare(randomRoll)
    return randomRoll <= 20
end

-- Get all coin stats based on rarity
function CoinManager.Logic.getCoinStats(isRare)
    if isRare then
        return { value = 5, diameter = 4, thickness = 0.4, color = BrickColor.new("Really red") }
    else
        return { value = 1, diameter = 2.5, thickness = 0.2, color = BrickColor.new("Bright yellow") }
    end
end

-- ==========================================
-- 2. ROBLOX ENGINE LOGIC (Effects and Spawn)
-- ==========================================
function CoinManager.createCollectEffect(position, color)
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

    particle:Emit(30)
    Debris:AddItem(attachment, 1.5)
end

function CoinManager.spawnCoin()
    -- Use our testable logic
    local randomRoll = math.random(1, 100)
    local isRare = CoinManager.Logic.isRare(randomRoll)
    local stats = CoinManager.Logic.getCoinStats(isRare)

    -- Create physical object
    local coin = Instance.new("Part")
    coin.Name = isRare and "RareCoin" or "Coin"
    coin.Shape = Enum.PartType.Cylinder
    coin.Size = Vector3.new(stats.thickness, stats.diameter, stats.diameter)
    
    local startY = 9 
    local startPos = Vector3.new(math.random(-20, 20), startY, math.random(-20, 20))
    coin.Position = startPos
    coin.BrickColor = stats.color
    coin.Material = Enum.Material.Neon
    coin.Anchored = true
    coin.CanCollide = false
    coin.Parent = Workspace

    -- Animation
    local timePassed = 0
    local animationConnection
    animationConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not coin or not coin.Parent then
            animationConnection:Disconnect()
            return
        end
        timePassed += deltaTime
        local rotation = CFrame.Angles(0, math.rad(100) * timePassed, 0)
        local hoverOffset = Vector3.new(0, math.sin(timePassed * 3) * 0.5, 0)
        coin.CFrame = CFrame.new(startPos + hoverOffset) * rotation
    end)

    -- Collecting event
    local touchConnection
    touchConnection = coin.Touched:Connect(function(otherPart)
        local character = otherPart.Parent
        local humanoid = character:FindFirstChild("Humanoid")

        if humanoid then
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                touchConnection:Disconnect()
                animationConnection:Disconnect()

                player.leaderstats.Coins.Value += stats.value
                
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://1347140027"
                sound.Volume = 0.8
                sound.Parent = character:FindFirstChild("Head") or Workspace
                sound:Play()
                Debris:AddItem(sound, 2)

                CoinManager.createCollectEffect(coin.Position, coin.Color)
                coin:Destroy()
                
                task.wait(1)
                CoinManager.spawnCoin()
            end
        end
    end)
end

return CoinManager
