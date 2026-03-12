--!strict
local MusicPlayer = {}
local SoundService = game:GetService("SoundService")

MusicPlayer.TRACK_LIST = {
    "rbxassetid://9043887091",  -- Working track from Roblox (Synthwave/Retro)
    "rbxassetid://1837879082",  -- Working track from Roblox (Upbeat Electronic)
    "rbxassetid://1848354536",  -- Working track from Roblox (Chill/Ambient)
    "rbxassetid://17422113153", -- Working track from Roblox (Upbeat Electronic)
}

function MusicPlayer.init()
    MusicPlayer.currentTrackIndex = 1
    
    local musicPlayer = Instance.new("Sound")
    musicPlayer.Name = "BackgroundMusic"
    musicPlayer.Volume = 0.3
    musicPlayer.Parent = SoundService
    
    MusicPlayer.sound = musicPlayer
    
    MusicPlayer.connection = musicPlayer.Ended:Connect(function()
        MusicPlayer.playNextTrack()
    end)
    
    MusicPlayer.playNextTrack()
end

function MusicPlayer.playNextTrack()
    if not MusicPlayer.sound then return end
    
    MusicPlayer.sound.SoundId = MusicPlayer.TRACK_LIST[MusicPlayer.currentTrackIndex]
    MusicPlayer.sound:Play()
    
    MusicPlayer.currentTrackIndex += 1
    if MusicPlayer.currentTrackIndex > #(MusicPlayer.TRACK_LIST) then
        MusicPlayer.currentTrackIndex = 1
    end
end

return MusicPlayer
