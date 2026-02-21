-- budsAuction (WotLK 3.3.5a)
-- UI.lua: Frame rendering, autocomplete, list rendering

local addonName, addonTable = ...

function budsAuction:SetupAuctionUIIntegration()
    print("|cFF00FF00budsAuction|r: Attached to Blizzard_AuctionUI.")
    
    self:CreateMainUI()
    
    -- When AuctionFrame is shown, show our addon; hide when it hides
    AuctionFrame:HookScript("OnShow", function() self.mainFrame:Show() end)
    AuctionFrame:HookScript("OnHide", function() self.mainFrame:Hide() end)
end

function budsAuction:CreateMainUI()
    -- Create Main Frame
    local frame = CreateFrame("Frame", "budsAuctionMainFrame", AuctionFrame)
    frame:SetSize(250, 428) -- Width reasonable for a list, height matching WoW Classic AH roughly
    frame:SetPoint("TOPLEFT", AuctionFrame, "TOPRIGHT", -2, -12)
    
    -- Basic 3.3.5a Backdrop (Dark/Translucent flat style like KkthnxUI/budsUI)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Make it optionally draggable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        if budsAuctionDB.unlocked then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    -- Title Text
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -10)
    title:SetText("budsAuction")

    -- Close Button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 1, 1)
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Unlock Button (Toggle Dragging)
    local unlockBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    unlockBtn:SetSize(60, 20)
    unlockBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -5)
    unlockBtn:SetText("Unlock")
    unlockBtn:SetScript("OnClick", function(self)
        budsAuctionDB.unlocked = not budsAuctionDB.unlocked
        if budsAuctionDB.unlocked then
            self:SetText("Lock")
            print("|cFF00FF00budsAuction|r: Frame is now draggable.")
        else
            self:SetText("Unlock")
            print("|cFF00FF00budsAuction|r: Frame is now locked.")
            -- unlock text reset
            -- Re-anchor
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", AuctionFrame, "TOPRIGHT", -2, -12)
        end
    end)

    -- Item Input EditBox
    local editBox = CreateFrame("EditBox", "budsAuctionInput", frame, "InputBoxTemplate")
    editBox:SetSize(160, 20)
    editBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -35)
    editBox:SetAutoFocus(false)

    -- Add / Save Button
    local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    addBtn:SetSize(50, 20)
    addBtn:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
    addBtn:SetText("Add")
    addBtn:SetScript("OnClick", function()
        local text = editBox:GetText()
        if text and text ~= "" then
            budsAuction:AddItem(text)
            editBox:SetText("")
            editBox:ClearFocus()
        end
    end)
    -- Also allow Enter key to add
    editBox:SetScript("OnEnterPressed", function(self)
        addBtn:Click()
    end)

    -- Auto-complete dropdown container
    local acFrame = CreateFrame("Frame", "budsAuctionAutoComplete", editBox, "UIDropDownMenuTemplate")
    acFrame:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", -15, 0)
    
    local function GetBagItemsMatching(matchStr)
        local results = {}
        matchStr = strlower(matchStr)
        for bag = 0, 4 do
            for slot = 1, GetContainerNumSlots(bag) do
                local itemLink = GetContainerItemLink(bag, slot)
                if itemLink then
                    local itemName = GetItemInfo(itemLink)
                    if itemName and string.find(strlower(itemName), matchStr) then
                        results[itemName] = true
                    end
                end
            end
        end
        
        local out = {}
        for k in pairs(results) do table.insert(out, k) end
        return out
    end

    editBox:HookScript("OnTextChanged", function(self, isUserInput)
        if not isUserInput then return end
        local text = self:GetText()
        if text and string.len(text) > 1 then
            local matches = GetBagItemsMatching(text)
            if #matches > 0 then
                -- Build DropDown
                local function InitializeDropDown(self, level)
                    for _, val in ipairs(matches) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = val
                        info.func = function()
                            editBox:SetText(val)
                            addBtn:Click()
                            CloseDropDownMenus()
                        end
                        info.notCheckable = true
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
                UIDropDownMenu_Initialize(acFrame, InitializeDropDown, "MENU")
                ToggleDropDownMenu(1, nil, acFrame, editBox, 0, 0)
            else
                CloseDropDownMenus()
            end
        else
            CloseDropDownMenus()
        end
    end)

    -- ScrollFrame for Item List
    local scrollFrame = CreateFrame("ScrollFrame", "budsAuctionScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", -5, -15)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(200, 10) -- Height will expand dynamically
    scrollFrame:SetScrollChild(scrollChild)
    self.scrollChild = scrollChild

    -- Table to hold the row frames
    self.listFrames = {}

    -- Save references
    self.mainFrame = frame
    
    -- Populate the initial list
    self:RefreshList()
    
    -- Initially visible if AuctionFrame is already visible (which it should be when ADDON_LOADED fires for AH)
    if AuctionFrame:IsVisible() then
        frame:Show()
    else
        frame:Hide()
    end
