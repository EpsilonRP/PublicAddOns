local EpsilonLib, EpsiLib = ...;

local CopyTable = CopyTable
local wipe = wipe
local tinsert = tinsert

EpsiLib.PhaseAddonData = EpsiLib.PhaseAddonData or {}

-- Max Calls Per Minute
local maxCPM = 80

local listenerFrame = CreateFrame("Frame")
listenerFrame:RegisterEvent("CHAT_MSG_ADDON")

local getAddonData = C_Epsilon.GetPhaseAddOnData --[[@as function]]

EpsiLib.PhaseAddonData.queue = {}
EpsiLib.PhaseAddonData.pending = {}
local numCalls = 0

local function stashRequest(key, callback)
    tinsert(EpsiLib.PhaseAddonData.pending, {key, callback})
end

local function resumePending()
    local pending = CopyTable(EpsiLib.PhaseAddonData.pending)
    wipe(EpsiLib.PhaseAddonData.pending)
    for i = 1, #pending do
        EpsiLib.PhaseAddonData.RequestAddOnData(pending[i][1], pending[i][2])
    end
end

---Requests the Data from the Phase via key, then calls the callback with the data as the first variable
---@param key string
---@param callback function
---@return string|boolean ticket The Message Ticket the server will reply using as the prefix, or false if it was stashed.
function EpsiLib.PhaseAddonData.RequestAddOnData(key, callback)
    if numCalls > maxCPM then
        stashRequest(key, callback)
        return false
    end

    numCalls = numCalls + 1
    if numCalls == 1 then
        C_Timer.After(60, function() -- reset after 60 seconds / 1 minute, then resume pending
            numCalls = 0
            resumePending()
        end)
    end

    local ticket = getAddonData(key)
    EpsiLib.PhaseAddonData.queue[ticket] = callback
    return ticket
end

listenerFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender, ...)
    if event == "CHAT_MSG_ADDON" and EpsiLib.PhaseAddonData.queue[prefix] then
        EpsiLib.PhaseAddonData.queue[prefix](text)
        EpsiLib.PhaseAddonData.queue[prefix] = nil
    end
end)