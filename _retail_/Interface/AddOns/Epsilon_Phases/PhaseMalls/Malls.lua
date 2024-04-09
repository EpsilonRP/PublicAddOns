local phases, EPSILON_PHASES = ...
local EpsiLib = EpsilonLib;


PhaseMalls = EPSILON_PHASES.PhaseMalls;

local f = CreateFrame("FRAME");
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:SetScript("OnEvent", function(self,event)

    PhaseMalls:addMall(26000, "Master Mall", "Builder's Haven")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")
    PhaseMalls:addMall(200, "Tile Mall", "Azarchius")

end)