end

function budsAuction:RefreshList()
    -- Hide old frames
    for _, row in ipairs(self.listFrames) do
        row:Hide()
    end
    
    local rowHeight = 24
    local numItems = #budsAuctionDB.items
    if not self.scrollChild then return end -- Guard
    self.scrollChild:SetHeight(math.max(10, numItems * rowHeight))
    
    for i, itemName in ipairs(budsAuctionDB.items) do
        local row = self.listFrames[i]
        
        if not row then
            row = CreateFrame("Button", nil, self.scrollChild)
            row:SetSize(200, rowHeight)
            
            -- Delete Button (Right)
            local delBtn = CreateFrame("Button", nil, row)
            delBtn:SetSize(16, 16)
            delBtn:SetPoint("RIGHT", row, "RIGHT", -2, 0)
            delBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
            delBtn:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight", "ADD")
            
            -- Edit Button (Left of Delete)
            local editBtn = CreateFrame("Button", nil, row)
            editBtn:SetSize(16, 16)
            editBtn:SetPoint("RIGHT", delBtn, "LEFT", -2, 0)
            editBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
            editBtn:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton-Highlight", "ADD")
            
            -- Icon (Left)
            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(20, 20)
            icon:SetPoint("LEFT", row, "LEFT", 2, 0)
            
            -- TexName (Middle)
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            nameText:SetPoint("LEFT", icon, "RIGHT", 5, 0)
            nameText:SetPoint("RIGHT", editBtn, "LEFT", -5, 0)
            nameText:SetJustifyH("LEFT")
            nameText:SetWordWrap(false)
            
            -- Row Interaction (CTRL+LeftClick to AH)
            row:RegisterForClicks("LeftButtonUp")
            row:SetScript("OnClick", function(self)
                if IsControlKeyDown() then
                    if BrowseName and AuctionFrameBrowse_Search then
                        BrowseName:SetText(self.itemName)
                        AuctionFrameBrowse_Search()
                    end
                end
            end)
            
            row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
            
            row.icon = icon
            row.nameText = nameText
            row.delBtn = delBtn
            row.editBtn = editBtn
            table.insert(self.listFrames, row)
        end
        
        -- Update Data
        row.itemName = itemName
        row.nameText:SetText(itemName)
        
        row.delBtn:SetScript("OnClick", function()
            budsAuction:RemoveItem(i)
        end)
        
        row.editBtn:SetScript("OnClick", function()
            budsAuctionInput:SetText(itemName)
            budsAuction:RemoveItem(i)
        end)
        
        -- Try to fetch icon
        local itemNameInfo, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemName)
        if itemTexture then
            row.icon:SetTexture(itemTexture)
        else
            -- Check standard question mark if API hasn't cached it
            row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end
        
        row:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 0, -(i-1)*rowHeight)
        row:Show()
    end
end
