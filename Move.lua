local L = AceLibrary("AceLocale-2.2"):new("SqueenixMovement")
L:RegisterTranslations("enUS", function() return {
	["Lock movement"] = true,
	["Lock/unlock minimap movement"] = true,
	["Locked"] = true,
	["Unlocked"] = true,
	["Reset Position"] = true,
	["Reset the minimap to it's default position"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Lock movement"] = "위치 고정",
	["Lock/unlock minimap movement"] = "미니맵의 위치를 이동하거나 고정합니다",
	["Locked"] = "고정",
	["Unlocked"] = "이동",
	["Reset Position"] = "위치 초기화",
	["Reset the minimap to it's default position"] = "미니맵의 위치를 기본값으로 되돌립니다",
} end)


local move = Squeenix:NewModule("Movement")


function move:OnInitialize()
	local self = self
	self.db = Squeenix:AcquireDBNamespace("Movement")
	Squeenix:RegisterDefaults("Movement", "profile", {lock = true})

	Squeenix.Options.args.lock = {
		name = L["Lock movement"],
		type = "toggle",
		desc = L["Lock/unlock minimap movement"],
		mask = {[true] = L["Locked"], [false] = L["Unlocked"]},
		get = function() return self.db.profile.lock end,
		set = function(v) self.db.profile.lock = v end,
	}
	Squeenix.Options.args.resetpos = {
		name = L["Reset Position"],
		type = "execute",
		desc = L["Reset the minimap to it's default position"],
		func = function()
			self.db.profile.x, self.db.profile.y = nil, nil
			Minimap:ClearAllPoints()
			Minimap:SetPoint("CENTER", "MinimapCluster", "TOP", 9, -92)
		end,
		disabled = function() return not self.db.profile.x end,
	}

	Minimap:SetMovable(true)
	Minimap:EnableMouse(true)
	Minimap:RegisterForDrag("LeftButton")
	Minimap:SetScript("OnDragStart", function() if not self.db.profile.lock then Minimap:StartMoving() end end)
	Minimap:SetScript("OnDragStop", function()
		if self.db.profile.lock then return end
		Minimap:StopMovingOrSizing()
		self.db.profile.x, self.db.profile.y = Minimap:GetCenter()
	end)

	Minimap:ClearAllPoints()
	if self.db.profile.x then Minimap:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", self.db.profile.x, self.db.profile.y)
	else Minimap:SetPoint("CENTER", "MinimapCluster", "TOP", 9, -92) end
end


