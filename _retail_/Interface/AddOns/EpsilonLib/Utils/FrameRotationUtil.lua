local _, EpsiLib = ...


-- Function to check if the mouse is over the rotated rectangle (aka hitbox region)
local function IsMouseOverRotatedFrame(frame, rotation)
	local fWidth, fHeight = frame.OriginalSize.width, frame.OriginalSize.height

	local mouseX, mouseY = GetCursorPosition()
	local scale = frame:GetEffectiveScale()
	mouseX, mouseY = mouseX / scale, mouseY / scale

	-- Convert rotation to radians
	local radRotation = math.rad(rotation)

	-- Translate mouse coordinates to origin
	local originX = mouseX - frame:GetCenter()
	local originY = mouseY - select(2, frame:GetCenter())

	-- Apply the inverse rotation to the mouse coordinates
	local cos = math.cos(-radRotation)
	local sin = math.sin(-radRotation)
	local rotatedX = originX * cos - originY * sin
	local rotatedY = originX * sin + originY * cos

	-- Translate back
	local translatedX = rotatedX + fWidth / 2
	local translatedY = rotatedY + fHeight / 2

	-- Check if the mouse is within the bounds of the un-rotated rectangle
	return translatedX >= 0 and translatedX <= fWidth
		and translatedY >= 0 and translatedY <= fHeight
end

local function UpdateFrameSizeToFitHitbox(frame, angle)
	if not angle then angle = frame._rotationAngle end
	if not angle then return end

	local width, height = frame.OriginalSize.width, frame.OriginalSize.height

	local centerX, centerY = frame:GetCenter()

	local points = {
		{ centerX - (width / 2), centerY + (height / 2) }, -- TL
		{ centerX + (width / 2), centerY + (height / 2) }, -- TR
		{ centerX + (width / 2), centerY - (height / 2) }, -- BR
		{ centerX - (width / 2), centerY - (height / 2) }, -- BL
	}

	local radians = math.rad(-angle)
	local minX, maxX, minY, maxY

	for i = 1, #points do
		local point = points[i]
		local x, y = point[1], point[2]

		-- Translate coordinates to origin
		local originX = x - frame:GetCenter()
		local originY = y - select(2, frame:GetCenter())

		-- Apply the inverse rotation to the points coordinates
		local cos = math.cos(-radians)
		local sin = math.sin(-radians)

		local rotatedX = (originX * cos - originY * sin)
		local rotatedY = (originX * sin + originY * cos)

		-- Update the actual point data in the points table with the rotated XY positions
		points[i][1] = rotatedX
		points[i][2] = rotatedY

		minX = math.min(rotatedX, (minX and minX or rotatedX))
		minY = math.min(rotatedY, (minY and minY or rotatedY))

		maxX = math.max(rotatedX, (maxX and maxX or rotatedX))
		maxY = math.max(rotatedY, (maxY and maxY or rotatedY))
	end

	-- Store the points for access by other functions as needed
	frame._rotationPoints = points

	local sizeX, sizeY = maxX - minX, maxY - minY
	frame:SetSize(sizeX, sizeY, true)
end

