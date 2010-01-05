
local myname, Squeenix = ...


local frames = {Minimap, MinimapZoneTextButton, MinimapToggleButton, GameTimeFrame}


function Squeenix:SetScale()
	for _,f in pairs(frames) do f:SetScale(self.db.scale or 1) end
end
