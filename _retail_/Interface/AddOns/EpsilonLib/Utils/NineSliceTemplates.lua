local EpsilonLib, EpsiLib = ...;

EpsiLib.Utils.NineSlice = {}
local NineSlice = EpsiLib.Utils.NineSlice

--#region [[ Constants & Frame File References ]] --

local addonPath = "Interface/AddOns/" .. tostring(EpsilonLib)

local ASSETS_PATH = addonPath .. "/Resources/"

local myNineSliceFile_corners = ASSETS_PATH .. "frame_border_corners"
local myNineSliceFile_vert = ASSETS_PATH .. "frame_border_vertical"
local myNineSliceFile_horz = ASSETS_PATH .. "frame_border_horizontal"

--#endregion

--#region [[ NineSlice Functions - Handles Setting Our Custom Layouts ]] --

local function SetupTextureCoordinates(piece, setupInfo, pieceLayout, userLayout)
	local left, right, top, bottom = 0, 1, 0, 1;
	left = pieceLayout.txl or left
	right = pieceLayout.txr or right
	top = pieceLayout.txt or top
	bottom = pieceLayout.txb or bottom

	-- Propogate userLayout mirror setting to piece if piece does not define it
	local pieceMirrored = pieceLayout.mirrorLayout;
	if pieceMirrored == nil then
		pieceMirrored = userLayout and userLayout.mirrorLayout;
	end

	if pieceMirrored then
		if setupInfo.mirrorVertical then
			top, bottom = bottom, top;
		end

		if setupInfo.mirrorHorizontal then
			left, right = right, left;
		end
	end

	piece:SetHorizTile(setupInfo.tileHorizontal);
	piece:SetVertTile(setupInfo.tileVertical);
	piece:SetTexCoord(left, right, top, bottom);
end

local function setupPieceVisualsFunction(container, piece, setupInfo, pieceLayout, textureKit, userLayout)
	--- Change texture coordinates before applying atlas.
	SetupTextureCoordinates(piece, setupInfo, pieceLayout, userLayout);

	-- textureKit is optional, that's fine; but if it's nil the caller should ensure that there are no format specifiers in .atlas
	--local atlasName = GetFinalNameFromTextureKit(pieceLayout.atlas, textureKit);
	--local info = C_Texture.GetAtlasInfo(atlasName);
	piece:SetHorizTile(pieceLayout and pieceLayout.tilesHorizontally or false);
	piece:SetVertTile(pieceLayout and pieceLayout.tilesVertically or false);
	piece:SetTexture(pieceLayout.tex, true, true);

	local baseSize = 132
	if pieceLayout.width then piece:SetWidth(pieceLayout.width) else piece:SetWidth(baseSize) end
	if pieceLayout.height then piece:SetHeight(pieceLayout.height) else piece:SetHeight(baseSize) end
end

--#endregion

--#region [[ Custom NineSlice Layouts ]] --

-- Layout 1: EpsilonGoldBorderFrameTemplate
NineSliceUtil.AddLayout("EpsilonGoldBorderFrameTemplate", {
	setupPieceVisualsFunction = setupPieceVisualsFunction,
	TopLeftCorner = { tex = myNineSliceFile_corners, txl = 0.263672, txr = 0.521484, txt = 0.263672, txb = 0.521484, x = -13, y = 16, },                  --0.263672, 0.521484, 0.263672, 0.521484
	TopRightCorner = { tex = myNineSliceFile_corners, txl = 0.12890625, txr = 0.259766, txt = 0.263672, txb = 0.521484, x = 4, y = 16, width = 132 / 2 }, -- 0.00195312, 0.259766, 0.263672, 0.521484
	BottomLeftCorner = { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.00195312, txb = 0.259766, x = -13, y = -3, },           -- 0.00195312, 0.259766, 0.00195312, 0.259766
	BottomRightCorner = { tex = myNineSliceFile_corners, txl = 0.392578, txr = 0.521484, txt = 0.00195312, txb = 0.259766, x = 4, y = -3, width = 132 / 2 }, -- 0.263672, 0.521484, 0.00195312, 0.259766
	TopEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.263672, txb = 0.521484, },                                                          -- 0, 1, 0.263672, 0.521484
	BottomEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.00195312, txb = 0.259766, },                                                     -- 0, 1, 0.00195312, 0.259766
	LeftEdge = { tex = myNineSliceFile_vert, txl = 0.00195312, txr = 0.259766, txt = 0, txb = 1, },                                                       -- 0.00195312, 0.259766, 0, 1
	RightEdge = { tex = myNineSliceFile_vert, txl = 0.263672, txr = 0.521484, txt = 0, txb = 1, },                                                        -- 0.263672, 0.521484, 0, 1
})

