
local L = GetLocale() == "koKR" and {
	["Compass"] = "방향지시자",
	["Show compass directions on map frame"] = "미니맵에 방향지시자를 표시합니다",
} or {
	["Compass"] = "Compass",
	["Show compass directions on map frame"] = "Show compass directions on map frame",
}

local frames = {}
local nesw = Squeenix:NewModule("Squeenix-NESW")

function nesw:Initialize()
--~ 	self.db = Squeenix:AcquireDBNamespace("NESW")
--~ 	Squeenix:RegisterDefaults("NESW", "profile", {show = true})
--~ 	Squeenix.Options.args.compass = {
--~ 		name = L["Compass"],
--~ 		type = "toggle",
--~ 		desc = L["Show compass directions on map frame"],
--~ 		handler = self,
--~ 		get = function() return self.db.profile.show end,
--~ 		set = "SetVisible",
--~ 	}

	local f = Minimap
	for dir,anc in pairs({W= "LEFT", S = "BOTTOM", E = "RIGHT", N = "TOP"}) do
		local w = f:CreateFontString()
		w:SetFontObject(GameFontNormal)
		w:SetPoint("CENTER", f, anc)
		w:SetTextColor(1, 1, dir == "N" and 0 or 1)
		w:SetText(dir)
--~ 		if self.db.profile.show then w:Show()
--~ 		else w:Hide() end
		frames[w] = true
	end
end


function nesw:SetVisible(v)
	self.db.profile.show = v
	if v then for f in pairs(frames) do f:Show() end
	else for f in pairs(frames) do f:Hide() end end
end
