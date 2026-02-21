-- budsAuction (WotLK 3.3.5a)
-- Core.lua: Initialization, DB management, and Events

-- Global ref
if not budsAuction then
    budsAuction = CreateFrame("Frame", "budsAuctionEventFrame", UIParent)
end

local defaultSettings = {
    listLimit = 35,
    fontSize = 12,
    unlocked = false,
    items = {} -- Array of item names for the quick-access list
}

function budsAuction:Initialize()
    -- Init DB
    if not budsAuctionDB then
        budsAuctionDB = CopyTable(defaultSettings)
    end
    
    -- Ensure backwards compatibility if adding new settings
    for k, v in pairs(defaultSettings) do
        if budsAuctionDB[k] == nil then
            if type(v) == "table" then
                budsAuctionDB[k] = CopyTable(v)
            else
                budsAuctionDB[k] = v
            end
        end
    end

    self:CreateOptionsPanel()
    
    -- Register Slash Commands
    SLASH_BUDSAUCTION1 = "/budsauction"
    SLASH_BUDSAUCTION2 = "/ba"
    SlashCmdList["BUDSAUCTION"] = function(msg)
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
        InterfaceOptionsFrame_OpenToCategory(self.optionsPanel) -- Called twice in 3.3.5 to bypass an old bug
    end

    self:RegisterEvent("ADDON_LOADED")
    self:SetScript("OnEvent", self.OnEvent)
end

function budsAuction:OnEvent(event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_AuctionUI" then
            self:SetupAuctionUIIntegration()
        end
    end
end

-- Wait for variables to load before doing anything
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("VARIABLES_LOADED")
loginFrame:SetScript("OnEvent", function(self, event)
    if event == "VARIABLES_LOADED" then
        budsAuction:Initialize()
        self:UnregisterEvent("VARIABLES_LOADED")
    end
end)

-- Item Management Functions
function budsAuction:AddItem(itemName)
    -- Deduplication and Limit check
    if #budsAuctionDB.items >= budsAuctionDB.listLimit then
        print("|cFFFF0000budsAuction|r: List limit reached ("..budsAuctionDB.listLimit.."). Remove items or increase limit.")
        return
    end
    
    for _, item in ipairs(budsAuctionDB.items) do
        if strlower(item) == strlower(itemName) then
            print("|cFFFFFF00budsAuction|r: Item already in list.")
            return
        end
    end
    
    table.insert(budsAuctionDB.items, itemName)
    self:RefreshList()
end

function budsAuction:RemoveItem(index)
    if budsAuctionDB.items[index] then
        table.remove(budsAuctionDB.items, index)
        self:RefreshList()
    end
end
