-- budsAuction (WotLK 3.3.5a)
-- Options.lua: Interface options and slash cmds

local addonName, addonTable = ...

function budsAuction:CreateOptionsPanel()
    local panel = CreateFrame("Frame", "budsAuctionOptionsPanel", UIParent)
    panel.name = "budsAuction"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("budsAuction Options")
    
    local limitSlider = CreateFrame("Slider", "budsAuctionLimitSlider", panel, "OptionsSliderTemplate")
    limitSlider:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -30)
    limitSlider:SetMinMaxValues(10, 100)
    limitSlider:SetValueStep(1)
    limitSlider:SetValue(budsAuctionDB.listLimit)
    
    _G[limitSlider:GetName() .. "Low"]:SetText("10")
    _G[limitSlider:GetName() .. "High"]:SetText("100")
    _G[limitSlider:GetName() .. "Text"]:SetText("List Limit: " .. budsAuctionDB.listLimit)
    
    limitSlider:SetScript("OnValueChanged", function(self, value)
        local val = math.floor(value + 0.5)
        budsAuctionDB.listLimit = val
        _G[self:GetName() .. "Text"]:SetText("List Limit: " .. val)
    end)

    local fontSlider = CreateFrame("Slider", "budsAuctionFontSlider", panel, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", limitSlider, "BOTTOMLEFT", 0, -40)
    fontSlider:SetMinMaxValues(8, 24)
    fontSlider:SetValueStep(1)
    fontSlider:SetValue(budsAuctionDB.fontSize or 12)
    
    _G[fontSlider:GetName() .. "Low"]:SetText("8")
    _G[fontSlider:GetName() .. "High"]:SetText("24")
    _G[fontSlider:GetName() .. "Text"]:SetText("Font Size: " .. (budsAuctionDB.fontSize or 12))
    
    fontSlider:SetScript("OnValueChanged", function(self, value)
        local val = math.floor(value + 0.5)
        if val == budsAuctionDB.fontSize then return end
        budsAuctionDB.fontSize = val
        _G[self:GetName() .. "Text"]:SetText("Font Size: " .. val)
        if budsAuction and budsAuction.RefreshList then
            budsAuction:RefreshList()
        end
    end)
    
    -- Optional Reload Button to apply constraints immediately 
    local reloadBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reloadBtn:SetSize(120, 25)
    reloadBtn:SetPoint("TOPLEFT", fontSlider, "BOTTOMLEFT", 0, -30)
    reloadBtn:SetText("Reload UI")
    reloadBtn:SetScript("OnClick", function() ReloadUI() end)
    
    InterfaceOptions_AddCategory(panel)
    self.optionsPanel = panel
end
