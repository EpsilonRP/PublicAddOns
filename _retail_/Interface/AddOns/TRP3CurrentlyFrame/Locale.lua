-- TRP3 Currently Frame by Tammya-Moonguard (2018)

local _, Me = ...

local Locales = {
   enUS = {
      -- The note that shows up in the game's addon list.
      CURFRAME_ADDON_NOTES = "Adds a window for editing your Currently.";
      -- The title of the addon.
      CURFRAME_ADDON_TITLE = "TRP3 Currently Frame";
      -- The title of this addon's section in the Frames settings.
      CURFRAME_CO_HEADER = "Currently frame";
      -- The title of the "Show frame" option.
      CURFRAME_CO_SHOW_FRAME = "Show frame";
      -- The tooltip text for the "Show frame" option.
      CURFRAME_CO_SHOW_FRAME_HELP = "Show or hide the currently frame. You can also hide the frame by setting your OOC flag, but this is useful if you're only interested in the /cur command.";
      -- The title of the "Show OOC" option.
      CURFRAME_CO_SHOW_OOC = "Show OOC";
      -- The tooltip for the "Show OOC" option.
      CURFRAME_CO_SHOW_OOC_HELP = "Show editor for OOC information in the frame.";
      -- Alias for the /cur command, for a more foreign-friendly slash command. Both /cur and this translation will invoke the currently slash command.
      CURFRAME_SLASH_CMD = "/cur";
      -- Command to set the OOC currently.
      CURFRAME_SLASH_CMD2 = "/cooc";
   };
}

---------------------------------------------------------------------------
-- Other languages imported from Curse during packaging.
---------------------------------------------------------------------------

Locales.frFR = {
	["CURFRAME_ADDON_NOTES"] = "Ajoute une fenêtre pour éditer votre Actuellement.",
	["CURFRAME_ADDON_TITLE"] = "TRP3 Cadre Actuellement",
	["CURFRAME_CO_HEADER"] = "Cadre Actuellement",
	["CURFRAME_CO_SHOW_FRAME"] = "Afficher cadre",
	["CURFRAME_CO_SHOW_FRAME_HELP"] = "Affiche ou cache le cadre Actuellement. Vous pouvez aussi cacher le cadre en vous mettant HRP, mais ceci est utile si vous êtes simplement intéressé par la commande /act.",
	["CURFRAME_SLASH_CMD"] = "/act"
}
Locales.deDE = {
	["CURFRAME_ADDON_NOTES"] = "Öffnet ein Fenster, in welchem du dein \"Aktuelles\" bearbeiten kannst.",
	["CURFRAME_ADDON_TITLE"] = "TRP3 \"Aktuelles\" Fenster.",
	["CURFRAME_CO_HEADER"] = "\"Aktuelles\" Fenster.",
	["CURFRAME_CO_SHOW_FRAME"] = "Zeige Fenster",
	["CURFRAME_CO_SHOW_FRAME_HELP"] = "Zeige oder verberge dein \"Aktuell\" fenster. Du kannst das Fenster auch verbergen, indem du dich OOC flaggst, dies ist allerdings nur nützlich, wenn du lediglich den /aktl Befehl benutzen möchtest.",
	["CURFRAME_SLASH_CMD"] = "/aktl"
}
Locales.itIT = {
}
Locales.koKR = {
}
Locales.zhCN = {
	["CURFRAME_ADDON_NOTES"] = "添加一个用于编辑当前状况的窗口。",
	["CURFRAME_ADDON_TITLE"] = "TRP3当前状况框架",
	["CURFRAME_CO_HEADER"] = "当前状况",
	["CURFRAME_CO_SHOW_FRAME"] = "显示框架",
	["CURFRAME_CO_SHOW_FRAME_HELP"] = "显示或隐藏当前状况框架。你也可以通过启动OOC状态来隐藏框架，但如果你只想使用/cur指令时这个选项很有用。",
	["CURFRAME_SLASH_CMD"] = "/cur"
}
Locales.zhTW = {
	["CURFRAME_ADDON_NOTES"] = "添加一個用於編輯當前狀況的窗口。",
	["CURFRAME_ADDON_TITLE"] = "TRP3當前狀況框架",
	["CURFRAME_CO_HEADER"] = "當前狀況",
	["CURFRAME_CO_SHOW_FRAME"] = "顯示框架",
	["CURFRAME_CO_SHOW_FRAME_HELP"] = "顯示或隱藏當前狀況框架。你也可以通過啟動OOC狀態來隱藏框架，但如果你只想使用/cur指令時這個選項很有用。",
	["CURFRAME_SLASH_CMD"] = "/cur"
}
Locales.ruRU = {
	["CURFRAME_ADDON_NOTES"] = "Добавляет окно для редактирования вашего статуса.",
	["CURFRAME_ADDON_TITLE"] = "Окно \"Сейчас\" TRP3",
	["CURFRAME_CO_HEADER"] = "Окно Сейчас",
	["CURFRAME_CO_SHOW_FRAME"] = "Показать окно",
	["CURFRAME_CO_SHOW_FRAME_HELP"] = "Показать или спрятать окно Сейчас. Его можно спрятать также с помощью кнопки OOC, это применимо при использовании команды /сейч.",
	["CURFRAME_SLASH_CMD"] = "/сейч"
}
Locales.esES = {
}
Locales.esMX = {
}
Locales.ptBR = {
	["CURFRAME_ADDON_NOTES"] = "Adiciona uma janela para editar o seu Atualmente.",
	["CURFRAME_ADDON_TITLE"] = "TRP3 - Janela p/ o Atualmente",
	["CURFRAME_CO_HEADER"] = "Janela p/ o Atualmente",
	["CURFRAME_CO_SHOW_FRAME"] = "Mostrar a janela",
	["CURFRAME_CO_SHOW_FRAME_HELP"] = "Mostra ou esconde sua janela de Atualmente. Você pode esconder a janela escolhendo o modo OOC, pode ser útil se você só está interessado no comando /atual.",
	["CURFRAME_SLASH_CMD"] = "/atual"
}


-------------------------------------------------------------------------------
function Me.AddLocales()
   TRP3_API.loc:GetDefaultLocale():AddTexts( Locales.enUS )
   for code, strings in pairs( Locales ) do
      TRP3_API.loc:GetLocale( code ):AddTexts( strings )
   end
   
   -- garbage collect
   Locales = nil
end
