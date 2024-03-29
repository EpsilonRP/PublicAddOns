-------------------------------------------------------------------------------
-- TRP3 Currently Frame by Tammya-Moonguard (2018)
--
-- Adds a standalone frame to edit your currently status.
-------------------------------------------------------------------------------

local addonName, Me = ...

local L = TRP3_API.loc

local CONFIG_POS_X     = "CONFIG_TRP3CURRENTLYFRAME_POS_X";
local CONFIG_POS_Y     = "CONFIG_TRP3CURRENTLYFRAME_POS_Y";
local CONFIG_POS_A     = "CONFIG_TRP3CURRENTLYFRAME_POS_A";
local CONFIG_SHOW      = "CONFIG_TRP3CURRENTLYFRAME_SHOW";
local CONFIG_SHOW_OOC  = "CONFIG_TRP3CURRENTLYFRAME_SHOW_OOC";

-------------------------------------------------------------------------------
-- Called when the module is initialized.
--
local function onInit()
   Me.AddLocales()
   L = TRP3_API.loc
   
   Me.frame = CreateFrame( "Frame", "TRP3CurrentlyFrame", UIParent,
                                                      "TRP3CurrentlyTemplate" )
   Me.frame.host = Me
   
   -- Set the currently frame's caption.
   Me.frame.caption.label:SetText( L.REG_PLAYER_CURRENT )
   Me.frame.textooc.label:SetText( L.CM_OOC )

   Me.frame:SetBackdrop {
      bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background";
      edgeFile = "Interface\\GLUES\\COMMON\\TextPanel-Border";
      tile     = true;
      edgeSize = 16;
      tileSize = 380;
      insets   = { left = 2, right = 2, top = 1, bottom = 3 };
   }
   
   Me.frame.caption:SetBackdrop {
      bgFile   = "Interface\\BankFrame\\Bank-Background";
      edgeFile = "Interface\\GLUES\\COMMON\\TextPanel-Border";
      tile     = true;
      edgeSize = 16;
      tileSize = 100;
      insets   = { left = 4, right = 2, top = 2, bottom = 2 };
   }
   
   Me.frame.UpdateHeight = function( self )
   
      if not TRP3_API.configuration.getValue( CONFIG_SHOW_OOC ) then
         self:SetHeight( -(self.text:GetBottom() - self:GetTop()) + 14 )
      else
         self:SetHeight( -(self.textooc:GetBottom() - self:GetTop()) + 14 )
      end
      
   end
end

-------------------------------------------------------------------------------
-- Update frame display.
--
local function updateFrame()
   local show_ooc = TRP3_API.configuration.getValue( CONFIG_SHOW_OOC )

   -- Update visibility.
   if TRP3_API.profile.getData( "player/character/RP" ) == 1
                          and TRP3_API.configuration.getValue(CONFIG_SHOW) then
      Me.frame:Show()
      if show_ooc then
         Me.frame.textooc:Show()
      else
         Me.frame.textooc:Hide()
      end
   else
      Me.frame:Hide()
   end
   
   -- Update text from profile currently.
   Me.frame.text:SetText( TRP3_API.profile.getData("player/character").CU or "" )
   Me.frame.textooc:SetText( TRP3_API.profile.getData("player/character").CO or "" )
   
   Me.frame:UpdateHeight()
end

-------------------------------------------------------------------------------
-- The /cur slash command.
--
local function SlashCommandCur( msg )
   Me:SetCurrently( msg )
end

-------------------------------------------------------------------------------
-- The /cooc slash command.
--
local function SlashCommandCooc( msg )
   Me:SetCurrently( msg, true )
end

