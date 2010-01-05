
local myname, Squeenix = ...


Squeenix.borders = {
	["Rounded"] = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", insets = {left = 5, right = 5, top = 5, bottom = 5}},

	["Square"] = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeSize = 16,
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", insets = {left = 5, right = 5, top = 5, bottom = 5}},

	["Black"] = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "", edgeSize = 0, insets = {left = 3, right = 3, top = 3, bottom = 3}},
}


local border = CreateFrame("Button", nil, Minimap)
border:SetPoint("TOPLEFT","Minimap",-5,5)
border:SetPoint("BOTTOMRIGHT","Minimap",5,-5)

border:SetFrameStrata("BACKGROUND")
border:SetFrameLevel(1)


function Squeenix:SetBorder(v)
	if v then self.db.border = v end
	border:SetBackdrop(self.borders[self.db.border or "Rounded"])
	border:SetBackdropColor(0,0,0,1)
end




