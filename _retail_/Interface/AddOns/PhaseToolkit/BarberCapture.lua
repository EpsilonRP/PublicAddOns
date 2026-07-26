local _, addon = ...;

addon.BarberCapture = {}

local function token(name)
  name = type(name) == "string" and name:gsub("’","'") or ""
  local base, side = name:match("^%s*(.-)%s*%((Left|Right)%)%s*$")
  if base and side then
    base = base:lower():gsub("%s+",""):gsub("[^%w]+","")
    return ("%s(%s)"):format(base, side:lower())
  end
  return name:lower():gsub("%s+",""):gsub("[^%w]+","")
end

local function idx1(opt)
  local c = opt and opt.choices
  if type(c) ~= "table" or #c == 0 then return nil end
  local i = opt.currentChoiceIndex
  if type(i) == "number" and c[i] then return i end
  for k, ch in ipairs(c) do
    if ch and (ch.isCurrent or ch.isActive or ch.selected) then return k end
  end
  return 1
end

local function close()
  if C_BarberShop and C_BarberShop.Cancel then pcall(C_BarberShop.Cancel) end
  if not BarberShopFrame then return end
  if BarberShopFrame.CloseButton and BarberShopFrame.CloseButton.Click then return BarberShopFrame.CloseButton:Click() end
  if HideUIPanel then return HideUIPanel(BarberShopFrame) end
  if BarberShopFrame.Hide then BarberShopFrame:Hide() end
end

local function capture()
  if not (C_BarberShop and C_BarberShop.GetAvailableCustomizations) then return nil, "No C_BarberShop.GetAvailableCustomizations" end
  local data = C_BarberShop.GetAvailableCustomizations()
  if not data then return nil, "No data (open barber UI)" end
  local out = {}
  for _, cat in ipairs(data) do
    for _, opt in ipairs(cat.options or {}) do
      local i = idx1(opt)
      if i then out[#out+1] = ("phase forge npc outfit custom %s %d"):format(token(opt.name), i) end
    end
  end
  return out
end

function addon.BarberCapture.Capture(cb)
  if UIParentLoadAddOn then pcall(UIParentLoadAddOn, "Blizzard_BarbershopUI") end
  if not (SendChatMessage and C_Timer and C_Timer.NewTicker) then return cb(nil, "Missing SendChatMessage/C_Timer") end
  SendChatMessage(".cheat barber", "SAY")

  local t, max = 0, 3.0
  local tick
  tick = C_Timer.NewTicker(0.05, function()
    t = t + 0.05
    if BarberShopFrame and BarberShopFrame.IsShown and BarberShopFrame:IsShown() then
      tick:Cancel()
      C_Timer.After(0.05, function()
        local cmds, err = capture()
        close()
        cb(cmds, err)
      end)
    elseif t >= max then
      tick:Cancel()
      cb(nil, "Timeout opening barber UI")
    end
  end)
end