local ADDON_NAME = ...;

local PANEL_NAME = "Quick Chat";
local DROPDOWN_WIDTH = 240;

local category = nil;
local panel = nil;
local dropdown = nil;
local noticeLabel = nil;

---------------------------------------------------------------------------
-- Tab dropdown
---------------------------------------------------------------------------

local function CreateHeader(parent, text, y)
    local header = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, y);
    header:SetText(text);
    return header;
end

local function IsTabSelected(tab)
    local _, resolvedIndex = QC_ResolveTab();
    return tab.index == (resolvedIndex or 1);
end

local function SelectTabOption(tab)
    QC_SetChoice(tab.index, tab.name);
    QC_SelectTab(tab.frame);
    QC_RefreshOptions();
end

local function SetupTabMenu(_, rootDescription)
    for _, tab in ipairs(QC_GetDockedTabs()) do
        local label = tab.name;
        if (tab.index == 1) then
            label = label .. " (default)";
        end
        rootDescription:CreateRadio(label, IsTabSelected, SelectTabOption, tab);
    end
end

function QC_RefreshOptions()
    if (panel == nil) then
        return;
    end

    dropdown:GenerateMenu();

    local _, resolvedIndex = QC_ResolveTab();
    local tabName = QuickChatDB.tabName;
    if (tabName ~= nil and resolvedIndex == nil) then
        noticeLabel:SetText('"' .. tabName .. '" is no longer docked or was renamed. Using General.');
        noticeLabel:Show();
    else
        noticeLabel:Hide();
    end
end

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------

local function CreatePanel()
    panel = CreateFrame("Frame");
    panel.name = PANEL_NAME;

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge");
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16);
    title:SetText(PANEL_NAME);

    local header = CreateHeader(panel, "Default Chat Tab", -52);

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall");
    description:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4);
    description:SetPoint("RIGHT", panel, "RIGHT", -16, 0);
    description:SetJustifyH("LEFT");
    description:SetText("Selected when you log in or reload. Only tabs docked with General are listed. Saved per character.");

    dropdown = CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate");
    dropdown:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -12);
    dropdown:SetWidth(DROPDOWN_WIDTH);
    dropdown:SetupMenu(SetupTabMenu);

    noticeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal");
    noticeLabel:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -12);
    noticeLabel:SetTextColor(RED_FONT_COLOR:GetRGB());
    noticeLabel:Hide();

    panel:SetScript("OnShow", QC_RefreshOptions);
    panel.OnRefresh = QC_RefreshOptions;
    panel.OnCommit = function() end;
    panel.OnDefault = function()
        QC_SetChoice(nil, nil);
        QC_RefreshOptions();
    end;

    category = Settings.RegisterCanvasLayoutCategory(panel, PANEL_NAME);
    Settings.RegisterAddOnCategory(category);
end

local loader = CreateFrame("Frame");
loader:RegisterEvent("ADDON_LOADED");
loader:SetScript("OnEvent", function(self, _, addonName)
    if (addonName ~= ADDON_NAME) then
        return;
    end
    self:UnregisterEvent("ADDON_LOADED");

    QC_InitDB();
    CreatePanel();
    QC_RefreshOptions();
end)

SLASH_QUICKCHAT1 = "/quickchat";
SLASH_QUICKCHAT2 = "/qchat";
SlashCmdList["QUICKCHAT"] = function()
    if (category ~= nil) then
        Settings.OpenToCategory(category:GetID());
    end
end
