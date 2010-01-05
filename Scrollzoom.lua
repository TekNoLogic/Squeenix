
local myname, Squeenix = ...


local f = CreateFrame("Frame", nil, Minimap)
f:SetFrameStrata("LOW")
f:EnableMouse(false)
f:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
f:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
f:EnableMouseWheel(true)
f:SetScript("OnMouseWheel", function(frame, delta)
	if Squeenix.db.noscrollzoom then return end
	if delta > 0 then MinimapZoomIn:Click() elseif delta < 0 then MinimapZoomOut:Click() end
end)

