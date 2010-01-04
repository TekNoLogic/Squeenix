
if not Squeenix then return end


----------------------
--      Locals      --
----------------------

local Squeenix = Squeenix
local tekcheck = LibStub("tekKonfig-Checkbox")
local frames = {GameTimeFrame = "calendar", MinimapZoneTextButton = "zone text", MiniMapWorldMapButton = "world map", MiniMapVoiceChatFrame = "voice chat", MiniMapTracking = "tracking"}
local GAP = 8


------------------------------
--      Initialization      --
------------------------------

local mailshow = MiniMapMailFrame.Show
function Squeenix:HideButtons()
	if self.db.hideMinimapZoom then MinimapZoomIn:Hide(); MinimapZoomOut:Hide() else MinimapZoomIn:Show(); MinimapZoomOut:Show() end
	if self.db.hideMiniMapMailFrame then
		MiniMapMailFrame.Show = MiniMapMailFrame.Hide
		MiniMapMailFrame:Hide()
	else
		MiniMapMailFrame.Show = mailshow
		if HasNewMail() then MiniMapMailFrame:Show() end
	end
	for name in pairs(frames) do
		if self.db["hide"..name] then _G[name]:Hide() else _G[name]:Show() end
	end
end


---------------------
--      Panel      --
---------------------

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Minimap buttons"
frame.parent = "Squeenix"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local Squeenix = Squeenix
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Squeenix - Minimap buttons", "These settings allow you to hide the various buttons attached to the minimap.")


	local zoom = tekcheck.new(frame, nil, "Show zoom buttons", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	local checksound = zoom:GetScript("OnClick")
	zoom:SetScript("OnClick", function(self) checksound(self); Squeenix.db.hideMinimapZoom = not Squeenix.db.hideMinimapZoom; Squeenix:HideButtons() end)
	zoom:SetChecked(not Squeenix.db.hideMinimapZoom)


	local mail = tekcheck.new(frame, nil, "Show new mail indicator", "TOPLEFT", zoom, "BOTTOMLEFT", 0, -GAP)
	mail:SetScript("OnClick", function(self) checksound(self); Squeenix.db.hideMiniMapMailFrame = not Squeenix.db.hideMiniMapMailFrame; Squeenix:HideButtons() end)
	mail:SetChecked(not Squeenix.db.hideMiniMapMailFrame)


	local anchor = mail
	for name,desc in pairs(frames) do
		local check = tekcheck.new(frame, nil, "Show "..desc, "TOPLEFT", anchor, "BOTTOMLEFT", 0, -GAP)
		check:SetScript("OnClick", function(self) checksound(self); Squeenix.db["hide"..name] = not Squeenix.db["hide"..name]; Squeenix:HideButtons() end)
		check:SetChecked(not Squeenix.db["hide"..name])
		anchor = check
	end


	frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)

