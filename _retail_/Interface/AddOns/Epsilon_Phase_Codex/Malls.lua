local EpsilonPhases = LibStub("AceAddon-3.0"):GetAddon("EpsilonPhases")
local PhaseClass = EpsilonLib.Classes.Phase

---@alias EPSILON_BH_MALLS_CACHE table<number, boolean|string>

---Prefill this cache with defaults i^(.*)(\r?\n\1)+$f you want! The main phase directory is additive to this
---@type EPSILON_BH_MALLS_CACHE
EPSILON_BH_MALLS_CACHE = {
    [26000] = false,
    [16000] = false,
    [14000] = false,
    [40966] = false,
    [57886] = false,
    [79152] = false,
    [57582] = false,
    [53963] = false,
    [92298] = false,
    [83543] = false,
    [55347] = false,
    [53411] = false,
    [72547] = false,
    [43079] = false,
    [49333] = false,
    [119440] = false,
    [53457] = false,
    [77711] = false,
    [51029] = false,
    [58539] = false,
    [108194] = false,
    [94590] = false,
    [50355] = false,
    [112913] = false,
    [111420] = false,
    [110333] = false,
    [46752] = false,
    [62433] = false,
    [97686] = false,
    [106270] = false,
    [121740] = false,
    [124143] = false,
    [89458] = false,
    [131207] = false,
    [69057] = false,
    [144496] = false,
    [155503] = false,
    [163475] = false,
    [165783] = false,
    [138126] = false,
    [78798] = false,
    [77945] = false,
    [178411] = false,
    [177630] = false,
    [4050] = false,
    [101308] = false,
    [50565] = false,
    [34317] = false,
    [71399] = false,
    [94345] = false,
    [172996] = false,
    [57802] = false,
    [89324] = false,
    [27472] = false,
    [27820] = false,
    [55834] = false,
    [78041] = false,
    [67937] = false,
    [45914] = false,
    [52985] = false,
    [110206] = false,
    [111198] = false,
    [112095] = false,
    [65924] = false,
    [120514] = false,
    [100102] = false,
    [28530] = false,
    [46687] = false,
    [61677] = false,
    [70977] = false,
    [120099] = false,
    [26699] = 'mall',
    [69676] = false,
    [31342] = false,
    [149133] = false,
    [127279] = false,
    [75786] = false,
    [160622] = false,
    [28561] = false,
    [116172] = false,
    [102330] = false,
    [54647] = false,
    [68266] = false,
    [68578] = false,
    [64145] = false,
    [103262] = false,
    [16059] = false,
    [112930] = false,
    [117476] = false,
    [64622] = false,
    [121394] = false,
    [65782] = false,
    [947] = false,
    [84049] = false,
    [82778] = false,
    [73756] = false,
    [147452] = false,
    [154191] = false,
    [152219] = false,
    [164988] = false,
    [113135] = false,
    [183633] = false,
    [164640] = false,
    [1459] = false,
    [171169] = false,
    [187080] = false,
    [200] = false,
    [47690] = false,
    [124905] = false,
    [82098] = false,
    [81962] = false,
    [83412] = false,
    [143315] = false,
    [80110] = false,
    [80108] = false,
    [64757] = false,
    [49420] = false,
    [70270] = false,
    [35945] = false,
    [130421] = false,
    [108273] = false,
    [80982] = false,
    [166503] = false,
    [67558] = false,
    [149709] = false,
    [112442] = false,
    [86836] = false,
}

-- quicker local access
local _malls = EPSILON_BH_MALLS_CACHE

-- Updater for our EpsilonPhases.Malls horizontal cache
local function mallInfoCallback(phase)
    phase.data.entry = _malls[phase:GetPhaseID()]
    if tContains(EpsilonPhases.Malls, phase) then return end
    tinsert(EpsilonPhases.Malls, phase)
    EpsilonPhases.SetPhaseListToMalls()
