---@class ns
local ns = select(2, ...)

local addonName = ...
local C = {}

C.addonName = addonName
C.addonVersion = GetAddOnMetadata(addonName, "Version")
C.addonAuthor = GetAddOnMetadata(addonName, "Author")
C.addonTitle =  GetAddOnMetadata(addonName, "Title")
C.playerName = UnitName("player") --[[@as string]]

---@enum TRIGGER_TYPES
C.TRIGGER_TYPES = {
    [1] = "Flight",
    [2] = "Sprint",
    [3] = "Both",
}

C.COLORS = {
    CONTRAST_RED = CreateColorFromHexString("FFFFAAAA"),
    GREEN = CreateColorFromHexString("ff57F287"),
    ORANGE_GOLD = CreateColorFromHexString("ffFFA600"),
    ALERT_RED = CreateColorFromHexString("FFFF0000"),
    GAME_GOLD = CreateColorFromHexString("FFFFD700"),
}

-----------------------------------------
--#region ---- DEFAULT SETTINGS ---------
-----------------------------------------

C.defaultGlobalSettings = {
    global = { ["debug"] = false, sprintKey = "LSHIFT", sprintMode = "dual", alwaysFixSprintJump = false, extendedFlightDetection = true, lastRunVersion = false },
    runOnceFixBindings = {},
    sprintSpellListStorage = {
        ["Sprint Roll"] = {171358},
        ["Sprint Trial Visual"] = {110519},
        ["Whirlwind Sprint"] = {108207},
    },
    flightSpellListStorage = {
        ["Poly Dust"] = {291362},
        ["Feather Trail"] = {153031},
        ["Prismatic"] = {223143},
        ["Levitating+Hover (Anim)"] = {252620, 138092},
    },
    profiles = {
        default = {
            flight = {
                enabled = true,
                landDelay = 0,
                needShift = false,
                tripleJump = true,
                jumpToLand = 2,
                maxKeyDelay = 0.25,

                arcanumToggle = false,
                arcanumStart = false,
                arcanumStop = false,

                sendSpells = true,
                spellList = {},
            },
            sprint = {
                arcanumToggle = false,
                arcanumStart = false,
                arcanumStop = false,

                enableCtrlSprintToggle = false,
                allowSprintWhenNotMoving = false,
                enabled = true,

                speedWalk = 1.6,
                speedFly = 10,
                speedSwim = 10,
                speedWalkEnabled = true,
                speedFlyEnabled = true,
                speedSwimEnabled = true,
                sprintReturnLastSpeed = true,
                toggleHoldShiftDelay = 0.35,

                emoteMessage = "begins to sprint.",
                emoteRateLimit = 5,
                sendEmote = { walk = false, fly = false, swim = false },

                sendSpells = { walk = true, fly = true, swim = true },
                spellList = {},
            },
        }
    }
}

C.defaultCharSettings = {
    activeProfile = "default"
}

-----------------------------------------
--#endregion ----------------------------
-----------------------------------------

ns.Constants = C