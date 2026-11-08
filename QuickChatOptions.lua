local ADDON_NAME = ...;

local MISSING_TAB = 0;

local category = nil;

---------------------------------------------------------------------------
-- Tab dropdown
---------------------------------------------------------------------------

local function IsTabMissing()
    local _, resolvedIndex = QC_ResolveTab();
    return QuickChatDB.tabName ~= nil and resolvedIndex == nil;
end

local function GetTabValue()
    if (IsTabMissing()) then
        return MISSING_TAB;
    end
    local _, resolvedIndex = QC_ResolveTab();
    return resolvedIndex or 1;
end

local function SetTabValue(index)
    if (index == MISSING_TAB) then
        return;
    end
    for _, tab in ipairs(QC_GetDockedTabs()) do
        if (tab.index == index) then
            QC_SetChoice(tab.index, tab.name);
            QC_SelectTab(tab.frame);
            return;
        end
    end
end

local function GetTabOptions()
    local container = Settings.CreateControlTextContainer();
    if (IsTabMissing()) then
        container:Add(MISSING_TAB, '"' .. QuickChatDB.tabName .. '" (not docked, using General)');
    end
    for _, tab in ipairs(QC_GetDockedTabs()) do
        local label = tab.name;
        if (tab.index == 1) then
            label = label .. " (default)";
        end
        container:Add(tab.index, label);
    end
    return container:GetData();
end

local function GetTabTooltip()
    local tooltip = "Selected when you log in or reload. Only tabs docked with General are listed. Saved per character.";
    if (IsTabMissing()) then
        tooltip = tooltip .. "\n\n" .. RED_FONT_COLOR:WrapTextInColorCode('"' .. QuickChatDB.tabName .. '" is no longer docked or was renamed. Using General.');
    end
    return tooltip;
end

---------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------

local function CreateSettings()
    category = QuickAddons:RegisterVerticalSubcategory("Chat");

    local setting = Settings.RegisterProxySetting(category, "QuickChat_DefaultTab", Settings.VarType.Number, "Default Chat Tab", 1, GetTabValue, SetTabValue);
    Settings.CreateDropdown(category, setting, GetTabOptions, GetTabTooltip);

    QuickAddons:RegisterMember(ADDON_NAME, "Chat", "Choose which chat tab is selected when you log in or reload.", category);
end

local loader = CreateFrame("Frame");
loader:RegisterEvent("ADDON_LOADED");
loader:SetScript("OnEvent", function(self, _, addonName)
    if (addonName ~= ADDON_NAME) then
        return;
    end
    self:UnregisterEvent("ADDON_LOADED");

    QC_InitDB();
    CreateSettings();
end)

SLASH_QUICKCHAT1 = "/quickchat";
SLASH_QUICKCHAT2 = "/qchat";
SlashCmdList["QUICKCHAT"] = function()
    if (category ~= nil) then
        Settings.OpenToCategory(category:GetID());
    end
end
