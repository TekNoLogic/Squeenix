local L = AceLibrary("AceLocale-2.2"):new("SqueenixScrollZoom")
L:RegisterTranslations("enUS", function() return {
	["Mousewheel zoom"] = true,
	["Use mousewheel to control minimap zoom"] = true,
} end)

L:RegisterTranslations("koKR", function() return {
	["Mousewheel zoom"] = "마우스휠 사용",
	["Use mousewheel to control minimap zoom"] = "미니맵을 마우스휠을 사용해서 확대/축소할 수 있습니다",
} end)

local zoom = Squeenix:NewModule("Scroll Zoom")

function zoom:OnInitialize()
	self.db = Squeenix:AcquireDBNamespace("Scroll Zoom")
	Squeenix:RegisterDefaults("Scroll Zoom", "profile", {scroll = true})
	Squeenix.Options.args.scroll = {
		name = L["Mousewheel zoom"],
		type = "toggle",
		desc = L["Use mousewheel to control minimap zoom"],
		get = function() return zoom.db.profile.scroll end,
		set = function(v) zoom.db.profile.scroll = v end,
	}

	local MinimapZoom = CreateFrame("Frame", nil, Minimap)
	MinimapZoom:SetFrameStrata("LOW")
	MinimapZoom:EnableMouse(false)
	MinimapZoom:SetPoint("TOPLEFT", Minimap, "TOPLEFT")
	MinimapZoom:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT")
	MinimapZoom:EnableMouseWheel(true)
	MinimapZoom:SetScript("OnMouseWheel", function()
		if not zoom.db.profile.scroll then return end
		if arg1 > 0 then MinimapZoomIn:Click()
		elseif arg1 < 0 then MinimapZoomOut:Click() end
	end)
end