-- Helper Function to generate or update a visual outline around the hitbox region, mostly for debug purposes
local function CreateRotatedRectangleOutline(frame)
	local angle = frame._rotationAngle or 0
	local points = frame._rotationPoints
	if not points then return end

	local lineThickness = 2
	local lines = frame._rotationOutlines or {}

	for i = 1, #points do
		local line = frame._rotationOutlines and frame._rotationOutlines[i] or frame:CreateLine()
		line:SetThickness(lineThickness)
		line:SetColorTexture(1, 1, 1)
		local startPoint = points[i]
		local endPoint = points[i % #points + 1] -- Loop back to the first point
		line:SetStartPoint("CENTER", startPoint[1], startPoint[2])
		line:SetEndPoint("CENTER", endPoint[1], endPoint[2])
		if not lines[i] then table.insert(lines, line) end
		line:Show()
	end
	frame._rotationOutlines = lines

	return lines
end

local RotationFrameMixin = {}

-- Allow updating the angle and/or speed directly
---comment
---@param self Frame|Button
---@param angle any
---@param speed any
---@param updateTextures any
function RotationFrameMixin.SetRotation(self, angle, speed, updateTextures)
	if not angle then angle = self._rotationAngle or 0 end
	if not speed then speed = self._rotationSpeed or nil end

	self._rotationAngle = angle
	self._rotationSpeed = speed
	UpdateFrameSizeToFitHitbox(self, angle)

	if self._rotSyncAngle and self._rotSyncAngle[1] then
		if self._rotSyncAngle[1]:IsShown() then
			CreateRotatedRectangleOutline(self)
		end
	end

	local radAngle = math.rad(angle)

	if not updateTextures then updateTextures = self._rotSyncAngle end
	if updateTextures then
		-- Allow passing a table of your own textures to update as well - must be an array of textures that should be rotated to match.
		if type(updateTextures) == "table" then
			for i = 1, #updateTextures do
				updateTextures[i]:SetRotation(radAngle)
			end
		else
			local normal = self:GetNormalTexture()
			local highlight = self:GetHighlightTexture()
			local pushed = self:GetPushedTexture()

			if normal then normal:SetRotation(radAngle) end
			if highlight then highlight:SetRotation(radAngle) end
			if pushed then pushed:SetRotation(radAngle) end
		end
	end
end

---@param self frame
function RotationFrameMixin.UpdateSize(self, width, height)
	if not self.OriginalSize then self.OriginalSize = {} end
	self.OriginalSize.width = width and width or self.OriginalSize.width
	self.OriginalSize.height = height and height or self.OriginalSize.height

	if self._rotSyncSize then
		for i = 1, #self._rotSyncSize do
			self._rotSyncSize[i]:SetSize(width, height)
		end
	end
end

function RotationFrameMixin.SetSize(self, width, height, custom)
	if not custom then -- came from a non-custom call, meaning we should update the real size...
		self:UpdateSize(width, height)
	end
	self:_OrigSetSize(width, height)
end

function RotationFrameMixin.SyncTextureToAngle(self, tex)
	if not tex then return end
	if not self._rotSyncAngle then self._rotSyncAngle = {} end
	tinsert(self._rotSyncAngle, tex)
end

function RotationFrameMixin.RemoveTextureAngleSync(self, tex)
	if self._rotSyncAngle and tex then
		tDeleteItem(self._rotSyncAngle, tex)
	end
end

function RotationFrameMixin.SyncTextureToRotationRegionSize(self, tex)
	if not tex then return end
	if not self._rotSyncSize then self._rotSyncSize = {} end
	tinsert(self._rotSyncSize, tex)
end

function RotationFrameMixin.RemoveTextureRotationRegionSizeSync(self, tex)
	if self._rotSyncSize and tex then
		tDeleteItem(self._rotSyncSize, tex)
	end
end

function RotationFrameMixin.CreateOutline(self)
	CreateRotatedRectangleOutline(self)
end

function RotationFrameMixin.HideOutline(self)
	for _, v in ipairs(self._rotationOutlines) do
		v:Hide()
	end
end

-- Check if the mouse is over the rotated rectangle
local function _OnUpdate(self, elapsed)
	-- Update the rotation based on elapsed, if a speed is set
	if self._rotationSpeed and self._rotationSpeed > 0 then
		self:SetRotation(self._rotationAngle + (elapsed * self._rotationSpeed))
	end

	-- Only call if the button is not currently pushed.
	if self:GetButtonState() ~= "PUSHED" then
		if self:IsMouseOver() and IsMouseOverRotatedFrame(self, self._rotationAngle) then
			self:EnableMouse(true)
			self._mouseInRotatedRegion = true
		else
			-- Disabling the mouse here means we can allow the mouse to pass-thru when not in the hitbox region
			-- This is needed if you want the button to interact truly like the frame is actually rotated, but is kind of expensive.
			-- To counter, we only call our custom function if the mouse is over the real frame also, which is always adapted to fully contain the rotated button region.
			self:EnableMouse(false)
			self._mouseInRotatedRegion = false
		end
	end

	-- Call the OnUpdate method if present on the frame.
	if self.OnUpdate then self:OnUpdate(elapsed) end
end

local function _OnMouseDown(self, ...)
	if self._mouseInRotatedRegion then
		self:OnMouseDown(...)
	end
end

local function _OnMouseUp(self, ...)
	self:OnMouseUp(...)
end


---Converts a button/frame into our custom Rotatable Button/Frame system.
---@param frame ScriptRegion|Frame
---@param ... Texture
local function InitializeFrameAsRotatable(frame, ...)
	if not frame then error("Must supply a frame to initialize a frame as rotatable .. Duh.") end

	local OriginalSize = { width = frame:GetWidth(), height = frame:GetHeight() }
	frame.OriginalSize = OriginalSize
	frame._rotSyncAngle = frame._rotSyncAngle or {}
	frame._rotSyncSize = frame._rotSyncSize or {}
	frame._OrigSetSize = frame.SetSize

	Mixin(frame, RotationFrameMixin)
	frame:SetScript("OnUpdate", _OnUpdate)
	frame:SetScript("OnMouseDown", _OnMouseDown)
	frame:SetScript("OnMouseUp", _OnMouseUp)

	local textures = { ... }
	if #textures > 0 then
		for i = 1, #textures do
			frame:SyncTextureToAngle(textures[i])
		end
	end
end


EpsiLib.InitializeFrameRotation = InitializeFrameAsRotatable


-- EXAMPLE

local function TEST_ROTATE_FRAME_UTIL()
	-- Your frame here
	local MyFrame = CreateFrame("Button", "MyRotatedFrame", UIParent)
	MyFrame:SetSize(100, 200) -- Set the size of your frame
	MyFrame:SetPoint("CENTER") -- Position it at the center of the screen
	MyFrame:RegisterForMouse("AnyUp", "AnyDown")
	MyFrame:Show()

	local background = MyFrame:CreateTexture()
	background:SetAllPoints(MyFrame)
	background:SetColorTexture(0, 0, 0) -- Set the color of the texture to black
	background:Show()

	local MyTexture = MyFrame:CreateTexture()
	MyTexture:SetPoint("CENTER")
	MyTexture:SetSize(100, 200)
	MyTexture:SetColorTexture(0, 0, 0) -- Set the color of the texture to black
	MyTexture:Show()

	EpsiLib.InitializeFrameRotation(MyFrame, MyTexture)
	MyFrame:SyncTextureToRotationRegionSize(MyTexture)

	CreateRotatedRectangleOutline(MyFrame)

	MyFrame.OnMouseDown = function(self, button)
		MyTexture:SetColorTexture(0, 0, 1, 1)
	end

	MyFrame.OnMouseUp = function(self)
		MyTexture:SetColorTexture(0, 0, 0, 1)
	end

	-- Now let's set a default angle & speed to showcase.
	MyFrame:SetRotation(45, 2)
end
--TEST_ROTATE_FRAME_UTIL()
