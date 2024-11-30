--[[

   ____       _  __     ___
  / ___| ___ | |_\ \   / (_) _____      _____ _ __
 | |  _ / _ \| '_ \ \ / /| |/ _ \ \ /\ / / _ \ '__|
 | |_| | (_) | |_) \ V / | |  __/\ V  V /  __/ |
  \____|\___/|_.__/ \_/  |_|\___| \_/\_/ \___|_|

               by Warli 🇫🇷 for Epsilon
---------------------------------------------------------

Hi! Enter here at you're own risk, you will probably see some bad code.
Let me know if you have any better ways to do anything you see in there!
I should probably work on getting it more readable...

A fraction of this code is based on the Brikabrok's model viewer.
Brikabrok was an all-in-one addon created by BinarySpace for Kuretar, a french GM-RP server (RIP 20/03/2024).

## Thanks: BinarySpace, Prosper, EpsilonDevTeam

]]

local addonName, utils = ...
local StdUi = LibStub('StdUi');
StdUi.config = utils.config
print("\124cFF4594C1[Epsilon_Viewer]\124r | /epsilonviewer - /viewer")


local default = {
   sessions = 0,
   columns = 4,
   rows = 2,
   maxgobs = 5000,
   catalogNameList = { {text = 'Default', value = 1}, },
   userCatalogs = {},
   includeEpsilonTiles = true
}

local object_name_replacements = {
	["eps_secret"] = "eps",
	["secret_eps"] = "eps",
}

local function perform_name_replacements(text)
	for pat, repl in pairs(object_name_replacements) do
		text = text:gsub(pat, repl)
	end
	return text
end

local object_names_hidden = {
	-- Broken objects, so hide them from viewer until they're fixed :(
	-- Warning: Broken objects may crash client when displayed
	"alphabet_caligo",
	"alphabet_futhark",
	"alphabet_mechanical",
	"alphabet_morpheus",
	"alphabet_romansd",
	"alphabet_suastornad",
}

local function OnEvent(self, event, addOnName)
   if addOnName == addonName then
      Epsilon_ViewerDB = Epsilon_ViewerDB or {}
      self.db = Epsilon_ViewerDB
      self:InitializeOptions()
      for k, v in pairs(default) do
         if self.db[k] == nil then
            self.db[k] = v
         end
      end
      self.db.sessions = self.db.sessions + 1
   end
end

local g = CreateFrame("Frame")

function g:InitializeOptions() --Interfaces options
   self.panel = CreateFrame("Frame")
   self.panel.name = "Epsilon_Viewer"

   local OptionsLabel = StdUi:Label(self.panel, "Epsilon_Viewer - Options")
   StdUi:GlueTop(OptionsLabel, self.panel, 0, -10)
   local OptionsLabel2 = StdUi:Label(self.panel, "A reload is needed when changing any options here.")
   StdUi:GlueTop(OptionsLabel2, self.panel, 0, -25)

   local sliderRows = CreateFrame("Slider", "Number of Rows", self.panel, "OptionsSliderTemplate")
   sliderRows:SetPoint("TOP", 0, -60)
   sliderRows:SetWidth(300)
   sliderRows:SetHeight(20)
   sliderRows:SetOrientation('HORIZONTAL')
   sliderRows:SetMinMaxValues(1, 4)
   sliderRows:SetValueStep(1)
   if g.db.rows == nil then sliderRows:SetValue(2, true) g.db.rows = default.rows else sliderRows:SetValue(g.db.rows, true) end --Bad, i know
   sliderRows:SetEnabled(true)
   sliderRows:SetObeyStepOnDrag(true)
   _G[sliderRows:GetName() .. 'Low']:SetText('1')
   _G[sliderRows:GetName() .. 'High']:SetText('4')
   sliderRows:Show()

   local sliderRowsLabel = StdUi:Label(sliderRows, "Numbers of Rows : "..g.db.rows)
   StdUi:GlueAbove(sliderRowsLabel, sliderRows, 0, 0)

   sliderRows:SetScript("OnValueChanged", function(self,value,userInput)
      if userInput then
         sliderRowsLabel:SetText("Numbers of Rows: "..value)
         g.db.rows = value
      end
   end)

   local sliderColumns = CreateFrame("Slider", "Number of Columns", self.panel, "OptionsSliderTemplate")
   sliderColumns:SetPoint("TOP", 0, -110)
   sliderColumns:SetWidth(300)
   sliderColumns:SetHeight(20)
   sliderColumns:SetOrientation('HORIZONTAL')
   sliderColumns:SetMinMaxValues(1, 4)
   sliderColumns:SetValueStep(1)
   if g.db.columns == nil then sliderColumns:SetValue(4, true) g.db.columns=default.columns else sliderColumns:SetValue(g.db.columns, true) end --Bad, i know
   sliderColumns:SetEnabled(true)
   sliderColumns:SetObeyStepOnDrag(true)
   _G[sliderColumns:GetName() .. 'Low']:SetText('1')
   _G[sliderColumns:GetName() .. 'High']:SetText('4')
   sliderColumns:Show()

   local sliderColumnsLabel = StdUi:Label(sliderColumns, "Numbers of Columns : "..g.db.columns)
   StdUi:GlueAbove(sliderColumnsLabel, sliderColumns, 0, 5)

   sliderColumns:SetScript("OnValueChanged", function(self,value,userInput)
      if userInput then
         sliderColumnsLabel:SetText("Numbers of Columns: "..value)
         g.db.columns = value
      end
   end)

   InterfaceOptions_AddCategory(self.panel)

end


g:RegisterEvent("ADDON_LOADED")
g:SetScript("OnEvent", OnEvent)

local isOVOpen = nil
local function toggleOV(frame)
   if not isOVOpen then
      isOVOpen = frame
   elseif isOVOpen:IsVisible() then
      isOVOpen:Hide()
   else
      isOVOpen:Show()
   end
end

local currentCatalog = nil

local function selectedCatalog(value)
   if value > 1 then
      local n = value - 1
      currentCatalog = g.db.userCatalogs[n]
   else
      currentCatalog = nil
   end
end

-- This searches a string to see if it contains ANY of the items in the filter array. I.e., searching a ban list and hiding if it matches any of the banned names
local function searchStringForAnyFilterItem(text, filterArray)
	if #filterArray == 0 then
		return true
	end

	for _, filter in pairs(filterArray) do
		if text:find(filter) then
			return true
		end
	end
	return false
end

-- This searches a string to see if it contains ALL of the items in the filter array. I.e., searching a gob name for two different name parts to find only objects with those keywords
local function searchStringForAllFilterItems(text, filterArray)
   if #filterArray == 0 then
      return true
   end

   -- Run through each searchTerm in the filterArray, and check if it does not exist - if found, continue, if not, return false out
   for _, filter in pairs(filterArray) do
      if not string.find(text, filter) then
         return false
      end
   end

   -- Made it through the whole search and did not fail, so return true
   return true
end

---@param text string the text to search inside
---@param token_string string the token string, i.e., "chair void"
local function tokenizedSearch(text, token_string)
	local filterItems = strsplittable(" ", token_string)
	return searchStringForAllFilterItems(text, filterItems)
