--[[
	
	sThreatMeter2
	Copyright (c) 2010, Nils Ruesch
	All rights reserved.
	
]]

local threatguid, threatunit, threatlist, threatbars = "", "target", {}, {};

hooksecurefunc(InterfaceOptionsFrame, "Show", function()
	if ( not IsAddOnLoaded("sThreatMeter2_Option") ) then
		LoadAddOn("sThreatMeter2_Option");
	end
end);

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

local function GetThreat(unit, pet)
	if ( UnitName(pet or unit) == UNKNOWN or not UnitIsVisible(pet or unit) ) then
		return;
	end
	
	local tperc, _, tvalue = select(3, UnitDetailedThreatSituation(pet or unit, threatunit));
	local name = pet and UnitName(unit) .. ": " .. UnitName(pet) or UnitName(unit);
	
	for index, value in ipairs(threatlist) do
		if ( value.name == name ) then
			tremove(threatlist, index);
			break;
		end
	end
	if tvalue and tvalue < 0 then
		tvalue = tvalue + 410065408;
	end
	table.insert(threatlist, {
		name = name,
		class = select(2, UnitClass(unit)),
		tperc = tperc or 0,
		tvalue = tvalue or 0,
	});
end

local function AddThreat(unit, pet)
	if ( UnitExists(pet) ) then
		GetThreat(unit);
		GetThreat(unit, pet);
	else
		if ( GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 ) then
			GetThreat(unit);
		end
	end
end

local function SortThreat(a, b)
	if ( sThreatMeter_Data.Direction == "down" or sThreatMeter_Data.Direction == "right" ) then
		return a.tperc > b.tperc;
	end
	return a.tperc < b.tperc;
end

local function OnUpdateBar(self, elpased)
	if ( self.moveTo == self.value ) then
		self:SetScript("OnUpdate", nil);
	else
		if ( self.moveTo > self.value ) then
			self.value = self.value+1;
		elseif ( self.moveTo < self.value ) then
			self.value = self.value-1;
		end
		self:SetValue(self.value);
	end
end

