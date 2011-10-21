
local myname, Squeenix = ...

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if Squeenix[event] then return Squeenix[event](Squeenix, event, ...) end end)
f:RegisterEvent("ADDON_LOADED")


function Squeenix:ADDON_LOADED(event, addon)
	if addon ~= myname then return end

	SqueenixDB2 = SqueenixDB2 or {}
	self.db = SqueenixDB2

	MinimapBorder:SetTexture()
	MinimapBorderTop:Hide()

	Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp")

	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("BOTTOM", Minimap, "TOP", -8, 5)
	MinimapZoneTextButton:SetScript("OnClick", ToggleMinimap)

	MinimapZoneText:SetPoint("TOP", MinimapZoneTextButton, "TOP", 9, 1)

	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("BOTTOMRIGHT", Minimap, "TOPLEFT", 5, -18)

	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 13, 0)

	MiniMapWorldMapButton:ClearAllPoints()
	MiniMapWorldMapButton:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -11, -8)
	MiniMapWorldMapButton:SetNormalTexture("Interface\\Addons\\Squeenix\\WorldMapSquare.tga")
	MiniMapWorldMapButton:SetPushedTexture("Interface\\Addons\\Squeenix\\WorldMapSquare.tga")

	MiniMapLFGFrame:ClearAllPoints()
	MiniMapLFGFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", 5, -53)

	MiniMapVoiceChatFrame:ClearAllPoints()
	MiniMapVoiceChatFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 5, 20)

	MinimapZoomIn:ClearAllPoints()
	MinimapZoomIn:SetPoint("LEFT", Minimap, "BOTTOMRIGHT", -10, 5)

	MinimapZoomOut:ClearAllPoints()
	MinimapZoomOut:SetPoint("TOP", Minimap, "BOTTOMRIGHT", -15, 0)

	GameTimeFrame:ClearAllPoints()
	GameTimeFrame:SetPoint("CENTER", Minimap, "TOPRIGHT", 5, -20)

	GuildInstanceDifficulty:ClearAllPoints()
	GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -7, 8)

	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -7, 7)

	self:SetBorder()
	self:HideButtons()
	self:ShowCompass()
	self:SetPosition()
	self:SetScale()

	LibStub("tekKonfig-AboutPanel").new("Squeenix", "Squeenix")

	self.ADDON_LOADED = self.ADDON_LOADED_2
	if IsAddOnLoaded("Blizzard_TimeManager") then self:ADDON_LOADED(event, "Blizzard_TimeManager") end
end


function Squeenix:ADDON_LOADED_2(event, addon)
	if addon ~= "Blizzard_TimeManager" then return end

	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("CENTER", Minimap, "CENTER", 0, -85)

	self:HideButtons()

	f:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end


local rl = ReloadUI
function ReloadUI()
	Minimap:SetMaskTexture("Textures\\MinimapMask")
	rl()
end


-- Global function, tells others the minimap shape
-- http://wowwiki.com/GetMinimapShape
function GetMinimapShape() return "SQUARE" end


-------------------------
--      LDB feeds      --
-------------------------

local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


local ICON1 = "Interface\\Icons\\INV_Misc_PocketWatch_01"
local ICON2 = "Interface\\Icons\\INV_Misc_QuestionMark"
local timeobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("BlizzClock", {
	type = "data source",
	icon = ICON1,
	text = "12:00",
	OnClick = function()
		if IsShiftKeyDown() then
			GameTimeFrame_OnClick(GameTimeFrame)
		else
			if not IsAddOnLoaded("Blizzard_TimeManager") then LoadAddOn("Blizzard_TimeManager") end
			if TimeManagerClockButton.alarmFiring then
				PlaySound("igMainMenuQuit")
				TimeManager_TurnOffAlarm()
			else TimeManager_Toggle() end
		end
	end,
	OnEnter = function(self)
		if not IsAddOnLoaded("Blizzard_TimeManager") then LoadAddOn("Blizzard_TimeManager") end
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(GetTipAnchor(self))

		if TimeManagerClockButton.alarmFiring then
			TimeManagerClockButton_UpdateTooltip()
		else
			GameTime_UpdateTooltip()
			GameTooltip:AddDoubleLine("Daily quests reset in:", SecondsToTimeAbbrev(GetQuestResetTime()), nil, nil, nil, 1,1,1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(GAMETIME_TOOLTIP_TOGGLE_CLOCK)
		end
		GameTooltip:AddLine("Shift-click to open calendar.")
		local pending = CalendarGetNumPendingInvites()
		if pending > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("You have "..pending.." pending event invite"..(pending > 1 and "s" or ""), 1, 1, 1)
		end
		GameTooltip:Show()
	end,
	OnLeave = function() GameTooltip:Hide() end,
})

local elapsed = 0
f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < 0.5 then return end

	elapsed = 0
	local pending = CalendarGetNumPendingInvites()
	if pending > 0 then
		timeobj.icon = math.floor(GetTime())%4 < 2 and ICON1 or ICON2
		timeobj.text = GameTime_GetTime(false)..(pending == 0 and "" or " ("..pending..")")
	else
		timeobj.icon = ICON1
		timeobj.text = GameTime_GetTime(false)
	end
end)


