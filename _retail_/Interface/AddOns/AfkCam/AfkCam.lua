-- CONFIG
local f_camSpeed = .05 -- Arbitrary number that looks good
local b_saveView = true;

-- GLOBALS --
local isAFK = false;
local cameraSmoothing;

-- Start the camera panning
local function StartCameraMovement (speed)
	cameraSmoothing = GetCVar("cameraSmoothStyle");
	if (b_saveView) then
		SaveView(5);
	end
	MoveViewLeftStart(speed);
	UIParent:Hide()
end

-- Stop the camera movement and pan back to original view
local function StopCameraMovement ()
	MoveViewLeftStop();
	if (b_saveView) then
		SetView(5);
		-- ResetView(5);
	end
	UIParent:Show()
	SetCVar("cameraSmoothStyle", cameraSmoothing);
end

-- Check to see if the player (un)AFK'd and call the appropriate function
local function onFlagChange (self, event, ...)
	if (UnitIsAFK("player") and not isAFK) then
	-- Player has become AFK
		if (C_PetBattles.IsInBattle()==false) then
			StartCameraMovement(f_camSpeed);
		end
		--DEFAULT_CHAT_FRAME:AddMessage("AfkCam activated.");
		isAFK = true;
	elseif (not UnitIsAFK("player") and isAFK) then
	-- Player has become un-AFK
		StopCameraMovement();
		--DEFAULT_CHAT_FRAME:AddMessage("AfkCam deactivated.");
		isAFK = false;
	-- else
	-- Player's flag change concerned DND, not becoming AFK or un-AFK
	end
end

local function main ()
	local frame = CreateFrame("FRAME", "AfkCamFrame");
	frame:RegisterEvent("PLAYER_FLAGS_CHANGED"); -- "PLAYER_FLAGS_CHANGED" triggers when a player becomes (un)AFK and (un)DND
	frame:SetScript("OnEvent", onFlagChange);
end

main();