-- Layout 1, alt variant (Double buttons in top-right): EpsilonGoldBorderFrameDoubleButtonTemplate
local doubleButton = CopyTable(NineSliceUtil.GetLayout("EpsilonGoldBorderFrameTemplate"), true) -- Reuse the same layout as the main, modify TopRightCorner texcoord
doubleButton.TopRightCorner = CopyTable(doubleButton.TopRightCorner)
doubleButton.TopRightCorner.txt = 0.525391
doubleButton.TopRightCorner.txb = 0.783203
NineSliceUtil.AddLayout("EpsilonGoldBorderFrameDoubleButtonTemplate", doubleButton)


-- Layout 2: EpsilonGoldBorderFrameTemplateNoPortrait -- Variant of Layout 1 without portrait
NineSliceUtil.AddLayout("EpsilonGoldBorderFrameTemplateNoPortrait", {
	setupPieceVisualsFunction = setupPieceVisualsFunction,
	TopLeftCorner = { tex = myNineSliceFile_corners, txl = 0.525391, txr = 0.783203, txt = 0.00195312, txb = 0.259766, x = -12, y = 16, },
	TopRightCorner = { tex = myNineSliceFile_corners, txl = 0.12890625, txr = 0.259766, txt = 0.263672, txb = 0.521484, x = 4, y = 16, width = 132 / 2 },
	BottomLeftCorner = { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.00195312, txb = 0.259766, x = -12, y = -3, },
	BottomRightCorner = { tex = myNineSliceFile_corners, txl = 0.392578, txr = 0.521484, txt = 0.00195312, txb = 0.259766, x = 4, y = -3, width = 132 / 2 },
	TopEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.263672, txb = 0.521484, tilesHorizontally = true },
	BottomEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.00195312, txb = 0.259766, tilesHorizontally = true },
	LeftEdge = { tex = myNineSliceFile_vert, txl = 0.00195312, txr = 0.259766, txt = 0, txb = 1, tilesVertically = true },
	RightEdge = { tex = myNineSliceFile_vert, txl = 0.263672, txr = 0.521484, txt = 0, txb = 1, tilesVertically = true },
})

-- Layout 2, alt variant (Double buttons in top-right): EpsilonGoldBorderFrameDoubleButtonTemplateNoPortrait
local doubleButtonNoPortrait = CopyTable(NineSliceUtil.GetLayout("EpsilonGoldBorderFrameTemplateNoPortrait"), true) -- Reuse the same layout as the main, modify TopRightCorner texcoord
doubleButtonNoPortrait.TopRightCorner = CopyTable(doubleButtonNoPortrait.TopRightCorner)
doubleButtonNoPortrait.TopRightCorner.txt = 0.525391
doubleButtonNoPortrait.TopRightCorner.txb = 0.783203
NineSliceUtil.AddLayout("EpsilonGoldBorderFrameDoubleButtonTemplateNoPortrait", doubleButtonNoPortrait)



-- You can add more custom templates if you want

--#endregion

--#region [[ NineSlice Util Functions ]] --

