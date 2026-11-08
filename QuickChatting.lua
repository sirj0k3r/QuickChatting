function QC_InitDB()
    if (type(QuickChattingDB) ~= "table") then
        QuickChattingDB = {};
    end

    local frameIndex = QuickChattingDB.frameIndex;
    local tabName = QuickChattingDB.tabName;
    if (type(frameIndex) ~= "number" or frameIndex < 1 or frameIndex > NUM_CHAT_WINDOWS or frameIndex ~= math.floor(frameIndex)
        or type(tabName) ~= "string" or tabName == "") then
        QuickChattingDB.frameIndex = nil;
        QuickChattingDB.tabName = nil;
    end
end

---------------------------------------------------------------------------
-- Docked tabs
---------------------------------------------------------------------------

local function GetTabName(index, frame, name)
    if (name == nil or name == "") then
        name = frame.name;
    end
    if (name == nil or name == "") then
        name = "Chat " .. index;
    end
    return name;
end

function QC_GetDockedTabs()
    local tabs = {};

    if (GENERAL_CHAT_DOCK and FCFDock_GetChatFrames) then
        for _, frame in ipairs(FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)) do
            local index = frame:GetID();
            if (not frame.isTemporary and index >= 1 and index <= NUM_CHAT_WINDOWS) then
                local name = GetChatWindowInfo(index);
                tabs[#tabs + 1] = { index = index, name = GetTabName(index, frame, name), frame = frame };
            end
        end
        return tabs;
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local name, _, _, _, _, _, shown, _, docked = GetChatWindowInfo(i);
        local frame = _G["ChatFrame" .. i];
        if (frame and (i == 1 or (docked and (shown or frame.isDocked)))) then
            tabs[#tabs + 1] = { index = i, name = GetTabName(i, frame, name), frame = frame };
        end
    end
    return tabs;
end

---------------------------------------------------------------------------
-- Choice
---------------------------------------------------------------------------

function QC_ResolveTab()
    if (type(QuickChattingDB) ~= "table") then
        return nil;
    end
    local tabName = QuickChattingDB.tabName;
    if (tabName == nil) then
        return nil;
    end

    local tabs = QC_GetDockedTabs();
    for _, tab in ipairs(tabs) do
        if (tab.index == QuickChattingDB.frameIndex and tab.name == tabName) then
            return tab.frame, tab.index;
        end
    end
    for _, tab in ipairs(tabs) do
        if (tab.name == tabName) then
            QuickChattingDB.frameIndex = tab.index;
            return tab.frame, tab.index;
        end
    end
    return nil;
end

function QC_SetChoice(index, name)
    if (index == nil or index == 1) then
        QuickChattingDB.frameIndex = nil;
        QuickChattingDB.tabName = nil;
    else
        QuickChattingDB.frameIndex = index;
        QuickChattingDB.tabName = name;
    end
end

function QC_SelectTab(frame)
    if (frame and FCF_SelectDockFrame and GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.selected ~= frame) then
        FCF_SelectDockFrame(frame);
    end
end

function QC_ApplyChoice()
    local frame = QC_ResolveTab();
    if (frame) then
        QC_SelectTab(frame);
    end
end

---------------------------------------------------------------------------
-- Login / reload
---------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:SetScript("OnEvent", function(self, _, isInitialLogin, isReloadingUi)
    if (not isInitialLogin and not isReloadingUi) then
        return;
    end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");

    C_Timer.After(0, QC_ApplyChoice);
    C_Timer.After(1, function()
        if (GENERAL_CHAT_DOCK and GENERAL_CHAT_DOCK.selected == ChatFrame1 and QC_ResolveTab()) then
            QC_ApplyChoice();
        end
    end);
end);
