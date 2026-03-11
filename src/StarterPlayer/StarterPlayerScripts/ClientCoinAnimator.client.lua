--!strict
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local activeCoins: { [BasePart]: { part: BasePart, startPos: Vector3, timePassed: number } } = {}

-- Create a visual dummy for a given coin hitbox
local function onCoinAdded(coin: BasePart)
    if not coin:IsA("BasePart") then return end

    -- Generate purely visual replica
    local clone = Instance.new("Part")
    clone.Name = "Visual" .. coin.Name
    clone.Shape = coin.Shape
    clone.Size = coin.Size
    clone.BrickColor = coin.BrickColor
    clone.Material = coin.Material
    clone.Anchored = true
    clone.CanCollide = false
    clone.CastShadow = false -- Optimization
    clone.Position = coin.Position
    clone.Parent = Workspace
    
    activeCoins[coin] = {
        part = clone,
        startPos = coin.Position,
        timePassed = 0
    }
end

-- Destroy the visual dummy when the server removes the hitbox
local function onCoinRemoved(coin: BasePart)
    local data = activeCoins[coin]
    if data then
        if data.part then
            data.part:Destroy()
        end
        activeCoins[coin] = nil
    end
end

-- Animate all visual dummies every frame
RunService.RenderStepped:Connect(function(deltaTime)
    for coin, data in pairs(activeCoins) do
        data.timePassed += deltaTime
        local rotation = CFrame.Angles(0, math.rad(100) * data.timePassed, 0)
        local hoverOffset = Vector3.new(0, math.sin(data.timePassed * 3) * 0.5, 0)
        
        -- Apply transformations to the purely visual clone
        if data.part and data.part.Parent then
            data.part.CFrame = CFrame.new(data.startPos + hoverOffset) * rotation
        end
    end
end)

-- Monitor the CollectionService for existing and new coins
CollectionService:GetInstanceAddedSignal("AnimatedCoin"):Connect(function(instance)
    onCoinAdded(instance :: BasePart)
end)

CollectionService:GetInstanceRemovedSignal("AnimatedCoin"):Connect(function(instance)
    onCoinRemoved(instance :: BasePart)
end)

-- Catch any coins that might have spawned before this specific script ran
for _, instance in pairs(CollectionService:GetTagged("AnimatedCoin")) do
    onCoinAdded(instance :: BasePart)
end
