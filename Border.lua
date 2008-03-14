local L = GetLocale == "koKR" and {
	["Border style"] = "외곽선",
	["Change the minimap border style"] = "미니맵의 외곽선의 종류를 변경합니다",
} or {
	["Border style"] = true,
	["Change the minimap border style"] = true,
}


local borders = {
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


--~ function Squeenix:InitializeBorder()
--~ 	self.db = Squeenix:AcquireDBNamespace("Border")
--~ 	Squeenix:RegisterDefaults("Border", "profile", {style = "Square"})

--~ 	local borderList = {}
--~ 	for k in pairs(borders) do table.insert(borderList, k) end

--~ 	Squeenix.Options.args.border = {
--~ 		name = L["Border style"],
--~ 		type = "text",
--~ 		desc = L["Change the minimap border style"],
--~ 		handler = self,
--~ 		get = function() return self.db.profile.style end,
--~ 		set = "SetBorder",
--~ 		validate = borderList,
--~ 	}
--~ end


function Squeenix:SetBorder(v)
--~ 	if v then self.db.profile.style = v end
--~ 	border:SetBackdrop(borders[self.db.profile.style])
	border:SetBackdrop(borders["Rounded"])
	border:SetBackdropColor(0,0,0,1)
end




