

local L = GetLocale() == "koKR" and {
	desc = "미니맵에 대한 설정 강화 애드온입니다.",
	reloaddesc = "reload: 미니맵을 리로딩 합니다. 미니맵이 검게 나타나는 현상을 해결할 수 있습니다",
} or {
	desc = "A modular Minimap enhancing addon.",
	reloaddesc = "reload: Reload the minimap frame, should fix blanked out maps",
}


Squeenix = DongleStub("Dongle-1.0"):New("Squeenix")


function Squeenix:Initialize()
	self.db = self:InitializeDB("SqueenixDB2")
	self.slash = self:InitializeSlashCommand(L.desc, "SQUEENIX", "squeenix", "squee")
	self.slash:RegisterSlashHandler(L.reloaddesc, "^reload$", function() Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp") end)

	MinimapBorder:SetTexture()
	MinimapBorderTop:Hide()

	Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp")

	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("BOTTOM", Minimap, "TOP", -8, 5)
	MinimapZoneTextButton:SetScript("OnClick", ToggleMinimap)

	MinimapZoneText:SetPoint("TOP", MinimapZoneTextButton, "TOP", 9, 1)

	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("RIGHT", Minimap, "TOPLEFT", 5, -10)


	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", 13, 10)

	MiniMapWorldMapButton:ClearAllPoints()
	MiniMapWorldMapButton:SetPoint("RIGHT", Minimap, "LEFT", 5, 0)
	MiniMapWorldMapButton:SetPoint("TOP", MiniMapTrackingFrame, "BOTTOM", 0, 4)

	MiniMapMeetingStoneFrame:ClearAllPoints()
	MiniMapMeetingStoneFrame:SetPoint("TOPLEFT", MiniMapWorldMapButton, "BOTTOMLEFT", 0, 5)

	MinimapZoomIn:ClearAllPoints()
	MinimapZoomIn:SetPoint("LEFT", Minimap, "BOTTOMRIGHT", -10, 5)

	MinimapZoomOut:ClearAllPoints()
	MinimapZoomOut:SetPoint("TOP", Minimap, "BOTTOMRIGHT", -15, 0)

	GameTimeFrame:ClearAllPoints()
	GameTimeFrame:SetPoint("CENTER", Minimap, "TOPRIGHT", 5, -25)

	MinimapToggleButton:ClearAllPoints()
	MinimapToggleButton:SetPoint("LEFT", MinimapZoneText, "RIGHT", 0, 0)
end


