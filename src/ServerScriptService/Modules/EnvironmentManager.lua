--!strict
local EnvironmentManager = {}
local InsertService = game:GetService("InsertService")
local Workspace = game:GetService("Workspace")

local TREE_IDS = {
    12549617200
}

-- Divide the map into 5 zones to prevent trees from spawning clumped together
local SPAWN_ZONES = {
    { xMin = -45, xMax = -15, zMin = -45, zMax = -15 }, -- Top Left
    { xMin = 15,  xMax = 45,  zMin = -45, zMax = -15 }, -- Top Right
    { xMin = -45, xMax = -15, zMin = 15,  zMax = 45 },  -- Bottom Left
    { xMin = 15,  xMax = 45,  zMin = 15,  zMax = 45 },  -- Bottom Right
    { xMin = -15, xMax = 15,  zMin = -15, zMax = 15 },  -- Center
}

function EnvironmentManager.spawnTrees()
    -- Configure collision parameters to ignore the floor (Baseplate)
    local overlapParams = OverlapParams.new()
    local baseplate = Workspace:WaitForChild("Baseplate", 5)
    if baseplate then
        overlapParams.FilterType = Enum.RaycastFilterType.Exclude
        overlapParams.FilterDescendantsInstances = {baseplate}
    end

    for _, zone in ipairs(SPAWN_ZONES) do
        local randomId = TREE_IDS[math.random(1, #TREE_IDS)]
        
        -- Load the asset model from the Roblox cloud
        local success, loadedModel = pcall(function()
            return InsertService:LoadAsset(randomId)
        end)

        if success and loadedModel then
            -- Extract the tree itself from the InsertService wrapper
            local tree = loadedModel:GetChildren()[1]
            if not tree or not tree:IsA("Model") then
                loadedModel:Destroy()
                continue
            end

            -- 🛡️ ANTI-VIRUS: Remove any scripts from the free model
            for _, desc in pairs(tree:GetDescendants()) do
                if desc:IsA("Script") or desc:IsA("LocalScript") then
                    desc:Destroy()
                end
            end

            -- Anchor all parts so the tree doesn't fall apart
            for _, part in pairs(tree:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = true
                end
            end

            tree.Parent = Workspace
            local boundingBoxCFrame, size = tree:GetBoundingBox()
            
            -- Search for a free spot in the current zone (up to 15 attempts)
            local finalDelta = nil
            for _ = 1, 15 do
                local randomX = math.random(zone.xMin, zone.xMax)
                local randomZ = math.random(zone.zMin, zone.zMax)
                
                -- Calculate so that the bottom of the tree (BoundingBox) touches the floor (Y=1)
                local targetCenterY = 1 + (size.Y / 2) 
                local testCenterCFrame = CFrame.new(randomX, targetCenterY, randomZ)

                -- Check if there's a Leaderboard, spawn, or another tree here
                local partsInside = Workspace:GetPartBoundsInBox(testCenterCFrame, size, overlapParams)

                if #partsInside == 0 then
                    -- Calculate the shift from the original position to the new one
                    finalDelta = testCenterCFrame.Position - boundingBoxCFrame.Position
                    break
                end
            end

            if finalDelta then
                -- Smoothly move the model to the found location
                tree:PivotTo(tree:GetPivot() + finalDelta)
            else
                -- If the zone is completely blocked, delete the tree
                tree:Destroy()
            end
            
            loadedModel:Destroy()
        else
            warn("Failed to load tree with ID: " .. tostring(randomId) .. ". Error: " .. tostring(loadedModel))
        end
    end
end

return EnvironmentManager
