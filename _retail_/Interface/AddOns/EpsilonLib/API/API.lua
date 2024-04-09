local EpsilonLib, EpsiLib = ...

EpsiLib.API.MathU = {}
EpsiLib.API.Mathf = {}
--  Math Functions

--  Linear Interpolation
function EpsiLib.API.Mathf:Lerp(a, b, t)
    return a + (b - a) * t
end

--  Time Functions
EpsiLib.API.Time = {}
--  Time between rendered frames
EpsiLib.API.Time.deltaTime = 0;

local APIUtils = CreateFrame("Frame")
APIUtils:SetScript("OnUpdate", function(self) 
    EpsiLib.API.Time.deltaTime = 1 / GetFramerate();
end)
