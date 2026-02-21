-- budsAuction (WotLK 3.3.5a)
-- Hooks.lua: Manages hooks into blizzard functions like bag clicks

local addonName, addonTable = ...

-- Wait until ADDON_LOADED to ensure function is defined
local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_LOGIN")
hookFrame:SetScript("OnEvent", function(self, event)
    -- Hook Bag clicks for quick-add (CTRL+Click)
    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", function(selfButton, button)
        if IsControlKeyDown() and button == "LeftButton" then
            local bagID = selfButton:GetParent():GetID()
            local slotID = selfButton:GetID()
            local itemLink = GetContainerItemLink(bagID, slotID)
            
            if itemLink then
                local itemName = GetItemInfo(itemLink)
                if itemName and budsAuction and budsAuction.AddItem then
                    budsAuction:AddItem(itemName)
                    return
                end
            end
        end
    end)
    self:UnregisterEvent("PLAYER_LOGIN")
end)
