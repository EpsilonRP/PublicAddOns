GBRadioAddonData = LibStub(GBR_Constants.LIB_ACE_ADDON):NewAddon(
    GBR_Constants.OPT_ADDON_ID, 
    GBR_Constants.LIB_ACE_COMM, 
    GBR_Constants.LIB_ACE_SERIALISER,
    GBR_Constants.LIB_ACE_EVENT,
    GBR_Constants.LIB_ACE_CONSOLE);
    
GBRadio = {};
GBR_Singletons = nil;

function GBRadioAddonData:OnInitialize()

    GBR_Singletons = GBR_SingletonService:New();

    GBRadio
        :AddServices()
        :AddCommands()
        :AddConfiguration()
        :AddCommunication()
        :AddHooks();

end

function GBRadio:AddServices()

    GBR_Singletons:RegisterManualService(GBR_Constants.SRV_ADDON_SERVICE, GBRadioAddonData);

    return self;

end

function GBRadio:AddCommands()

    GBR_Singletons:InstantiateService(GBR_Constants.SRV_COMMAND_SERVICE);

    return self;
end

function GBRadio:AddCommunication()

    local frameEnteringWorldTriggers = CreateFrame("FRAME");
    frameEnteringWorldTriggers:RegisterEvent("PLAYER_ENTERING_WORLD");

    local frameLeavingWorldTriggers = CreateFrame("FRAME");
    frameLeavingWorldTriggers:RegisterEvent("PLAYER_LEAVING_WORLD")
    
    function frameEnteringWorldTriggers:OnEvent(event, isInitialLogin, isReloadingUi)
        local configService = GBR_Singletons:FetchService(GBR_Constants.SRV_CONFIG_SERVICE);
        local microMenu = GBR_Singletons:FetchService(GBR_Constants.SRV_MICROMENU_SERVICE);

        JoinChannelByName(GBR_Constants.OPT_COMM_CHANNEL_NAME, nil);
        
        if configService:ShouldShowMicroMenu(isInitialLogin, isReloadingUi) then
            microMenu:Display();
        end
        
        if configService:IsFirstTimeUser() then
            microMenu:DisplayFirstTimeUserScreen();
        end
    end

    function frameLeavingWorldTriggers:OnEvent(event)
        local microMenu = GBR_Singletons:FetchService(GBR_Constants.SRV_MICROMENU_SERVICE);
        local configService = GBR_Singletons:FetchService(GBR_Constants.SRV_CONFIG_SERVICE);

        if microMenu.isShown then
            local x, y = microMenu._window.frame:GetCenter();
            configService:SaveMicroMenuPosition(x, y);
        end
    end
    
    frameEnteringWorldTriggers:SetScript("OnEvent", frameEnteringWorldTriggers.OnEvent);
    frameLeavingWorldTriggers:SetScript("OnEvent", frameLeavingWorldTriggers.OnEvent);
    
    GBRadioAddonData:RegisterComm(GBR_Constants.OPT_ADDON_CHANNEL_PREFIX, GBR_MessageService.StaticReceiveMessage);

    return self;

end

function GBRadio:AddConfiguration()

    local defaultSettings = GBR_ConfigPresets.BuzzBox;
    
    GBRadioAddonDataSettingsDB = LibStub(GBR_Constants.LIB_ACE_DB):New(GBR_Constants.OPT_ADDON_SETTINGS_DB, defaultSettings);

    local channelCount = 0;

    for k,v in pairs(GBRadioAddonDataSettingsDB.char.Channels) do
        channelCount = channelCount + 1;
    end

    if channelCount == 0 then 
        GBRadioAddonDataSettingsDB.char.Channels["DEFAULT"] = GBR_ConfigPresets.DefaultChannel;
    end

    GBR_Singletons:InstantiateService(GBR_Constants.SRV_CONFIG_SERVICE);

    return self;

end

function GBRadio:AddHooks()

    GBR_Singletons:InstantiateService(GBR_Constants.SRV_HOOK_SERVICE)
        :RegisterHooks();

    if TRP3_API then
        if TRP3_API.globals.extended_display_version then
            TRP3_API.globals.extended_display_version = TRP3_API.globals.extended_display_version .. GBRadio:GetTooltipVersionDisplay();
        else
            TRP3_API.globals.version_display = TRP3_API.globals.version_display .. GBRadio:GetTooltipVersionDisplay();
        end
    end

    return self;

end

function GBRadio:GetTooltipVersionDisplay()
    return string.format("\n" 
        .. [[|TInterface\COMMON\Indicator-Green:16:16:0:0|t |cFF00FF00GBRadio v-%s|r]],
        GBR_Constants.OPT_ADDON_VERSION);
end