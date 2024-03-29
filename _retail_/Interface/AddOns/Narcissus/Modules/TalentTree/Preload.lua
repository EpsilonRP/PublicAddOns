local _, addon = ...

local OnEnterDelay = CreateFrame("Frame");

addon.TalentTreeOnEnterDelay = OnEnterDelay;


OnEnterDelay.onUpdate = function(self, elapsed)
    self.t = self.t + elapsed;
    if self.t > 0.1 then
        self:SetScript("OnUpdate", nil);
        self.t = 0;
        if self.button and self.button.OnEnterCallback then
            self.button:OnEnterCallback();
        end
        self.button = nil;
    end
end

function OnEnterDelay:WatchButton(button)
    self.button = button;
    self.t = 0;
    self:SetScript("OnUpdate", self.onUpdate);
end

function OnEnterDelay:ClearButton()
    self.button = nil;
    self:SetScript("OnUpdate", nil);
end