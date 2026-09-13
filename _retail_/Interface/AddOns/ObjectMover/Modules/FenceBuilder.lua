local ADDON_NAME = ...
---@class ns
local ns = select(2, ...)

local Utils = ns.Utils
local cmd = Utils.cmd
local cmdChain = Utils.cmdChain
local op_cmd = Utils.op_cmd
local clearMsg = Utils.clearMsg
local sysMsg = Utils.sysMsg

local AceGUI = LibStub("AceGUI-3.0")

--[[
	Fence / Barrier Builder: mark points while walking the path, then Build.
	Height comes from your own position at each point - no terrain query needed.
]]

--#region State

---@type { x:number, y:number, z:number, map:number }[]
local points = {}

local function round(n)
	return math.floor(n + 0.5)
end

local function normalizeDegrees(deg)
	deg = deg % 360
	if deg < 0 then deg = deg + 360 end
	return deg
end

--#endregion

--#region Point Capture

local pointsLabel ---@type table? AceGUI Label widget, set once the window has been built

local function refreshPointsLabel()
	if pointsLabel then
		pointsLabel:SetText(("Points marked: |cffFFD700%d|r"):format(#points))
	end
end

local function markPoint()
	local x, y, z, mapID = C_Epsilon.GetPosition()
	if not x then
		sysMsg("Could not read your current position.")
		return
	end

	if #points > 0 and points[#points].map ~= mapID then
		sysMsg("You changed maps since the last point - clearing the fence path.")
		wipe(points)
	end

	table.insert(points, { x = x, y = y, z = z, map = mapID })
	sysMsg(("Fence point %d marked. (%.1f, %.1f, %.1f)"):format(#points, x, y, z))
	refreshPointsLabel()
end

local function undoPoint()
	if #points == 0 then
		sysMsg("No points to undo.")
		return
	end
	table.remove(points)
	sysMsg(("Removed last point. %d point(s) remaining."):format(#points))
	refreshPointsLabel()
end

local function clearPoints()
	if #points == 0 then return end
	wipe(points)
	sysMsg("Fence path cleared.")
	refreshPointsLabel()
end

--#endregion

--#region Build

local buildConfig = {
	entry = "",
	segLength = "2",
	overlap = "0.1",
	sinkDepth = "0.15",
	scale = "1",
	turnOffset = "0",
	centerPivot = true,
	loop = false,
	endPostEntry = "",
	capStart = true,
	capEnd = true,
	overlapEndPosts = true,
	jointPosts = false,
	jointPostEntry = "",
	followSlope = false,
	slopeAxis = "pitch", -- "pitch" (Y) or "roll" (X) - whichever axis this model tilts vertically on
	invertSlope = false,
	pitchOffset = "0",
	rollOffset = "0",
	cornerAngle = "35",
}

local function spawnCommandFor(scale, p)
	return ("gobject spawn %d scale %s posx %.3f posy %.3f posz %.3f pitch %.3f roll %.3f face north turn %.3f")
		:format(round(p.entry), scale, p.x, p.y, p.z, p.pitch or 0, p.roll or 0, p.turn)
end

local function buildFence()
	if not EpsilonLib.GameObject.CanSpawn(true) then return end

	if #points < 2 then
		sysMsg("You need at least 2 marked points to build a fence.")
		return
	end

	local entry = tonumber(buildConfig.entry)
	if not entry or entry <= 0 then
		sysMsg("Enter a valid GameObject Entry ID for the fence segment first.")
		return
	end

	local segLength = tonumber(buildConfig.segLength)
	if not segLength or segLength <= 0 then
		sysMsg("Segment Length must be a positive number of yards.")
		return
	end

	local scale = tonumber(buildConfig.scale)
	if not scale or scale <= 0 then scale = 1 end

	local overlap = math.max(0, tonumber(buildConfig.overlap) or 0)
	local step = math.max(0.01, segLength - overlap)
	local sinkDepth = math.max(0, tonumber(buildConfig.sinkDepth) or 0)

	local turnOffsetDeg = tonumber(buildConfig.turnOffset) or 0
	local pitchOffsetDeg = tonumber(buildConfig.pitchOffset) or 0
	local rollOffsetDeg = tonumber(buildConfig.rollOffset) or 0
	local n = #points
	local CORNER_ANGLE_THRESHOLD = tonumber(buildConfig.cornerAngle) or 35 -- degrees; turns sharper than this stay crisp instead of getting smoothed

	-- rawDir[i]: unit direction from points[i] to points[i+1] (plus rawDir[n] for the loop-closing leg)
	local rawDir = {}
	local function computeRawDir(ia, ib)
		local a, b = points[ia], points[ib]
		local dx, dy = b.x - a.x, b.y - a.y
		local len = math.sqrt(dx * dx + dy * dy)
		return (len > 0.0001) and { x = dx / len, y = dy / len } or nil
	end
	for i = 1, n - 1 do
		rawDir[i] = computeRawDir(i, i + 1)
	end
	if buildConfig.loop and n > 2 then
		rawDir[n] = computeRawDir(n, 1)
	end

	local function incomingDir(i)
		if i > 1 then return rawDir[i - 1] end
		if buildConfig.loop then return rawDir[n] end
		return nil
	end
	local function outgoingDir(i)
		if i < n then return rawDir[i] end
		if buildConfig.loop then return rawDir[n] end
		return nil
	end

	-- Blend the in/out directions only for gentle turns (walking noise);
	-- sharp corners are left alone so they stay crisp.
	local tangents = {}
	for i = 1, n do
		local inD, outD = incomingDir(i), outgoingDir(i)
		if inD and outD then
			local dot = math.max(-1, math.min(1, inD.x * outD.x + inD.y * outD.y))
			local turnAngle = math.deg(math.acos(dot))
			if turnAngle <= CORNER_ANGLE_THRESHOLD then
				local sx, sy = inD.x + outD.x, inD.y + outD.y
				local slen = math.sqrt(sx * sx + sy * sy)
				tangents[i] = (slen > 0.0001) and { x = sx / slen, y = sy / slen } or outD
			end
			-- else: sharp corner, keep tangents[i] nil (legs fall back to their own direction)
		else
			tangents[i] = inD or outD
		end
	end

	-- Straight chords between consecutive points, with endpoint tangents for heading blending.
	local legs = {}
	local function addLeg(ia, ib)
		local a, b = points[ia], points[ib]
		local dx, dy, dz = b.x - a.x, b.y - a.y, b.z - a.z
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist >= 0.05 then
			local dir = { x = dx / dist, y = dy / dist }
			table.insert(legs, {
				a = a, b = b, dx = dx, dy = dy, dz = dz, length = dist,
				aTangent = tangents[ia] or dir, bTangent = tangents[ib] or dir,
				pitchDeg = math.deg(math.atan2(dz, dist)),
			})
		end
	end
	for i = 1, n - 1 do
		addLeg(i, i + 1)
	end
	if buildConfig.loop and n > 2 then
		addLeg(n, 1)
	end

	if #legs == 0 then
		sysMsg("Nothing to build - marked points are too close together.")
		return
	end

	---Path tangent (unit x/y, no calibration offset) at parameter legT (0 = a, 1 = b) along a leg.
	local function tangentAt(leg, legT)
		local tx = leg.aTangent.x + (leg.bTangent.x - leg.aTangent.x) * legT
		local ty = leg.aTangent.y + (leg.bTangent.y - leg.aTangent.y) * legT
		if tx == 0 and ty == 0 then tx, ty = leg.dx, leg.dy end
		local len = math.sqrt(tx * tx + ty * ty)
		return tx / len, ty / len
	end

	---Find which leg/legT corresponds to arc-length s along the whole path.
	local function findLegAt(s)
		local remaining = s
		for _, leg in ipairs(legs) do
			if remaining <= leg.length or leg == legs[#legs] then
				return leg, math.max(0, math.min(1, leg.length > 0 and (remaining / leg.length) or 0))
			end
			remaining = remaining - leg.length
		end
		return legs[#legs], 1
	end

	---Ground height at arc-length s along the whole path.
	local function zAt(s)
		local leg, legT = findLegAt(s)
		return leg.a.z + leg.dz * legT
	end

	local totalLength = 0
	for _, leg in ipairs(legs) do totalLength = totalLength + leg.length end

	for _, leg in ipairs(legs) do
		local atx, aty = tangentAt(leg, 0)
		local btx, bty = tangentAt(leg, 1)
		sysMsg(("Leg (%.1f, %.1f) -> (%.1f, %.1f): heading %.1f -> %.1f deg, slope %.1f deg, length %.1f"):format(
			leg.a.x, leg.a.y, leg.b.x, leg.b.y,
			normalizeDegrees(math.deg(math.atan2(aty, atx)) + turnOffsetDeg),
			normalizeDegrees(math.deg(math.atan2(bty, btx)) + turnOffsetDeg), leg.pitchDeg, leg.length))
	end

	-- Points are just a guide - pieces chain edge-to-edge (like a bike chain)
	-- so they always touch their neighbor, instead of drifting apart on curves.
	local count = math.max(1, round(totalLength / step))
	local sampleStep = totalLength / count

	local placements = {}
	local joints = {}
	local cursor = { x = points[1].x, y = points[1].y }
	local firstEdge = { x = points[1].x, y = points[1].y, z = points[1].z - sinkDepth }
	local lastEdge = firstEdge
	local firstTangent, lastTangent
	local firstHFactor, lastHFactor = 1, 1
	for i = 0, count - 1 do
		-- Sample heading/height at the piece's actual center (not its leading edge) -
		-- matters a lot for long pieces, where the two can be far apart.
		local edgeS = math.min(totalLength, i * sampleStep)
		local s = buildConfig.centerPivot and math.min(totalLength, edgeS + segLength / 2) or edgeS
		local leg, legT = findLegAt(s)
		local tx, ty = tangentAt(leg, legT)
		local z = leg.a.z + leg.dz * legT - sinkDepth
		local turnDeg = normalizeDegrees(math.deg(math.atan2(ty, tx)) + turnOffsetDeg)

		local pitchDeg, rollDeg = 0, 0
		-- Tilted pieces cover less horizontal ground (cos(tilt), like a leaning ladder) - shrink spacing to match.
		local horizontalFactor = 1
		if buildConfig.followSlope then
			-- The piece's OWN average slope, from its true start to its true end -
			-- not the local leg's slope, which can be noisy over a much shorter span.
			local pieceEndS = math.min(totalLength, edgeS + segLength)
			local pieceRun = math.max(0.01, pieceEndS - edgeS)
			local piecePitchDeg = math.deg(math.atan2(zAt(pieceEndS) - zAt(edgeS), pieceRun))
			local slopeDeg = buildConfig.invertSlope and -piecePitchDeg or piecePitchDeg
			if buildConfig.slopeAxis == "roll" then
				rollDeg = slopeDeg
			else
				pitchDeg = slopeDeg
				horizontalFactor = math.cos(math.rad(slopeDeg))
			end
		end
		-- Per-model calibration trim, on top of the computed tilt (or on its own if
		-- Follow Terrain Slope is off) - some models just aren't modeled dead level.
		pitchDeg = pitchDeg + pitchOffsetDeg
		rollDeg = rollDeg + rollOffsetDeg

		local px, py
		if buildConfig.centerPivot then
			px, py = cursor.x + tx * (segLength * horizontalFactor / 2), cursor.y + ty * (segLength * horizontalFactor / 2)
		else
			px, py = cursor.x, cursor.y
		end

		table.insert(placements, { entry = entry, x = px, y = py, z = z, turn = turnDeg, pitch = pitchDeg, roll = rollDeg })
		lastEdge = { x = cursor.x + tx * segLength * horizontalFactor, y = cursor.y + ty * segLength * horizontalFactor, z = z, turn = turnDeg }
		if i == 0 then
			firstTangent, firstHFactor = { x = tx, y = ty }, horizontalFactor
		end
		lastTangent, lastHFactor = { x = tx, y = ty }, horizontalFactor

		-- Joint with the next piece (or loop wrap), centered in their overlap zone.
		if i < count - 1 or buildConfig.loop then
			table.insert(joints, {
				x = cursor.x + tx * (segLength - overlap / 2) * horizontalFactor,
				y = cursor.y + ty * (segLength - overlap / 2) * horizontalFactor,
				z = z, turn = turnDeg,
			})
		end

		cursor.x = cursor.x + tx * step * horizontalFactor
		cursor.y = cursor.y + ty * step * horizontalFactor
	end

	-- Cap the open ends with a post, if one was set (skipped for a closed loop).
	local endPostEntry = tonumber(buildConfig.endPostEntry)
	if endPostEntry and endPostEntry > 0 and not buildConfig.loop then
		local postOverlap = buildConfig.overlapEndPosts and overlap or 0
		if buildConfig.capStart then
			table.insert(placements, {
				entry = endPostEntry,
				x = firstEdge.x + firstTangent.x * postOverlap * firstHFactor,
				y = firstEdge.y + firstTangent.y * postOverlap * firstHFactor,
				z = firstEdge.z, turn = placements[1].turn,
			})
		end
		if buildConfig.capEnd then
			table.insert(placements, {
				entry = endPostEntry,
				x = lastEdge.x - lastTangent.x * postOverlap * lastHFactor,
				y = lastEdge.y - lastTangent.y * postOverlap * lastHFactor,
				z = lastEdge.z, turn = lastEdge.turn,
			})
		end
	end

	-- Post at every joint too, using its own entry or falling back to End Post.
	local jointPostEntry = tonumber(buildConfig.jointPostEntry) or endPostEntry
	if buildConfig.jointPosts and jointPostEntry and jointPostEntry > 0 then
		for _, j in ipairs(joints) do
			table.insert(placements, { entry = jointPostEntry, x = j.x, y = j.y, z = j.z, turn = j.turn })
		end
	end

	sysMsg(("Building fence: %d segment(s)..."):format(#placements))

	local firstCmd = spawnCommandFor(scale, placements[1])

	local function onFirstSpawn(success, messages)
		if not success then
			sysMsg("Failed to spawn the first fence segment - build aborted.")
			return
		end

		if #placements == 1 then
			sysMsg("Fence built: 1 segment.")
			return
		end

		local leaderGUID
		for _, v in ipairs(messages or {}) do
			local clean = clearMsg(v)
			local id = clean:match("%(GUID: |Hgameobject_GUID:%d+|h(%d+)|h%)")
			if id then
				leaderGUID = id
				break
			end
		end

		if not leaderGUID then
			sysMsg("Fence spawned, but couldn't capture the group leader GUID - remaining segments won't be grouped.")
		end

		local chain = {}
		for i = 2, #placements do
			table.insert(chain, spawnCommandFor(scale, placements[i]))
			if leaderGUID then
				table.insert(chain, ("gobject group add %s"):format(leaderGUID))
			end
		end

		cmdChain(chain, function(success2)
			if success2 then
				if leaderGUID then
					cmd(("gobject group select %s"):format(leaderGUID))
					sysMsg(("Fence built: %d segments, grouped under leader GUID %s."):format(#placements, leaderGUID))
				else
					sysMsg(("Fence built: %d segments."):format(#placements))
				end
			else
				sysMsg("Fence build stopped partway through due to a command failure. Some segments may be missing.")
			end
		end, false)
	end

	op_cmd(firstCmd, nil, nil, onFirstSpawn)
end

--#endregion

--#region Window

local ttOpts = { delay = 0.1 }
local window ---@type table? AceGUI Window widget

local function buildWindow()
	local f = AceGUI:Create("Window")
	f:SetTitle("Fence Builder")
	f:SetLayout("Flow")
	f:SetWidth(300)
	f:SetHeight(770)
	f:EnableResize(false)
	f:SetCallback("OnClose", function(widget) widget:Hide() end)

	local entryBox = AceGUI:Create("MAW-Editbox")
	entryBox:SetLabel("Fence Segment Object ID")
	entryBox:SetText(buildConfig.entry)
	entryBox:SetFullWidth(true)
	entryBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.entry = text end)
	f:AddChild(entryBox)
	EpsilonLib.Utils.Tooltip.SetAce(entryBox, "Fence Segment Object ID", "The GameObject Entry ID to spawn for each fence/barrier piece.", ttOpts)

	local segLenBox = AceGUI:Create("MAW-Editbox")
	segLenBox:SetLabel("Segment Length (yards)")
	segLenBox:SetText(buildConfig.segLength)
	segLenBox:SetFullWidth(true)
	segLenBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.segLength = text end)
	f:AddChild(segLenBox)
	EpsilonLib.Utils.Tooltip.SetAce(segLenBox, "Segment Length", "The real length (in yards) of one fence piece. Pieces are chained end-to-end using this length.", ttOpts)

	local cornerAngleBox = AceGUI:Create("MAW-Editbox")
	cornerAngleBox:SetLabel("Corner Smoothing (deg)")
	cornerAngleBox:SetText(buildConfig.cornerAngle)
	cornerAngleBox:SetFullWidth(true)
	cornerAngleBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.cornerAngle = text end)
	f:AddChild(cornerAngleBox)
	EpsilonLib.Utils.Tooltip.SetAce(cornerAngleBox, "Corner Smoothing", "Turns sharper than this get smoothed into a curve; gentler ones stay crisp. Lower it (or set 0) if you're marking points densely and the path looks over-smoothed.", ttOpts)

	local overlapBox = AceGUI:Create("MAW-Editbox")
	overlapBox:SetLabel("Overlap (yards)")
	overlapBox:SetText(buildConfig.overlap)
	overlapBox:SetRelativeWidth(0.48)
	overlapBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.overlap = text end)
	f:AddChild(overlapBox)
	EpsilonLib.Utils.Tooltip.SetAce(overlapBox, "Overlap", "How far each piece sinks into the next at the joint. A small amount (0.1-0.3) hides seam gaps. 0 = pieces touch edge-to-edge.", ttOpts)

	local scaleBox = AceGUI:Create("MAW-Editbox")
	scaleBox:SetLabel("Scale")
	scaleBox:SetText(buildConfig.scale)
	scaleBox:SetRelativeWidth(0.48)
	scaleBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.scale = text end)
	f:AddChild(scaleBox)
	EpsilonLib.Utils.Tooltip.SetAce(scaleBox, "Scale", "Size multiplier applied to every piece. 1 = normal size.", ttOpts)

	local turnBox = AceGUI:Create("MAW-Editbox")
	turnBox:SetLabel("Turn Offset (deg)")
	turnBox:SetText(buildConfig.turnOffset)
	turnBox:SetRelativeWidth(0.48)
	turnBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.turnOffset = text end)
	f:AddChild(turnBox)
	EpsilonLib.Utils.Tooltip.SetAce(turnBox, "Turn Offset", "Corrects the model's own 'forward' direction. If a test piece faces sideways or backwards, try 90, -90 or 180.", ttOpts)

	local sinkDepthBox = AceGUI:Create("MAW-Editbox")
	sinkDepthBox:SetLabel("Sink Into Ground")
	sinkDepthBox:SetText(buildConfig.sinkDepth)
	sinkDepthBox:SetRelativeWidth(0.48)
	sinkDepthBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.sinkDepth = text end)
	f:AddChild(sinkDepthBox)
	EpsilonLib.Utils.Tooltip.SetAce(sinkDepthBox, "Sink Into Ground", "Pushes every piece down by this much (yards), so small height errors bury the base instead of leaving a gap. Too much and pieces clip visibly.", ttOpts)

	local centerPivotCheck = AceGUI:Create("CheckBox")
	centerPivotCheck:SetLabel("Center pivot on each segment")
	centerPivotCheck:SetValue(buildConfig.centerPivot)
	centerPivotCheck:SetFullWidth(true)
	centerPivotCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.centerPivot = value end)
	f:AddChild(centerPivotCheck)
	EpsilonLib.Utils.Tooltip.SetAce(centerPivotCheck, "Center Pivot", "Most fence pieces are modeled around their center. Untick this if your object's pivot point is at one end instead, and pieces look shifted.", ttOpts)

	local loopCheck = AceGUI:Create("CheckBox")
	loopCheck:SetLabel("Close loop (last point back to first)")
	loopCheck:SetValue(buildConfig.loop)
	loopCheck:SetFullWidth(true)
	loopCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.loop = value end)
	f:AddChild(loopCheck)
	EpsilonLib.Utils.Tooltip.SetAce(loopCheck, "Close Loop", "Adds one more piece connecting the last point back to the first, for a closed enclosure.", ttOpts)

	local followSlopeCheck = AceGUI:Create("CheckBox")
	followSlopeCheck:SetLabel("Follow terrain slope (tilt pieces)")
	followSlopeCheck:SetValue(buildConfig.followSlope)
	followSlopeCheck:SetFullWidth(true)
	followSlopeCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.followSlope = value end)
	f:AddChild(followSlopeCheck)
	EpsilonLib.Utils.Tooltip.SetAce(followSlopeCheck, "Follow Terrain Slope", "Experimental: tilts each rail piece to match the ground slope instead of staying flat. End posts always stay upright.", ttOpts)

	local slopeAxisDropdown = AceGUI:Create("Dropdown")
	slopeAxisDropdown:SetLabel("Tilt Axis")
	slopeAxisDropdown:SetList({ pitch = "Pitch (Y)", roll = "Roll (X)" }, { "pitch", "roll" })
	slopeAxisDropdown:SetValue(buildConfig.slopeAxis)
	slopeAxisDropdown:SetFullWidth(true)
	slopeAxisDropdown:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.slopeAxis = value end)
	f:AddChild(slopeAxisDropdown)
	EpsilonLib.Utils.Tooltip.SetAce(slopeAxisDropdown, "Tilt Axis", "Which axis this model tilts vertically on. Test on a slope and switch if it tilts sideways instead of up/down.", ttOpts)

	local invertSlopeCheck = AceGUI:Create("CheckBox")
	invertSlopeCheck:SetLabel("Invert Tilt")
	invertSlopeCheck:SetValue(buildConfig.invertSlope)
	invertSlopeCheck:SetFullWidth(true)
	invertSlopeCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.invertSlope = value end)
	f:AddChild(invertSlopeCheck)
	EpsilonLib.Utils.Tooltip.SetAce(invertSlopeCheck, "Invert Tilt", "Flips the tilt direction, if pieces lean uphill instead of downhill (or vice versa).", ttOpts)

	local pitchOffsetBox = AceGUI:Create("MAW-Editbox")
	pitchOffsetBox:SetLabel("Pitch Offset (deg)")
	pitchOffsetBox:SetText(buildConfig.pitchOffset)
	pitchOffsetBox:SetRelativeWidth(0.48)
	pitchOffsetBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.pitchOffset = text end)
	f:AddChild(pitchOffsetBox)
	EpsilonLib.Utils.Tooltip.SetAce(pitchOffsetBox, "Pitch Offset", "Constant correction added to every piece's Pitch, for a model that isn't modeled dead level. Works even with Follow Terrain Slope off.", ttOpts)

	local rollOffsetBox = AceGUI:Create("MAW-Editbox")
	rollOffsetBox:SetLabel("Roll Offset (deg)")
	rollOffsetBox:SetText(buildConfig.rollOffset)
	rollOffsetBox:SetRelativeWidth(0.48)
	rollOffsetBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.rollOffset = text end)
	f:AddChild(rollOffsetBox)
	EpsilonLib.Utils.Tooltip.SetAce(rollOffsetBox, "Roll Offset", "Same as Pitch Offset, but for Roll.", ttOpts)

	local endPostBox = AceGUI:Create("MAW-Editbox")
	endPostBox:SetLabel("End Post Object ID (optional)")
	endPostBox:SetText(buildConfig.endPostEntry)
	endPostBox:SetFullWidth(true)
	endPostBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.endPostEntry = text end)
	f:AddChild(endPostBox)
	EpsilonLib.Utils.Tooltip.SetAce(endPostBox, "End Post", "Optional standalone post GameObject to cap each open end. Leave blank to skip. Ignored when Loop is checked.", ttOpts)

	local capStartCheck = AceGUI:Create("CheckBox")
	capStartCheck:SetLabel("Cap start")
	capStartCheck:SetValue(buildConfig.capStart)
	capStartCheck:SetRelativeWidth(0.48)
	capStartCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.capStart = value end)
	f:AddChild(capStartCheck)
	EpsilonLib.Utils.Tooltip.SetAce(capStartCheck, "Cap Start", "Uncheck to skip the post at the first point, e.g. if this fence continues an existing structure.", ttOpts)

	local capEndCheck = AceGUI:Create("CheckBox")
	capEndCheck:SetLabel("Cap end")
	capEndCheck:SetValue(buildConfig.capEnd)
	capEndCheck:SetRelativeWidth(0.48)
	capEndCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.capEnd = value end)
	f:AddChild(capEndCheck)
	EpsilonLib.Utils.Tooltip.SetAce(capEndCheck, "Cap End", "Uncheck to skip the post at the last point, e.g. if this fence continues into an existing structure.", ttOpts)

	local overlapEndPostsCheck = AceGUI:Create("CheckBox")
	overlapEndPostsCheck:SetLabel("Overlap end posts")
	overlapEndPostsCheck:SetValue(buildConfig.overlapEndPosts)
	overlapEndPostsCheck:SetFullWidth(true)
	overlapEndPostsCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.overlapEndPosts = value end)
	f:AddChild(overlapEndPostsCheck)
	EpsilonLib.Utils.Tooltip.SetAce(overlapEndPostsCheck, "Overlap End Posts", "Sinks the start/end posts into their neighboring rail by the Overlap amount, same as rail-to-rail joints.", ttOpts)

	local jointPostsCheck = AceGUI:Create("CheckBox")
	jointPostsCheck:SetLabel("Post at every joint")
	jointPostsCheck:SetValue(buildConfig.jointPosts)
	jointPostsCheck:SetFullWidth(true)
	jointPostsCheck:SetCallback("OnValueChanged", function(widget, event, value) buildConfig.jointPosts = value end)
	f:AddChild(jointPostsCheck)
	EpsilonLib.Utils.Tooltip.SetAce(jointPostsCheck, "Post At Every Joint", "Also spawns a post at every joint between rail pieces, not just the two open ends.", ttOpts)

	local jointPostBox = AceGUI:Create("MAW-Editbox")
	jointPostBox:SetLabel("Intermediate Post ID (optional)")
	jointPostBox:SetText(buildConfig.jointPostEntry)
	jointPostBox:SetFullWidth(true)
	jointPostBox:SetCallback("OnTextChanged", function(widget, event, text) buildConfig.jointPostEntry = text end)
	f:AddChild(jointPostBox)
	EpsilonLib.Utils.Tooltip.SetAce(jointPostBox, "Intermediate Post ID", "GameObject Entry ID used for joint posts. Leave blank to reuse the End Post Object ID instead.", ttOpts)

	pointsLabel = AceGUI:Create("Label")
	pointsLabel:SetFullWidth(true)
	pointsLabel:SetFontObject(GameFontNormal)
	f:AddChild(pointsLabel)

	local markBtn = AceGUI:Create("Button")
	markBtn:SetText("Mark Point Here")
	markBtn:SetWidth(150)
	markBtn:SetCallback("OnClick", markPoint)
	f:AddChild(markBtn)
	EpsilonLib.Utils.Tooltip.SetAce(markBtn, "Mark Point Here", "Adds your current position to the fence path. Walk to the next corner/post and mark again. Can be bound to a key (Key Bindings > Object Mover).", ttOpts)

	local undoBtn = AceGUI:Create("Button")
	undoBtn:SetText("Undo Last")
	undoBtn:SetWidth(110)
	undoBtn:SetCallback("OnClick", undoPoint)
	f:AddChild(undoBtn)
	EpsilonLib.Utils.Tooltip.SetAce(undoBtn, "Undo Last", "Removes the last marked point.", ttOpts)

	local clearBtn = AceGUI:Create("Button")
	clearBtn:SetText("Clear Points")
	clearBtn:SetWidth(150)
	clearBtn:SetCallback("OnClick", function()
		EpsilonLib.Utils.GenericDialogs.CustomConfirmation({
			text = "Clear all marked fence points?",
			acceptText = "Clear",
			showAlert = true,
			callback = clearPoints,
		})
	end)
	f:AddChild(clearBtn)
	EpsilonLib.Utils.Tooltip.SetAce(clearBtn, "Clear Points", "Removes all marked points and starts over.", ttOpts)

	local buildBtn = AceGUI:Create("Button")
	buildBtn:SetText("Build Fence")
	buildBtn:SetWidth(110)
	buildBtn:SetCallback("OnClick", buildFence)
	f:AddChild(buildBtn)
	EpsilonLib.Utils.Tooltip.SetAce(buildBtn, "Build Fence", "Spawns the fence using the marked points and the settings above.", ttOpts)

	refreshPointsLabel()

	return f
end

local function toggleWindow()
	if window and window.frame:IsShown() then
		window:Hide()
		return
	end

	if not window then
		window = buildWindow()
	else
		window:Show()
		refreshPointsLabel()
	end
end

--#endregion

--#region Registration

OBJECT_TOOLBOX_API.FenceBuilder = {
	MarkPoint = markPoint,
	UndoPoint = undoPoint,
	Toggle = toggleWindow,
}

ns.AddTool({
	{
		text = "Fence / Barrier Builder",
		tooltipText = "Walk a path in-world, mark points along it, then auto-spawn a chain of fence/barrier GameObjects following the ground.",
		func = toggleWindow,
		disabled = function()
			return not EpsilonLib.GameObject.CanSpawn()
		end,
	},
})

--#endregion
