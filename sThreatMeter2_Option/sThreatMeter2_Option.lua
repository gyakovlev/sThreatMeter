--[[
	
	sThreatMeter2_Option
	Copyright (c) 2010, Nils Ruesch
	All rights reserved.
	
]]

local function L(string)
	local getlocale = GetLocale();
	if ( sThreatMeter_locale[getlocale] and sThreatMeter_locale[getlocale][string] ) then
		if ( type(sThreatMeter_locale[getlocale][string]) == "string" ) then
			return sThreatMeter_locale[getlocale][string];
		else
			return string;
		end
	elseif ( sThreatMeter_locale["default"] and sThreatMeter_locale["default"][string] ) then
		if ( type(sThreatMeter_locale["default"][string]) == "string" ) then
			return sThreatMeter_locale["default"][string];
		else
			return string;
		end
	else
		return "Error...";
	end
end

local SML = LibStub and LibStub("LibSharedMedia-3.0", true) or nil;

local font, fontsize, fontflags = GameFontNormalSmallLeft:GetFont();

local standardfont = {
	["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF",
	["Arial Narrow"] = "Fonts\\ARIALN.TTF",
	["Skurri"] = "Fonts\\SKURRI.TTF",
	["Morpheus"] = "Fonts\\MORPHEUS.TTF",
};

local testthreat;

local function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function short_value(value)
	local strLen = strlen(value);
	local retString = value;
	if ( strLen > 6 ) then
		retString = string.sub(value, 1, -7)..SECOND_NUMBER_CAP;
	elseif ( strLen > 3 ) then
		retString = string.sub(value, 1, -4)..FIRST_NUMBER_CAP;
	end
	return retString;
end


local function ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local frame = CreateFrame("Frame", "sThreatMeter2_Option");
frame.name = "sThreatMeter2";
InterfaceOptions_AddCategory(frame);

local fontoption = CreateFrame("Frame", "sThreatMeter2_OptionFont");
fontoption.name = L("Text");
fontoption.parent = "sThreatMeter2";
InterfaceOptions_AddCategory(fontoption);

local function UpdateBars(msg, toggle)
	local bar, text, r, g, b;
	if ( msg ~= "test" or toggle ) then
		for i=1, 10, 1 do
			bar = _G["sThreatMeter2_OptionBar"..i];
			if ( bar ) then
				bar:Hide();
			end
		end
	end
	for i=1, 10, 1 do
		bar = _G["sThreatMeterBar"..i];
		if ( bar ) then
			bar:SetWidth(TukuiDB.Scale(sThreatMeter_Data.Width));
			bar:SetHeight(TukuiDB.Scale(sThreatMeter_Data.Height));
			bar:SetStatusBarTexture(sThreatMeter_Data.Texture);
			if ( type(sThreatMeter_Data.Color) == "table" ) then
				bar:SetStatusBarColor(unpack(sThreatMeter_Data.Color));
			end
			bar:ClearAllPoints();
			if ( i == 1 ) then
				bar:SetPoint("TOP", sThreatMeter);
			else
				if ( sThreatMeter_Data.Direction == "down" ) then
					bar:SetPoint("TOP", _G["sThreatMeterBar"..i-1], "BOTTOM", 0, TukuiDB.Scale(-sThreatMeter_Data.Spacing));
				elseif ( sThreatMeter_Data.Direction == "right" ) then
					bar:SetPoint("LEFT", _G["sThreatMeterBar"..i-1], "RIGHT", TukuiDB.Scale(sThreatMeter_Data.Spacing), 0);
				elseif ( sThreatMeter_Data.Direction == "left" ) then
					bar:SetPoint("RIGHT", _G["sThreatMeterBar"..i-1], "LEFT", TukuiDB.Scale(-sThreatMeter_Data.Spacing), 0);
				else
					bar:SetPoint("BOTTOM", _G["sThreatMeterBar"..i-1], "TOP", 0, TukuiDB.Scale(sThreatMeter_Data.Spacing));
				end
			end
			bar.background:SetTexture(sThreatMeter_Data.Texture);
			bar.background:SetVertexColor(unpack(sThreatMeter_Data.BackgroundColor));
			bar.textright:SetFont(unpack(sThreatMeter_Data.Font));
			bar.textright:SetShadowColor(0, 0, 0, sThreatMeter_Data.FontShadowAlpha);
			bar.textleft:SetFont(unpack(sThreatMeter_Data.Font));
			bar.textleft:SetShadowColor(0, 0, 0, sThreatMeter_Data.FontShadowAlpha);
		end
	end
	testthreat = {
		{ name = "Test1", class = "WARRIOR", scaledPercent = 100, threatValue = 1000000 },
		{ name = "Test2", class = "DRUID", scaledPercent = 90, threatValue = 500000 },
		{ name = "Test3", class = "HUNTER", scaledPercent = 80, threatValue = 10000 },
		{ name = "Test4", class = "MAGE", scaledPercent = 70, threatValue = 1000 },
		{ name = "Test5", class = "SHAMAN", scaledPercent = 60, threatValue = 700 },
		{ name = "Test6", class = "WARLOCK", scaledPercent = 50, threatValue = 400 },
		{ name = "Test7", class = "DEATHKNIGHT", scaledPercent = 40, threatValue = 300 },
		{ name = "Test8", class = "PRIEST", scaledPercent = 30, threatValue = 200 },
		{ name = "Test2: Pet1", class = "HUNTER", scaledPercent = 20, threatValue = 100 },
		{ name = "Test10", class = "PALADIN", scaledPercent = 10, threatValue = 50 },
	};
	table.sort(testthreat, function(a, b)
		if ( sThreatMeter_Data.Direction == "down" or sThreatMeter_Data.Direction == "right" ) then
			return a.scaledPercent > b.scaledPercent;
		end
		return a.scaledPercent < b.scaledPercent;
	end);
	if ( sThreatMeter_Data.Direction == "up" or sThreatMeter_Data.Direction == "left" ) then
		local menge = #testthreat;
		for i=1, (menge - sThreatMeter_Data.Bars), 1 do
			tremove(testthreat, 1);
		end
	end
	
	for i=1, sThreatMeter_Data.Bars, 1 do
		bar = _G["sThreatMeter2_OptionBar"..i];
		if ( not bar ) then
			bar = CreateFrame("StatusBar", "sThreatMeter2_OptionBar"..i, UIParent);
			bar:SetMinMaxValues(0, 100);
			bar:EnableMouse(1);
			bar:RegisterForDrag("LeftButton");
			bar:SetScript("OnDragStart", function(self)
				sThreatMeter:StartMoving();
			end);
			bar:SetScript("OnDragStop", function(self)
				sThreatMeter:StopMovingOrSizing();
				sThreatMeter_Data.Point = { sThreatMeter:GetPoint() };
			end);
			bar:Hide();
			
			bar.bg = CreateFrame("Frame","$parentBG",bar)
			bar.bg:SetPoint("TOPLEFT", bar, "TOPLEFT",TukuiDB.Scale(-2),TukuiDB.Scale(2))
			bar.bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT",TukuiDB.Scale(2),TukuiDB.Scale(-2))
			bar.bg:SetFrameStrata"LOW"
			TukuiDB.SetTemplate(bar.bg)

			bar.background = bar:CreateTexture("$parentBackground", "BACKGROUND");
			bar.background:SetAllPoints();
			bar.background:Hide();
						
			bar.textright = bar:CreateFontString("$parentTextRight", "ARTWORK");
			bar.textright:SetShadowOffset(1, -1);
			bar.textright:SetJustifyH("RIGHT");
			bar.textright:SetPoint("RIGHT", -1, 1);
			
			bar.textleft = bar:CreateFontString("$parentTextLeft", "ARTWORK");
			bar.textleft:SetShadowOffset(1, -1);
			bar.textleft:SetJustifyH("LEFT");
			bar.textleft:SetPoint("LEFT", TukuiDB.Scale(1), TukuiDB.Scale(1));
			bar.textleft:SetPoint("RIGHT", bar.textright, "LEFT", (-1), TukuiDB.Scale(1));
		end
		
		bar:SetValue(testthreat[i].scaledPercent);
		bar:SetWidth(TukuiDB.Scale(sThreatMeter_Data.Width-2));
		bar:SetHeight(TukuiDB.Scale(sThreatMeter_Data.Height-2));
		bar:SetStatusBarTexture(sThreatMeter_Data.Texture);
		if ( type(sThreatMeter_Data.Color) == "string" ) then
			class = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[testthreat[i].class] and CUSTOM_CLASS_COLORS[testthreat[i].class] or RAID_CLASS_COLORS[testthreat[i].class];
			bar:SetStatusBarColor(class.r, class.g, class.b, 1);
		else
			bar:SetStatusBarColor(unpack(sThreatMeter_Data.Color));
		end
		bar:ClearAllPoints();
		if ( i == 1 ) then
			bar:SetPoint("TOP", sThreatMeter);
		else
			if ( sThreatMeter_Data.Direction == "down" ) then
				bar:SetPoint("TOP", _G["sThreatMeter2_OptionBar"..i-1], "BOTTOM", 0, TukuiDB.Scale(-sThreatMeter_Data.Spacing));
			elseif ( sThreatMeter_Data.Direction == "right" ) then
				bar:SetPoint("LEFT", _G["sThreatMeter2_OptionBar"..i-1], "RIGHT", TukuiDB.Scale(sThreatMeter_Data.Spacing), 0);
			elseif ( sThreatMeter_Data.Direction == "left" ) then
				bar:SetPoint("RIGHT", _G["sThreatMeter2_OptionBar"..i-1], "LEFT", TukuiDB.Scale(-sThreatMeter_Data.Spacing), 0);
			else
				bar:SetPoint("BOTTOM", _G["sThreatMeter2_OptionBar"..i-1], "TOP", 0, TukuiDB.Scale(sThreatMeter_Data.Spacing));
			end
		end
		
		bar.background:SetTexture(sThreatMeter_Data.Texture);
		if ( testthreat[i].class == select(2, UnitClass("player")) ) then
			if ( sThreatMeter_Data.MyThreatIndicator[1] == 1 ) then
				bar.textright:SetTextColor(sThreatMeter_Data.MyThreatIndicatorColor[1], sThreatMeter_Data.MyThreatIndicatorColor[2], sThreatMeter_Data.MyThreatIndicatorColor[3], 1);
				bar.textleft:SetTextColor(sThreatMeter_Data.MyThreatIndicatorColor[1], sThreatMeter_Data.MyThreatIndicatorColor[2], sThreatMeter_Data.MyThreatIndicatorColor[3], 1);
			else
				bar.textright:SetTextColor(1, 1, 1, 1);
				bar.textleft:SetTextColor(1, 1, 1, 1);
			end
			if ( sThreatMeter_Data.MyThreatIndicator[2] == 1 ) then
				bar:SetStatusBarColor(sThreatMeter_Data.MyThreatIndicatorColor[1], sThreatMeter_Data.MyThreatIndicatorColor[2], sThreatMeter_Data.MyThreatIndicatorColor[3], sThreatMeter_Data.Color[4] or 1);
			end
			if ( sThreatMeter_Data.MyThreatIndicator[3] == 1 ) then
				bar.background:SetVertexColor(sThreatMeter_Data.MyThreatIndicatorColor[1], sThreatMeter_Data.MyThreatIndicatorColor[2], sThreatMeter_Data.MyThreatIndicatorColor[3], sThreatMeter_Data.BackgroundColor[4] or 1);
			else
				bar.background:SetVertexColor(unpack(sThreatMeter_Data.BackgroundColor));
			end
		else
			bar.textright:SetTextColor(1, 1, 1, 1);
			bar.textleft:SetTextColor(1, 1, 1, 1);
			bar.background:SetVertexColor(unpack(sThreatMeter_Data.BackgroundColor));
		end
		
		r, g, b = ColorGradient((testthreat[i].scaledPercent/100), 0, 1, 0, 1, 1, 0, 1, 0, 0);
		bar.textright:SetFont(unpack(sThreatMeter_Data.Font));
		bar.textright:SetShadowColor(0, 0, 0, sThreatMeter_Data.FontShadowAlpha);
		text = string.gsub(sThreatMeter_Data.TextRight, "$value", comma_value(testthreat[i].threatValue));
		text = string.gsub(text, "$shortvalue", short_value(testthreat[i].threatValue));
		text = string.gsub(text, "$perc", string.format("|cff%02x%02x%02x%d|r", r*255, g*255, b*255, testthreat[i].scaledPercent));
		text = string.gsub(text, "$name", testthreat[i].name);
		bar.textright:SetText(text);
		
		bar.textleft:SetFont(unpack(sThreatMeter_Data.Font));
		bar.textleft:SetShadowColor(0, 0, 0, sThreatMeter_Data.FontShadowAlpha);
		text = string.gsub(sThreatMeter_Data.TextLeft, "$value", comma_value(testthreat[i].threatValue));
		text = string.gsub(text, "$shortvalue", short_value(testthreat[i].threatValue));
		text = string.gsub(text, "$perc", string.format("|cff%02x%02x%02x%d|r", r*255, g*255, b*255, testthreat[i].scaledPercent));
		text = string.gsub(text, "$name", testthreat[i].name);
		bar.textleft:SetText(text);
		
		if ( msg == "show" or toggle and frame.testmode ) then
			bar:Show();
		end
	end
	sThreatMeter:SetWidth(TukuiDB.Scale(sThreatMeter_Data.Width));
	sThreatMeter:SetHeight(TukuiDB.Scale(sThreatMeter_Data.Height));
end

local dropdownlist = {};
local dropdownframe = CreateFrame("Frame", "sThreatMeterDropDownList", InterfaceOptionsFrame);
dropdownframe:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 8, edgeSize = 14, insets = { left = 3, right = 3, top = 3, bottom = 3 } });
dropdownframe:SetBackdropColor(0, 0, 0, 0.9);
dropdownframe:SetFrameStrata("TOOLTIP");
dropdownframe:SetFrameLevel(InterfaceOptionsFrame:GetFrameLevel()+3);
dropdownframe:EnableMouse(1);
dropdownframe:SetWidth(130);
dropdownframe:Hide();
dropdownframe.button = {};
for i=1, 15, 1 do
	dropdownframe.button[i] = CreateFrame("Button", "$parentButton"..i, dropdownframe);
	dropdownframe.button[i]:SetWidth(130);
	dropdownframe.button[i]:SetHeight(16);
	if ( i == 1 ) then
		dropdownframe.button[i]:SetPoint("TOPLEFT", 0, -5);
	else
		dropdownframe.button[i]:SetPoint("TOPLEFT", dropdownframe.button[i-1], "BOTTOMLEFT");
	end
	dropdownframe.button[i]:SetScript("OnClick", function(self)
		self.func();
		UIDropDownMenu_SetText(self.update, self.text:GetText());
		UpdateBars("test");
		dropdownframe:Hide();
		PlaySound("igMainMenuOptionCheckBoxOn");
	end);
	dropdownframe.button[i]:SetScript("OnEnter", function(self)
		self.text:SetTextColor(1, 0.82, 0);
	end);
	dropdownframe.button[i]:SetScript("OnLeave", function(self)
		self.text:SetTextColor(1, 1, 1);
	end);
	dropdownframe.button[i].check = dropdownframe.button[i]:CreateTexture("$parentCheck", "BORDER");
	dropdownframe.button[i].check:SetWidth(18);
	dropdownframe.button[i].check:SetHeight(18);
	dropdownframe.button[i].check:SetPoint("LEFT", 5, 0);
	dropdownframe.button[i].check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check");
	dropdownframe.button[i].check:Hide();
	dropdownframe.button[i].text = dropdownframe.button[i]:CreateFontString("$parentText", "ARTWORK", "GameFontNormalSmallLeft");
	dropdownframe.button[i].text:SetTextColor(1, 1, 1);
	dropdownframe.button[i].text:SetJustifyH("LEFT");
	dropdownframe.button[i].text:SetPoint("LEFT", 25, 0);
	dropdownframe.button[i].text:SetPoint("RIGHT");
	dropdownframe.button[i].background = dropdownframe.button[i]:CreateTexture("$parentBackground", "BACKGROUND");
	dropdownframe.button[i].background:SetVertexColor(0.5, 0.5, 0.5, 1);
	dropdownframe.button[i].background:SetHeight(16);
	dropdownframe.button[i].background:SetPoint("LEFT", 5, 0);
	dropdownframe.button[i].background:SetPoint("RIGHT", -5, 0);
	dropdownframe.button[i].background:Hide();
