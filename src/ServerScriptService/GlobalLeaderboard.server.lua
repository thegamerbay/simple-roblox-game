--!strict
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local leaderboardStore = DataStoreService:GetOrderedDataStore("GlobalCoinLeaderboard")

-- 1. NEW: Create a glowing neon background (Glow Frame)
local glowFrame = Instance.new("Part")
glowFrame.Name = "LeaderboardGlow"
-- Make the frame slightly wider and taller than the main board, but thinner
glowFrame.Size = Vector3.new(15.4, 12.4, 0.5) 
glowFrame.Position = Vector3.new(0, 6, -20.2) -- Place 0.2 studs behind the main board
glowFrame.Anchored = true
glowFrame.BrickColor = BrickColor.new("Deep orange") -- Beautiful golden-orange color for coins
glowFrame.Material = Enum.Material.Neon -- The material that makes the object glow
glowFrame.Parent = Workspace

-- 2. Create the physical board in the world (Black screen)
local board = Instance.new("Part")
board.Name = "LeaderboardBoard"
board.Size = Vector3.new(15, 12, 1)
board.Position = Vector3.new(0, 6, -20)
board.Anchored = true
board.BrickColor = BrickColor.new("Really black")
board.Material = Enum.Material.SmoothPlastic
board.Parent = Workspace

-- 3. Function to create the screen interface on a specific face
local listFrames = {} -- Store references to the scrolling frames to update them later

local function createBoardUI(face: Enum.NormalId)
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = face
    surfaceGui.Parent = board

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.Text = "🏆 TOP 20 COIN COLLECTORS 🏆"
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1, 0.8, 0)
    title.BackgroundTransparency = 1
    title.Parent = surfaceGui

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 0.85, 0)
    listFrame.Position = UDim2.new(0, 0, 0.15, 0)
    listFrame.BackgroundTransparency = 1
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Automatic scroll
    listFrame.Parent = surfaceGui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = listFrame
    
    table.insert(listFrames, listFrame)
end

-- Create UI for both sides
createBoardUI(Enum.NormalId.Front)
createBoardUI(Enum.NormalId.Back)

-- 4. Function to update the list
local function updateBoard()
    -- Request the top 20 results, sorted in descending order
    local success, pages = pcall(function()
        return leaderboardStore:GetSortedAsync(false, 20)
    end)

    if success and pages then
        -- Destroy old rows from all boards
        for _, frame in ipairs(listFrames) do
            for _, child in pairs(frame:GetChildren()) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
        end

        -- Read the first page of results
        local topData = pages:GetCurrentPage()
        
        for rank, data in ipairs(topData) do
            local userId = tonumber(data.key)
            local coins = data.value
            local username = "Unknown"

            -- Convert UserId back to a readable player username
            pcall(function()
                username = Players:GetNameFromUserIdAsync(userId)
            end)

            -- Create a new row in all lists
            for _, frame in ipairs(listFrames) do
                local entry = Instance.new("TextLabel")
                entry.Size = UDim2.new(1, 0, 0, 45)
                entry.Text = "#" .. tostring(rank) .. "  " .. username .. "  -  " .. tostring(coins)
                entry.TextScaled = true
                entry.Font = Enum.Font.Gotham
                entry.TextColor3 = Color3.new(1, 1, 1)
                entry.BackgroundTransparency = 1
                entry.Parent = frame
            end
        end
    end
end

-- 5. Start an infinite update loop in a separate thread
task.spawn(function()
    while true do
        updateBoard()
        task.wait(60) -- Update every 60 seconds
    end
end)
