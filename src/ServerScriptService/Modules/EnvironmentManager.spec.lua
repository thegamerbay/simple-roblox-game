-- selene:allow(undefined_variable)
return function()
    local EnvironmentManager = require(script.Parent.EnvironmentManager)

    describe("EnvironmentManager.spawnTrees", function()
        it("should execute safely without any unhandled errors", function()            
            -- Since InsertService:LoadAsset is wrapped in a pcall inside the script,
            -- this test verifies that the iteration over zones and the error handling
            -- works as intended without throwing fatal runtime errors, even if LoadAsset fails (e.g., in a CI environment).
            expect(function()
                EnvironmentManager.spawnTrees()
            end).never.to.throw()
        end)
    end)
end