end


--local function getListFromEpsilon(filter, filterArray, maxgobs) --C_Epsilon is the best
local function getListFromEpsilon(filter, maxgobs) --C_Epsilon is the best
   currentCatalog = {}

   for i = 0, C_Epsilon.GODI_Search(filter)-1 do -- 0 indexed
      if i > maxgobs then print("\124cFF4594C1[Epsilon_Viewer]\124r - Too much result ("..maxgobs.."+), ending the search.") break; end
      local result = C_Epsilon.GODI_RetrieveSearch(i)
      if not currentCatalog[result.fileid] then
		if not string.find(result.name, "%.wmo") then -- No WMOs!!
		if (not searchStringForAnyFilterItem(result.name, object_names_hidden)) then

				result.name = perform_name_replacements(result.name)

				currentCatalog[result.fileid] = result
				currentCatalog[result.fileid].entries = {} --for future usage
			end
		end
         --[[
      else
         local insert = {text = result.displayid, value = #currentCatalog[result.fileid].entries+1}
         tinsert(currentCatalog[result.fileid].entries, insert)
         ]]
      end
   end
end

---Get's the name of a gob by either fid or gobData if provided. FileID must be from a currentCatalog, cannot access the GODI results directly
---@param fid number
---@param gobData? table
---@return string
local function getGobName(fid, gobData)

	if gobData and type(gobData) == "table" and gobData.name then return gobData.name end

   if fid == 1 or fid == false then
      return " "
   elseif fid == 130738 then
      return "talktomequestionmark.m2" --Since i'm not using the GobList anymore, need to make sure of that.
   else
	  if not currentCatalog or not currentCatalog[fid] then return "(no name found)" end
      --local baseName = currentCatalog[fid].name or "(no name found)"
      --local gobName = string.match(baseName, ".*/(.-%.m2)")
      local gobName = currentCatalog[fid].name or "(no name found)"
      return gobName
   end
end

--[[ Don't need this anymore
local function getGobPath(fid)
   if fid == 1 then
      return " "
   elseif fid == 130738 then
      return "talktomequestionmark.m2" --Since i'm not using the GobList anymore, need to make sure of that.
   else
      local baseName = currentCatalog[fid].name or currentCatalog[fid]
      local gobPath = string.match(baseName, "(.-%.m2)")
      return gobPath
   end
end]]

local function getGobList(filter, catalogValue, maxgobs, epstiles)  --Filter to build resultTable
   --no filter or bad filter
   local usedList = currentCatalog
   local resultList = {}
   local firstKeyword = strsplit(" ", filter)

   if (filter == nil or filter:len() < 2) and catalogValue == 1 then
      return nil
   elseif catalogValue > 1 then --Will permit no filter to show every gob in a catalog if it's not the default one.
      for iFileData, gobData in pairs(usedList) do
         local gobName = getGobName(iFileData)
         if (filter == nil or filter:len() < 2) or tokenizedSearch(gobName:lower(), filter) then --string.match(gobName:lower(), filter) then
            if not epstiles then --don't insert if includeEpsilonTiles is false
               if not string.match(gobName:lower(), 'buildingtile') and not string.match(gobName:lower(), 'buildingplane') then
                  tinsert(resultList, {fid = iFileData, name = gobName, displayid = gobData.displayid--[[, entries = gobData.entries]]})
               end
            else
               tinsert(resultList, {fid = iFileData, name = gobName, displayid = gobData.displayid--[[, entries = gobData.entries]]})
            end
         end
      end
   else
      --getListFromEpsilon(filter, filterArray, maxgobs)
	  getListFromEpsilon(filter, maxgobs)
      usedList = currentCatalog
      for iFileData, gobData in pairs (usedList) do
         local gobName = getGobName(iFileData)
         if tokenizedSearch(gobName:lower(), filter) then
            if not epstiles then  --don't insert if includeEpsilonTiles is false
               if not string.match(gobName:lower(), 'buildingtile') and not string.match(gobName:lower(), 'buildingplane') then
                  tinsert(resultList, {fid = iFileData, name = gobName, displayid = gobData.displayid--[[, entries = gobData.entries]]})
               end
            else
               tinsert(resultList, {fid = iFileData, name = gobName, displayid = gobData.displayid--[[, entries = gobData.entries]]})
            end
         else --remove from Epsilon's results catalog the unwanted results
            currentCatalog[iFileData] = nil
         end
      end
   end

   table.sort(resultList, function(a, b)
      return a.name < b.name
   end)

   return resultList

end

local function divideGobList(rawList, c, r)

   if rawList == nil then return nil end
   local finalList = {}
   local maxGobInGrid = c * r
   local numberOfPage =  math.ceil(#rawList / maxGobInGrid)
   if numberOfPage < 1 then numberOfPage = 1 end
   for i = 1, numberOfPage do
      finalList[i] = {}

      for j = 1, maxGobInGrid do

         if #rawList < maxGobInGrid then
            local gobToAdd = maxGobInGrid - #rawList
            for holder = 1, gobToAdd do
               tinsert(rawList, {fid = false}) --placeHolder (talktomequestionmark.m2) if not enough gob, bad but it will do for now.
            end
         end


         local removed = table.remove(rawList, 1)
         --print(LibParse:JSONEncode(removed))
         tinsert(finalList[i], removed)
      end
   end

   return finalList

end

local function setSpawnTooltip(self, gridObject, gobData)
   local null = {}
   if not gobData then gobData = null end
   local gobName = (gobData and gobData.name) or (gridObject.gobData and gridObject.gobData.name) or getGobName(gridObject:GetModelFileID())
   local gobDisplay = (gobData and gobData.displayid) or (gridObject.gobData and gridObject.gobData.displayid) or 804602
   --self:SetText(("Left Click to Spawn %s (%s)\nRight Click to select others versions"):format(getGobName(gridObject:GetModelFileID()), gobData.displayid or 804602))
   self:SetText(("Left Click to Spawn %s (%s).\nRight Click to lookup."):format(gobName, gobDisplay))
end

local fakePaginationGODITableOffset = 1
local numPerPage = 8

local page_meta = {
	__index = function(tbl, key)
		if type(key) ~= "number" then return tbl[key] end
		local realEntry = (fakePaginationGODITableOffset + key) - 1

		if realEntry > (C_Epsilon.GODI_Count()-1) then
			return { fid = false }
		end

		local GODI_Data = C_Epsilon.GODI_Get(realEntry)
		GODI_Data.fid = GODI_Data.fileid
		return GODI_Data
	end,
}
local genericPageTable = setmetatable({}, page_meta)

local top_meta = {
	__index = function(tbl, key)
		if type(key) ~= "number" then return tbl[key] end
		fakePaginationGODITableOffset = (key-1)*numPerPage
		return genericPageTable
	end,
}

local fakePaginationGODITable = setmetatable({}, top_meta)
local function getGODIPageCount()
	return math.ceil((C_Epsilon.GODI_Count()-1)/numPerPage)
end
getGODIPageCount()

local function ShowGobBrowser()

   local columns = g.db.columns;
   local rows = g.db.rows;
   local maxgobs = g.db.maxgobs or 5000
   includeEpsilonTiles = g.db.includeEpsilonTiles
   local currentGobList = {}
   local selectedGobs = {}
   local currentPage = 1


   local gobFrame = utils.Window(UIParent, 1000, 700, 'GameObject Viewer');
   gobFrame:Show()

   StdUi:EasyLayout(gobFrame, {columns = columns, padding = {top = 100, bottom = 60, right = 20}}); --A lot of placeholder in there


   local gameObjectsGrid = {} --will be all the gob in the rows. So gameObjectsGrid[1][2] will be the identifier for the second preview in the first row.

   local model_actor_OnModelLoaded = function(self)
	local x1, y1, z1, x2, y2, z2 = self:GetActiveBoundingBox()
	if x2 == nil then return end
	local lx = x2 - x1
	local ly = y2 - y1
	local lz = z2 - z1
	local size = math.sqrt(lx ^ 2 + ly ^ 2 + lz ^ 2) * 1.5
	local angle = math.max(lx, ly) < lz and 45 / 3 or 45 / 2
	local camera = self:GetParent():GetActiveCamera()
	camera:SetPitch(math.rad(angle))
	camera:SetYaw(0)
	camera:SetRoll(0)
	camera:SetTarget(0, 0, 0)
	camera:SetMinZoomDistance(size * 0.5)
	camera:SetMaxZoomDistance(size * 2)
	camera:SetZoomDistance(size * 1.1)
	camera:SnapAllInterpolatedValues();

	-- Always face slightly left
	self:SetYaw(math.pi/1.2)
   end

   for i = 1, g.db.rows do
      local r = gobFrame:AddRow(); --will add a row for each rows
      gameObjectsGrid[i] = {} --first identifier

      for j = 1, g.db.columns do
         --local g = CreateFrame("DressUpModel", nil, gobFrame, "ModelWithZoomTemplate") --create a frame to show the models
         local _modelScene = CreateFrame("ModelScene", nil, gobFrame, "ModelSceneMixinTemplate")
		 local actor = _modelScene:CreateActor(nil, "ModelSceneActorTemplate")

		 actor.onModelLoadedCallback = model_actor_OnModelLoaded

		 actor:SetModelByFileID(130738) --"interface/buttons/talktomequestionmark.m2"
		 actor:SetUseCenterForOrigin(true, true, true)

		 actor._modelScene = _modelScene

		 _modelScene:SetCameraNearClip(0.01)
		 _modelScene:SetCameraFarClip(2 ^ 64)
		 _modelScene.Camera = _modelScene:CreateCameraFromScene(114)
		 _modelScene.Camera:SetPitch(0)
		 _modelScene.Actor = actor

		 local camera = _modelScene.Camera
		 camera:SetRightMouseButtonXMode(ORBIT_CAMERA_MOUSE_PAN_HORIZONTAL, true);
    	 camera:SetRightMouseButtonYMode(ORBIT_CAMERA_MOUSE_PAN_VERTICAL, true);
		 camera:SetLeftMouseButtonYMode(ORBIT_CAMERA_MOUSE_MODE_PITCH_ROTATION, true);
		 camera.OnUpdate = function(self, elapsed) -- override
			if self:IsLeftMouseButtonDown() then
				local deltaX, deltaY = GetScaledCursorDelta();
				if IsShiftKeyDown() then
					self:HandleMouseMovement(ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION, deltaX * self:GetDeltaModifierForCameraMode(ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION), not self.buttonModes.leftXinterpolate);
					self:HandleMouseMovement(ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION, -deltaY * self:GetDeltaModifierForCameraMode(ORBIT_CAMERA_MOUSE_MODE_ROLL_ROTATION), not self.buttonModes.leftYinterpolate);
				else
					self:HandleMouseMovement(self.buttonModes.leftX, deltaX * self:GetDeltaModifierForCameraMode(self.buttonModes.leftX), not self.buttonModes.leftXinterpolate);
					self:HandleMouseMovement(self.buttonModes.leftY, deltaY * self:GetDeltaModifierForCameraMode(self.buttonModes.leftY), not self.buttonModes.leftYinterpolate);
				end
			end

			if self:IsRightMouseButtonDown() then
				local deltaX, deltaY = GetScaledCursorDelta();
				self:HandleMouseMovement(self.buttonModes.rightX, deltaX * self:GetDeltaModifierForCameraMode(self.buttonModes.rightX), not self.buttonModes.rightXinterpolate);
				self:HandleMouseMovement(self.buttonModes.rightY, -deltaY * self:GetDeltaModifierForCameraMode(self.buttonModes.rightY), not self.buttonModes.rightYinterpolate);
			end

			self:UpdateInterpolationTargets(elapsed);
			self:SynchronizeCamera();
		end


		 -- Pass thru functions for the actor:
		 function _modelScene:SetModel(id)
			actor:SetModelByFileID(id)
		 end
		 function _modelScene:GetModelFileID()
			return actor:GetModelFileID()
		 end

          --Zoom of the gob
		  --[[
         g:SetPortraitZoom(0)
         local camdistance = 3;
         g:SetCamDistanceScale(camdistance)
		 --]]

		 local g = _modelScene
          --allow the interface to adapt
         local gHSize = 250
         local gWSize = 250
         gHSize = gHSize * (4/columns)
         gWSize = gWSize * (2/rows)
         g:SetSize(gHSize, gWSize)

         g.texture = g:CreateTexture()
         g.texture:SetPoint("CENTER")
         g.texture:SetSize(g:GetWidth(), g:GetHeight()+60)
         --g.texture:SetTexture("Interface\\AddOns\\Epsilon_Viewer\\assets\\EpsiIndexObjectFrameLarge")

         tinsert(gameObjectsGrid[i], g); --create the second identifier.


         --Zoom
		 --[[
         gameObjectsGrid[i][j].camdistance = camdistance
         g:SetScript('OnMouseWheel', function(self, value)
            if value == 1 then --scrolling up
               gameObjectsGrid[i][j].camdistance = gameObjectsGrid[i][j].camdistance - 0.5
               if gameObjectsGrid[i][j].camdistance < 0.5 then gameObjectsGrid[i][j].camdistance = 0.5 end
               g:SetCamDistanceScale(gameObjectsGrid[i][j].camdistance)
            else --scrolling down
               gameObjectsGrid[i][j].camdistance = gameObjectsGrid[i][j].camdistance + 0.5
               if gameObjectsGrid[i][j].camdistance > 15 then gameObjectsGrid[i][j].camdistance = 15 end
               g:SetCamDistanceScale(gameObjectsGrid[i][j].camdistance)
            end
         end);
		 --]]

         local gobName = getGobName(g:GetModelFileID()) --Keep only the name of the game object
         local textSize = 10
         if columns > 4 then textSize = textSize * (4 / columns) end
         gameObjectsGrid[i][j].label = StdUi:Label(g, gobName, textSize);
         StdUi:GlueTop(gameObjectsGrid[i][j].label, gameObjectsGrid[i][j], 0, 0);

         --Button for gob selection
         local ButtonWSize = 60
         local ButtonHSize = 20
         if columns > 4 then ButtonWSize = (ButtonWSize * (4/columns)) ButtonHSize = (ButtonHSize * (2/rows)) end
         gameObjectsGrid[i][j].buttonSelect = StdUi:Button(g, ButtonWSize, ButtonHSize, "Select");
         gameObjectsGrid[i][j].buttonSelect:SetHighlightTexture("interface\\buttons\\ui-listbox-highlight.blp","ADD")
         StdUi:GlueBottom(gameObjectsGrid[i][j].buttonSelect, g, (40 * (4/columns)), 0, "LEFT");
         gameObjectsGrid[i][j].buttonSelect:SetScript("OnClick", function()


            local isGobAlreadyInThere = false --In case someone want to glitch it.
            for k, v in pairs(selectedGobs) do
               if gameObjectsGrid[i][j].label:GetText() == getGobName(v.id, {name = v.name}) then
                  isGobAlreadyInThere = true
               end
            end

            if not gameObjectsGrid[i][j].buttonSelect.selected and not isGobAlreadyInThere then
                  gameObjectsGrid[i][j].buttonSelect.selected = true
                  gameObjectsGrid[i][j].buttonSelect:LockHighlight()
                  tinsert(selectedGobs, { id = gameObjectsGrid[i][j]:GetModelFileID(), displayid = gameObjectsGrid[i][j].gobData.displayid, name = gameObjectsGrid[i][j].gobData.name --[[, entries = gameObjectsGrid[i][j].gobData.entries]]} )
            elseif gameObjectsGrid[i][j].buttonSelect.selected then
               gameObjectsGrid[i][j].buttonSelect.selected = false
               gameObjectsGrid[i][j].buttonSelect:UnlockHighlight()
               local idPos
               for k, v in ipairs(selectedGobs) do
                  if v.id == gameObjectsGrid[i][j]:GetModelFileID() then
                     table.remove(selectedGobs, k)
                  end
               end
            else
               print("\124cFF4594C1[Epsilon_Viewer]\124r - Can't select the same gob twice.")
            end
         end)
         StdUi:FrameTooltip(gameObjectsGrid[i][j].buttonSelect, "Select this object to Add/Rmv from Catalog", "gobvwr_button_sel_tt_"..i..j, "TOPRIGHT", true)

         --Button for gob spawn
         gameObjectsGrid[i][j].buttonSpawn = StdUi:Button(g, ButtonWSize, ButtonHSize, "Spawn");
         --gameObjectsGrid[i][j].displayidDropdown = StdUi:Dropdown(gameObjectsGrid[i][j].buttonSpawn, ButtonWSize, ButtonHSize, testTable, 1) --displayidDropdown declaration
         gameObjectsGrid[i][j].buttonSpawn:SetHighlightTexture("interface\\buttons\\ui-listbox-highlight.blp","ADD")
         gameObjectsGrid[i][j].buttonSpawn:RegisterForClicks("RightButtonUp", "LeftButtonUp")
         gameObjectsGrid[i][j].buttonSpawn:SetScript("OnClick", function(self, arg1) --Will tell us what button was used to click it.
			local gobData = gameObjectsGrid[i][j].gobData
			local gobName = gobData.name or getGobName(gameObjectsGrid[i][j]:GetModelFileID())
			local gobDisplayID

			if arg1 == "LeftButton" then --Spawning
               if gameObjectsGrid[i][j]:GetModelFileID() == 130738 then gobDisplayID = -804602 else gobDisplayID = gameObjectsGrid[i][j].gobData.displayid end --if talktomequestion_ltblue then displayid is...
               print("\124cFF4594C1[Epsilon_Viewer]\124r - Spawning : "..gobName)
               SendChatMessage(".gob spawn "..gobDisplayID, "GUILD")
            else --Lookup
               --gameObjectsGrid[i][j].displayidDropdown:ToggleOptions()
			   gobName = gobName:gsub("%.m2", ""):gsub("%.wmo", "")
			   local command = ".lookup object "
			   if gobName:find("buildingtile") then
				  command = ".lookup tile "
				  gobName = gobName:gsub("_[0-9]+$", "")
			   elseif gobName:find("buildingplane") then
				  command = ".lookup plane "
				  gobName = gobName:gsub("_[0-9]+$", "")
			   end
			   print("\124cFF4594C1[Epsilon_Viewer]\124r - Searching : "..gobName)
               SendChatMessage(command..gobName, "GUILD")
            end

         end)
         StdUi:GlueBottom(gameObjectsGrid[i][j].buttonSpawn, g, (-40 * (4/columns)), 0, "RIGHT");
         gameObjectsGrid[i][j].buttonSpawn:SetFrameLevel(10) --Force SpawnButton to be on top of displayidDropdown
         gameObjectsGrid[i][j].buttonSpawn.toolTip = StdUi:FrameTooltip(gameObjectsGrid[i][j].buttonSpawn, function(self)
               setSpawnTooltip(self, gameObjectsGrid[i][j], gameObjectsGrid[i][j].gobData)
            end,
            "gobvwr_button_spawn_tt_"..i..j, "TOPRIGHT", true
         )


         --[[

         --Dropdown to select the gob's displayid, declared in buttonspawn.

         gameObjectsGrid[i][j].displayidDropdown:SetFrameLevel(9) --Force spawnButton to be on top
         gameObjectsGrid[i][j].displayidDropdown.optsFrame:SetFrameLevel(11) --but allow the dropdown to overthrow every other button
         StdUi:GlueBottom(gameObjectsGrid[i][j].displayidDropdown, gameObjectsGrid[i][j].buttonSpawn, 0, 0, "RIGHT");

         --Button for lo ob
         gameObjectsGrid[i][j].buttonLob = StdUi:Button(g, ButtonWSize, ButtonHSize, "Lookup");
         gameObjectsGrid[i][j].buttonLob:SetHighlightTexture("interface\\buttons\\ui-listbox-highlight.blp","ADD")
         gameObjectsGrid[i][j].buttonLob:SetScript("OnClick", function()

            local gobName = getGobName(gameObjectsGrid[i][j]:GetModelFileID())
            print("\124cFF4594C1[Epsilon_Viewer]\124r - Searching : "..gobName)
            SendChatMessage(".lo ob "..gobName, "GUILD")

         end)
         StdUi:GlueBottom(gameObjectsGrid[i][j].buttonLob, g, (-40 * (4/columns)), 0, "RIGHT");
         StdUi:FrameTooltip(gameObjectsGrid[i][j].buttonLob, "Click to Lookup this Object", "gobvwr_button_lob_tt_"..i..j, "TOPRIGHT", true)
         ]]



      end

      tinsert(gameObjectsGrid[i], { column = 'even' }); --
      r:AddElements(unpack(gameObjectsGrid[i]));
      --tinsert(rowsGrid, r)

   end




   local currentPageLabel = StdUi:Label(gobFrame, "1/1", 14, nil, 150, 30) --Label indicating page number
   currentPageLabel:SetJustifyH('MIDDLE');

   local gobFrameSlider = StdUi:Slider(gobFrame, 15, 520, 1, true, 1, 1)
   gobFrameSlider:EnableMouseWheel(1)
   gobFrameSlider:SetValueStep(1)
   gobFrameSlider:SetObeyStepOnDrag(true)
   gobFrameSlider:SetFrameLevel(15)
   gobFrameSlider:SetScript("OnMouseWheel", function(self, arg1)

      local value = gobFrameSlider:GetValue()
      if arg1 >= 1 then
         gobFrameSlider:SetValue(value-1)
      else
         gobFrameSlider:SetValue(value+1)
      end

   end)

   local function updateNamesLabel() --Called to update the names
      for i = 1, rows do
         for j = 1, columns do
            local gobName = (gameObjectsGrid[i][j].gobData and gameObjectsGrid[i][j].gobData.name) or getGobName(gameObjectsGrid[i][j]:GetModelFileID())
			if not gobName then gobName = "<no name found>" end
            if string.len(gobName) > 32 then gobName = string.sub(gobName, 1, 32)..".." end
            gameObjectsGrid[i][j].label:SetText(gobName);

            setSpawnTooltip(gameObjectsGrid[i][j].buttonSpawn.toolTip, gameObjectsGrid[i][j], gameObjectsGrid[i][j].gobData)
         end
      end
   end

   local function updateGobGrid(resultList, page)
      if resultList == nil then return nil end
      local localResult = utils.deepcopy(resultList)
      for i = 1, rows do
         for j = 1, columns do
         -- index is the current column plus the colums of all previous rows
         local index = j + ((i - 1) * columns)
            --print(LibParse:JSONEncode(localResult[page]))
			local resultData = localResult[page][index]

			local gobName = resultData.name or getGobName(resultData.fid)
			if gobName == "" then gobName = ("<INVALID DISPLAY-%s>"):format(resultData.fid) end
			if not gobName:find("%.m2") then
				gameObjectsGrid[i][j]:SetModel(130738)
			else
				gameObjectsGrid[i][j]:SetModel(resultData.fid)
			end
            --gameObjectsGrid[i][j].camdistance = 3
            --gameObjectsGrid[i][j]:SetCamDistanceScale(3)
            gameObjectsGrid[i][j].buttonSelect.selected = false
            gameObjectsGrid[i][j].buttonSelect:UnlockHighlight()
			--gameObjectsGrid[i][j].label:SetText(gobName)
            gameObjectsGrid[i][j].gobData = resultData

			setSpawnTooltip(gameObjectsGrid[i][j].buttonSpawn.toolTip, gameObjectsGrid[i][j], resultData)

         end
      end
      updateNamesLabel()
      currentPage = page
	  selectedGobs = {}
	  local numPages = ((resultList == fakePaginationGODITable) and getGODIPageCount()) or #localResult
      currentPageLabel:SetText(page..'/'..numPages)
      gobFrameSlider:SetMinMaxValues(1, numPages)
      if currentPage == 1 then
         gobFrameSlider:SetValue(1)
      end

   end

   gobFrameSlider:SetScript("OnValueChanged", function(self,value,userInput)

      if value ~= currentPage then
         updateGobGrid(currentGobList, value)
      end

   end)


   local catalogListScrollDown = StdUi:Dropdown(gobFrame, 140, 30, g.db.catalogNameList, 1) --List all catalogs so that the player can chose which one he wants
   catalogListScrollDown.OnValueChanged = function(self, value)

      if value > 1 then --if not default, show everything in the catalog

         selectedCatalog(value)
         currentGobList = divideGobList(getGobList(" ", value, maxgobs, includeEpsilonTiles), columns, rows)
         updateGobGrid(currentGobList, 1)

      else --if default, show all objects using the fakePaginationGODITable system

         selectedCatalog(value)
		 currentGobList = fakePaginationGODITable
         updateGobGrid(currentGobList, 1)

      end

   end;


   local function deleteCatalog(catalogValue)
      -- Verify if catalog's position is valid
      if catalogValue > 1 and catalogValue <= #g.db.catalogNameList then
         -- Delete the displayid of catalogNameList
         local deletedName = g.db.catalogNameList[catalogValue].text
         table.remove(g.db.catalogNameList, catalogValue)

         -- Update other's catalog positions
         for _, catalog in ipairs(g.db.catalogNameList) do
               if catalog.value > catalogValue then
                  catalog.value = catalog.value - 1
               end
         end

         -- Delete the displayid in userCatalogs
         catalogValue = catalogValue - 1
         table.remove(g.db.userCatalogs, catalogValue)
         catalogListScrollDown:SetOptions(g.db.catalogNameList)
         catalogListScrollDown:SetValue(1)

         print("\124cFF4594C1[Epsilon_Viewer]\124r - Catalog '"..deletedName.."' deleted successfully.")

      else
         print("\124cFF4594C1[Epsilon_Viewer]\124r - Can't delete the default catalog.")
      end
   end


   local function addCatalog(name)

      if name ~= nil and name:len() > 2 then
         tinsert(g.db.userCatalogs, {})
         local value = #g.db.catalogNameList+1
         tinsert(g.db.catalogNameList, {text = name, value = value})
         catalogListScrollDown:SetOptions(g.db.catalogNameList)
         print("\124cFF4594C1[Epsilon_Viewer]\124r - Catalog '"..name.."' added successfully !")
         return value
      else
         print("\124cFF4594C1[Epsilon_Viewer]\124r - Catalog could not be added, please enter a valid name.")
         return nil
      end

   end

   local function importCatalog(name, importString)

      local catalogPos =  addCatalog(name)
      if catalogPos ~= nil then
         catalogPos = catalogPos - 1
         g.db.userCatalogs[catalogPos] = utils.deserialize(importString)
      end

   end



   local catalogNewOrDelete = StdUi:Button(gobFrame, 120, 30, 'Catalog Manager'); --Catalog Manager, to create and remove catalogs.
   catalogNewOrDelete:SetScript("OnClick", function()

      local catalogManager = utils.Window(UIParent, 300, 500, "Catalog Manager")
      catalogManager:SetFrameLevel(20)
      catalogManager.closeBtn:SetFrameLevel(21)
      catalogManager:Show()



      --Delete a catalog

      local catalogManagerList = StdUi:Dropdown(catalogManager, 225, 30, g.db.catalogNameList, 1)
      catalogManagerList:SetFrameLevel(21)
      local deleteCatalogLabel = StdUi:Label(catalogManager, "-- Delete a Catalog --")
      --deleteCatalogLabel:SetFrameLevel(21)
      local deleteCatalogButton = StdUi:Button(catalogManager, 80, 30, "Confirm")
      deleteCatalogButton:SetScript('OnClick', function()

         local deleteValue = catalogManagerList:GetValue()

         local buttons = {
            confirm = {
               text = "Confirm",
               onClick = function(b)
                  deleteCatalog(deleteValue)
                  catalogManagerList:SetOptions(g.db.catalogNameList)
                  catalogManagerList:SetValue(1)
                  b.window:Hide();
                  catalogManager.closeBtn:Click()
               end
            },

            cancel = {
               text = "Cancel",
               onClick = function(b)
                  b.window:Hide();
               end
            }
         }

         StdUi:Confirm("Delete "..g.db.catalogNameList[deleteValue].text.."?", "Are you sure you want to delete this catalog ?", buttons, g.db.catalogNameList[deleteValue].text) --random id, just in case.


      end);
      deleteCatalogButton:SetFrameLevel(21)


      --Add a catalog
      local newCatalogName = StdUi:SimpleEditBox(catalogManager, 225, 30, "Name");
      newCatalogName:SetFrameLevel(21)
      local newCatalogLabel = StdUi:Label(catalogManager, "-- Create a Catalog --")
      --newCatalogLabel:SetFrameLevel(21)
      local newCatalogButton = StdUi:Button(catalogManager, 80, 30, "Confirm")
      newCatalogButton:SetScript('OnClick', function()

         local catalogTitle = newCatalogName:GetText()
         addCatalog(catalogTitle)
         catalogManagerList:SetOptions(g.db.catalogNameList)
         catalogManager.closeBtn:Click()

      end);
      newCatalogButton:SetFrameLevel(21)

      --Rename a Catalog
      local renameCatalogLabel = StdUi:Label(catalogManager, "-- Rename a Catalog --")
      local renameCatalogList = StdUi:Dropdown(catalogManager, 225, 30, g.db.catalogNameList, 1)
      renameCatalogList:SetFrameLevel(21)
      local renameCatalogName = StdUi:SimpleEditBox(catalogManager, 225, 30, "New Catalog's name");
      renameCatalogName:SetFrameLevel(21)
      local renameCatalogButton = StdUi:Button(catalogManager, 80, 30, "Confirm")
      renameCatalogButton:SetScript('OnClick', function()

         local renameValue =  renameCatalogList:GetValue()
         if renameValue > 1 then
            local oldName = g.db.catalogNameList[renameValue].text
            local newName = renameCatalogName:GetText()
            g.db.catalogNameList[renameValue].text = newName
            print("\124cFF4594C1[Epsilon_Viewer]\124r - Changed name of "..oldName.." to "..newName..". ")
            catalogManagerList:SetOptions(g.db.catalogNameList)
            if renameValue == catalogListScrollDown:GetValue() then catalogListScrollDown:SetValue(renameValue, newName) end
            catalogListScrollDown:SetOptions(g.db.catalogNameList)
            catalogManager.closeBtn:Click()
         else
            print("\124cFF4594C1[Epsilon_Viewer]\124r - You can't rename the default catalog. ")
         end

      end);
      renameCatalogButton:SetFrameLevel(21)

      --Positionning
      StdUi:GlueTop(catalogManagerList, catalogManager, 0, -80);
      StdUi:GlueAbove(deleteCatalogLabel, catalogManagerList, 0, 20);
      StdUi:GlueBelow(deleteCatalogButton, catalogManagerList, 0, -20);
      StdUi:GlueBelow(newCatalogName, deleteCatalogButton, 0, -50);
      StdUi:GlueAbove(newCatalogLabel, newCatalogName, 0, 20);
      StdUi:GlueBelow(newCatalogButton, newCatalogName, 0, -20);
      StdUi:GlueAbove(renameCatalogLabel, renameCatalogList, 0, 20);
      StdUi:GlueBelow(renameCatalogList, newCatalogButton, 0, -50);
      StdUi:GlueBelow(renameCatalogName, renameCatalogList, 0, -20);
      StdUi:GlueBelow(renameCatalogButton, renameCatalogName, 0, -20);





   end)


   local function isGobInUserCatalog(value, fid) --Verify if a gob is already in the catalog
      for iFileData, path in pairs(g.db.userCatalogs[value]) do
         if iFileData == fid then return true end
      end
      return false
   end


   local addOrRemoveFromCatalog = StdUi:Button(gobFrame, 70, 30, 'Add/Rmv'); -- Add or Remove Gob(s) from a catalog
   addOrRemoveFromCatalog:RegisterForClicks("RightButtonUp", "LeftButtonUp")
   StdUi:FrameTooltip(addOrRemoveFromCatalog, "Left Click to Add or Remove selected gobs from a catalog.\nRight Click to convert current result to a new catalog.", "gobvwr_button_addrmv", "TOPRIGHT", true)
   addOrRemoveFromCatalog:SetScript("OnClick", function(self, arg1)
      if arg1 == 'LeftButton' then
         if #selectedGobs > 0 then

            local listLabel = "list of selected Gobs:"
            local countOfDot = 0
            local status = 2
            for i, j in pairs(selectedGobs) do
               listLabel = listLabel.." "..(j.name or getGobName(j.id))..";"
               countOfDot = countOfDot + 1 --Window adapt
            end

            if countOfDot > 2 then status = countOfDot end --Yes, it is dumb
            local catalogGOBWindow = utils.Window(UIParent, 320, (200+(status*10)), "Add or Remove")
            catalogGOBWindow:SetFrameLevel(20)
            catalogGOBWindow.closeBtn:SetFrameLevel(21)
            catalogGOBWindow:Show()

            --

            local addOrRemoveLabel = StdUi:Label(catalogGOBWindow, listLabel, 11, nil, 260);
            addOrRemoveLabel:SetJustifyH('MIDDLE');

            local catalogGOBlist = StdUi:Dropdown(catalogGOBWindow, 180, 30, g.db.catalogNameList, 1)
            catalogGOBlist:SetFrameLevel(21)

            local options = {
               {text = "Add", value = 1},
               {text = "Remove", value = 2}
            }

            local optionDropDown = StdUi:Dropdown(catalogGOBWindow, 180, 30, options, 1)
            optionDropDown:SetFrameLevel(21)

            local confirmButton = StdUi:Button(catalogGOBWindow, 180, 20, 'Confirm');
            confirmButton:SetFrameLevel(21)
            confirmButton:SetScript('OnClick', function()

               local value = catalogGOBlist:GetValue() - 1

               if catalogGOBlist:GetValue() ~= 1 then

                  if optionDropDown:GetValue() == 1 then --Add

                     local addedGobs = "\124cFF4594C1[Epsilon_Viewer]\124r - Those gobs were successfully added to the catalog : "
                     local notAddedGobs = "\124cFF4594C1[Epsilon_Viewer]\124r - Those gobs already are in the catalog : "
                     local DoesAnyGobWereAdded = false
                     local WasThereAnyGobInHereAlready = false

                     for i, j in pairs(selectedGobs) do
                        if isGobInUserCatalog(value, j.id) then --Already in there
                           notAddedGobs = notAddedGobs..""..(j.name or getGobName(j.id)).."; "
                           WasThereAnyGobInHereAlready = true
                        else
                           DoesAnyGobWereAdded = true
                           addedGobs = addedGobs..""..(j.name or getGobName(j.id)).."; "
                           g.db.userCatalogs[value][j.id] = { name = (j.name or getGobName(j.id)), displayid = j.displayid--[[, entries = j.entries]]}
                        end
                     end

                     if catalogListScrollDown:GetValue() == (value + 1) then --refresh if same catalog
                        selectedCatalog(catalogListScrollDown:GetValue())
                        currentGobList = divideGobList(getGobList(" ", catalogListScrollDown:GetValue(), maxgobs, includeEpsilonTiles), columns, rows)
                        updateGobGrid(currentGobList, 1)
                     end

                     if DoesAnyGobWereAdded then print(addedGobs) else print(addedGobs.." None.") end
                     if  WasThereAnyGobInHereAlready then print(notAddedGobs) end
                     catalogGOBWindow.closeBtn:Click()

                  else --Remove

                     local removedGobs = "\124cFF4594C1[Epsilon_Viewer]\124r - Those gobs were successfully removed from the catalog : "
                     local gobNotInUserCatalog = "\124cFF4594C1[Epsilon_Viewer]\124r - Those gobs were not in the catalog : "
                     local WasThereAnyRemovedGob = false
                     local WasThereAnyMissingGob = false

                     local confirmOptions = {

                        confirm = {
                           text = 'Confirm',
                           onClick = function(b)
                              for i, j in pairs(selectedGobs) do
                                 if isGobInUserCatalog(value, j.id) then --In there, as expected.
                                    WasThereAnyRemovedGob = true
                                    removedGobs = removedGobs..""..(j.name or getGobName(j.id)).."; "
                                    g.db.userCatalogs[value][j.id] = nil
                                 else
                                    WasThereAnyMissingGob = true
                                    gobNotInUserCatalog = gobNotInUserCatalog..""..(j.name or getGobName(j.id)).."; "
                                 end
                              end
                              if catalogListScrollDown:GetValue() == (value + 1) then --refresh if same catalog
                                 selectedCatalog(catalogListScrollDown:GetValue())
                                 currentGobList = divideGobList(getGobList(" ", catalogListScrollDown:GetValue(), maxgobs, includeEpsilonTiles), columns, rows)
                                 updateGobGrid(currentGobList, 1)
                              end
                              if WasThereAnyRemovedGob then print(removedGobs) else print(removedGobs.." None.") end
                              if WasThereAnyMissingGob then print(gobNotInUserCatalog) end
                              b.window:Hide();
                              catalogGOBWindow.closeBtn:Click()
                           end
                        },

                        cancel = {
                           text = "Cancel",
                           onClick = function(b)
                              b.window:Hide();
                           end
                        }
                     }

                     StdUi:Confirm("Delete all "..countOfDot.." gobs ?", "Are you sure ?", confirmOptions, nil)
                  end

               else print("\124cFF4594C1[Epsilon_Viewer]\124r - You can't add or remove gobs from the Default list.") end

            end)


            StdUi:GlueTop(addOrRemoveLabel, catalogGOBWindow, 0, -40);
            StdUi:GlueAbove(catalogGOBlist, optionDropDown, 0, 10);
            StdUi:GlueAbove(optionDropDown, confirmButton, 0, 10);
            StdUi:GlueBottom(confirmButton, catalogGOBWindow, 0, 20);


         else
            print("\124cFF4594C1[Epsilon_Viewer]\124r - No GOB has been selected.")
         end
      else --if right click, add the whole research as a catalog

         local newCatalogFromSearchResult = utils.Window(UIParent, 250, 150, "Result to Catalog")
         newCatalogFromSearchResult:SetFrameLevel(20)
         newCatalogFromSearchResult.closeBtn:SetFrameLevel(21)
         newCatalogFromSearchResult:Show()

         local AddLabel = StdUi:Label(newCatalogFromSearchResult, "You will create a catalog from your current result, enter a name for it.", 11, nil, 220, 50)
         AddLabel:SetJustifyH('MIDDLE');

         local editBox = StdUi:SimpleEditBox(newCatalogFromSearchResult, 225, 25, "Catalog's Name");
         editBox:SetFrameLevel(21)

         local confirmButton = StdUi:Button(newCatalogFromSearchResult, 80, 30, "Confirm")
         confirmButton:SetFrameLevel(21)
         confirmButton:SetScript('OnClick', function()

            importCatalog(editBox:GetText(), utils.serialize(currentCatalog))
            newCatalogFromSearchResult.closeBtn:Click()

         end)

         StdUi:GlueTop(AddLabel, newCatalogFromSearchResult, -0, -30);
         StdUi:GlueBelow(editBox, AddLabel, 0, 0);
         StdUi:GlueBelow(confirmButton, editBox, 0, -10);
      end

   end)


   local importButton = StdUi:Button(gobFrame, 50, 30, 'Import'); --Import a catalog (not is JSON)
   importButton:SetScript("OnClick", function()

      local importWindow = utils.Window(UIParent, 250, 180, "Catalog Import")
      importWindow:SetFrameLevel(20)
      importWindow.closeBtn:SetFrameLevel(21)
      importWindow:Show()

      local importName = StdUi:SimpleEditBox(importWindow, 225, 25, "Catalog's name");
      importName:SetFrameLevel(21)

      local importString = StdUi:SimpleEditBox(importWindow, 225, 25, "Catalog's table");
      importString:SetFrameLevel(21)

      local confirmButton = StdUi:Button(importWindow, 80, 30, "Import")
      confirmButton:SetScript('OnClick', function()

         local catalogTitle = importName:GetText()
         local catalogString = importString:GetText()
         importCatalog(catalogTitle, catalogString)
         importWindow.closeBtn:Click()

      end);
      confirmButton:SetFrameLevel(21)

      StdUi:GlueTop(importName, importWindow, 0, -50);
      StdUi:GlueBelow(importString, importName, 0, -20);
      StdUi:GlueBelow(confirmButton, importString, 0, -20);

   end)



   local exportButton = StdUi:Button(gobFrame, 50, 30, 'Export'); --Export a catalog (not is JSON)
   exportButton:SetScript("OnClick", function()

      local catalogValue = catalogListScrollDown:GetValue()

      if catalogValue > 1 then
         local catalogName = g.db.catalogNameList[catalogValue].text
         local exportWindow = utils.Window(UIParent, 250, 125, "Export "..catalogName)
         exportWindow:SetFrameLevel(20)
         exportWindow.closeBtn:SetFrameLevel(21)
         exportWindow:Show()
         local catalogValue = catalogValue - 1
         local editBox = StdUi:SimpleEditBox(exportWindow, 225, 25, utils.serialize(g.db.userCatalogs[catalogValue])); --Well, json is a shitty option for that case, glad I fund something else.
         editBox:SetFrameLevel(21)
         StdUi:GlueBottom(editBox, exportWindow, 0, 40)

      else
         print("\124cFF4594C1[Epsilon_Viewer]\124r - You can't export the default catalog ! Trust me, you don't want to do that.")
      end


   end)




   local previousButton = StdUi:SquareButton(gobFrame, 30, 30, 'LEFT'); --Previous page button
   previousButton:SetScript("OnClick", function()
      local numPages = ((currentGobList == fakePaginationGODITable) and getGODIPageCount()) or #currentGobList
      if currentPage > 1 then
         updateGobGrid(currentGobList, currentPage-1)
      else
         updateGobGrid(currentGobList, numPages)
      end
      gobFrameSlider:SetValue(currentPage)
   end)



   local nextButton = StdUi:SquareButton(gobFrame, 30, 30, 'RIGHT'); --Next page button
   nextButton:SetScript("OnClick", function()
      local numPages = ((currentGobList == fakePaginationGODITable) and getGODIPageCount()) or #currentGobList
      if currentPage < numPages then
         updateGobGrid(currentGobList, currentPage+1)
      else
         updateGobGrid(currentGobList, 1)
      end
      gobFrameSlider:SetValue(currentPage)
   end)


   local searchBox = StdUi:SearchEditBox(gobFrame, 400, 30, 'Keywords') --SearchBox
   searchBox:SetFontSize(16);

   local function startSearch()
      local input = searchBox:GetText():lower()
      if input:len() > 1 then
         selectedCatalog(catalogListScrollDown:GetValue())
         currentGobList = divideGobList(getGobList(input, catalogListScrollDown:GetValue(), maxgobs, includeEpsilonTiles), columns, rows)
         updateGobGrid(currentGobList, 1)
	  elseif input:len() == 1 then
		print("\124cFF4594C1[Epsilon_Viewer]\124r - Cannot search for a single letter, sorry. Try again.")
	  else
         selectedCatalog(1)
		 currentGobList = fakePaginationGODITable
         updateGobGrid(currentGobList, 1)
      end
   end

   local searchTimer = C_Timer.NewTimer(0, function() end)
   searchBox:SetScript('OnEnterPressed', function(self)
      searchTimer:Cancel()
	  startSearch()
	  self:ClearFocus()
   end);

   searchBox:HookScript('OnTextChanged', function(self, userInput)
	  if not userInput then return end
	  -- Cancel last timer, start a new one
	  searchTimer:Cancel()
	  searchTimer = C_Timer.NewTimer(1, startSearch)
   end)

   --Search Options
   local searchOptionsShowed = false
   local searchOptionsButton = utils.SquareButton(gobFrame, 30, 30, 'DOWN');
   StdUi:FrameTooltip(searchOptionsButton, "Show searching options.", "gobvwr_button_searchopts", "TOPRIGHT", true)
   local optsFrame = StdUi:Panel(searchOptionsButton, 460, 100)
   optsFrame:SetFrameLevel(22)
   optsFrame:Hide()

   local showEpsTilesCheckBox = StdUi:Checkbox(optsFrame, "Include Epsilon's buildingplanes/buildingtiles in search results.", 400, 50) --Include tiles or not
   showEpsTilesCheckBox:SetChecked(g.db.includeEpsilonTiles)
   showEpsTilesCheckBox.OnValueChanged = function(self, state, value)
      g.db.includeEpsilonTiles = state
      includeEpsilonTiles = state
   end
   StdUi:GlueTop(showEpsTilesCheckBox, optsFrame, 10, 0);

   local sliderMaxGobs = CreateFrame("Slider", "Max GOB Result", optsFrame, "OptionsSliderTemplate") --Max gobs
   sliderMaxGobs:SetWidth(300)
   sliderMaxGobs:SetHeight(20)
   sliderMaxGobs:SetOrientation('HORIZONTAL')
   sliderMaxGobs:SetMinMaxValues(1000, 10000)
   sliderMaxGobs:SetValueStep(100)
   sliderMaxGobs:SetValue(g.db.maxgobs, true)
   sliderMaxGobs:SetEnabled(true)
   sliderMaxGobs:SetObeyStepOnDrag(true)
   _G[sliderMaxGobs:GetName() .. 'Low']:SetText('1000')
   _G[sliderMaxGobs:GetName() .. 'High']:SetText('10000')
   StdUi:GlueBelow(sliderMaxGobs, showEpsTilesCheckBox, 0, -10, 'CENTER')
   sliderMaxGobs:Show()

   local sliderMaxGobsLabel = StdUi:Label(sliderMaxGobs, "Max Gobs in Result: "..g.db.maxgobs)
   StdUi:GlueAbove(sliderMaxGobsLabel, sliderMaxGobs, 0, 5)

   sliderMaxGobs:SetScript("OnValueChanged", function(self,value,userInput)
      if userInput then
         sliderMaxGobsLabel:SetText("Max Gob in Result: "..value)
         g.db.maxgobs = value
         maxgobs = value
      end
   end)


   searchOptionsButton:SetScript("OnClick", function()

      if not searchOptionsShowed then
         searchOptionsShowed = true
         optsFrame:Show()
      else
         searchOptionsShowed = false
         optsFrame:Hide()
      end

   end)



   local searchButton = utils.SquareButton(gobFrame, 30, 30, "Interface\\AddOns\\Epsilon_Viewer\\assets\\EpsiIndexSearch"); --SearchButton
   searchButton:SetScript("OnClick", function()
      startSearch()
   end)


   --Layout
   StdUi:GlueBottom(currentPageLabel, gobFrame, 0, 10, "CENTER");
   StdUi:GlueTop(searchBox, gobFrame, 35, -40, 'LEFT');
   StdUi:GlueRight(searchButton, searchBox, 0, 0);
   StdUi:GlueRight(searchOptionsButton, searchButton, 0, 0);
   StdUi:GlueBelow(optsFrame, searchOptionsButton, 0, 0, 'RIGHT')
   StdUi:GlueRight(catalogNewOrDelete, searchOptionsButton, 5, 0);
   StdUi:GlueRight(catalogListScrollDown, catalogNewOrDelete, 5, 0);
   StdUi:GlueRight(addOrRemoveFromCatalog, catalogListScrollDown, 5, 0);
   StdUi:GlueRight(importButton, addOrRemoveFromCatalog, 5, 0);
   StdUi:GlueRight(exportButton, importButton, 5, 0);
   StdUi:GlueRight(gobFrameSlider, gobFrame, -10, -20, true)
   StdUi:GlueBottom(previousButton, gobFrame, 25, 10, "LEFT");
   StdUi:GlueBottom(nextButton, gobFrame, -25, 10, "RIGHT");


   gobFrame:DoLayout();
   updateNamesLabel()
   toggleOV(gobFrame)

   currentGobList = fakePaginationGODITable
   updateGobGrid(currentGobList, 1)

   -- Making the models reappear after closing
   gobFrame:HookScript("OnShow", function(self)
      if not currentGobList or #currentGobList <= 1 then --if no search was made before closing
         --currentGobList = divideGobList(getGobList("talktomequestionmark.m2", 1, maxgobs, includeEpsilonTiles), columns, rows)
         --updateGobGrid(currentGobList, 1)
		 currentGobList = fakePaginationGODITable
         updateGobGrid(currentGobList, 1)
      else
         updateGobGrid(currentGobList, currentPage)
      end
   end)


end


SLASH_EPSV1 = "/epsilonviewer"
SLASH_EPSV2 = "/viewer"
SlashCmdList["EPSV"] = function(msg)
   if isOVOpen then
      toggleOV()
   else ShowGobBrowser()
   end
end
