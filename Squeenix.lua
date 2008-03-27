

Squeenix = {}
local Squeenix, f = Squeenix, CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...) if Squeenix[event] then return Squeenix[event](Squeenix, event, ...) end end)
f:RegisterEvent("ADDON_LOADED")


function Squeenix:ADDON_LOADED()
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
	self:SetPosition()
	self:SetScale()

	f:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end


