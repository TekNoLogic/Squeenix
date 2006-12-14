local L = AceLibrary("AceLocale-2.2"):new("SqueenixHide")
L:RegisterTranslations("enUS", function() return {
	["Hidden"] = true,
	["Shown"] = true,
	["Hide buttons"] = true,
	["Hide minimap buttons"] = true,
	["MinimapToggleButton"] = true,
	["Hide the MinimapToggleButton"] = true,
	["MinimapZoom"] = true,
	["Hide the minimap zoom buttons"] = true,
	["GameTimeFrame"] = true,
	["Hide the GameTimeFrame"] = true,
	["MinimapZoneTextButton"] = true,
	["Hide the MinimapZoneTextButton"] = true,
	["MinimapWorldMapButton"] = true,
	["Hide the MinimapWorldMapButton"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Hidden"] = "숨김",
	["Shown"] = "표시",
	["Hide buttons"] = "버튼 숨김",
	["Hide minimap buttons"] = "미니맵의 버튼을 숨깁니다",
	["MinimapToggleButton"] = "미니맵 토글 버튼",
	["Hide the MinimapToggleButton"] = "미니맵토글버튼을 숨깁니다",
	["MinimapZoom"] = "미니맵 줌 버튼",
	["Hide the minimap zoom buttons"] = "미니맵 줌 버튼을 숨깁니다",
	["GameTimeFrame"] = "게임시간",
	["Hide the GameTimeFrame"] = "미니맵의 시간표시를 숨깁니다",
	["MinimapZoneTextButton"] = "미니맵 지역명",
	["Hide the MinimapZoneTextButton"] = "미니맵의 지역명을 숨깁니다",
	--["MinimapWorldMapButton"] = true,
	--["Hide the MinimapWorldMapButton"] = true,
} end)

local map = {[true] = L["Hidden"], [false] = L["Shown"]}

local hide = Squeenix:NewModule("Hide")


function hide:OnInitialize()
	local self = self
	self.db = Squeenix:AcquireDBNamespace("Hide")
	Squeenix:RegisterDefaults("Hide", "profile", {
		MinimapToggleButton = true,
		MinimapZoom = true,
		GameTimeFrame = true,
		MinimapZoneTextButton = false,
	})

	Squeenix.Options.args.hide = {
		name = L["Hide buttons"],
		type = "group",
		desc = L["Hide minimap buttons"],
		handler = self,
		args = {
			toggle = {
				name = L["MinimapToggleButton"],
				type = "toggle",
				desc = L["Hide the MinimapToggleButton"],
				map = map,
				handler = self,
				get = function() return self.db.profile.MinimapToggleButton end,
				set = "HideToggle",
			},
			worldmap = {
				name = L["MinimapWorldMapButton"],
				type = "toggle",
				desc = L["Hide the MinimapWorldMapButton"],
				map = map,
				handler = self,
				get = function() return self.db.profile.MinimapToggleMap end,
				set = "HideMap",
			},
			zoom = {
				name = L["MinimapZoom"],
				type = "toggle",
				desc = L["Hide the minimap zoom buttons"],
				map = map,
				handler = self,
				get = function() return self.db.profile.MinimapZoom end,
				set = "HideZoom",
			},
			time = {
				name = L["GameTimeFrame"],
				type = "toggle",
				desc = L["Hide the GameTimeFrame"],
				map = map,
				handler = self,
				get = function() return self.db.profile.GameTimeFrame end,
				set = "HideTime",
			},
			text = {
				name = L["MinimapZoneTextButton"],
				type = "toggle",
				desc = L["Hide the MinimapZoneTextButton"],
				map = map,
				handler = self,
				get = function() return self.db.profile.MinimapZoneTextButton end,
				set = "HideText",
			},
		}
	}

	self:HideText(self.db.profile.MinimapZoneTextButton)
	self:HideTime(self.db.profile.GameTimeFrame)
	self:HideToggle(self.db.profile.MinimapToggleButton)
	self:HideZoom(self.db.profile.MinimapZoom)
	hide:HideMap(self.db.profile.MinimapToggleMap)
end


function hide:HideText(v)
	self.db.profile.MinimapZoneTextButton = v
	if v then MinimapZoneTextButton:Hide()
	else MinimapZoneTextButton:Show() end
end

function hide:HideMap(v)
	self.db.profile.MinimapToggleMap = v
	if v then MiniMapWorldMapButton:Hide()
	else MiniMapWorldMapButton:Show() end
end

function hide:HideTime(v)
	self.db.profile.GameTimeFrame = v
	if v then GameTimeFrame:Hide()
	else GameTimeFrame:Show() end
end


function hide:HideToggle(v)
	self.db.profile.MinimapToggleButton = v
	if v then MinimapToggleButton:Hide()
	else MinimapToggleButton:Show() end
end


function hide:HideZoom(v)
	self.db.profile.MinimapZoom = v
	if v then
		MinimapZoomIn:Hide()
		MinimapZoomOut:Hide()
	else
		MinimapZoomIn:Show()
		MinimapZoomOut:Show()
	end
end

