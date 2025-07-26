local a, t = ...
local s, n = t.AddSetToMall, 1
local mog = MogIt

t.AddMall(1, "Epsilon (Cosmic)")

-- mog:ToStringItem(id, bonus, diff)
local m = function(id, bonus, diff) return mog:ToStringItem(id, bonus, diff) end

-- function mog:LinkToSet(link)
local l = function(link) return mog:LinkToSet(link) end

--function s.AddSetToMall(phaseId, id, name, items, mogSetFormat, skipRefresh)
local c = function(name, items)
	s(1, n, name, items, nil, true)
	n = n + 1;
end

--c("Grey Warden", l("MogIt:9cJH;lN6k;KY1H;ynAx;hB0n;Cvey;w7xs;doTg;pZfU:00:0"))
--c("Wardeness", { 1189927, })