end

local function sThreatMeterDropDownList_Update()
	FauxScrollFrame_Update(sThreatMeterDropDownListScrollFrame, #dropdownlist, 15, 10);
	local count = 0;
	for i=1, 15, 1 do
		local offset = i+FauxScrollFrame_GetOffset(sThreatMeterDropDownListScrollFrame);
		local button = dropdownframe.button[i];
		if ( offset <= #dropdownlist ) then
			local data = dropdownlist[offset];
			button.func = data.func;
			button.update = data.update;
			button.text:SetText(data.text);
			
			if ( data.checked ) then
				button.check:Show();
			else
				button.check:Hide();
			end
			if ( data.background ) then
				button.background:SetTexture(data.background);
				button.background:Show();
			else
				button.background:Hide();
			end
			
			if ( data.font ) then
				button.text:SetFont(data.font, fontsize);
			else
				button.text:SetFont(font, fontsize);
			end
			
			button:Show();
			count = count+1;
		else
			button:Hide();
		end
	end
	dropdownframe:SetHeight(#dropdownlist < 15 and ((16*count)+10) or ((16*15)+10));
end

dropdownframe.itemscroll = CreateFrame("ScrollFrame", "$parentScrollFrame", dropdownframe, "FauxScrollFrameTemplate");
dropdownframe.itemscroll:SetWidth(104);
dropdownframe.itemscroll:SetHeight(243);
dropdownframe.itemscroll:SetPoint("TOPLEFT", 0, -4);
dropdownframe.itemscroll:SetScript("OnVerticalScroll", function(self, offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, 10, sThreatMeterDropDownList_Update);
end);

local function InitializeDropDownMenu(frame, menu)
	if ( sThreatMeterDropDownList:IsShown() ) then
		sThreatMeterDropDownList:Hide();
		return;
	end
	dropdownlist = {};
	
	if ( menu == "direction" ) then
		table.insert(dropdownlist, { update = frame, text = L("Up"), func = function() sThreatMeter_Data.Direction = "up" end });
		if ( sThreatMeter_Data.Direction == "up" ) then dropdownlist[#dropdownlist].checked = true end;
		table.insert(dropdownlist, { update = frame, text = L("Down"), func = function() sThreatMeter_Data.Direction = "down" end });
		if ( sThreatMeter_Data.Direction == "down" ) then dropdownlist[#dropdownlist].checked = true end;
		table.insert(dropdownlist, { update = frame, text = L("Left"), func = function() sThreatMeter_Data.Direction = "left" end });
		if ( sThreatMeter_Data.Direction == "left" ) then dropdownlist[#dropdownlist].checked = true end;
		table.insert(dropdownlist, { update = frame, text = L("Right"), func = function() sThreatMeter_Data.Direction = "right" end });
		if ( sThreatMeter_Data.Direction == "right" ) then dropdownlist[#dropdownlist].checked = true end;
	elseif ( menu == "texture" ) then
		if ( SML ) then
			for index, value in pairs(SML:List("statusbar")) do
				table.insert(dropdownlist, { update = frame, text = value, func = function() sThreatMeter_Data.Texture = SML:Fetch("statusbar", value) end, background = SML:Fetch("statusbar", value) });
				if ( sThreatMeter_Data.Texture == SML:Fetch("statusbar", value) ) then dropdownlist[#dropdownlist].checked = true end;
			end
		else
			table.insert(dropdownlist, { update = frame, text = "Blizzard", func = function() sThreatMeter_Data.Texture = "Interface\\TargetingFrame\\UI-StatusBar" end, background = "Interface\\TargetingFrame\\UI-StatusBar" });
			if ( sThreatMeter_Data.Texture == "Interface\\TargetingFrame\\UI-StatusBar" ) then dropdownlist[#dropdownlist].checked = true end;
		end
		table.insert(dropdownlist, { update = frame, text = "sThreatMeter2", func = function() sThreatMeter_Data.Texture = "Interface\\AddOns\\sThreatMeter2\\statusbar" end, background = "Interface\\AddOns\\sThreatMeter2\\statusbar" });
		if ( sThreatMeter_Data.Texture == "Interface\\AddOns\\sThreatMeter2\\statusbar" ) then dropdownlist[#dropdownlist].checked = true end;
	elseif ( menu == "font" ) then
		if ( SML ) then
			for index, value in pairs(SML:List("font")) do
				table.insert(dropdownlist, { update = frame, text = value, func = function() sThreatMeter_Data.Font[1] = SML:Fetch("font", value) end, font = SML:Fetch("font", value) });
				if ( sThreatMeter_Data.Font[1] == SML:Fetch("font", value) ) then dropdownlist[#dropdownlist].checked = true end;
			end
		else
			local count = 1;
			for index, value in pairs(standardfont) do
				table.insert(dropdownlist, { update = frame, text = index, func = function() sThreatMeter_Data.Font[1] = value end, font = value });
				if ( sThreatMeter_Data.Font[1] == value ) then dropdownlist[#dropdownlist].checked = true end;
				count = count+1;
			end
		end
		table.insert(dropdownlist, { update = frame, text = "sThreatMeter2", func = function() sThreatMeter_Data.Font[1] = "Interface\\AddOns\\sThreatMeter2\\font.ttf" end, font = "Interface\\AddOns\\sThreatMeter2\\font.ttf" });
		if ( sThreatMeter_Data.Font[1] == "Interface\\AddOns\\sThreatMeter2\\font.ttf" ) then dropdownlist[#dropdownlist].checked = true end;
	elseif ( menu == "fontoutline" ) then
		table.insert(dropdownlist, { update = frame, text = NONE, func = function() sThreatMeter_Data.Font[3] = "" end });
		if ( sThreatMeter_Data.Font[3] == "" ) then dropdownlist[#dropdownlist].checked = true end;
		table.insert(dropdownlist, { update = frame, text = L("Outline"), func = function() sThreatMeter_Data.Font[3] = "OUTLINE" end });
		if ( sThreatMeter_Data.Font[3] == "OUTLINE" ) then dropdownlist[#dropdownlist].checked = true end;
		table.insert(dropdownlist, { update = frame, text =  L("Thick outline"), func = function() sThreatMeter_Data.Font[3] = "THICKOUTLINE" end });
		if ( sThreatMeter_Data.Font[3] == "THICKOUTLINE" ) then dropdownlist[#dropdownlist].checked = true end;
	else
		return;
	end
	
	sThreatMeterDropDownList_Update();
	sThreatMeterDropDownList:ClearAllPoints();
	sThreatMeterDropDownList:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 18, 5);
	sThreatMeterDropDownList:Show();
end

local function CreateDropDownMenu(frame, id, text, menu, ...)
	local dropdownmenu = CreateFrame("Frame", "$parentDropDownMenu"..id, frame, "UIDropDownMenuTemplate");
	dropdownmenu:SetPoint(...);
	dropdownmenu:SetScript("OnHide", function(self)
		sThreatMeterDropDownList:Hide();
	end);
	dropdownmenu.text = dropdownmenu:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	dropdownmenu.text:SetPoint("BOTTOMLEFT", dropdownmenu, "TOPLEFT", 16, 3);
	dropdownmenu.text:SetText(text);
	dropdownmenu.button = _G[dropdownmenu:GetName().."Button"];
	dropdownmenu.button:SetScript("OnClick", function(self)
		InitializeDropDownMenu(dropdownmenu, menu);
		PlaySound("igMainMenuOptionCheckBoxOn");
	end);
	
	UIDropDownMenu_SetWidth(dropdownmenu, 140);
	UIDropDownMenu_SetButtonWidth(dropdownmenu, 16);
	UIDropDownMenu_SetText(dropdownmenu, L("Select..."));
	UIDropDownMenu_JustifyText(dropdownmenu, "LEFT");
	
	return dropdownmenu;
end

local function CreateSlider(frame, id, text, min, max, step, ...)
	local slider = CreateFrame("Slider", "$parentSlider"..id, frame, "OptionsSliderTemplate")
	slider:SetPoint(...);
	_G[slider:GetName().."Text"]:SetText(text);
	_G[slider:GetName().."High"]:SetText(max == 1 and min == 0 and "100%" or max);
	_G[slider:GetName().."Low"]:SetText(max == 1 and min == 0 and "0%" or min);
	slider:SetMinMaxValues(min, max);
	slider:SetValueStep(step);
	slider:SetWidth(180);
	slider:EnableMouseWheel(1);
	slider.text = slider:CreateFontString("$parentCenterText", "ARTWORK", "GameFontHighlightSmall");
	slider.text:SetPoint("TOP", slider, "BOTTOM", 0, 3);
	
	return slider;
end

local function CreateColorSwatch(frame, id, text, ...)
	local colorswatch = CreateFrame("Button", "$parentColorSwatch"..id, frame);
	colorswatch:SetWidth(16);
	colorswatch:SetHeight(16);
	colorswatch:SetPoint(...);
	colorswatch:SetScript("OnEnter", function(self)
		self.bg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end);
	colorswatch:SetScript("OnLeave", function(self)
		self.bg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end);
	colorswatch.texture = colorswatch:CreateTexture(nil, "OVERLAY");
	colorswatch.texture:SetWidth(14);
	colorswatch.texture:SetHeight(14);
	colorswatch.texture:SetPoint("CENTER");
	colorswatch.texture:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
	colorswatch.bg = colorswatch:CreateTexture(nil, "BACKGROUND");
	colorswatch.bg:SetWidth(14);
	colorswatch.bg:SetHeight(14);
	colorswatch.bg:SetPoint("CENTER");
	colorswatch.bg:SetTexture(1, 1, 1, 1);
	colorswatch.text = colorswatch:CreateFontString("$parentText", "ARTWORK", "GameFontHighlight");
	colorswatch.text:SetPoint("LEFT", colorswatch, "RIGHT", 3, 0);
	colorswatch.text:SetText(text);
	
	return colorswatch;
end

local function CreateEditBox(frame, id, text, ...)
	local editbox = CreateFrame("EditBox", "$parentEditBox"..id, frame, "InputBoxTemplate");
	editbox:SetPoint(...);
	editbox:SetWidth(380);
	editbox:SetHeight(22);
	editbox:SetAutoFocus(false);
	editbox.text = editbox:CreateFontString("$parentText", "ARTWORK", "GameFontHighlightSmall");
	editbox.text:SetPoint("BOTTOMLEFT", editbox, "TOPLEFT", -6, 1);
	editbox.text:SetText(text);

	return editbox;
end

frame.test = CreateFrame("Button", "$parentTest", frame, "UIPanelButtonTemplate");
frame.test:SetWidth(160);
frame.test:SetHeight(22);
frame.test:SetPoint("TOPLEFT", 10, -15);
frame.test:SetText(L("Show test bars"));
frame.test:SetScript("OnClick", function(self)
	if ( not frame.testmode ) then
		frame.testmode = true;
		sThreatMeter:SetMovable(1);
		UpdateBars("show");
		self:SetText(L("Hide test bars"));
	else
		frame.testmode = nil;
		sThreatMeter:SetMovable(nil);
		UpdateBars("hide");
		self:SetText(L("Show test bars"));
	end
end);

frame.animation = CreateFrame("CheckButton", "$parentAnimation", frame, "OptionsCheckButtonTemplate");
frame.animation:SetPoint("LEFT", frame.test, "RIGHT", 43, 0);
_G[frame.animation:GetName().."Text"]:SetText(L("Animated bars"));
_G[frame.animation:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
frame.animation:SetScript("OnShow", function(self)
	self:SetChecked(sThreatMeter_Data.Animation == 1 and true or nil);
end);
frame.animation:SetScript("OnClick", function(self)
	if ( sThreatMeter_Data.Animation == 1 ) then
		sThreatMeter_Data.Animation = 0;
	else
		sThreatMeter_Data.Animation = 1;
	end
end);

frame.width = CreateSlider(frame, "1", L("Width"), 1, 300, 1, "TOPLEFT", 16, -60);
frame.width:SetScript("OnShow", function(self)
	self:SetValue(sThreatMeter_Data.Width);
	self.text:SetText(sThreatMeter_Data.Width);
end);
frame.width:SetScript("OnValueChanged", function(self)
	sThreatMeter_Data.Width = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Width);
	UpdateBars("test");
end);
frame.width:SetScript("OnMouseWheel", function(self, wheele)
	self:SetValue(IsShiftKeyDown() and self:GetValue()+5*wheele or self:GetValue()+wheele);
	sThreatMeter_Data.Width = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Width);
	UpdateBars("test");
end);

frame.height = CreateSlider(frame, "2", L("Height"), 1, 50, 1, "LEFT", frame.width, "RIGHT", 20, 0);
frame.height:SetScript("OnShow", function(self)
	self:SetValue(sThreatMeter_Data.Height);
	self.text:SetText(sThreatMeter_Data.Height);
end);
frame.height:SetScript("OnValueChanged", function(self)
	sThreatMeter_Data.Height = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Height);
	UpdateBars("test");
end);
frame.height:SetScript("OnMouseWheel", function(self, wheele)
	self:SetValue(IsShiftKeyDown() and self:GetValue()+5*wheele or self:GetValue()+wheele);
	sThreatMeter_Data.Height = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Height);
	UpdateBars("test");
end);

frame.direction = CreateDropDownMenu(frame, "1", L("Direction"), "direction", "TOPLEFT", frame.width, "BOTTOMLEFT", -20, -29);

frame.spacing = CreateSlider(frame, "3", L("Spacing"), 0, 10, 1, "TOP", frame.height, "BOTTOM", 0, -30);
frame.spacing:SetScript("OnShow", function(self)
	self:SetValue(sThreatMeter_Data.Spacing);
	self.text:SetText(sThreatMeter_Data.Spacing);
end);
frame.spacing:SetScript("OnValueChanged", function(self)
	sThreatMeter_Data.Spacing = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Spacing);
	UpdateBars("test");
end);
frame.spacing:SetScript("OnMouseWheel", function(self, wheele)
	self:SetValue(IsShiftKeyDown() and self:GetValue()+5*wheele or self:GetValue()+wheele);
	sThreatMeter_Data.Spacing = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Spacing);
	UpdateBars("test");
end);

frame.bars = CreateSlider(frame, "4", L("Number"), 1, 10, 1, "TOP", frame.spacing, "BOTTOM", 0, -30);
frame.bars:SetScript("OnShow", function(self)
	self:SetValue(sThreatMeter_Data.Bars);
	self.text:SetText(sThreatMeter_Data.Bars);
end);
frame.bars.test = true;
frame.bars:SetScript("OnValueChanged", function(self)
	sThreatMeter_Data.Bars = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Bars);
	if ( not frame.bars.test ) then
		UpdateBars("test", true);
	end
	frame.bars.test = nil;
end);
frame.bars:SetScript("OnMouseWheel", function(self, wheele)
	self:SetValue(IsShiftKeyDown() and self:GetValue()+5*wheele or self:GetValue()+wheele);
	sThreatMeter_Data.Bars = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Bars);
	UpdateBars("test");
end);

frame.texture = CreateDropDownMenu(frame, "2", L("Texture"), "texture", "TOP", frame.direction, "BOTTOM", 0, -15);

frame.classcolor = CreateFrame("CheckButton", "$parentClasscolor", frame, "OptionsCheckButtonTemplate");
frame.classcolor:SetPoint("TOPLEFT", frame.texture, "BOTTOMLEFT", 16, -10);
_G[frame.classcolor:GetName().."Text"]:SetText(L("Class colors"));
_G[frame.classcolor:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
frame.classcolor:SetScript("OnShow", function(self)
	self:SetChecked(type(sThreatMeter_Data.Color) == "string" and true or nil);
end);
frame.classcolor:SetScript("OnClick", function(self)
	if ( type(sThreatMeter_Data.Color) == "string" ) then
		sThreatMeter_Data.Color = { 1, 1, 1, 1 };
		frame.colorswatchclass.texture:SetVertexColor(1, 1, 1, 1);
		frame.colorswatchclass.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		frame.colorswatchclass:SetScript("OnEnter", function(self)
			self.bg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end);
		frame.colorswatchclass:SetScript("OnLeave", function(self)
			self.bg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end);
		frame.colorswatchclass:Enable();
	else
		sThreatMeter_Data.Color = "class";
		frame.colorswatchclass.texture:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		frame.colorswatchclass.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		frame.colorswatchclass:SetScript("OnEnter", nil);
		frame.colorswatchclass:SetScript("OnLeave", nil);
		frame.colorswatchclass:Disable();
	end
	UpdateBars("test");
end);

frame.colorswatchclass = CreateColorSwatch(frame, "1", L("Own color"), "LEFT", frame.classcolor, "RIGHT", 120, 0);
frame.colorswatchclass:SetScript("OnShow", function(self)
	if ( type(sThreatMeter_Data.Color) == "string" ) then
		self.texture:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		self.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		self:SetScript("OnEnter", nil);
		self:SetScript("OnLeave", nil);
		self:Disable();
	else
		self.texture:SetVertexColor(unpack(sThreatMeter_Data.Color));
		self.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self:SetScript("OnEnter", function(self)
			self.bg:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end);
		self:SetScript("OnLeave", function(self)
			self.bg:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end);
		self:Enable();
	end
end);
frame.colorswatchclass:SetScript("OnClick", function(self)
	CloseMenus();
	local info = UIDropDownMenu_CreateInfo();
	info.r, info.g, info.b, info.opacity = unpack(sThreatMeter_Data.Color);
	info.hasOpacity = true;
	info.swatchFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		local a = 1-OpacitySliderFrame:GetValue();
		sThreatMeter_Data.Color = { r, g, b, a };
		self.texture:SetVertexColor(r, g, b, a);
		UpdateBars("test");
	end;
	info.cancelFunc = function(old)
		sThreatMeter_Data.Color = { old.r, old.g, old.b, old.opacity };
		self.texture:SetVertexColor(old.r, old.g, old.b, old.opacity);
		UpdateBars("test");
	end;
	info.opacityFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		local a = 1-OpacitySliderFrame:GetValue();
		sThreatMeter_Data.Color = { r, g, b, a };
		self.texture:SetVertexColor(r, g, b, a);
		UpdateBars("test");
	end;
	OpenColorPicker(info);
	OpacitySliderFrame:SetValue(tonumber(sThreatMeter_Data.Color[4]));
end);

frame.colorswatchbackground = CreateColorSwatch(frame, "2", L("Background"), "LEFT", frame.colorswatchclass, "RIGHT", 120, 0);
frame.colorswatchbackground:SetScript("OnShow", function(self)
	self.texture:SetVertexColor(unpack(sThreatMeter_Data.BackgroundColor));
end);
frame.colorswatchbackground:SetScript("OnClick", function(self)
	CloseMenus();
	local info = UIDropDownMenu_CreateInfo();
	info.r, info.g, info.b, info.opacity = unpack(sThreatMeter_Data.BackgroundColor);
	info.hasOpacity = true;
	info.swatchFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		local a = 1-OpacitySliderFrame:GetValue();
		sThreatMeter_Data.BackgroundColor = { r, g, b, a };
		self.texture:SetVertexColor(r, g, b, a);
		UpdateBars("test");
	end;
	info.cancelFunc = function(old)
		sThreatMeter_Data.BackgroundColor = { old.r, old.g, old.b, old.opacity };
		self.texture:SetVertexColor(old.r, old.g, old.b, old.opacity);
		UpdateBars("test");
	end;
	info.opacityFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		local a = 1-OpacitySliderFrame:GetValue();
		sThreatMeter_Data.BackgroundColor = { r, g, b, a };
		self.texture:SetVertexColor(r, g, b, a);
		UpdateBars("test");
	end;
	OpenColorPicker(info);
	OpacitySliderFrame:SetValue(tonumber(sThreatMeter_Data.BackgroundColor[4]));
end);

frame.indicator = frame:CreateFontString("$parentText", "ARTWORK", "GameFontNormal");
frame.indicator:SetPoint("TOPLEFT", frame.classcolor, "BOTTOMLEFT", 0, -10);
frame.indicator:SetText(L("My threat indicator"));

frame.indicatortext = CreateFrame("CheckButton", "$parentIndicatorText", frame, "OptionsCheckButtonTemplate");
frame.indicatortext:SetPoint("TOPLEFT", frame.classcolor, "BOTTOMLEFT", 0, -30);
_G[frame.indicatortext:GetName().."Text"]:SetText(L("Text"));
_G[frame.indicatortext:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
frame.indicatortext:SetScript("OnShow", function(self)
	self:SetChecked(sThreatMeter_Data.MyThreatIndicator[1] == 1 and true or nil);
end);
frame.indicatortext:SetScript("OnClick", function(self)
	if ( sThreatMeter_Data.MyThreatIndicator[1] == 1 ) then
		sThreatMeter_Data.MyThreatIndicator[1] = 0;
	else
		sThreatMeter_Data.MyThreatIndicator[1] = 1;
	end
	UpdateBars("test");
end);

frame.indicatorbar = CreateFrame("CheckButton", "$parentIndicatorBar", frame, "OptionsCheckButtonTemplate");
frame.indicatorbar:SetPoint("LEFT", frame.indicatortext, "RIGHT", 115, 0);
_G[frame.indicatorbar:GetName().."Text"]:SetText(L("Bar"));
_G[frame.indicatorbar:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
frame.indicatorbar:SetScript("OnShow", function(self)
	self:SetChecked(sThreatMeter_Data.MyThreatIndicator[2] == 1 and true or nil);
end);
frame.indicatorbar:SetScript("OnClick", function(self)
	if ( sThreatMeter_Data.MyThreatIndicator[2] == 1 ) then
		sThreatMeter_Data.MyThreatIndicator[2] = 0;
	else
		sThreatMeter_Data.MyThreatIndicator[2] = 1;
	end
	UpdateBars("test");
end);

frame.indicatorbackground = CreateFrame("CheckButton", "$parentIndicatorBackground", frame, "OptionsCheckButtonTemplate");
frame.indicatorbackground:SetPoint("LEFT", frame.indicatorbar, "RIGHT", 110, 0);
_G[frame.indicatorbackground:GetName().."Text"]:SetText(L("Background"));
_G[frame.indicatorbackground:GetName().."Text"]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
frame.indicatorbackground:SetScript("OnShow", function(self)
	self:SetChecked(sThreatMeter_Data.MyThreatIndicator[3] == 1 and true or nil);
end);
frame.indicatorbackground:SetScript("OnClick", function(self)
	if ( sThreatMeter_Data.MyThreatIndicator[3] == 1 ) then
		sThreatMeter_Data.MyThreatIndicator[3] = 0;
	else
		sThreatMeter_Data.MyThreatIndicator[3] = 1;
	end
	UpdateBars("test");
end);

frame.indicatorcolor = CreateColorSwatch(frame, "3", L("Own color"), "TOPLEFT", frame.indicatortext, "BOTTOMLEFT", 5, -5);
frame.indicatorcolor:SetScript("OnShow", function(self)
	self.texture:SetVertexColor(unpack(sThreatMeter_Data.MyThreatIndicatorColor));
end);
frame.indicatorcolor:SetScript("OnClick", function(self)
	CloseMenus();
	local info = UIDropDownMenu_CreateInfo();
	info.r, info.g, info.b = unpack(sThreatMeter_Data.MyThreatIndicatorColor);
	info.hasOpacity = false;
	info.swatchFunc = function()
		local r, g, b = ColorPickerFrame:GetColorRGB();
		sThreatMeter_Data.MyThreatIndicatorColor = { r, g, b };
		self.texture:SetVertexColor(r, g, b);
		UpdateBars("test");
	end;
	info.cancelFunc = function(old)
		sThreatMeter_Data.MyThreatIndicatorColor = { old.r, old.g, old.b };
		self.texture:SetVertexColor(old.r, old.g, old.b);
		UpdateBars("test");
	end;
	OpenColorPicker(info);
end);

--[[
	SCHRITART OPTION
]]

fontoption.font = CreateDropDownMenu(fontoption, "3", L("Font"), "font", "TOPLEFT", -5, -30);

fontoption.fontsize = CreateSlider(fontoption, "5", L("Font size"), 4, 24, 1, "LEFT", fontoption.font, "RIGHT", 30, 5);
fontoption.fontsize:SetScript("OnShow", function(self)
	self:SetValue(sThreatMeter_Data.Font[2]);
	self.text:SetText(sThreatMeter_Data.Font[2]);
end);
fontoption.fontsize:SetScript("OnValueChanged", function(self)
	sThreatMeter_Data.Font[2] = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Font[2]);
	UpdateBars("test");
end);
fontoption.fontsize:SetScript("OnMouseWheel", function(self, wheele)
	self:SetValue(IsShiftKeyDown() and self:GetValue()+5*wheele or self:GetValue()+wheele);
	sThreatMeter_Data.Font[2] = self:GetValue();
	self.text:SetText(sThreatMeter_Data.Font[2]);
	UpdateBars("test");
end);

fontoption.fontflags = CreateDropDownMenu(fontoption, "4", L("Font outline"), "fontoutline", "TOP", fontoption.font, "BOTTOM", 0, -15);

fontoption.fontshadow = CreateSlider(fontoption, "6", L("Font shadow alpha"), 0, 1, 0.1, "TOP", fontoption.fontsize, "BOTTOM", 0, -30);
fontoption.fontshadow:SetScript("OnShow", function(self)
	self:SetValue(sThreatMeter_Data.FontShadowAlpha);
	self.text:SetText((tonumber(string.format("%.1f", sThreatMeter_Data.FontShadowAlpha))*100).."%");
end);
fontoption.fontshadow:SetScript("OnValueChanged", function(self)
	sThreatMeter_Data.FontShadowAlpha = self:GetValue();
	self.text:SetText((tonumber(string.format("%.1f", sThreatMeter_Data.FontShadowAlpha))*100).."%");
	UpdateBars("test");
end);
fontoption.fontshadow:SetScript("OnMouseWheel", function(self, wheele)
	self:SetValue(IsShiftKeyDown() and self:GetValue()+5*wheele/5 or self:GetValue()+wheele/5);
	sThreatMeter_Data.FontShadowAlpha = self:GetValue();
	self.text:SetText((tonumber(string.format("%.1f", sThreatMeter_Data.FontShadowAlpha))*100).."%");
	UpdateBars("test");
end);

fontoption.textleft = CreateEditBox(fontoption, "1", L("Text left"), "TOPLEFT", fontoption.fontflags, "BOTTOMLEFT", 21, -30);
fontoption.textleft:SetScript("OnShow", function(self)
	self:SetText(sThreatMeter_Data.TextLeft);
end);
fontoption.textleft:SetScript("OnEnterPressed", function(self)
	self:ClearFocus();
end);
fontoption.textleft.test = true;
fontoption.textleft:SetScript("OnTextChanged", function(self)
	if ( not self.test ) then
		sThreatMeter_Data.TextLeft = self:GetText();
		UpdateBars("test");
	end
	self.test = nil;
end);

fontoption.textright = CreateEditBox(fontoption, "2", L("Text right"), "TOP", fontoption.textleft, "BOTTOM", 0, -15);
fontoption.textright:SetScript("OnShow", function(self)
	self:SetText(sThreatMeter_Data.TextRight);
end);
fontoption.textright:SetScript("OnEnterPressed", function(self)
	self:ClearFocus();
end);
fontoption.textright.test = true;
fontoption.textright:SetScript("OnTextChanged", function(self)
	if ( not self.test ) then
		sThreatMeter_Data.TextRight = self:GetText();
		UpdateBars("test");
	end
	self.test = nil;
end);

fontoption.texthelp = fontoption:CreateFontString("$parentTextLeft", "ARTWORK", "GameFontHighlightLeft");
fontoption.texthelp:SetPoint("TOPLEFT", fontoption.textright, "BOTTOMLEFT", -3, -3);
fontoption.texthelp:SetText(L("$name = Threat name\n$shortvalue = Short threat value\n$value = Threat value\n$perc = Threat percent number"));
