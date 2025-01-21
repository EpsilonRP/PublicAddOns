---@class ns
local ns = select(2, ...)


-- # DEPRECATED
--[===[
local Constants = ns.Constants
local NineSlice = ns.Utils.NineSlice

local ASSETS_PATH = Constants.ASSETS_PATH

local myNineSliceFile_corners = ASSETS_PATH .. "/frame_border_corners"
local myNineSliceFile_vert = ASSETS_PATH .. "/frame_border_vertical"
local myNineSliceFile_horz = ASSETS_PATH .. "/frame_border_horizontal"

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
		piece:SetTexture(pieceLayout.tex, true);
end

NineSlice.AddLayout("ArcanumFrameTemplate", {
	setupPieceVisualsFunction = setupPieceVisualsFunction,
	TopLeftCorner = { tex = myNineSliceFile_corners, txl = 0.263672, txr = 0.521484, txt = 0.263672, txb = 0.521484, x = -13, y = 16, }, --0.263672, 0.521484, 0.263672, 0.521484
	--TopRightCorner =  { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.263672, txb = 0.521484, x = 4, y = 16,}, -- 0.00195312, 0.259766, 0.263672, 0.521484
	TopRightCorner =  { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.525391, txb = 0.783203, x = 4, y = 16, }, -- 0.00195312, 0.259766, 0.525391, 0.783203 -- this is the double button one in the top right corner.
	BottomLeftCorner =  { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.00195312, txb = 0.259766, x = -13, y = -3, }, -- 0.00195312, 0.259766, 0.00195312, 0.259766
	BottomRightCorner = { tex = myNineSliceFile_corners, txl = 0.263672, txr = 0.521484, txt = 0.00195312, txb = 0.259766, x = 4, y = -3, }, -- 0.263672, 0.521484, 0.00195312, 0.259766
	TopEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.263672, txb = 0.521484, }, -- 0, 1, 0.263672, 0.521484
	BottomEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.00195312, txb = 0.259766, }, -- 0, 1, 0.00195312, 0.259766
	LeftEdge = { tex = myNineSliceFile_vert, txl = 0.00195312, txr = 0.259766, txt = 0, txb = 1, }, -- 0.00195312, 0.259766, 0, 1
	RightEdge = { tex = myNineSliceFile_vert, txl = 0.263672, txr = 0.521484, txt = 0, txb = 1, }, -- 0.263672, 0.521484, 0, 1
})

NineSlice.AddLayout("ArcanumFrameTemplateNoPortrait", {
	setupPieceVisualsFunction = setupPieceVisualsFunction,
	TopLeftCorner = { tex = myNineSliceFile_corners, txl = 0.525391, txr = 0.783203, txt = 0.00195312, txb = 0.259766, x = -12, y = 16, },
	TopRightCorner =  { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.263672, txb = 0.521484, x = 4, y = 16, },
	--TopRightCorner =  { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.525391, txb = 0.783203, x = 4, y = 16, }, -- this is the double one
	BottomLeftCorner =  { tex = myNineSliceFile_corners, txl = 0.00195312, txr = 0.259766, txt = 0.00195312, txb = 0.259766, x = -12, y = -3, },
	BottomRightCorner = { tex = myNineSliceFile_corners, txl = 0.263672, txr = 0.521484, txt = 0.00195312, txb = 0.259766, x = 4, y = -3, },
	TopEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.263672, txb = 0.521484, tilesHorizontally = true},
	BottomEdge = { tex = myNineSliceFile_horz, txl = 0, txr = 1, txt = 0.00195312, txb = 0.259766, tilesHorizontally = true},
	LeftEdge = { tex = myNineSliceFile_vert, txl = 0.00195312, txr = 0.259766, txt = 0, txb = 1, tilesVertically = true },
	RightEdge = { tex = myNineSliceFile_vert, txl = 0.263672, txr = 0.521484, txt = 0, txb = 1, tilesVertically = true },
})
--]===]