-------------------------------------------------------------------------------
-- Secondary initialization.
--
local function onStart()

   local self = Me
   TRP3_API.currently_frame = Me;
   
   SlashCmdList.CUR  = SlashCommandCur
   SlashCmdList.COOC = SlashCommandCooc
   SLASH_CUR1  = "/cur"
   SLASH_COOC1 = "/cooc"
   
   -- Add alternat slash commands if the translation is different.
   if L.CURFRAME_SLASH_CMD ~= "/cur" then
      SLASH_CUR2 = L.CURFRAME_SLASH_CMD
   end
   
   if L.CURFRAME_SLASH_CMD2 ~= "/cooc" then
      SLASH_COOC2 = L.CURFRAME_SLASH_CMD2
   end

   TRP3_API.configuration.registerConfigKey( CONFIG_POS_A, "TOP" );
   TRP3_API.configuration.registerConfigKey( CONFIG_POS_X, 0 );
   TRP3_API.configuration.registerConfigKey( CONFIG_POS_Y, -60 );
   TRP3_API.configuration.registerConfigKey( CONFIG_SHOW, true );
   TRP3_API.configuration.registerConfigKey( CONFIG_SHOW_OOC, false );
   
   -- Build configuration page (todo: localization)
   tinsert( TRP3_API.configuration.CONFIG_FRAME_PAGE.elements, {
      inherit = "TRP3_ConfigH1";
      title   = L.CURFRAME_CO_HEADER;
   });
   
   tinsert( TRP3_API.configuration.CONFIG_FRAME_PAGE.elements, {
      inherit   = "TRP3_ConfigCheck";
      title     = L.CURFRAME_CO_SHOW_FRAME;
      help      = L.CURFRAME_CO_SHOW_FRAME_HELP;
      configKey = CONFIG_SHOW;
   });
   
   tinsert( TRP3_API.configuration.CONFIG_FRAME_PAGE.elements, {
      inherit   = "TRP3_ConfigCheck";
      title     = L.CURFRAME_CO_SHOW_OOC;
      help      = L.CURFRAME_CO_SHOW_OOC_HELP;
      configKey = CONFIG_SHOW_OOC;
   });
   
   -- handler for when the show toggle is changed.
   TRP3_API.configuration.registerHandler( CONFIG_SHOW, updateFrame )
   TRP3_API.configuration.registerHandler( CONFIG_SHOW_OOC, updateFrame )
   
   function Me:ResetConfig()
      TRP3_API.configuration.setValue( CONFIG_POS_A, "TOP" );
      TRP3_API.configuration.setValue( CONFIG_POS_X, 0 );
      TRP3_API.configuration.setValue( CONFIG_POS_Y, -60 );
      TRP3_API.configuration.setValue( CONFIG_SHOW, true );
      TRP3_API.configuration.setValue( CONFIG_SHOW_OOC, false );
   end   

   Me.frame:ClearAllPoints()
   Me.frame:SetPoint(
      TRP3_API.configuration.getValue(CONFIG_POS_A), 
      UIParent, 
      TRP3_API.configuration.getValue(CONFIG_POS_A),
      TRP3_API.configuration.getValue(CONFIG_POS_X), 
      TRP3_API.configuration.getValue(CONFIG_POS_Y));
   
   Me.frame:SetMovable(true) 
   Me.frame.caption:SetScript( "OnMouseDown", function( self, button )
      if button == "LeftButton" then
         Me.frame:StartMoving()
      end
   end)
   
   Me.frame.caption:SetScript( "OnMouseUp", function( self, button )
      if button == "LeftButton" then
         Me.frame:StopMovingOrSizing()
         local anchor, _, _, x, y = Me.frame:GetPoint(1)

         TRP3_API.configuration.setValue( CONFIG_POS_A, anchor )
         TRP3_API.configuration.setValue( CONFIG_POS_X, x )
         TRP3_API.configuration.setValue( CONFIG_POS_Y, y )
      end
   end)
   
   function Me:SetCurrently( text, ooc )
      if not ooc then
         Me.frame.text:SetText( text or "" )
      else
         Me.frame.textooc:SetText( text or "" )
      end
      Me:SaveCurrently()
   end
   
   function Me:SaveCurrently()
      local character = TRP3_API.profile.getData("player/character")
      local old_cu = character.CU
      local old_co = character.CO
      character.CU = self.frame.text:GetText()
      character.CO = self.frame.textooc:GetText()
      local changed = false
      if old_cu ~= character.CU then
         changed = true
         local context = TRP3_API.navigation.page.getCurrentContext()
         if context and context.isPlayer then
            TRP3_RegisterMiscViewCurrentlyICScrollText:SetText( character.CU or "" )
         end
      end
      
      if old_co ~= character.CO then
         changed = true
         local context = TRP3_API.navigation.page.getCurrentContext()
         if context and context.isPlayer then
            TRP3_RegisterMiscViewCurrentlyOOCScrollText:SetText( character.CO or "" )
         end
      end
      
      if changed then
         -- Update profile version (v) and then trigger an event for other
         --  TRP handlers.
         character.v = TRP3_API.utils.math.incrementNumber(character.v or 1, 2)
         TRP3_API.events.fireEvent( 
            TRP3_API.events.REGISTER_DATA_UPDATED,
            TRP3_API.globals.player_id, 
            TRP3_API.profile.getPlayerCurrentProfileID(), 
            "character"
         )
      end
   end
   
   TRP3_API.events.listenToEvent( TRP3_API.events.REGISTER_DATA_UPDATED,
                                               function( player_id, profileID )
      if player_id == TRP3_API.globals.player_id then
         updateFrame()
      end
   end)
   
   -- 1.6 offers support for ElvUI skinning. It's kind of wonky how this is
   --  done, but it works out...
   TRP3_API.Events.registerCallback(
                                TRP3_API.Events.WORKFLOW_ON_FINISH, function()
      -- Check if the ElvUI support module is loaded. We're using it to
      --  determine if we want to skin ourselves or not. It's not the most 
      --  intuitive thing - piggybacking off of the "target frame" skinning,
      --  but an extra option is just clunky. -Maybe- it might be best in the
      --  future if the ElvUI section of the configuration had our own option
      --  shown.
      if TRP3_API.module.isModuleLoaded("trp3_elvui") then
         if TRP3_API.configuration.getValue( "elvui_skin_target_frame" ) then
            if not ElvUI[1] then return end
            
            local function SkinFrames()
               local ElvUI_Tooltip = ElvUI[1]:GetModule('Tooltip');
               ElvUI_Tooltip:SetStyle( Me.frame )
               ElvUI_Tooltip:SetStyle( Me.frame.caption )
               
               -- Adjust a few things. Normally the label is 1px above the
               --  center, because it works better with the default font.
               -- ElvUI font makes it look off centered and ugly, so we
               --  reset the anchor here.
               -- We also make the background color solid for the label.
               --  Not 100% sure if it's the right color, because this is
               --  just for tooltips, but it looks close enough.
               local r, g, b = Me.frame.caption:GetBackdropColor()
               Me.frame.caption:SetBackdropColor(r, g, b, 1)
               Me.frame.caption.label:SetPoint( "CENTER" )
            end
            
            if not ElvUI[1].initialized then
               -- ElvUI isn't fully initialized yet, and we will error
               --  if we try to use the tooltip module right now. Defer
               --  action until we're sure everything is loaded. We could
               --  hook their initialization routine or do something else.
               hooksecurefunc( ElvUI[1], "Initialize", SkinFrames )
            else
               SkinFrames()
            end
         end
      end
      
   end)
   
   -- If the user clicks on the world (screen with no UI element), remove
   --  focus from the frames.
   WorldFrame:HookScript( "OnMouseDown", function()
      if Me.frame.text:HasFocus() then
         Me.frame.text:ClearFocus()
      end
      if Me.frame.textooc:HasFocus() then
         Me.frame.textooc:ClearFocus()
      end
   end)
   
   updateFrame()
end
 
------------------------------------------------------------------------------
-- Register with TRP3.
--
local MODULE_INFO = {

   -- copy info over from the TOC file
   --
   ["name"]        = GetAddOnMetadata( addonName, "Title" );
   ["description"] = GetAddOnMetadata( addonName, "Notes" );
   
   -- we are cutting off the minor version for the two-figure version number
   -- in the module
   --
   ["version"]     = tonumber( GetAddOnMetadata( addonName, "Version" ):match("^%d+%.%d+") );
   
   ["id"]          = "trp3_currently_frame";
   ["onStart"]     = onStart;
   ["onInit"]      = onInit;
   ["minVersion"]  = 3;
};

TRP3_API.module.registerModule( MODULE_INFO );
