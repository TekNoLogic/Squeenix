local L = GetLocale() == "koKR" and {
	["Mousewheel zoom"] = "마우스휠 사용",
	["Use mousewheel to control minimap zoom"] = "미니맵을 마우스휠을 사용해서 확대/축소할 수 있습니다",
} or {
	["Mousewheel zoom"] = true,
	["Use mousewheel to control minimap zoom"] = true,
}

local zoom = Squeenix:NewModule("Scroll Zoom")

function zoom:Initialize()
--~ 	self.db = Squeenix:AcquireDBNamespace("Scroll Zoom")
--~ 	Squeenix:RegisterDefaults("Scroll Zoom", "profile", {scroll = true})
--~ 	Squeenix.Options.args.scroll = {
--~ 		name = L["Mousewheel zoom"],
--~ 		type = "toggle",
--~ 		desc = L["Use mousewheel to control minimap zoom"],
--~ 		get = function() return zoom.db.profile.scroll end,
--~ 		set = function(v) zoom.db.profile.scroll = v end,
--~ 	}

	local f = CreateFrame("Frame", nil, Minimap)
	f:SetFrameStrata("LOW")
	f:EnableMouse(false)
	f:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
	f:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
	f:EnableMouseWheel(true)
	f:SetScript("OnMouseWheel", function(frame, delta)
--~ 		if not zoom.db.profile.scroll then return end
		if delta > 0 then MinimapZoomIn:Click()
		elseif delta < 0 then MinimapZoomOut:Click() end
	end)
end

