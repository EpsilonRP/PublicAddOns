local EpsilonLib, EpsiLib = ...;

EpsiLib.Classes = {}

--- Meta Object Definitions

---@class PhaseClass
---@field data PhaseData
---@field loaded? boolean
---@field ContinueOnPhaseLoad function
---@field GetPhaseBackground function
---@field GetPhaseColor function
---@field GetPhaseDescription function
---@field GetPhaseID function
---@field GetPhaseInfo function
---@field GetPhaseMessage function
---@field GetPhaseName function
---@field GetPhaseTags function
---@field _Clear function
---@field _GetDataByKey function
---@field _Init function
---@field _SetDataByKey function
---@field _SetPhaseID function

---@class PhaseData
---@field id number
---@field name string
---@field icon string
---@field message string
---@field info string
---@field desc string
---@field tags string[]
---@field color string
---@field bg string
