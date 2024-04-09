local EpsilonLib, EpsiLib = ...

--EpsiLib.Container = CreateFrame("FRAME", "ContainerFrame", UIParent, "EpsiLibDefaultPanelTemplate");

EpsiLib.Container = CreateFrame("FRAME", "ContainerFrame", UIParent, "EpsiLibButtonFrameTemplate");


local container = EpsiLib.Container;

local init = true;
local main = EpsiLib.Container;
--main:ClearAllPoints()
main:Hide() -- Start Hidden fam
main:SetWidth(540)
main:SetPoint("CENTER", UIParent, 0, 0)
main:EnableMouse(true)
main:SetAttribute("UIPanelLayout-area", "top")
main:SetAttribute("UIPanelLayout-defined", true)
main:SetAttribute("UIPanelLayout-enabled", true)
main:SetAttribute("UIPanelLayout-pushable", 3)
main:SetAttribute("UIPanelLayout-whileDead", true)
main:SetAttribute("UIPanelLayout-width", main:GetWidth())
main:SetClampedToScreen(true)
--main:SetBackdropColor(0.5,0.5,0.5,1);

--main:SetBackdropBorderColor(0.4,0.4,0.4,0.6)

if main.portrait then
    main.portrait:SetTexture("Interface\\addons\\EpsilonLib\\Resources\\Epsilon_Icon")
    main.portrait:SetMask("Interface\\Minimap\\UI-Minimap-Background")
end


main:SetScript("OnShow", function()
	PlaySoundFile("igCharacterInfoTab");
end)
main:SetScript("OnHide", function()
	PlaySoundFile("igMainMenuClose");
end)

main:SetMovable(true)
main:EnableMouse(true)
main:RegisterForDrag("LeftButton")
main:SetScript("OnDragStart", main.StartMoving)
main:SetScript("OnDragStop", main.StopMovingOrSizing)


--Resize Button
main:SetResizable(true)
main.resizeButton = CreateFrame("Button", "ResizeButton", main)
main.resizeButton:SetFrameLevel(5)
main.resizeButton:SetSize(16, 16)
main.resizeButton:SetPoint("BOTTOMRIGHT")
main.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
main.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
main.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")



main.isResizing = false;
main.defaultSize = {width = 550, height = 350}

function main:ValidSize(width, height)

    if main:GetWidth() <= main.defaultSize.width-(main.defaultSize.width / 200) and main:GetHeight() <= main.defaultSize.height-(main.defaultSize.height / 200) then
        return false;
	else
		return true;
    end
end


main.Overlay = main:CreateTexture("OverlayTex", "OVERLAY")
main.Overlay:SetPoint("TOPLEFT", 0, 0)
main.Overlay:SetPoint("BOTTOMRIGHT", 0, 0)
main.Overlay:SetVertexColor(1, 0, 0, 0)
main.Overlay:SetTexture("Interface/Tooltips/UI-Tooltip-Background")

local colour = {red = 1, blue = 0, green = 0, alpha = 0} -- r, g, b, a

function main:Resizing()
	if main:ValidSize(main:GetWidth(), main:GetHeight()) == false then
		colour.alpha = EpsiLib.API.Mathf:Lerp(colour.alpha, 1, EpsiLib.API.Time.deltaTime * 10)
	else
		colour.alpha = EpsiLib.API.Mathf:Lerp(colour.alpha, 0, EpsiLib.API.Time.deltaTime * 10)
	end
	
	main.Overlay:SetVertexColor(colour.red, colour.blue, colour.green, colour.alpha)
	
	C_Timer.After(EpsiLib.API.Time.deltaTime, function(self) 
		if main.isResizing then
			main:Resizing()
		else
			return
		end
	end)
end

function main:StopSizing()
	print(main:GetWidth(), main:GetHeight(), main:ValidSize(main:GetWidth(), main:GetHeight()), colour.alpha)
	--If invalid size set to valid size
	if not main:ValidSize(main:GetWidth(), main:GetHeight()) and colour.alpha ~= 0 then
		--Resize
		main:SetWidth(EpsiLib.API.Mathf:Lerp(main:GetWidth(), main.defaultSize.width, EpsiLib.API.Time.deltaTime * 20))
		main:SetHeight(EpsiLib.API.Mathf:Lerp(main:GetHeight(), main.defaultSize.height, EpsiLib.API.Time.deltaTime * 20))
		--Reset colour
		colour.alpha = EpsiLib.API.Mathf:Lerp((colour.alpha/main.defaultSize.width)/100, 0, EpsiLib.API.Time.deltaTime * 20)
		main.Overlay:SetVertexColor(colour.red, colour.blue, colour.green, colour.alpha)
	else
		main.isResizing = false
		return
	end

	C_Timer.After(EpsiLib.API.Time.deltaTime, function(self) 
		if main.isResizing then
			main:StopSizing()
		end
	end)
