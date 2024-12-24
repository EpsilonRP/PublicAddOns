local EpsilonLib, EpsiLib = ...;


EpsiLib.Utils.Misc = {}
local _misc = EpsiLib.Utils.Misc

-- SimpleHTML with Custom Img Tag Attributes Util

-- mask helper functions
local function removeAllMasks(tex)
	for i = 1, tex:GetNumMaskTextures() do
		tex:RemoveMaskTexture(tex:GetMaskTexture(i))
	end
end

local function maskUp(tex, str)
	if not tex or not str then return end
	local frame = tex:GetParent()
	local mask = tex.mask or frame:CreateMaskTexture()
	tex.mask = mask
	mask:SetAllPoints(tex)
	mask:SetTexture(str, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
	tex:AddMaskTexture(mask)
end

-- Custom Attributes (customAttrs) are an array of tables, containing the following valid keys:
-- key = 'string' -- The key that the found data is store in during calls, and really just for easier remembering what this stuff is.
-- handler = 'string:methodName'|func(region, foundStr) -- Either a string, being a method name on the region object, passed the values of the found string split by commas (strsplit(",", match), OR a function that takes in the region, and the RAW string found as the value of that attribute)
-- pattern = 'string' -- The pattern to use when searching the preAttrs and postAttrs of the img tag. Optional, and just uses the key formatted in the default 'keyPattern' below if not given.

-- Feel free to extend the usage more if needed - right now, it's primary use is texCoord support in SimpleHTML


local customAttrs = {
	{
		key = 'texCoords',
		--pattern = 'texCoords="([^"]+)"', -- Not needed, using 'key' for the 'keyPattern' instead here
		--handler="SetTexCoord", -- This should ALSO work, but highlighting both cases here
		handler = function(region, texCoordsStr)
			if texCoordsStr then
				local coords = { strsplit(",", texCoordsStr, 4) }
				region:SetTexCoord(unpack(coords))
			end
		end
	},
	{
		key = 'vertexColour',
		handler = function(region, vertexColourStr)
			if vertexColourStr then
				local rgb = { strsplit(",", vertexColourStr, 3) }
				region:SetVertexColor(unpack(rgb));
			end
		end
	},
	{
		key = 'blendMode',
		handler = function(region, blendMode)
			if blendMode then
				region:SetBlendMode(blendMode)
			end
		end
	},
	{
		key = 'desaturate',
		handler = function(region)
			region:SetDesaturated(true)
		end
	},
	{
		key = 'rotation',
		handler = function(region, degrees)
			if degrees then
				local radians = rad(degrees)
				if radians then
					region:SetRotation(radians)
				end
			end
		end
	},
	{
		key = 'mask',
		handler = function(region, maskStr)
			if maskStr then
				maskUp(region, maskStr)
			end
		end
	}
}

local keyPattern = '%s="([^"]+)"'

_misc.SetSimpleHTMLWithImageExtensions = function(simpleHTMLFrame, html)
	local imageLookups = {}

	-- Function to process <img> tags
	local id = 1
	html = string.gsub(html, '<img%s+([^>]-)src="([^"]+)"([^>]*)>', function(preAttrs, src, postAttrs)
		-- Store the src value in the lookup table
		local srcData = { file = src }

		-- Check for customAttrs in preAttrs or postAttrs
		for _, attrData in ipairs(customAttrs) do
			local pattern = attrData.pattern or keyPattern:format(attrData.key) -- if no specific pattern, uses default of key based pattern
			local match = preAttrs:match(pattern) or postAttrs:match(pattern)
			if match then
				srcData[attrData.key] = match
			end
		end

		table.insert(imageLookups, srcData)
		-- Replace the src value with the sequential ID.
		-- Note that unsupported ATTRIBUTES are just ignored, and DO NOT CAUSE AN ISSUE, so we are fine leaving them in!
		local replacement = string.format('<img %ssrc="%d"%s>', preAttrs, id, postAttrs)
		id = id + 1
		return replacement
	end)

	-- Set the processed HTML to the SimpleHTML object
	simpleHTMLFrame:SetText(html)

	-- Process the regions to fix textures
	local regions = { simpleHTMLFrame:GetRegions() }
	for idx, region in ipairs(regions) do
		if region:GetObjectType() == "Texture" then
			local texturePath = region:GetTextureFilePath()
			if texturePath then
				local index = tonumber(texturePath)
				if index and imageLookups[index] then
					local lookupData = imageLookups[index]
					-- Update the texture using the original src value
					region:SetTexture(lookupData.file)
					region:SetBlendMode("BLEND")
					region:SetVertexColor(1, 1, 1, 1);
					region:SetDesaturated(false)
					removeAllMasks(region)
					region:SetRotation(0)
					region:SetTexCoord(0, 1, 0, 1) -- Always reset first, to ensure previous modifications are not kept

					-- process custom attributes
					for _, attrData in ipairs(customAttrs) do
						local match = lookupData[attrData.key]
						if match then
							if type(attrData.handler) == "string" then
								local splitMatches = { strsplit(",", match) }
								region[attrData.handler](region, unpack(splitMatches))
							elseif type(attrData.handler) == "function" then
								attrData.handler(region, match)
							end
						end
					end
				else
					-- non-blocking error handling
					geterrorhandler()(string.format("EL-SetSimpleHTMLWithImageExtensions Error: Texture ID %s not found in imageLookups!", texturePath))
				end
			else
				-- non-blocking error handling
				geterrorhandler()(string.format("EL-SetSimpleHTMLWithImageExtensions Error: Region %s (%s) does not have a valid texture path.", idx, tostring(region)))
			end
		end
	end
end

-- Simple Frame Measurement Tool:
-- Use '/run MEASURE_FRAME(frame)' to initiate
-- Use '/run MARK_POINT()' to mark a point to measure distance from. Default point is where the cursor is when MEASURE_FRAME is ran.
-- Both 'Frame Relative' coords, and distance from last marked point, are shown in the tooltip.

local lastX, lastY, curX, curY = 0, 0, 0, 0
function MARK_POINT()
	lastX = curX
	lastY = curY
end

local function measure_script(self, elapsed)
	-- Get the mouse's position relative to the frame
	local mouseX, mouseY = GetCursorPosition()
	local frameLeft, frameBottom = self:GetLeft(), self:GetBottom()
	local frameScale = self:GetEffectiveScale()
	local frameHeight = self:GetHeight()

	-- Convert global coordinates to frame-relative coordinates
	local relativeX = (mouseX / frameScale) - frameLeft
	local relativeY = (mouseY / frameScale) - frameBottom
	relativeY = frameHeight - relativeY

	curX = relativeX
	curY = relativeY

	-- Display the relative coordinates in a tooltip
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Mouse Coordinates (Relative to Frame):")
	GameTooltip:AddLine(string.format("X: %.1f, Y: %.1f", relativeX, relativeY))
	GameTooltip:AddLine(string.format("dX: %.1f, dY: %.1f", relativeX - lastX, relativeY - lastY))
	GameTooltip:Show()
end

function MEASURE_FRAME(frame)
	frame:HookScript("OnUpdate", measure_script)
	MARK_POINT()
end
