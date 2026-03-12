-- selene:allow(undefined_variable)
return function()
    local ClientShop = require(script.Parent.ClientShop)

    describe("ClientShop Initialization", function()
        it("should expose an init function", function()
            expect(type(ClientShop.init)).to.equal("function")
            -- We cannot fully mock the LocalPlayer, PlayerGui, and RemoteFunction 
            -- behavior purely in TestEZ without an extensive mocking architecture 
            -- simulating the client environment. However, verifying the module
            -- loads and exposes its init ensures there are no syntax errors.
        end)
    end)
end
