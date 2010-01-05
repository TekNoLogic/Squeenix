
local myname, Squeenix = ...


Minimap:SetMovable(true)
Minimap:EnableMouse(true)
Minimap:RegisterForDrag("LeftButton")
Minimap:SetScript("OnDragStart", function(frame) if Squeenix.db.unlocked then frame:StartMoving() end end)
Minimap:SetScript("OnDragStop", function(frame)
	if not Squeenix.db.unlocked then return end
	frame:StopMovingOrSizing()
	Squeenix.db.x, Squeenix.db.y = frame:GetCenter()
	Squeenix.db.anchorframe, Squeenix.db.anchor = "UIParent", "BOTTOMLEFT"
end)


function Squeenix:SetPosition()
	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", self.db.anchorframe or "MinimapCluster", self.db.anchor or "TOP", self.db.x or 9, self.db.y or -92)
end