local function CropNineSliceCorners(slice, cropFactor, horizontal)
	local function SafeSetTexCoordAndSize(region, fromTopOrLeft)
		if region and region.SetTexCoord then
			local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = region:GetTexCoord()

			-- Store original tex coords and size for reset
			if not region._orig then
				region._orig = {
					tex = { ULx, ULy, LLx, LLy, URx, URy, LRx, LRy },
					height = region:GetHeight(),
					width = region:GetWidth()
				}
			end

			if horizontal then
				if fromTopOrLeft then
					-- crop from left
					local croppedX = ULx + (URx - ULx) * (1 - cropFactor)
					region:SetTexCoord(croppedX, ULy, croppedX, LLy, URx, URy, URx, LRy)
				else
					-- crop from right
					local croppedX = ULx + (URx - ULx) * cropFactor
					region:SetTexCoord(ULx, ULy, LLx, LLy, croppedX, URy, croppedX, LRy)
				end
				region:SetWidth(region._orig.width * cropFactor)
			else
				-- vertical cropping
				if fromTopOrLeft then
					-- crop from top
					local croppedY = ULy + (LRy - ULy) * (1 - cropFactor)
					region:SetTexCoord(ULx, croppedY, LLx, LLy, URx, croppedY, LRx, LRy)
				else
					-- crop from bottom
					local croppedY = ULy + (LRy - ULy) * cropFactor
					region:SetTexCoord(ULx, ULy, LLx, croppedY, URx, URy, LRx, croppedY)
				end
				region:SetHeight(region._orig.height * cropFactor)
			end
		end
	end

	if horizontal then
		-- Left/right crop
		SafeSetTexCoordAndSize(slice.TopLeftCorner, false)
		SafeSetTexCoordAndSize(slice.BottomLeftCorner, false)
		SafeSetTexCoordAndSize(slice.TopRightCorner, true)
		SafeSetTexCoordAndSize(slice.BottomRightCorner, true)
	else
		-- Top/bottom crop
		SafeSetTexCoordAndSize(slice.TopLeftCorner, false)
		SafeSetTexCoordAndSize(slice.TopRightCorner, false)
		SafeSetTexCoordAndSize(slice.BottomLeftCorner, true)
		SafeSetTexCoordAndSize(slice.BottomRightCorner, true)
	end
end

local function ResetNineSliceCorners(slice)
	local function SafeReset(region)
		if region and region._orig then
			local t = region._orig.tex
			region:SetTexCoord(unpack(t))
			region:SetHeight(region._orig.height)
			region:SetWidth(region._orig.width)
		end
	end

	SafeReset(slice.TopLeftCorner)
	SafeReset(slice.TopRightCorner)
	SafeReset(slice.BottomLeftCorner)
	SafeReset(slice.BottomRightCorner)
end

NineSlice.CropNineSliceCorners = CropNineSliceCorners
NineSlice.ResetNineSliceCorners = ResetNineSliceCorners

--#endregion

-- Function to set a frame's background to a fixed viewport-aligned texture
local function SetBackgroundAsViewport(f, bg, texture)
	local frame = f
	bg = bg or f.Bg

	if not texture then texture = ASSETS_PATH .. "MainBg" end

	bg:SetTexture(texture, true, true)
	bg:SetHorizTile(false)
	bg:SetVertTile(false)
	bg:SetAlpha(0.99)

	local lastLeft, lastTop, lastW, lastH
	local texSize = 1024 -- your texture is 1024x1024

	local function UpdateBackground()
		local left, top = frame:GetLeft(), frame:GetTop()
		local width, height = frame:GetWidth(), frame:GetHeight()
		if not left or not top then return end

		-- Only update if something actually changed
		if left == lastLeft and top == lastTop and width == lastW and height == lastH then
			return
		end

		-- Save last values
		lastLeft, lastTop, lastW, lastH = left, top, width, height

		-- Do the thing here
		local screenW, screenH = UIParent:GetWidth(), UIParent:GetHeight()

		-- Calculate slice of texture coords
		local u1 = (left % texSize) / texSize
		local v1 = ((screenH - top) % texSize) / texSize
		local u2 = ((left + width) % texSize) / texSize
		local v2 = ((screenH - (top - height)) % texSize) / texSize

		-- Handle wraparound (if the window spans across a tile boundary)
		if u2 < u1 then u2 = u2 + 1 end
		if v2 < v1 then v2 = v2 + 1 end

		bg:SetTexCoord(u1, u2, v1, v2)
	end

	-- Poll only while visible
	frame:HookScript("OnUpdate", UpdateBackground)

	-- Force update immediately on init
	UpdateBackground()
end
NineSlice.SetBackgroundAsViewport = SetBackgroundAsViewport