end

main.resizeButton:SetScript("OnMouseDown", function(self, button)
	--print("Resizing ", main:GetWidth(), main:GetHeight())
    main:StartSizing("BOTTOMRIGHT")
	main.isResizing = true
	main:Resizing()
end)

main.resizeButton:SetScript("OnMouseUp", function(self, button)
	main:StopSizing()
	main:StopMovingOrSizing()
    main:SetUserPlaced(true)
end)


main.TitleText:SetText(EpsilonLib)

     
-- create the frame that will hold all other frames/objects:

-- Tabs
do -- Tabs
	EpsiLib.ContainerTemplate.Tabs = {}
	local Tabs = EpsiLib.ContainerTemplate.Tabs
	
	function Tabs.setTab(parent, id)
		if parent.TitleText then parent.TitleText:SetText(parent.Tabs[id]:GetText()) end
		ShowUIPanel(parent)
		for i = 1, parent.numTabs do
			parent.Containers[i]:Hide()
		end
		PanelTemplates_SetTab(parent, id)
		parent.Containers[parent.selectedTab]:Show()
		PlaySoundFile("igMainMenuOptionCheckBoxOn")
	end
	
	function Tabs.onClick(self)
		Tabs.setTab(self:GetParent(), self:GetID())
	end
	
	function Tabs.createTab(text, parent)
		parent.Tabs = parent.Tabs or {}
		parent.Containers = parent.Containers or {}
		local id = #parent.Tabs + 1
		local container = CreateFrame("FRAME", "$parentContainer"..id, parent.Inset, "EpsiLibInsetFrameTemplate")
		container:SetPoint("TOPLEFT")
		container:SetPoint("BOTTOMRIGHT")
		container:SetID(id)
		local tab = CreateFrame("BUTTON", "$parentTab"..id, parent, "EpsiLibCharacterFrameTabButtonTemplate")
		tab:SetText(text)
		tab:SetClampedToScreen(true)
		table.insert(parent.Tabs, tab)
		table.insert(parent.Containers, container)
		tab:SetID(id)
		PanelTemplates_SetNumTabs(parent, #parent.Tabs)
		if id == 1 then
			tab:SetPoint("BOTTOMLEFT", 5, -30)
			PanelTemplates_SetTab(parent, id)
			parent.TitleText:SetText(text)
			container:Show()
		else
			tab:SetPoint("LEFT", parent.Tabs[parent.numTabs - 1], "RIGHT", -15, 0)
			PanelTemplates_UpdateTabs(parent)
			container:Hide()
		end
		tab:SetScript("OnClick", Tabs.onClick)
		return container
	end

end

do -- Headers
	EpsiLib.ContainerTemplate.Headers = {}
	local Headers = EpsiLib.ContainerTemplate.Headers

	local tabs = EpsiLib.ContainerTemplate.Tabs
	
	function Headers.onClick(self)
		tabs.setTab(self:GetParent(), self:GetID())
	end
	
	function Headers.createHeader(text, parent)
		parent.Tabs = parent.Tabs or {}
		parent.Containers = parent.Containers or {}
		local id = #parent.Tabs + 1
		local container = CreateFrame("FRAME", "$parentContainer"..id, parent, "EpsiLibInsetFrameTemplate")
		container:SetPoint("TOPLEFT")
		container:SetPoint("BOTTOMRIGHT")
		local tab = CreateFrame("BUTTON", "$parentTab"..id, parent, "EpsiLibTabButtonTemplate")
		tab:SetText(text)
		table.insert(parent.Tabs, tab)
		table.insert(parent.Containers, container)
		tab:SetID(id)
		PanelTemplates_SetNumTabs(parent, #parent.Tabs)
		if id == 1 then
			tab:SetPoint("BOTTOM", parent, "TOP")
			tab:SetPoint("LEFT", 50, 0)
			PanelTemplates_SetTab(parent, id)
			container:Show()
		else
			tab:SetPoint("LEFT", parent.Tabs[parent.numTabs - 1], "RIGHT")
			PanelTemplates_UpdateTabs(parent)
			container:Hide()
		end
		PanelTemplates_TabResize(tab, 0)
		tab:SetScript("OnClick", Headers.onClick)
		return container
	end

end



