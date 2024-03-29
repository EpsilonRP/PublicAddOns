local _, addon = ...

local DataProvider = {};
addon.TalentTreeDataProvider = DataProvider;

local C_ClassTalents = C_ClassTalents;
local C_Traits = C_Traits;
local GetSpecialization = GetSpecialization;
local GetSpecializationInfo = GetSpecializationInfo;


-- Should use C_Traits.GetConditionInfo, conditionInfo.ranksGranted and conditionInfo.isMet to check if the talent is granted for free
-- But the API returns a table so I'd like to use this fast but less adaptive approach.

local AUTO_GRANTED_NODES = {
    --[specID] = {[nodeID] = true},
    --https://wowpedia.fandom.com/wiki/SpecializationID
    --/dump GetMouseFocus().nodeID

    [250] = {76071}, --Blood
    [251] = {76081}, --Frost
    [252] = {76072}, --Unholy

    [577] = {90942}, --Havoc
    [581] = {90943}, --Vengeance

    [102] = {82201, 82202}, --Balance
    [103] = {82199, 82223}, --Feral
    [104] = {82220, 82223}, --Guardian
    [105] = {82217, 82216}, --Restoration

    [1467] = {68681},    --Devastation
    [1468] = {68689},    --Preservation

    [253] = {79935}, --Beast Mastery
    [254] = {79834}, --Marksmanship
    [255] = {79839}, --Survival

    [62] = {62121},  --Arcane
    [63] = {62119},  --Fire
    [64] = {62117},  --Frost

    [268] = {80689}, --Brewmaster
    [270] = {80691}, --Mistweaver
    [269] = {80690}, --Windwalker

    [65] = {81597, 81599},  --Holy
    [66] = {81597, 81599},  --Protection
    [70] = {81510, 81601},  --Retribution

    [256] = {82717, 82713}, --Discipline
    [257] = {82717, 82718}, --Holy
    [258] = {82713, 82712}, --Shadow

    [259] = {90740}, --Assassination
    [260] = {90684}, --Outlaw
    [261] = {90685}, --Subtlety

    [262] = {81061, 81062}, --Elemental
    [263] = {81060, 81061}, --Enhancement
    [264] = {81062, 81063}, --Restoration

    [265] = {71933}, --Affliction   All The Same?
    [266] = {71933}, --Demonology
    [267] = {71933}, --Destruction

    [71] = {90327},  --Arms
    [72] = {90325},  --Fury
    [73] = {90261, 90330},  --Protection
};

do
    local total;

    for specID, grantedNodeIDs in pairs(AUTO_GRANTED_NODES) do
        total = #grantedNodeIDs;
        for i = 1, total do
            AUTO_GRANTED_NODES[specID][grantedNodeIDs[i]] = true;
            AUTO_GRANTED_NODES[specID][i] = nil;
        end
    end
end


function DataProvider:IsAutoGrantedTalent(nodeID)
    return self.autoGrantedNodes[nodeID]
end



function DataProvider:UpdateSpecInfo()
    local specIndex = GetSpecialization() or 1;
    local specID, specName = GetSpecializationInfo(specIndex);
    self.specID = specID;
    self.specName = specName;

    self.autoGrantedNodes = AUTO_GRANTED_NODES[specID] or {};
end

function DataProvider:GetCurrentSpecID()
    if not self.specID then
        self:UpdateSpecInfo();
    end
    return self.specID
end

function DataProvider:GetActiveLoadoutName()
    local specID = self:GetCurrentSpecID();
    local configs = C_ClassTalents.GetConfigIDsBySpecID(specID);
    local total = #configs;

    if total == 0 then
        return self.specName
    else
        local selectedID = C_ClassTalents.GetLastSelectedSavedConfigID(specID);
        local name;
        if selectedID then
            local info = C_Traits.GetConfigInfo(selectedID);
            name = info and info.name;
        end
        return name or self.specName
    end
end

function DataProvider:GetSelecetdConfigID()
    local specID = self:GetCurrentSpecID();
    local selectedID = C_ClassTalents.GetLastSelectedSavedConfigID(specID);
    return selectedID
end
