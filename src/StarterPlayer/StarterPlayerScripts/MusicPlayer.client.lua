--!strict
local SoundService = game:GetService("SoundService")

-- List of classic Roblox tracks (Asset IDs)
local TRACK_LIST = {
    "rbxassetid://9043887091",  -- Working track from Roblox (Synthwave/Retro)
    "rbxassetid://1837879082",  -- Working track from Roblox (Upbeat Electronic)
    "rbxassetid://1848354536",  -- Working track from Roblox (Chill/Ambient)
    "rbxassetid://17422113153", -- Working track from Roblox (Upbeat Electronic)
}

local currentTrackIndex = 1

-- Create a Sound object and parent it to SoundService
local musicPlayer = Instance.new("Sound")
musicPlayer.Name = "BackgroundMusic"
musicPlayer.Volume = 0.3 -- Set volume to 30% so it's not too loud
musicPlayer.Parent = SoundService

local function playNextTrack()
    -- Set the current track and play it
    musicPlayer.SoundId = TRACK_LIST[currentTrackIndex]
    musicPlayer:Play()
    
    -- Calculate the index of the next track
    currentTrackIndex += 1
    if currentTrackIndex > #TRACK_LIST then
        currentTrackIndex = 1 -- Loop back to the beginning of the playlist
    end
end

-- When the current track ends, play the next one
musicPlayer.Ended:Connect(playNextTrack)

-- Play the first track when the player joins
playNextTrack()
