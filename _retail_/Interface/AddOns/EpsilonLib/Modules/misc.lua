local EpsilonLib, EpsiLib = ...;


-- Add PhaseID to MiniMap Zone Tooltip
hooksecurefunc("Minimap_SetTooltip", function()
	GameTooltip:AddDoubleLine("Phase: ", C_Epsilon.GetPhaseId(), nil, nil, nil, 1, 1, 1)
end)
