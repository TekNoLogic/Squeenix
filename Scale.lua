local L = AceLibrary("AceLocale-2.2"):new("SqueenixScale")
L:RegisterTranslations("enUS", function() return {
	["Scale map"] = true,
	["Minimap scale"] = true,
	["Scale text"] = true,
	["Minimap text header scale"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Scale map"] = "맵 크기",
	["Minimap scale"] = "미니맵의 크기를 설정합니다",
	["Scale text"] = "텍스트 크기",
	["Minimap text header scale"] = "미니맵의 상단바 텍스트의 크기를 설정합니다.",
} end)

local scale = Squeenix:NewModule("Scale")


function scale:OnInitialize()
	local self = self
	self.db = Squeenix:AcquireDBNamespace("Scale")
	Squeenix:RegisterDefaults("Scale", "profile", {
		mapscale = 1,
		textscale = 1,
	})

	Squeenix.Options.args.mapscale = {
		name = L["Scale map"],
		type = "range",
		desc = L["Minimap scale"],
		min = 0.5,
		max = 2,
		step = 0.05,
		isPercent = true,
		handler = self,
		get = function() return self.db.profile.mapscale end,
		set = "SetMapScale",
	}
	Squeenix.Options.args.textscale = {
		name = L["Scale text"],
		type = "range",
		desc = L["Minimap text header scale"],
		min = 0.5,
		max = 2,
		step = 0.05,
		isPercent = true,
		handler = self,
		get = function() return self.db.profile.textscale end,
		set = "SetTextScale",
	}

	self:SetMapScale()
	self:SetTextScale()
end


function scale:SetMapScale(v)
	if v then self.db.profile.mapscale = v end
	Minimap:SetScale(self.db.profile.mapscale)
end


function scale:SetTextScale(v)
	if v then self.db.profile.textscale = v end
	MinimapZoneTextButton:SetScale(self.db.profile.textscale)
end


