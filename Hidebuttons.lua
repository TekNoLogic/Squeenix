
local myname, Squeenix = ...


----------------------
--      Locals      --
----------------------

local tekcheck = LibStub("tekKonfig-Checkbox")
local GAP = 8
local frames = {
	GameTimeFrame = "calendar",
	MinimapZoneTextButton = "zone text",
	MiniMapWorldMapButton = "world map",
	MiniMapVoiceChatFrame = "voice chat",
	MiniMapTracking = "tracking",
	TimeManagerClockButton = "clock",
}
Squeenix.hidesetupframes = {
	GarrisonLandingPageMinimapButton = "garrison",
	GuildInstanceDifficulty = "guild dungeon mode",
	MiniMapChallengeMode = "challenge mode",
	MiniMapInstanceDifficulty = "dungeon mode",
}
for i,v in pairs(frames) do Squeenix.hidesetupframes[i] = v end


------------------------------
--      Initialization      --
------------------------------

local mailshow, diffshow = MiniMapMailFrame.Show, MiniMapInstanceDifficulty.Show
local garryparent = GarrisonLandingPageMinimapButton:GetParent()
local garryhider = CreateFrame("Frame", nil, garryparent)
garryhider:Hide()

function Squeenix:HideButtons()
	if self.db.hideMinimapZoom then
		MinimapZoomIn:Hide()
		MinimapZoomOut:Hide()
	else
		MinimapZoomIn:Show()
		MinimapZoomOut:Show()
	end

	if self.db.hideMiniMapMailFrame then
		MiniMapMailFrame.Show = MiniMapMailFrame.Hide
		MiniMapMailFrame:Hide()
	else
		MiniMapMailFrame.Show = mailshow
		if HasNewMail() then MiniMapMailFrame:Show() end
	end

	if self.db.hideMiniMapInstanceDifficulty then
		MiniMapInstanceDifficulty.Show = MiniMapInstanceDifficulty.Hide
		MiniMapInstanceDifficulty:Hide()
	else
		MiniMapInstanceDifficulty.Show = diffshow
		MiniMapInstanceDifficulty_OnEvent(MiniMapInstanceDifficulty)
	end

	if self.db.hideGarrisonLandingPageMinimapButton then
		GarrisonLandingPageMinimapButton:SetParent(garryhider)
	else
		GarrisonLandingPageMinimapButton:SetParent(garryparent)
	end

	for name in pairs(frames) do
		if _G[name] then
			if self.db["hide"..name] then _G[name]:Hide() else _G[name]:Show() end
		end
	end
end
