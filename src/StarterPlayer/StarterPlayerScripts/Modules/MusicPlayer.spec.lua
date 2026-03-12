-- selene:allow(undefined_variable)
return function()
    local MusicPlayer = require(script.Parent.MusicPlayer)
    local SoundService = game:GetService("SoundService")

    describe("MusicPlayer Initialization", function()
        it("should initialize and create a Sound object", function()
            MusicPlayer.init()
            local sound = SoundService:FindFirstChild("BackgroundMusic")
            expect(sound).to.be.ok()
            expect(sound.Volume).to.equal(0.3)
            
            -- cleanup
            if sound then sound:Destroy() end
            if MusicPlayer.connection then MusicPlayer.connection:Disconnect() end
        end)
    end)
    
    describe("MusicPlayer.playNextTrack", function()
        it("should play tracks in order", function()
            MusicPlayer.init()
            
            -- The init calls playNextTrack, so index should be 2 now
            expect(MusicPlayer.currentTrackIndex).to.equal(2)
            expect(MusicPlayer.sound.SoundId).to.equal(MusicPlayer.TRACK_LIST[1])
            
            -- call again manually
            MusicPlayer.playNextTrack()
            expect(MusicPlayer.currentTrackIndex).to.equal(3)
            expect(MusicPlayer.sound.SoundId).to.equal(MusicPlayer.TRACK_LIST[2])
            
            local sound = SoundService:FindFirstChild("BackgroundMusic")
            if sound then sound:Destroy() end
            if MusicPlayer.connection then MusicPlayer.connection:Disconnect() end
        end)
    end)
end
