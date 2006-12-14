

local L = AceLibrary("AceLocale-2.2"):new("Squeenix")
Squeenix = AceLibrary("AceAddon-2.0"):new("AceDB-2.0", "AceConsole-2.0", "AceModuleCore-2.0")

L:RegisterTranslations("enUS", function() return {
	["A modular Minimap enhancing addon."] = true,
	["Reload"] = true,
	["Reload the minimap frame, should fix blanked out maps"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["A modular Minimap enhancing addon."] = "미니맵에 대한 설정 강화 애드온입니다.",
	["Reload"] = "리로드",
	["Reload the minimap frame, should fix blanked out maps"] = "미니맵을 리로딩 합니다. 미니맵이 검게 나타나는 현상을 해결할 수 있습니다",
} end)


function Squeenix:OnInitialize()
	self:RegisterDB("SqueenixDB")
	self.Options = {
		name = "Squeenix",
		desc = L["A modular Minimap enhancing addon."],
		type = "group",
		args = {
			reload = {
				name = L["Reload"],
				type = "execute",
				desc = L["Reload the minimap frame, should fix blanked out maps"],
				func = function() Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp") end,
			},
		}
	}
	self:RegisterChatCommand({"/squeenix", "/squee"}, self.Options)

	MinimapBorder:SetTexture()
	MinimapBorderTop:Hide()

	Minimap:SetMaskTexture("Interface\\AddOns\\Squeenix\\Mask.blp")

	MinimapZoneTextButton:ClearAllPoints()
	MinimapZoneTextButton:SetPoint("BOTTOM", Minimap, "TOP", -8, 5)
	MinimapZoneTextButton:SetScript("OnClick", ToggleMinimap)

	MinimapZoneText:SetPoint("TOP", MinimapZoneTextButton, "TOP", 9, 1)

	MiniMapTrackingFrame:ClearAllPoints()
	MinimapZoomIn:ClearAllPoints()
	MinimapZoomOut:ClearAllPoints()
	GameTimeFrame:ClearAllPoints()
	MinimapToggleButton:ClearAllPoints()

	MiniMapTrackingFrame:SetPoint("RIGHT", Minimap, "TOPLEFT", 0, -10)
	MinimapZoomIn:SetPoint("LEFT", Minimap, "BOTTOMRIGHT", -10, 15)
	MinimapZoomOut:SetPoint("TOP", Minimap, "BOTTOMRIGHT", -15, 10)
	GameTimeFrame:SetPoint("CENTER", Minimap, "TOPRIGHT", 5, -25)
	MinimapToggleButton:SetPoint("LEFT", MinimapZoneText, "RIGHT", 0, 0)
end