end

local function UpdatePhaseMallsHorizCache(cache)
    local cache = cache or _malls
    for k, _ in pairs(cache) do
        PhaseClass:Get(k, mallInfoCallback)
    end
end
EpsilonPhases.UpdatePhaseMallsHorizCache = UpdatePhaseMallsHorizCache

--#region Mall Directory Management
-- Main Phase Mall Data to be formatted as "id:teleport,id:teleport" - teleport is optional and can be left off (do not put `:`)

local function processMPDirectoryString(data, callback)
    if data == "" then -- No data, so we'll just use the current or default cache
        if callback then callback(_malls) end
        return
    end
    local malls = strsplittable(",", data)
    for _, mall in ipairs(malls) do
        local id, teleport = strsplit(":", mall, 2)

        if not tonumber(id) then
            print("Invalid mall ID in BH_MALLS: " .. id)
            print("Mall data: " .. data)
            error("Invalid mall ID in BH_MALLS: " .. id)
        end

        _malls[tonumber(id)] = (teleport or false)
    end

    if callback then callback(_malls) end
end

---Gets the list of malls from the main phase directory and saves to local cache
function EpsilonPhases:GetMallsFromMPDirectory(callback)
    if tonumber(C_Epsilon.GetPhaseId()) ~= 169 then return end
    EpsilonLib.PhaseAddonData.Get("BH_MALLS", function(data) processMPDirectoryString(data, callback) end)
end

---Add a new phase to the main phase directory, with an optional teleport point name
---@param mallId number
---@param teleName string
function EpsilonPhases:AddMallToMPDirectory(mallId, teleName)
    if tonumber(C_Epsilon.GetPhaseId()) ~= 169 then error("Must be in main phase") end -- Must be in main phase fam
    local teleEntryStr = mallId .. (teleName and ":" .. teleName or "")
    EpsilonLib.PhaseAddonData.Get("BH_MALLS", function(data)
        local mallsRaw = strsplittable(",", data)
        local malls = {}
        local overwrite = false

        if data == "" then
            EpsilonLib.PhaseAddonData.Set("BH_MALLS", teleEntryStr)
            return
        end

        -- Check if this ID is already in the list. If it is, overwrite it.
        for index, mall in ipairs(mallsRaw) do
            local id, teleport = strsplit(":", mall, 2)
            if tonumber(id) == mallId then
                table.insert(malls, teleEntryStr)
                overwrite = true
            else
                table.insert(malls, mall)
            end
        end
        if not overwrite then
            table.insert(malls, teleEntryStr)
        end

        local finalMallsStr = table.concat(malls, ",")
        EpsilonLib.PhaseAddonData.Set("BH_MALLS", finalMallsStr)

        processMPDirectoryString(finalMallsStr, nil)
    end)
end

---Remove a mall from the main phase directory
---@param mallId number
function EpsilonPhases:RemoveMallFromMPDirectory(mallId)
    if tonumber(C_Epsilon.GetPhaseId()) ~= 169 then error("Must be in main phase") end -- Must be in main phase fam

    _malls[mallId] = nil

    PhaseClass:Get(mallId, function(phase)
        tDeleteItem(EpsilonPhases.Malls, phase)
    end)

    EpsilonLib.PhaseAddonData.Get("BH_MALLS", function(data)
        local mallsRaw = strsplittable(",", data)
        local malls = {}

        if data == "" then return end

        -- Check if this ID is already in the list. If it is, skip adding it to the new table & then save.
        for index, mall in ipairs(mallsRaw) do
            local id, teleport = strsplit(":", mall, 2)
            if tonumber(id) ~= mallId then
                table.insert(malls, mall)
            end
        end

        local finalMallsStr = table.concat(malls, ",")
        EpsilonLib.PhaseAddonData.Set("BH_MALLS", finalMallsStr)

        processMPDirectoryString(finalMallsStr, nil)
    end)
end
