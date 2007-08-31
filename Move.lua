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


function move:Initialize()
	self.db = Squeenix.db:RegisterNamespace("Movement")
	self.db:RegisterDefaults({profile={
		lock = true,
		x = 9, y = -92,
		anchor = "TOP",
		anchorframe = "MinimapCluster",
	}})

	Minimap:SetMovable(true)
	Minimap:EnableMouse(true)
	Minimap:RegisterForDrag("LeftButton")
	Minimap:SetScript("OnDragStart", function(frame) if not self.db.profile.lock then frame:StartMoving() end end)
	Minimap:SetScript("OnDragStop", function(frame)
		if self.db.profile.lock then return end
		frame:StopMovingOrSizing()
		self.db.profile.x, self.db.profile.y = frame:GetCenter()
		self.db.profile.anchorframe, self.db.profile.anchor = "UIParent", "BOTTOMLEFT"
	end)

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", self.db.profile.anchorframe, self.db.profile.anchor, self.db.profile.x, self.db.profile.y)

	Squeenix.slash:RegisterSlashHandler("move: Lock/unlock minimap movement", "^move$", function()
		self.db.profile.lock = not self.db.profile.lock
		self:Print("Minimap movement "..(self.db.profile.lock and "|cffff0000locked" or "|cff00ff00unlocked"))
	end)
	Squeenix.slash:RegisterSlashHandler("resetpos: Resets the minimap to the default location", "^resetpos$", function()
		self.db.profile.x, self.db.profile.y, self.db.profile.anchorframe, self.db.profile.anchor = nil, nil, nil, nil
		Minimap:ClearAllPoints()
		Minimap:SetPoint("CENTER", self.db.profile.anchorframe, self.db.profile.anchor, self.db.profile.x, self.db.profile.y)
		self:Print("Minimap position reset")
	end)
end


