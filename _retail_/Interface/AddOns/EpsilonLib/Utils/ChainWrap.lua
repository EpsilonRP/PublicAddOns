--[[
ChainWrap.lua

Wraps any WoW UI object (or plain Lua table) so that every method call
returns the wrapped object itself, enabling fluent/chained syntax:

    local btn = ChainWrap(CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate"))
    btn:SetSize(120, 24)
       :SetText("Click Me")
       :SetPoint("CENTER")
       :Show()

Real return values are NOT lost - they're just not part of the chain.
Use :Unwrap() to get the raw object, and :Call("Method", ...) if you need
the actual return values instead of the proxy.
--]]

local proxyCache = setmetatable({}, { __mode = "k" }) -- weak keys, avoid leaks

local function ChainWrap(obj)
    if obj == nil then return nil end

    -- Return existing proxy if we already wrapped this object
    if proxyCache[obj] then
        return proxyCache[obj]
    end

    local proxy = {}
    local methodCache = {} -- cache wrapped functions per-key, avoid re-closuring every access

    local mt = {
        __index = function(_, key)
            -- Special "escape hatch" methods
            if key == "Unwrap" then
                return function() return obj end
            elseif key == "Call" then
                -- btn:Call("GetPoint") -> returns the REAL results, no proxy
                return function(_, methodName, ...)
                    local field = obj[methodName]
                    if type(field) ~= "function" then
                        error("ChainWrap: '"..tostring(methodName).."' is not a method", 2)
                    end
                    return field(obj, ...)
                end
            end

            if methodCache[key] then
                return methodCache[key]
            end

            local field = obj[key]

            if type(field) == "function" then
                local wrapped = function(_, ...)
                    field(obj, ...) -- call real method on the REAL object, discard returns
                    return proxy    -- always return proxy for chaining
                end
                methodCache[key] = wrapped
                return wrapped
            else
                -- Non-function field (e.g. obj.SomeValue) - just pass through
                return field
            end
        end,

        __newindex = function(_, key, value)
            obj[key] = value -- writes go straight to the real object
        end,
    }

    setmetatable(proxy, mt)
    proxyCache[obj] = proxy
    return proxy
end

_G.ChainWrap = ChainWrap
return ChainWrap