local function UpdateThreatBars()
	for index, value in ipairs(threatbars) do
		value:Hide();
	end
	table.sort(threatlist, SortThreat);
	if ( sThreatMeter_Data.Direction == "up" or sThreatMeter_Data.Direction == "left" ) then
		for i=1, (#threatlist - sThreatMeter_Data.Bars), 1 do
			tremove(threatlist, 1);
		end
	end
	local bar, class, r, g, b, text;
	for index, value in ipairs(threatlist) do
		if ( index > sThreatMeter_Data.Bars ) then
			return;
		end
		bar = threatbars[index];
		if ( not bar ) then
			bar = CreateFrame("StatusBar", "sThreatMeterBar"..index, UIParent);
			bar:SetWidth(TukuiDB.Scale(sThreatMeter_Data.Width-2));
			bar:SetHeight(TukuiDB.Scale(sThreatMeter_Data.Height-2));
			bar:SetStatusBarTexture(sThreatMeter_Data.Texture);
			bar:SetMinMaxValues(0, 100);
			bar:SetValue(0);
			if ( index == 1 ) then
				bar:SetPoint("TOP", sThreatMeter);
			else
				if ( sThreatMeter_Data.Direction == "down" ) then
					bar:SetPoint("TOP", threatbars[index-1], "BOTTOM", 0, TukuiDB.Scale(-sThreatMeter_Data.Spacing));
				elseif ( sThreatMeter_Data.Direction == "right" ) then
					bar:SetPoint("LEFT", threatbars[index-1], "RIGHT", TukuiDB.Scale(sThreatMeter_Data.Spacing), 0);
				elseif ( sThreatMeter_Data.Direction == "left" ) then
					bar:SetPoint("RIGHT", threatbars[index-1], "LEFT", TukuiDB.Scale(-sThreatMeter_Data.Spacing), 0);
				else
					bar:SetPoint("BOTTOM", threatbars[index-1], "TOP", 0, TukuiDB.Scale(sThreatMeter_Data.Spacing));
				end
			end
			bar.bg = CreateFrame("Frame","$parentBG",bar)
			bar.bg:SetPoint("TOPLEFT", bar, "TOPLEFT",TukuiDB.Scale(-2),TukuiDB.Scale(2))
			bar.bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT",TukuiDB.Scale(2),TukuiDB.Scale(-2))
			bar.bg:SetFrameStrata"LOW"
			TukuiDB.SetTemplate(bar.bg)
			
			bar.background = bar:CreateTexture("$parentBackground", "BACKGROUND");
			bar.background:SetAllPoints();
			bar.background:SetTexture(sThreatMeter_Data.Texture);
			bar.background:Hide()
			
			bar.textright = bar:CreateFontString("$parentTextRight", "ARTWORK");
			bar.textright:SetFont(unpack(sThreatMeter_Data.Font));
			bar.textright:SetShadowOffset(1, -1);
			bar.textright:SetShadowColor(0, 0, 0, sThreatMeter_Data.FontShadowAlpha);
			bar.textright:SetJustifyH("RIGHT");
			bar.textright:SetPoint("RIGHT", TukuiDB.Scale(-1), TukuiDB.Scale(1));
			
			bar.textleft = bar:CreateFontString("$parentTextLeft", "ARTWORK");
			bar.textleft:SetFont(unpack(sThreatMeter_Data.Font));
			bar.textleft:SetShadowOffset(1, -1);
			bar.textleft:SetShadowColor(0, 0, 0, sThreatMeter_Data.FontShadowAlpha);
			bar.textleft:SetJustifyH("LEFT");
			bar.textleft:SetPoint("LEFT", TukuiDB.Scale(1), TukuiDB.Scale(1));
			bar.textleft:SetPoint("RIGHT", bar.textright, "LEFT", TukuiDB.Scale(-1), TukuiDB.Scale(1));
			
			tinsert(threatbars, bar);
		end
		
		if ( sThreatMeter_Data.Animation == 1 ) then
			bar.moveTo = tonumber(format("%d", value.tperc));
			bar.value = tonumber(format("%d", bar:GetValue()));
			if ( bar.value > 100 ) then
				bar.value = 100;
			elseif ( bar.value < 0 ) then
				bar.value = 0;
			end
			bar:SetScript("OnUpdate", OnUpdateBar);
		else
			bar:SetValue(tonumber(format("%d", value.tperc)));
		end
		
		if ( type(sThreatMeter_Data.Color) == "string" ) then
			class = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[value.class] and CUSTOM_CLASS_COLORS[value.class] or RAID_CLASS_COLORS[value.class];
			bar:SetStatusBarColor(class.r, class.g, class.b, 1);
		else
			bar:SetStatusBarColor(unpack(sThreatMeter_Data.Color));
		end
		if ( value.name == UnitName("player") ) then
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
		
		r, g, b = ColorGradient(((value.tperc > 100 and 100 or value.tperc)/100), 0, 1, 0, 1, 1, 0, 1, 0, 0);
		text = string.gsub(sThreatMeter_Data.TextRight, "$value", comma_value(tonumber(format("%d", value.tvalue/100))));
		text = string.gsub(text, "$shortvalue", short_value(tonumber(format("%d", value.tvalue/100))));
		text = string.gsub(text, "$perc", string.format("|cff%02x%02x%02x%d|r", r*255, g*255, b*255, value.tperc));
		text = string.gsub(text, "$name", value.name);
		bar.textright:SetText(text);
		
		text = string.gsub(sThreatMeter_Data.TextLeft, "$value", comma_value(tonumber(format("%d", value.tvalue/100))));
		text = string.gsub(text, "$shortvalue", short_value(tonumber(format("%d", value.tvalue/100))));
		text = string.gsub(text, "$perc", string.format("|cff%02x%02x%02x%d|r", r*255, g*255, b*255, value.tperc));
		text = string.gsub(text, "$name", value.name);
		bar.textleft:SetText(text);
		
		bar:Show();
	end
end

local function OnEvent(self, event, ...)
	local unit = ...;
	if ( event == "ADDON_LOADED" and unit == "sThreatMeter2" ) then
		if ( not sThreatMeter_Data ) then
			sThreatMeter_Data = {
				Point = { "TOP", 0, -200 },
				Direction = "down",
				Spacing = 0,
				Width = 200,
				Height = 15,
				Texture = "Interface\\AddOns\\sThreatMeter2\\statusbar",
				Color = "class",
				BackgroundColor = { 0.5, 0.5, 0.5, 0.7 },
				Bars = 5,
				Font = { "Interface\\AddOns\\sThreatMeter2\\font.ttf", 10 },
				TextLeft = "$name",
				TextRight = "$value [$perc%]",
			};
		end
		if ( not sThreatMeter_Data.Animation ) then
			sThreatMeter_Data.Animation = 1;
		end
		if ( not sThreatMeter_Data.Font[3] ) then
			sThreatMeter_Data.Font[3] = "";
		end
		if ( not sThreatMeter_Data.FontShadowAlpha ) then
			sThreatMeter_Data.FontShadowAlpha = 1;
		end
		if ( not sThreatMeter_Data.MyThreatIndicator ) then
			sThreatMeter_Data.MyThreatIndicator = { 0, 0, 1 };
		end
		if ( not sThreatMeter_Data.MyThreatIndicatorColor ) then
			sThreatMeter_Data.MyThreatIndicatorColor = { 1, 0, 0 };
		end
		self:SetPoint(unpack(sThreatMeter_Data.Point));
		self:SetWidth(sThreatMeter_Data.Width);
		self:SetHeight(sThreatMeter_Data.Height);
		self:UnregisterEvent(event);
	elseif ( event == "UNIT_THREAT_LIST_UPDATE" ) then
		if ( unit and UnitExists(unit) and UnitGUID(unit) == threatguid and UnitCanAttack("player", threatunit) ) then
			if ( GetNumRaidMembers() > 0 ) then
				for i=1, GetNumRaidMembers(), 1 do
					AddThreat("raid"..i, "raid"..i.."pet");
				end
			elseif ( GetNumPartyMembers() > 0 ) then
				AddThreat("player", "pet");
				for i=1, GetNumPartyMembers(), 1 do
					AddThreat("party"..i, "party"..i.."pet");
				end
			else
				AddThreat("player", "pet");
			end
			UpdateThreatBars();
		end
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		if ( UnitExists("target") and not UnitIsDead("target") and not UnitIsPlayer("target") ) then
			threatguid = UnitGUID("target");
			--[[threatunit = "target";
		elseif ( UnitExists("targettarget") and not UnitIsDead("targettarget") and not UnitIsPlayer("targettarget") ) then
			threatguid = UnitGUID("targettarget");
			threatunit = "targettarget";]] -- Mhhh... Man kann die Ziel des Ziels Bedrohnung auslesen, aber das Event dazu (UNIT_THREAT_LIST_UPDATE) feuert nicht... Keine Lust auf ein OnUpdate. :x
		else
			threatguid = "";
		end
		wipe(threatlist);
		UpdateThreatBars();
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		wipe(threatlist);
		UpdateThreatBars();
	end
end

local frame = CreateFrame("Frame", "sThreatMeter", UIParent);
frame:SetClampedToScreen(true);
frame:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
frame:RegisterEvent("PLAYER_TARGET_CHANGED");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");
frame:RegisterEvent("ADDON_LOADED");
frame:SetScript("OnEvent", OnEvent);
