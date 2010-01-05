
local myname, Squeenix = ...


local f = CreateFrame("Frame", nil, Minimap)
f:SetAllPoints()
for dir,anc in pairs{W = "LEFT", S = "BOTTOM", E = "RIGHT"} do
	local w = f:CreateFontString()
	w:SetFontObject(GameFontWhite)
	w:SetPoint("CENTER", f, anc)
	w:SetText(dir)
end


function Squeenix:ShowCompass()
	if self.db.hidecompass then f:Hide() else f:Show() end
end
