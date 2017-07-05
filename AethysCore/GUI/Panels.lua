--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, AC = ...;
  -- Lua
  local stringformat = string.format;
  local strsplit = strsplit;
  -- File Locals
  AC.GUI = {};
  local GUI = AC.GUI;


--- ============================ CONTENT ============================
--- ======= PRIVATE PANELS FUNCTIONS =======
  -- Find a setting recursively
  local function FindSetting (InitialKey, ...)
    local Keys = {...};
    local SettingTable = InitialKey;
    for i = 1, #Keys-1 do
      SettingTable = SettingTable[Keys[i]];
    end
    return SettingTable, Keys[#Keys];
  end
  -- Filter tooltips based on Optionals input
  local function FilterTooltip (Tooltip, Optionals)
    local Tooltip = Tooltip;
    if Optionals then
      if Optionals["ReloadRequired"] then
        Tooltip = Tooltip .. "\n\n|cFFFF0000This option requires a reload to take effect.|r";
      end
    end
    return Tooltip;
  end
  -- Anchor a tooltip to a frame
  local function AnchorTooltip (Frame, Tooltip)
    Frame:SetScript("OnEnter",
      function (self)
          GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
          GameTooltip:ClearLines();
          GameTooltip:SetBackdropColor(0, 0, 0, 1);
          GameTooltip:SetText(Tooltip, nil, nil, nil, 1, true);
          GameTooltip:Show();
      end
    );
    Frame:SetScript("OnLeave",
      function (self)
        GameTooltip:Hide();
      end
    );
  end
  local LastOptionAttached = {};
  -- Make a check button
  local function CreateCheckButton (Parent, Setting, Text, Tooltip, Optionals)
    -- Constructor
    local CheckButton = CreateFrame("CheckButton", "$parent_"..Setting, Parent, "InterfaceOptionsCheckButtonTemplate");
    Parent[Setting] = CheckButton;
    CheckButton.SettingTable, CheckButton.SettingKey = FindSetting(Parent.SettingsTable, strsplit(".", Setting));
    CheckButton.SavedVariablesTable, CheckButton.SavedVariablesKey = Parent.SavedVariablesTable, Setting;

    -- Frame init
    if not LastOptionAttached[Parent.name] then
      CheckButton:SetPoint("TOPLEFT", 15, -15);
    else
      CheckButton:SetPoint("TOPLEFT", LastOptionAttached[Parent.name][1], "BOTTOMLEFT", LastOptionAttached[Parent.name][2], LastOptionAttached[Parent.name][3]-5);
    end
    LastOptionAttached[Parent.name] = {CheckButton, 0, 0};

    CheckButton:SetChecked(CheckButton.SettingTable[CheckButton.SettingKey]);

    _G[CheckButton:GetName().."Text"]:SetText("|c00dfb802" .. Text .. "|r");

    AnchorTooltip(CheckButton, FilterTooltip(Tooltip, Optionals));

    -- Setting update
    local UpdateSetting;
    if Optionals and Optionals["ReloadRequired"] then
      UpdateSetting = function (self)
        self.SavedVariablesTable[self.SavedVariablesKey] = not self.SettingTable[self.SettingKey];
      end
    else
      UpdateSetting = function (self)
        local NewValue = not self.SettingTable[self.SettingKey];
        self.SettingTable[self.SettingKey] = NewValue;
        self.SavedVariablesTable[self.SavedVariablesKey] = NewValue;
      end
    end
    CheckButton:SetScript("onClick", UpdateSetting);
  end
  -- Make a dropdown
  local function CreateDropdown (Parent, Setting, Values, Text, Tooltip, Optionals)
    -- Constructor
    local Dropdown = CreateFrame("Button", "$parent_"..Setting, Parent, "UIDropDownMenuTemplate")
    Parent[Setting] = Dropdown;
    Dropdown.SettingTable, Dropdown.SettingKey = FindSetting(Parent.SettingsTable, strsplit(".", Setting));
    Dropdown.SavedVariablesTable, Dropdown.SavedVariablesKey = Parent.SavedVariablesTable, Setting;

    -- Setting update
    local UpdateSetting;
    if Optionals and Optionals["ReloadRequired"] then
      UpdateSetting = function (self)
        UIDropDownMenu_SetSelectedID(Dropdown, self:GetID());
        Dropdown.SavedVariablesTable[Dropdown.SavedVariablesKey] = UIDropDownMenu_GetText(Dropdown);
      end
    else
      UpdateSetting = function (self)
        UIDropDownMenu_SetSelectedID(Dropdown, self:GetID());
        local SettingValue = UIDropDownMenu_GetText(Dropdown);
        Dropdown.SettingTable[Dropdown.SettingKey] = SettingValue;
        Dropdown.SavedVariablesTable[Dropdown.SavedVariablesKey] = SettingValue;
      end
    end

    -- Frame init
    if not LastOptionAttached[Parent.name] then
      Dropdown:SetPoint("TOPLEFT", 0, -30);
    else
      Dropdown:SetPoint("TOPLEFT", LastOptionAttached[Parent.name][1], "BOTTOMLEFT", LastOptionAttached[Parent.name][2]-15, LastOptionAttached[Parent.name][3]-25);
    end
    LastOptionAttached[Parent.name] = {Dropdown, 15, 0};

    local function Initialize (Self, Level)
      local Info = UIDropDownMenu_CreateInfo();
      for Key, Value in pairs(Values) do
        Info = UIDropDownMenu_CreateInfo();
        Info.text = Value;
        Info.value = Value;
        Info.func = UpdateSetting;
        UIDropDownMenu_AddButton(Info, Level);
      end
    end
    UIDropDownMenu_Initialize(Dropdown, Initialize);
    UIDropDownMenu_SetSelectedValue(Dropdown, Dropdown.SettingTable[Dropdown.SettingKey]);
    UIDropDownMenu_JustifyText(Dropdown, "LEFT");

    local Title = Dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    Parent[Setting .. "DropdownTitle"] = Title;
    Title:SetPoint("BOTTOMLEFT", Dropdown, "TOPLEFT", 20, 5)
    Title:SetWidth(InterfaceOptionsFramePanelContainer:GetRight() - InterfaceOptionsFramePanelContainer:GetLeft() - 30);
    Title:SetJustifyH("LEFT");
    Title:SetText("|c00dfb802" .. Text .. "|r");

    AnchorTooltip(Dropdown, FilterTooltip(Tooltip, Optionals));
  end
  -- Make a Slider
  local function CreateSlider (Parent, Setting, Values, Text, Tooltip, Optionals)
    -- Constructor
    local Slider = CreateFrame("Slider", "$parent_"..Setting, Parent, "OptionsSliderTemplate");
    Parent[Setting] = Slider;
    Slider.SettingTable, Slider.SettingKey = FindSetting(Parent.SettingsTable, strsplit(".", Setting));
    Slider.SavedVariablesTable, Slider.SavedVariablesKey = Parent.SavedVariablesTable, Setting;

    -- Frame init
    if not LastOptionAttached[Parent.name] then
      Slider:SetPoint("TOPLEFT", 20, -30);
    else
      Slider:SetPoint("TOPLEFT", LastOptionAttached[Parent.name][1], "BOTTOMLEFT", LastOptionAttached[Parent.name][2]+5, LastOptionAttached[Parent.name][3]-25);
    end
    LastOptionAttached[Parent.name] = {Slider, -5, -20};

    Slider:SetMinMaxValues(Values[1], Values[2]);
    Slider.minValue, Slider.maxValue = Slider:GetMinMaxValues() 
    Slider:SetValue(Slider.SettingTable[Slider.SettingKey]);
    Slider:SetValueStep(Values[3]);

    local Name = Slider:GetName();
    _G[Name .. "Low"]:SetText(Slider.minValue);
    _G[Name .. "High"]:SetText(Slider.maxValue);
    _G[Name .. "Text"]:SetText("|c00dfb802" .. Text .. "|r");

    AnchorTooltip(Slider, FilterTooltip(Tooltip, Optionals));

    -- Setting update
    local ShowValue = Slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    Parent[Setting .. "SliderShowValue"] = ShowValue;
    ShowValue:SetPoint("TOP", Slider, "BOTTOM", 0 , 0)
    ShowValue:SetWidth(50);
    ShowValue:SetJustifyH("CENTER");
    ShowValue:SetText(stringformat("%.2f", Slider.SettingTable[Slider.SettingKey]));

    if Optionals and Optionals["ReloadRequired"] then
      UpdateSetting = function (self)
        local Value = self:GetValue();
        self.SavedVariablesTable[self.SavedVariablesKey] = Value;
        ShowValue:SetText(stringformat("%.2f", Value));
      end
    else
      UpdateSetting = function (self)
        local Value = self:GetValue();
        self.SettingTable[self.SettingKey] = Value;
        self.SavedVariablesTable[self.SavedVariablesKey] = Value;
        ShowValue:SetText(stringformat("%.2f", Value));
      end
    end
    Slider:SetScript("OnValueChanged", UpdateSetting);
  end

--- ======= PUBLIC PANELS FUNCTIONS =======
  -- Make a panel
  function GUI.CreatePanel (Parent, Addon, PName, SettingsTable, SavedVariablesTable)
    local Panel = CreateFrame("Frame", Addon .. "_" .. PName, UIParent);
    Parent.Panel = Panel;
    Parent.Panel.Childs = {};
    Parent.Panel.SettingsTable = SettingsTable;
    Parent.Panel.SavedVariablesTable = SavedVariablesTable;
    Panel.name = Addon;
    InterfaceOptions_AddCategory(Panel);
    return Panel;
  end
  -- Make a child panel
  function GUI.CreateChildPanel (Parent, CName)
    local CP = CreateFrame("Frame", Parent:GetName() .. "_ChildPanel_" .. CName, Parent);
    Parent.Childs[CName] = CP;
    CP.Childs = {};
    CP.SettingsTable = Parent.SettingsTable;
    CP.SavedVariablesTable = Parent.SavedVariablesTable;
    CP.name = CName;
    CP.parent = Parent.name;
    InterfaceOptions_AddCategory(CP);
    return CP;
  end
  -- Make a panel option
  local CreatePanelOption = {
    CheckButton = CreateCheckButton,
    Dropdown = CreateDropdown,
    Slider = CreateSlider
  }
  function GUI.CreatePanelOption (Type, ...)
    CreatePanelOption[Type](...);
  end