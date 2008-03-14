

local L = GetLocale() == "koKR" and {
	desc = "미니맵에 대한 설정 강화 애드온입니다.",
	reloaddesc = "reload: 미니맵을 리로딩 합니다. 미니맵이 검게 나타나는 현상을 해결할 수 있습니다",
} or {
	desc = "A modular Minimap enhancing addon.",
	reloaddesc = "reload: Reload the minimap frame, should fix blanked out maps",
}


Squeenix = {}
local Squeenix, f = Squeenix, CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if Squeenix[event] then return Squeenix[event](Squeenix, event, ...) end end)
f:RegisterEvent("ADDON_LOADED")


function Squeenix:ADDON_LOADED()
	SqueenixDB2 = SqueenixDB2 or {}
	self.db = SqueenixDB2
--~ 	self.slash:RegisterSlashHandler(L.reloaddesc, "^reload$", function() Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp") end)

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
	MiniMapWorldMapButton:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", 5, -22)

	MiniMapMeetingStoneFrame:ClearAllPoints()
	MiniMapMeetingStoneFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", 5, -53)

	MiniMapVoiceChatFrame:ClearAllPoints()
	MiniMapVoiceChatFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMLEFT", 5, 20)

	MinimapZoomIn:ClearAllPoints()
	MinimapZoomIn:SetPoint("LEFT", Minimap, "BOTTOMRIGHT", -10, 5)

	MinimapZoomOut:ClearAllPoints()
	MinimapZoomOut:SetPoint("TOP", Minimap, "BOTTOMRIGHT", -15, 0)

	GameTimeFrame:ClearAllPoints()
	GameTimeFrame:SetPoint("CENTER", Minimap, "TOPRIGHT", 5, -25)

	MinimapToggleButton:ClearAllPoints()
	MinimapToggleButton:SetPoint("LEFT", MinimapZoneText, "RIGHT", -2, 0)

	self:SetBorder()
	self:HideButtons()
	self:ShowCompass()

	f:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end


