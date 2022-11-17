
local AddOnName, MoveAny = ...

local config = {
	["title"] = format( "MoveAny |T135994:16:16:0:0|t v|cff3FC7EB%s", "0.9.5" )
}

local PREFIX = "MOAN"
local IASendProfiles = {}
local IAWantProfiles = {}
local WebStatus = 0
local WebProfile = ""
local WebOwner = ""
local WebProfileData = {}

local searchStr = ""
local br = 8
local sw = 520
local sh = 520
local posy = -4
local cas = {}
local cbs = {}
local sls = {}

local EMMapForced = {}
EMMapForced["Minimap"] = true
EMMapForced["MINIMAP"] = true
EMMapForced["PlayerFrame"] = true
EMMapForced["PLAYERFRAME"] = true
EMMapForced["ObjectiveTrackerFrame"] = true
EMMapForced["QUESTTRACKER"] = true
EMMapForced["ChatFrame1"] = true
EMMapForced["CHAT"] = true

local EMMap = {}
EMMap["MAPetBar"] = "ShowPetActionBar"
EMMap["MAGameTooltip"] = "ShowHudTooltip"
EMMap["TalkingHeadFrame"] = "ShowTalkingHeadFrame"
EMMap["MABuffBar"] = "ShowBuffFrame"
EMMap["MADebuffBar"] = "ShowDebuffFrame"
EMMap["TargetFrame"] = "ShowTargetAndFocus"
EMMap["FocusFrame"] = "ShowTargetAndFocus"
EMMap["ExtraAbilityFrame"] = "ShowExtraAbility"
EMMap["PossessActionBar"] = "ShowPossessActionBar"
EMMap["PossessBarFrame"] = "ShowPossessActionBar"
EMMap["MainMenuBarVehicleLeaveButton"] = "ShowVehicleLeaveButton"
EMMap["PlayerCastingBarFrame"] = "ShowCastBar"

function MoveAny:IsBlizEditModeEnabled()
	if EditModeManagerFrame then
		return true
	end
	return false
end

function MoveAny:IsInEditModeEnabled( val )
	local editModeEnum = nil

	if not MoveAny:IsBlizEditModeEnabled() then
		return false, false
	end

	if EMMapForced[val] then
		return true, true
	end
	if Enum and Enum.EditModeAccountSetting then
		if EMMap[val] then
			editModeEnum = Enum.EditModeAccountSetting[EMMap[val]]
		else
			editModeEnum = Enum.EditModeAccountSetting[val]
		end
		if EMMap[val] and editModeEnum == nil then
			for i, v in pairs( Enum.EditModeAccountSetting ) do
				MoveAny:MSG( "ENUM i: " .. tostring( i ) .. " v: " .. tostring( v ) )
			end
		end
	end

	if editModeEnum and EditModeManagerFrame then
		if EditModeManagerFrame:GetAccountSettingValueBool( editModeEnum ) then
			return true, false
		end
	end
	return false, false
end

local function AddCategory( key )
	if cas[key] == nil then
		cas[key] = CreateFrame( "Frame", key .. "_Category", MALock.SC )
		local ca = cas[key]
		ca:SetSize( 24, 24 )

		ca.f = ca:CreateFontString( nil, nil, "GameFontNormal" )
		ca.f:SetPoint( "LEFT", ca, "LEFT", 0, 0 )
		ca.f:SetText( MoveAny:GT( key ) )
	end

	cas[key]:ClearAllPoints()
	if strfind( strlower( key ), strlower( searchStr ) ) or strfind( strlower( MoveAny:GT( key ) ), strlower( searchStr ) ) then
		cas[key]:Show()

		if posy < -4 then
			posy = posy - 10
		end
		cas[key]:SetPoint( "TOPLEFT", MALock.SC, "TOPLEFT", 6, posy )
		posy = posy - 24
	else
		cas[key]:Hide()
	end
end

local function AddCheckBox( x, key, val, func, id, editModeEnum )
	if val == nil then
		MoveAny:MSG( "Missing Value For: " .. tostring( key ) )
		val = true
	end
	local lstr = "|cFFFFFFFF" .. MoveAny:GT( key )
	if id then
		lstr = format( lstr, id )
	end
	
	local enabled1, forced1 = MoveAny:IsInEditModeEnabled( key )
	local enabled2, forced2 = MoveAny:IsInEditModeEnabled( editModeEnum )
	if enabled1 or enabled2 then
		if forced1 or forced2 then
			lstr = lstr .. " |cFFFF0000" .. MoveAny:GT( "ISENABLEDINEDITMODE" )
		else
			lstr = lstr .. " |cFFFFFF00" .. MoveAny:GT( "ISENABLEDINEDITMODE" )
		end
	end

	if id then
		key = key .. id
	end
	if cbs[key] == nil then
		cbs[key] = CreateFrame( "CheckButton", key .. "_CB", MALock.SC, "UICheckButtonTemplate" )
		local cb = cbs[key]
		cb:SetSize( 24, 24 )
		cb:SetChecked( MoveAny:IsEnabled( key, val ) )
		cb:SetScript( "OnClick", function( self )
			MoveAny:SetEnabled( key, self:GetChecked() )

			if func then
				func()
			end

			if MALock.save then
				MALock.save:Enable()
			end
		end)

		cb.f = cb:CreateFontString( nil, nil, "GameFontNormal" )
		cb.f:SetPoint( "LEFT", cb, "RIGHT", 0, 0 )
		cb.f:SetText( lstr )
	end

	cbs[key]:ClearAllPoints()
	if strfind( strlower( key ), strlower( searchStr ) ) or strfind( strlower( lstr ), strlower( searchStr ) ) then
		cbs[key]:Show()

		cbs[key]:SetPoint( "TOPLEFT", MALock.SC, "TOPLEFT", x, posy )
		posy = posy - 24
	else
		cbs[key]:Hide()
	end
end

local function AddSlider( x, key, val, func, vmin, vmax, steps )
	if sls[key] == nil then
		sls[key] = CreateFrame( "Slider", "sls[" .. key .. "]", MALock.SC, "OptionsSliderTemplate" )

		sls[key]:SetWidth( MALock.SC:GetWidth() - 30 - x )
		sls[key]:SetPoint( "TOPLEFT", MALock.SC, "TOPLEFT", x + 5, posy )

		sls[key].Low:SetText(vmin)
		sls[key].High:SetText(vmax)
		
		sls[key].Text:SetText( MoveAny:GT(key) .. ": " .. MoveAny:GV( key, val ) )

		sls[key]:SetMinMaxValues(vmin, vmax)
		sls[key]:SetObeyStepOnDrag(true)
		sls[key]:SetValueStep(steps)

		sls[key]:SetValue( MoveAny:GV( key, val ) )

		sls[key]:SetScript("OnValueChanged", function(self, val)
			val = tonumber( string.format( "%" .. steps .. "f", val ) )
			if val and val ~= MoveAny:GV( key ) then
				MoveAny:SV( key, val )
				sls[key].Text:SetText( MoveAny:GT( key ) .. ": " .. val )

				if func then
					func()
				end

				if MALock.save then
					MALock.save:Enable()
				end
			end
		end)
		posy = posy - 10
	end

	sls[key]:ClearAllPoints()
	if strfind( strlower( key ), strlower( searchStr ) ) or strfind( strlower( MoveAny:GT( key ) ), strlower( searchStr ) ) then
		sls[key]:Show()

		sls[key]:SetPoint( "TOPLEFT", MALock.SC, "TOPLEFT", x, posy )
		posy = posy - 24
	else
		sls[key]:Hide()
	end
end

function MoveAny:InitMALock()
	MALock = CreateFrame( "Frame", "MALock", UIParent, "BasicFrameTemplate" )
	MALock:SetSize( sw, sh )
	MALock:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

	MALock:SetFrameStrata( "HIGH" )
	MALock:SetFrameLevel( 999 )

	MALock:SetClampedToScreen( true )
	MALock:SetMovable( true )
	MALock:EnableMouse( true )
	MALock:RegisterForDrag( "LeftButton" )
	MALock:SetScript( "OnDragStart", MALock.StartMoving )
	MALock:SetScript( "OnDragStop", function()
		MALock:StopMovingOrSizing()

		local p1, p2, p3, p4, p5 = MALock:GetPoint()
		p4 = MoveAny:Grid( p4 )
		p5 = MoveAny:Grid( p5 )
		MoveAny:SetElePoint( "MALock", p1, _, p3, p4, p5 )
	end )

	MALock.TitleText:SetText( config.title )

	MALock.CloseButton:SetScript( "OnClick", function()
		MoveAny:ToggleMALock()
	end )

	function MAUpdateElementList()
		local _, class = UnitClass( "PLAYER" )
		
		local sh = 24
		posy = -4

		AddCategory( "GENERAL" )
		AddCheckBox( 4, "SHOWMINIMAPBUTTON", true, MoveAny.UpdateMinimapButton )
		AddSlider( 24, "GRIDSIZE", 10, MoveAny.UpdateGrid, 1, 100, 1 )
		AddCheckBox( 4, "MOVEFRAMES", true )
		AddCheckBox( 24, "FRAMESSHIFTDRAG", false )
		AddCheckBox( 24, "FRAMESSHIFTSCALE", false )
		AddCheckBox( 24, "FRAMESSHIFTRESET", false )

		AddCategory( "BUILTIN" )
		AddCheckBox( 4, "EDITMODE", MABUILDNR < 100000 )
		AddCheckBox( 24, "PLAYERFRAME", MABUILDNR < 100000 )
		AddCheckBox( 24, "TARGETFRAME", MABUILDNR < 100000, nil, nil, "ShowTargetAndFocus" )
		AddCheckBox( 24, "FOCUSFRAME", MABUILDNR < 100000, nil, nil, "ShowTargetAndFocus" )
		AddCheckBox( 24, "BUFFS", MABUILDNR < 100000, nil, nil, "ShowBuffFrame" )
		AddCheckBox( 24, "DEBUFFS", false, nil, nil, "ShowDebuffFrame" )
		AddCheckBox( 24, "GAMETOOLTIP", MABUILDNR < 100000, nil, nil, "ShowHudTooltip" )
		AddCheckBox( 24, "PETBAR", MABUILDNR < 100000, nil, nil, "ShowPetActionBar" )
		AddCheckBox( 24, "STANCEBAR", MABUILDNR < 100000, nil, nil, "ShowStanceBar" )
		AddCheckBox( 24, "POSSESSBAR", false, nil, nil, "ShowPossessActionBar" )
		AddCheckBox( 24, "LEAVEVEHICLE", MABUILDNR < 100000, nil, nil, "ShowVehicleLeaveButton" )
		if ExtraAbilityContainer then
			AddCheckBox( 24, "EXTRAABILITYCONTAINER", MABUILDNR < 100000, nil, nil, "ShowExtraAbilities" )
		end
		AddCheckBox( 24, "CASTINGBAR", MABUILDNR < 100000, nil, nil, "ShowCastBar" )
		AddCheckBox( 24, "TALKINGHEAD", MABUILDNR < 100000, nil, nil, "ShowTalkingHeadFrame" )
		if MABUILD ~= "RETAIL" then
			AddCheckBox( 24, "ACTIONBARS", MABUILDNR < 100000 )
		end
		for i = 1, 5 do
			if _G["ChatFrame" .. i .. "Tab"]:GetParent() ~= GeneralDockManager or i == 1 then
				AddCheckBox( 24, "CHAT", true, nil, i )
			end
		end
		AddCheckBox( 24, "MINIMAP", MABUILDNR < 100000 )
		AddCheckBox( 24, "QUESTTRACKER", true )
		
		AddCategory( "NORMAL" )
		AddCheckBox( 4, "PETFRAME", true )
		AddCheckBox( 4, "TARGETOFTARGETFRAME", false )
		AddCheckBox( 4, "TARGETOFFOCUSFRAME", false )
		AddCheckBox( 4, "ZONETEXTFRAME", true )
		AddCheckBox( 4, "VEHICLESEATINDICATOR", true )
		AddCheckBox( 4, "DURABILITY", true )
		AddCheckBox( 4, "MICROMENU", true )
		AddCheckBox( 4, "BAGS", true )
		if QueueStatusButton then
			AddCheckBox( 4, "QUEUESTATUSBUTTON", true )
		end

		if MABUILD ~= "RETAIL" then
			AddCheckBox( 4, "ACTIONBAR7", false )
			AddCheckBox( 4, "ACTIONBAR8", false )
			AddCheckBox( 4, "ACTIONBAR9", false )
			AddCheckBox( 4, "ACTIONBAR10", false )
		end
		if StatusTrackingBarManager then
			AddCheckBox( 4, "STATUSTRACKINGBARMANAGER", true )
		else
			AddCheckBox( 4, "MAINMENUEXPBAR", true )
			AddCheckBox( 4, "REPUTATIONWATCHBAR", true )
		end
		
		AddCheckBox( 4, "MAFPSFrame", true )
		AddCheckBox( 4, "ZONEABILITYFRAME", true )
		AddCheckBox( 4, "UIWIDGETPOWERBAR", true )

		if QuickJoinToastButton then
			AddCheckBox( 4, "CHATQUICKJOIN", false )
		end

		
		if SpellActivationOverlayFrame then
			AddCheckBox( 4, "SPELLACTIVATIONOVERLAYFRAME", false )
		end

		AddCategory( "CLASSSPECIFIC" )
		if RuneFrame and class == "DEATHKNIGHT" then
			AddCheckBox( 4, "RUNEFRAME", false )
		end
		if MABUILD == "WRATH" and class == "SHAMAN" then
			AddCheckBox( 4, "TOTEMBAR", true )
		end
		if WarlockPowerFrame and class == "WARLOCK" then
			AddCheckBox( 4, "WARLOCKPOWERFRAME", false )
		end
		if MonkHarmonyBarFrame and class == "MONK" then
			AddCheckBox( 4, "MONKHARMONYBARFRAME", false )
		end
		if MageArcaneChargesFrame and class == "MAGE" then
			AddCheckBox( 4, "MAGEARCANECHARGESFRAME", false )
		end
		if EssencePlayerFrame and class == "EVOKER" then
			AddCheckBox( 4, "ESSENCEPLAYERFRAME", false )
		end
		if PaladinPowerBarFrame and class == "PALADIN" then
			AddCheckBox( 4, "PALADINPOWERBARFRAME", false )
		end

		AddCategory( "ADVANCED" )
		if TotemFrame then
			AddCheckBox( 4, "TOTEMFRAME", false )
		end
		AddCheckBox( 4, "TARGETFRAMESPELLBAR", false )
		AddCheckBox( 4, "FOCUSFRAMESPELLBAR", false )
		AddCheckBox( 4, "UIWIDGETTOPCENTER", true )
		AddCheckBox( 4, "UIWIDGETBELOWMINIMAP", true )
		AddCheckBox( 4, "ARENAENEMYFRAMES", false )
		AddCheckBox( 4, "ARENAPREPFRAMES", false )
		AddCheckBox( 4, "GAMETOOLTIP_ONCURSOR", false )
		AddCheckBox( 4, "GROUPLOOTCONTAINER", true )
		AddCheckBox( 4, "ALERTFRAME", true )
		AddCheckBox( 4, "CHATBUTTONFRAME", false )
		AddCheckBox( 4, "CHATEDITBOX", false )
		if BNToastFrame then
			AddCheckBox( 4, "BATTLENETFRIENDSNOTIFICATION", true )
		end
		AddCheckBox( 4, "COMPACTRAIDFRAMEMANAGER", true )

		if IsAddOnLoaded( "ImproveAny" ) then
			AddCategory( "ImproveAny" )
			if IASkills and MABUILD ~= "RETAIL" then
				AddCheckBox( 4, "IASKILLS", true )
			end
			if IAMoneyBar then
				AddCheckBox( 4, "MONEYBAR", true )
			end
			if IATokenBar then
				AddCheckBox( 4, "TOKENBAR", true )
			end
			if IAILVLBar then
				AddCheckBox( 4, "IAILVLBAR", true )
			end
		end
	end

	MALock.Search = CreateFrame( "EditBox", "MALock_Search", MALock, "InputBoxTemplate" )
	MALock.Search:SetPoint( "TOPLEFT", MALock, "TOPLEFT", 12, -26 )
	MALock.Search:SetSize( sw - 2 * br - br - 100, 24 )
	MALock.Search:SetAutoFocus( false )
	MALock.Search:SetScript( "OnTextChanged", function( self, ... )
		searchStr = MALock.Search:GetText()
		MAUpdateElementList()
	end )

	MALock.Profiles = CreateFrame( "Button", "MALock_Profiles", MALock, "UIPanelButtonTemplate" )
	MALock.Profiles:SetPoint( "TOPLEFT", MALock, "TOPLEFT", sw - 100 - br, -26 )
	MALock.Profiles:SetSize( 100, 24 )
	MALock.Profiles:SetText( MoveAny:GT( "PROFILES" ) )
	MALock.Profiles:SetScript( "OnClick", function()
		MoveAny:SetEnabled( "MALOCK", false )
		MoveAny:HideMALock()

		MoveAny:SetEnabled( "MAPROFILES", true )
		MoveAny:ShowProfiles()
	end )

	MALock.SF = CreateFrame( "ScrollFrame", "MALock_SF", MALock, "UIPanelScrollFrameTemplate" )
	MALock.SF:SetPoint( "TOPLEFT", MALock, br, -30 - 24 )
	MALock.SF:SetPoint( "BOTTOMRIGHT", MALock, -32, 24 + br )

	MALock.SC = CreateFrame( "Frame", "MALock_SC", MALock.SF )
	MALock.SC:SetSize( 400, 400 )
	MALock.SC:SetPoint( "TOPLEFT", MALock.SF, "TOPLEFT", 0, 0 )

	MALock.SF:SetScrollChild( MALock.SC )

	MALock.SF.bg = MALock.SF:CreateTexture( "MALock.SF.bg", "ARTWORK" )
	MALock.SF.bg:SetAllPoints( MALock.SF )
	MALock.SF.bg:SetColorTexture( 0.03, 0.03, 0.03, 0.5 )

	MALock.save = CreateFrame( "BUTTON", "MALock" .. ".save", MALock, "UIPanelButtonTemplate" )
	MALock.save:SetSize( 120, 24 )
	MALock.save:SetPoint( "TOPLEFT", MALock, "TOPLEFT", 4, -MALock:GetHeight() + 24 + 4 )
	MALock.save:SetText( SAVE )
	MALock.save:SetScript("OnClick", function()
		C_UI.Reload()
	end)
	MALock.save:Disable()

	MALock.reload = CreateFrame( "BUTTON", "MALock" .. ".reload", MALock, "UIPanelButtonTemplate" )
	MALock.reload:SetSize( 120, 24 )
	MALock.reload:SetPoint( "TOPLEFT", MALock, "TOPLEFT", 4 + 120 + 4, -MALock:GetHeight() + 24 + 4 )
	MALock.reload:SetText( RELOADUI )
	MALock.reload:SetScript("OnClick", function()
		C_UI.Reload()
	end)

	MALock.DISCORD = CreateFrame( "EditBox", "MALock" .. ".DISCORD", MALock, "InputBoxTemplate" )
	MALock.DISCORD:SetText( "discord.gg/pRjC7cbqYW" )
	MALock.DISCORD:SetSize( 160, 24 )
	MALock.DISCORD:SetPoint("TOPLEFT", MALock, "TOPLEFT", MALock:GetWidth() - 160 - 8, -MALock:GetHeight() + 24 + 4 )
	MALock.DISCORD:SetAutoFocus( false )



	MAGridFrame = CreateFrame( "Frame", "MAGridFrame", UIParent )
	MAGridFrame:EnableMouse( false )
	MAGridFrame:SetSize( GetScreenWidth(), GetScreenHeight() )
	MAGridFrame:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

	MAGridFrame:SetFrameStrata( "LOW" )
	MAGridFrame:SetFrameLevel( 1 )

	MAGridFrame.bg = MAGridFrame:CreateTexture( "MAGridFrame.bg", "BACKGROUND", nil, 0 )
	MAGridFrame.bg:SetAllPoints( MAGridFrame )
	MAGridFrame.bg:SetColorTexture( 0.03, 0.03, 0.03, 0 )

	MAGridFrame.hor = MAGridFrame:CreateTexture()
	MAGridFrame.hor:SetPoint( "CENTER", 0, -0.5 )
	MAGridFrame.hor:SetSize( GetScreenWidth(), 1 )
	MAGridFrame.hor:SetColorTexture( 1, 1, 1, 1 )

	MAGridFrame.ver = MAGridFrame:CreateTexture()
	MAGridFrame.ver:SetPoint( "CENTER", 0.5, 0 )
	MAGridFrame.ver:SetSize( 1, GetScreenHeight() )
	MAGridFrame.ver:SetColorTexture( 1, 1, 1, 1 )

	MoveAny:UpdateGrid()
	
	local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( "MALock" )
	if dbp1 and dbp3 then
		MALock:ClearAllPoints()
		MALock:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
	end

	MoveAny:HideMALock()
end

function MoveAny:UpdateGrid()
	local id = 0
	MAGridFrame.lines = MAGridFrame.lines or {}
	for i, v in pairs( MAGridFrame.lines ) do
		v:Hide()
	end

	for x = 0, GetScreenWidth() / 2, MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint( "CENTER", 0.5 + x, 0 )
		MAGridFrame.lines[id]:SetSize( 1.09, GetScreenHeight() )
		if x % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture( 1, 1, 0.5, 0.25 )
		else
			MAGridFrame.lines[id]:SetColorTexture( 0.5, 0.5, 0.5, 0.25 )
		end
		MAGridFrame.lines[id]:Show()
		id = id + 1
	end
	for x = 0, -GetScreenWidth() / 2, -MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint( "CENTER", 0.5 + x, 0 )
		MAGridFrame.lines[id]:SetSize( 1.09, GetScreenHeight() )
		if x % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture( 1, 1, 0.5, 0.25 )
		else
			MAGridFrame.lines[id]:SetColorTexture( 0.5, 0.5, 0.5, 0.25 )
		end
		MAGridFrame.lines[id]:Show()
		id = id + 1
	end
	for y = 0, GetScreenHeight() / 2, MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint( "CENTER", 0, 0.5 + y )
		MAGridFrame.lines[id]:SetSize( GetScreenWidth(), 1.09, GetScreenHeight() )
		if y % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture( 1, 1, 0.5, 0.25 )
		else
			MAGridFrame.lines[id]:SetColorTexture( 0.5, 0.5, 0.5, 0.25 )
		end
		MAGridFrame.lines[id]:Show()
		id = id + 1
	end
	for y = 0, -GetScreenHeight() / 2, -MoveAny:GetGridSize() do
		MAGridFrame.lines[id] = MAGridFrame.lines[id] or MAGridFrame:CreateTexture()
		MAGridFrame.lines[id]:SetPoint( "CENTER", 0, 0.5 + y )
		MAGridFrame.lines[id]:SetSize( GetScreenWidth(), 1.09 )
		if y % 50 == 0 then
			MAGridFrame.lines[id]:SetColorTexture( 1, 1, 0.5, 0.25 )
		else
			MAGridFrame.lines[id]:SetColorTexture( 0.5, 0.5, 0.5, 0.25 )
		end
		MAGridFrame.lines[id]:Show()
		id = id + 1
	end
end

function MoveAny:ShowProfiles()
	if MAProfiles == nil then
		MAProfiles = CreateFrame( "Frame", "MAProfiles", UIParent, "BasicFrameTemplate" )
		MAProfiles:SetSize( sw, sh )
		MAProfiles:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

		MAProfiles:SetFrameStrata( "HIGH" )
		MAProfiles:SetFrameLevel( 999 )

		MAProfiles:SetClampedToScreen( true )
		MAProfiles:SetMovable( true )
		MAProfiles:EnableMouse( true )
		MAProfiles:RegisterForDrag( "LeftButton" )
		MAProfiles:SetScript( "OnDragStart", MAProfiles.StartMoving )
		MAProfiles:SetScript( "OnDragStop", function()
			MAProfiles:StopMovingOrSizing()

			local p1, p2, p3, p4, p5 = MAProfiles:GetPoint()
			p4 = MoveAny:Grid( p4 )
			p5 = MoveAny:Grid( p5 )
			MoveAny:SetElePoint( "MALock", p1, _, p3, p4, p5 )
		end )

		MAProfiles.TitleText:SetText( config.title )

		MAProfiles.CloseButton:SetScript( "OnClick", function()
			MoveAny:SetEnabled( "MAPROFILES", false )
			MAProfiles:Hide()

			MoveAny:SetEnabled( "MALOCK", true )
			MoveAny:ShowMALock()
		end )



		MAProfiles.SF = CreateFrame( "ScrollFrame", "MAProfiles_SF", MAProfiles, "UIPanelScrollFrameTemplate" )
		MAProfiles.SF:SetPoint( "TOPLEFT", MAProfiles, br, -30 - 24 )
		MAProfiles.SF:SetPoint( "BOTTOMRIGHT", MAProfiles, -32, 24 + br )

		MAProfiles.SC = CreateFrame( "Frame", "MAProfiles_SC", MAProfiles.SF )
		MAProfiles.SC:SetSize( 400, 400 )
		MAProfiles.SC:SetPoint( "TOPLEFT", MAProfiles.SF, "TOPLEFT", 0, 0 )

		MAProfiles.SF:SetScrollChild( MAProfiles.SC )

		MAProfiles.SF.bg = MAProfiles.SF:CreateTexture()
		MAProfiles.SF.bg:SetAllPoints( MAProfiles.SF )
		MAProfiles.SF.bg:SetColorTexture( 0.03, 0.03, 0.03, 0.5 )



		MAProfiles.AddProfile = CreateFrame( "Button", "MAProfiles_AddProfile", MAProfiles, "UIPanelButtonTemplate" )
		MAProfiles.AddProfile:SetPoint( "TOPLEFT", MAProfiles, "TOPLEFT", br, -26 )
		MAProfiles.AddProfile:SetSize( 160, 24 )
		MAProfiles.AddProfile:SetText( MoveAny:GT( "ADDPROFILE" ) )
		MAProfiles.AddProfile:SetScript( "OnClick", function()
			if MAAddProfile == nil then
				MAAddProfile = CreateFrame( "Frame", "MAAddProfile", UIParent, "BasicFrameTemplate" )
				MAAddProfile:SetSize( 300, 130 )
				MAAddProfile:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

				MAAddProfile:SetFrameStrata( "HIGH" )
				MAAddProfile:SetFrameLevel( 1010 )

				MAAddProfile:SetClampedToScreen( true )
				MAAddProfile:SetMovable( true )
				MAAddProfile:EnableMouse( true )
				MAAddProfile:RegisterForDrag( "LeftButton" )
				MAAddProfile:SetScript( "OnDragStart", MAAddProfile.StartMoving )
				MAAddProfile:SetScript( "OnDragStop", MAAddProfile.StopMovingOrSizing )
				MAAddProfile.name = "NEW"
				MAAddProfile.inheritFrom = ""

				MAAddProfile.TitleText:SetText( MoveAny:GT( "ADDPROFILE" ) )

				MAAddProfile.CloseButton:SetScript( "OnClick", function()
					MAAddProfile:Hide()
				end )

				MAAddProfile.Name = CreateFrame( "EditBox", "MAAddProfile_Search", MAAddProfile, "InputBoxTemplate" )
				MAAddProfile.Name:SetPoint( "TOPLEFT", MAAddProfile, "TOPLEFT", 12, -26 )
				MAAddProfile.Name:SetSize( 300 - 24, 24 )
				MAAddProfile.Name:SetAutoFocus( false )
				MAAddProfile.Name:SetText( MAAddProfile.name )
				MAAddProfile.Name:SetScript( "OnTextChanged", function( self, text )
					MAAddProfile.name = MAAddProfile.Name:GetText()
				end )

				local profileNames = {}
				tinsert( profileNames, "" )
				for name, tab in pairs( MoveAny:GetProfiles() ) do
					tinsert( profileNames, name )
				end

				local profiles = {
					["name"] = "profiles",
					["parent"]= MAAddProfile,
					["title"] = MoveAny:GT( "INHERITFROM" ),
					["items"]= profileNames,
					["defaultVal"] = "", 
					["changeFunc"] = function( dropdown_frame, dropdown_val )
						MAAddProfile.inheritFrom = dropdown_val
					end
				}
	
				local ddprofiles = MoveAny:CreateDropdown( profiles )
				ddprofiles:SetPoint( "TOPLEFT", MAAddProfile, "TOPLEFT", 0, -26 - 30 - br )

				MAAddProfile.AddProfile = CreateFrame( "Button", "MAAddProfile_Profiles", MAAddProfile, "UIPanelButtonTemplate" )
				MAAddProfile.AddProfile:SetPoint( "TOPLEFT", MAAddProfile, "TOPLEFT", br, -26 - 24 - br - 30 - br )
				MAAddProfile.AddProfile:SetSize( 160, 24 )
				MAAddProfile.AddProfile:SetText( MoveAny:GT( "ADD" ) )
				MAAddProfile.AddProfile:SetScript( "OnClick", function()
					MoveAny:AddProfile( MAAddProfile.name, MAAddProfile.inheritFrom )
					C_UI.Reload()
				end )
			else
				MAAddProfile:Show()
			end
		end )

		MAProfiles.GetProfile = CreateFrame( "Button", "MAProfiles_GetProfile", MAProfiles, "UIPanelButtonTemplate" )
		MAProfiles.GetProfile:SetPoint( "TOPLEFT", MAProfiles, "TOPLEFT", br + 160 + br, -26 )
		MAProfiles.GetProfile:SetSize( 160, 24 )
		MAProfiles.GetProfile:SetText( MoveAny:GT( "GETPROFILE" ) )
		MAProfiles.GetProfile:SetScript( "OnClick", function()
			if MAGetProfile == nil then
				MAGetProfile = CreateFrame( "Frame", "MAGetProfile", UIParent, "BasicFrameTemplate" )
				MAGetProfile:SetSize( 600, 200 )
				MAGetProfile:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

				MAGetProfile:SetFrameStrata( "HIGH" )
				MAGetProfile:SetFrameLevel( 1010 )

				MAGetProfile:SetClampedToScreen( true )
				MAGetProfile:SetMovable( true )
				MAGetProfile:EnableMouse( true )
				MAGetProfile:RegisterForDrag( "LeftButton" )
				MAGetProfile:SetScript( "OnDragStart", MAGetProfile.StartMoving )
				MAGetProfile:SetScript( "OnDragStop", MAGetProfile.StopMovingOrSizing )
				
				MAGetProfile.TitleText:SetText( MoveAny:GT( "GETPROFILE" ) )

				MAGetProfile.CloseButton:SetScript( "OnClick", function()
					MAGetProfile:Hide()
				end )

				MAGetProfile.f = MAGetProfile:CreateFontString( nil, nil, "GameFontNormal" )
				MAGetProfile.f:SetPoint( "TOPLEFT", MAGetProfile, "TOPLEFT", 6, -26 )
				MAGetProfile.f:SetText( MoveAny:GT( "GETPROFILE" ) )

				MAGetProfile.f2 = MAGetProfile:CreateFontString( nil, nil, "GameFontNormal" )
				MAGetProfile.f2:SetPoint( "BOTTOMLEFT", MAGetProfile, "BOTTOMLEFT", 6, 6 )
				MAGetProfile.f2:SetText( MoveAny:GT( "WAITFORPLAYERPROFILE2" ) )

				MAGetProfile.SF = CreateFrame( "ScrollFrame", "MAGetProfile_SF", MAGetProfile, "UIPanelScrollFrameTemplate" )
				MAGetProfile.SF:SetPoint( "TOPLEFT", MAGetProfile, br, -30 - 24 )
				MAGetProfile.SF:SetPoint( "BOTTOMRIGHT", MAGetProfile, -32, 24 + br )
		
				MAGetProfile.SC = CreateFrame( "Frame", "MAGetProfile_SC", MAGetProfile.SF )
				MAGetProfile.SC:SetSize( 600, 200 )
				MAGetProfile.SC:SetPoint( "TOPLEFT", MAGetProfile.SF, "TOPLEFT", 0, 0 )
		
				MAGetProfile.SF:SetScrollChild( MAGetProfile.SC )
		
				MAGetProfile.SF.bg = MAGetProfile.SF:CreateTexture()
				MAGetProfile.SF.bg:SetAllPoints( MAGetProfile.SF )
				MAGetProfile.SF.bg:SetColorTexture( 0.03, 0.03, 0.03, 0.5 )
			else
				MAGetProfile:Show()
			end
			MAGetProfile.f:SetText( MoveAny:GT( "PROFILES" ) .. ":" )

			IASendProfiles = {} -- Reset

			local function AddLine( id, source, profile )
				MAGetProfile.lines = MAGetProfile.lines or {}

				if MAGetProfile.lines[id] == nil then
					MAGetProfile.lines[id] = CreateFrame( "Frame", "lines[" .. id .. "]", MAGetProfile.SC )
					MAGetProfile.lines[id]:SetSize( 600, 25 )
					MAGetProfile.lines[id]:SetPoint( "TOPLEFT", MAGetProfile.SC, "TOPLEFT", 0, 0 )
					
					MAGetProfile.lines[id].name = MAGetProfile.lines[id]:CreateFontString( nil, nil, "GameFontNormal" )
					MAGetProfile.lines[id].name:SetPoint( "LEFT", MAGetProfile.lines[id], "LEFT", 0, 0 )
					
					MAGetProfile.lines[id].profile = MAGetProfile.lines[id]:CreateFontString( nil, nil, "GameFontNormal" )
					MAGetProfile.lines[id].profile:SetPoint( "LEFT", MAGetProfile.lines[id], "LEFT", 250, 0 )

					MAGetProfile.lines[id].btn = CreateFrame( "Button", name, MAGetProfile.lines[id], "UIPanelButtonTemplate" )
					MAGetProfile.lines[id].btn:SetPoint( "LEFT", MAGetProfile.lines[id], "LEFT", 450, 0 )
					MAGetProfile.lines[id].btn:SetSize( 100, 24 )
					MAGetProfile.lines[id].btn:SetText( MoveAny:GT( "DOWNLOAD" ) )
					MAGetProfile.lines[id].btn:SetScript( "OnClick", function()
						MAGetProfile:Hide()
						WebOwner = source
						WebProfile = profile
						WebProfileData = {}
						C_ChatInfo.SendAddonMessage( PREFIX, "WP;" .. profile, "WHISPER", source )
						
						if MADownloadProfile == nil then
							MADownloadProfile = CreateFrame( "Frame", "MADownloadProfile", UIParent, "BasicFrameTemplate" )
							MADownloadProfile:SetSize( 300, 120 )
							MADownloadProfile:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

							MADownloadProfile:SetFrameStrata( "HIGH" )
							MADownloadProfile:SetFrameLevel( 1010 )

							MADownloadProfile:SetClampedToScreen( true )
							MADownloadProfile:SetMovable( true )
							MADownloadProfile:EnableMouse( true )
							MADownloadProfile:RegisterForDrag( "LeftButton" )
							MADownloadProfile:SetScript( "OnDragStart", MADownloadProfile.StartMoving )
							MADownloadProfile:SetScript( "OnDragStop", MADownloadProfile.StopMovingOrSizing )
							
							MADownloadProfile.TitleText:SetText( MoveAny:GT( "DOWNLOAD" ) )

							MADownloadProfile.name = MADownloadProfile:CreateFontString( nil, nil, "GameFontNormal" )
							MADownloadProfile.name:SetPoint( "TOPLEFT", MADownloadProfile, "TOPLEFT", 12, -26 )
							
							MADownloadProfile.ProfileName = CreateFrame( "EditBox", "MADownloadProfile", MADownloadProfile, "InputBoxTemplate" )
							MADownloadProfile.ProfileName:SetPoint( "TOPLEFT", MADownloadProfile, "TOPLEFT", 12, -52 )
							MADownloadProfile.ProfileName:SetSize( 300 - 24, 24 )
							MADownloadProfile.ProfileName:SetAutoFocus( false )
							MADownloadProfile.ProfileName:SetScript( "OnTextChanged", function( self, text )
								MADownloadProfile.profileName = MADownloadProfile.ProfileName:GetText()
							end )

							MADownloadProfile.btn = CreateFrame( "Button", name, MADownloadProfile, "UIPanelButtonTemplate" )
							MADownloadProfile.btn:SetPoint( "TOPLEFT", MADownloadProfile, "TOPLEFT", 12, -78 )
							MADownloadProfile.btn:SetSize( 100, 24 )
							MADownloadProfile.btn:SetText( MoveAny:GT( "ADD" ) )
							MADownloadProfile.btn:SetScript( "OnClick", function()
								local profileName = MADownloadProfile.ProfileName:GetText()
								if MATAB["PROFILES"][profileName] == nil then 

									MoveAny:ImportProfile( profileName, WebProfileData )

									C_UI.Reload()
								else
									MoveAny:MSG( "[AddProfile] can't add, Name already exists." )
								end
							end )

							function MADownloadProfile:UpdateStatus()
								if WebStatus == 0 then
									MADownloadProfile.name:SetText( MoveAny:GT( "WAITINGFOROWNER" ) )
									MADownloadProfile.btn:SetEnabled( false )
								elseif WebStatus == 100 then
									MADownloadProfile.name:SetText( MoveAny:GT( "DONE" ) )
									MADownloadProfile.btn:SetEnabled( true )
								else
									MADownloadProfile.name:SetText( MoveAny:GT( "STATUS" ) .. ": " .. WebStatus .. "%")
									MADownloadProfile.btn:SetEnabled( false )
								end
								C_Timer.After( 0.1, MADownloadProfile.UpdateStatus )
							end
							MADownloadProfile:UpdateStatus()

							MADownloadProfile.CloseButton:SetScript( "OnClick", function()
								MADownloadProfile:Hide()
							end )
						end

						MADownloadProfile.profileName = WebProfile
						MADownloadProfile.ProfileName:SetText( MADownloadProfile.profileName )
						MADownloadProfile:Show()
					end )
				end

				MAGetProfile.lines[id].name:SetText( MoveAny:GT( "PLAYER" ) .. ": " .. source )
				MAGetProfile.lines[id].profile:SetText( MoveAny:GT( "PROFILE" ) .. ": " .. profile )
			end

			local function GetProfiles()
				if MAGetProfile:IsVisible() then
					MAGetProfile.lines = MAGetProfile.lines or {}
					local id = 0
					for name, tab in pairs( IASendProfiles ) do
						AddLine( id, name, tab.profile )
						id = id + 1
					end
					C_Timer.After( 1, GetProfiles )
				end
			end
			GetProfiles()
		end ) 

		local index = 0
		for name, tab in pairs( MoveAny:GetProfiles() ) do
			btn = CreateFrame( "Button", name, MAProfiles.SC, "UIPanelButtonTemplate" )
			btn:SetPoint( "TOPLEFT", MAProfiles.SC, "TOPLEFT", br, -index * 40 - br )
			btn:SetSize( 160, 24 )
			if name == MoveAny:GetCP() then
				btn:SetText( "(" .. MoveAny:GT( "CURRENT" ) .. ") " .. name )
			else
				btn:SetText( name )
			end
			btn:SetScript( "OnClick", function()
				MoveAny:SetCP( name )
				C_UI.Reload()
			end )

			btnShare = CreateFrame( "Button", name, MAProfiles.SC, "UIPanelButtonTemplate" )
			btnShare:SetPoint( "TOPLEFT", MAProfiles.SC, "TOPLEFT", br + 160  + br, -index * 40 - br )
			btnShare:SetSize( 80, 24 )
			btnShare:SetText( MoveAny:GT( "SHARE" ) )
			btnShare:SetScript( "OnClick", function()
				if MAShareProfile == nil then
					MAShareProfile = CreateFrame( "Frame", "MAShareProfile", UIParent, "BasicFrameTemplate" )
					MAShareProfile:SetSize( 600, 200 )
					MAShareProfile:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

					MAShareProfile:SetFrameStrata( "HIGH" )
					MAShareProfile:SetFrameLevel( 1010 )

					MAShareProfile:SetClampedToScreen( true )
					MAShareProfile:SetMovable( true )
					MAShareProfile:EnableMouse( true )
					MAShareProfile:RegisterForDrag( "LeftButton" )
					MAShareProfile:SetScript( "OnDragStart", MAShareProfile.StartMoving )
					MAShareProfile:SetScript( "OnDragStop", MAShareProfile.StopMovingOrSizing )
					
					MAShareProfile.TitleText:SetText( MoveAny:GT( "SHAREPROFILE" ) )

					MAShareProfile.CloseButton:SetScript( "OnClick", function()
						MAShareProfile:Hide()
					end )

					MAShareProfile.f = MAShareProfile:CreateFontString( nil, nil, "GameFontNormal" )
					MAShareProfile.f:SetPoint( "TOPLEFT", MAShareProfile, "TOPLEFT", 6, -26 )
					MAShareProfile.f:SetText( MoveAny:GT( "PROFILE" ) .. ": " .. name )

					MAShareProfile.f2 = MAShareProfile:CreateFontString( nil, nil, "GameFontNormal" )
					MAShareProfile.f2:SetPoint( "BOTTOMLEFT", MAShareProfile, "BOTTOMLEFT", 6, 6 )
					MAShareProfile.f2:SetText( MoveAny:GT( "WAITFORPLAYERPROFILE" ) )

					MAShareProfile.SF = CreateFrame( "ScrollFrame", "MAShareProfile_SF", MAShareProfile, "UIPanelScrollFrameTemplate" )
					MAShareProfile.SF:SetPoint( "TOPLEFT", MAShareProfile, br, -30 - 24 )
					MAShareProfile.SF:SetPoint( "BOTTOMRIGHT", MAShareProfile, -32, 24 + br )
			
					MAShareProfile.SC = CreateFrame( "Frame", "MAShareProfile_SC", MAShareProfile.SF )
					MAShareProfile.SC:SetSize( 600, 200 )
					MAShareProfile.SC:SetPoint( "TOPLEFT", MAShareProfile.SF, "TOPLEFT", 0, 0 )
			
					MAShareProfile.SF:SetScrollChild( MAShareProfile.SC )
			
					MAShareProfile.SF.bg = MAShareProfile.SF:CreateTexture()
					MAShareProfile.SF.bg:SetAllPoints( MAShareProfile.SF )
					MAShareProfile.SF.bg:SetColorTexture( 0.03, 0.03, 0.03, 0.5 )
				else
					MAShareProfile:Show()
				end
				MAShareProfile.f:SetText( MoveAny:GT( "PROFILE" ) .. ": " .. name )

				IAWantProfiles = {} -- Reset

				local function AddLine( id, source, profile )
					MAShareProfile.lines = MAShareProfile.lines or {}

					if MAShareProfile.lines[id] == nil then
						MAShareProfile.lines[id] = CreateFrame( "Frame", "lines[" .. id .. "]", MAShareProfile.SC )
						MAShareProfile.lines[id]:SetSize( 600, 25 )
						MAShareProfile.lines[id]:SetPoint( "TOPLEFT", MAShareProfile.SC, "TOPLEFT", 0, id * 25 )
						
						MAShareProfile.lines[id].name = MAShareProfile.lines[id]:CreateFontString( nil, nil, "GameFontNormal" )
						MAShareProfile.lines[id].name:SetPoint( "LEFT", MAShareProfile.lines[id], "LEFT", 0, id * 25 )

						MAShareProfile.lines[id].btn = CreateFrame( "Button", profile, MAShareProfile.lines[id], "UIPanelButtonTemplate" )
						MAShareProfile.lines[id].btn:SetPoint( "LEFT", MAShareProfile.lines[id], "LEFT", 450, 0 )
						MAShareProfile.lines[id].btn:SetSize( 100, 24 )
						MAShareProfile.lines[id].btn:SetText( MoveAny:GT( "UPLOAD" ) )
						MAShareProfile.lines[id].btn:SetScript( "OnClick", function()
							local delay = 0.01
							C_ChatInfo.SendAddonMessage( PREFIX, "UP;" .. profile .. ";0", "WHISPER", source )
							if MATAB["PROFILES"][profile] then
								local max = 0
								local count = 0
								local cur = 0
								for i, v in pairs( MATAB["PROFILES"][profile]["ELES"]["POINTS"] ) do
									for j, w in pairs( v ) do
										max = max + 1
									end
								end
								for i, v in pairs( MATAB["PROFILES"][profile]["ELES"]["SIZES"] ) do		
									for j, w in pairs( v ) do
										max = max + 1
									end
								end
								for i, v in pairs( MATAB["PROFILES"][profile]["ELES"]["OPTIONS"] ) do					
									for j, w in pairs( v ) do
										max = max + 1
									end
								end

								for i, v in pairs( MATAB["PROFILES"][profile]["ELES"]["POINTS"] ) do
									for j, w in pairs( v ) do
										count = count + 1
										C_Timer.After( count * delay, function()
											cur = cur + 1
											local per = string.format( "%0.1f", cur / max * 100 )
											WebStatus = tonumber( per )
											C_ChatInfo.SendAddonMessage( PREFIX, "UP;" .. profile .. ";" .. per, "WHISPER", source )
											if w ~= nil then
												local typ = type( w )
												local val = w
												if typ == "boolean" then
													if w then
														val = 1
													else
														val = 0
													end
												elseif typ == "table" then
													val = ""
												end
												if typ ~= "table" then
													C_ChatInfo.SendAddonMessage( PREFIX, "DL;" .. profile .. ";" .. "POINTS" .. ";" .. i .. ";" .. j .. ";" .. typ .. ";" .. val, "WHISPER", source )
												end
											end
										end )
									end
								end
								C_Timer.After( count * delay, function()
									count = 0
									for i, v in pairs( MATAB["PROFILES"][profile]["ELES"]["SIZES"] ) do
										for j, w in pairs( v ) do
											count = count + 1
											C_Timer.After( count * delay, function()
												cur = cur + 1
												local per = string.format( "%0.1f", cur / max * 100 )
												WebStatus = tonumber( per )
												C_ChatInfo.SendAddonMessage( PREFIX, "UP;" .. profile .. ";" .. per, "WHISPER", source )
												if w ~= nil then
													local typ = type( w )
													local val = w
													if typ == "boolean" then
														if w then
															val = 1
														else
															val = 0
														end
													elseif typ == "table" then
														val = ""
													end
													if typ ~= "table" then
														C_ChatInfo.SendAddonMessage( PREFIX, "DL;" .. profile .. ";" .. "SIZES" .. ";" .. i .. ";" .. j .. ";" .. typ .. ";" .. val, "WHISPER", source )
													end
												end
											end )
										end
									end
									C_Timer.After( count * delay, function()
										count = 0
										for i, v in pairs( MATAB["PROFILES"][profile]["ELES"]["OPTIONS"] ) do
											for j, w in pairs( v ) do
												count = count + 1
												C_Timer.After( count * delay, function()
													cur = cur + 1
													local per = string.format( "%0.1f", cur / max * 100 )
													WebStatus = tonumber( per )
													C_ChatInfo.SendAddonMessage( PREFIX, "UP;" .. profile .. ";" .. per, "WHISPER", source )
													if w ~= nil then
														local typ = type( w )
														local val = w
														if typ == "boolean" then
															if w then
																val = 1
															else
																val = 0
															end
														elseif typ == "table" then
															val = ""
														end
														if typ ~= "table" then
															C_ChatInfo.SendAddonMessage( PREFIX, "DL;" .. profile .. ";" .. "OPTIONS" .. ";" .. i .. ";" .. j .. ";" .. typ .. ";" .. val, "WHISPER", source )
														end
													end
												end )
											end
										end
									end )
								end )
							end

							MAShareProfile:Hide()

							if MAUploadProfile == nil then
								MAUploadProfile = CreateFrame( "Frame", "MAUploadProfile", UIParent, "BasicFrameTemplate" )
								MAUploadProfile:SetSize( 120, 120 )
								MAUploadProfile:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

								MAUploadProfile:SetFrameStrata( "HIGH" )
								MAUploadProfile:SetFrameLevel( 1010 )

								MAUploadProfile:SetClampedToScreen( true )
								MAUploadProfile:SetMovable( true )
								MAUploadProfile:EnableMouse( true )
								MAUploadProfile:RegisterForDrag( "LeftButton" )
								MAUploadProfile:SetScript( "OnDragStart", MAUploadProfile.StartMoving )
								MAUploadProfile:SetScript( "OnDragStop", MAUploadProfile.StopMovingOrSizing )
								
								MAUploadProfile.TitleText:SetText( MoveAny:GT( "DOWNLOAD" ) )

								MAUploadProfile.CloseButton:SetScript( "OnClick", function()
									MAUploadProfile:Hide()
								end )
			
								MAUploadProfile.name = MAUploadProfile:CreateFontString( nil, nil, "GameFontNormal" )
								MAUploadProfile.name:SetPoint( "TOPLEFT", MAUploadProfile, "TOPLEFT", 12, -26 )
								
								MAUploadProfile.btn = CreateFrame( "Button", name, MAUploadProfile, "UIPanelButtonTemplate" )
								MAUploadProfile.btn:SetPoint( "TOPLEFT", MAUploadProfile, "TOPLEFT", 12, -78 )
								MAUploadProfile.btn:SetSize( 100, 24 )
								MAUploadProfile.btn:SetText( "X" )
								MAUploadProfile.btn:SetScript( "OnClick", function()
									MAUploadProfile:Hide()
								end )

								function MAUploadProfile:UpdateStatus()
									if WebStatus == 0 or WebStatus == 0.0 then
										MAUploadProfile.name:SetText( MoveAny:GT( "WAITINGFOROWNER" ) )
										MAUploadProfile.btn:SetEnabled( false )
									elseif WebStatus == 100 or WebStatus == 100.0 then
										MAUploadProfile.name:SetText( MoveAny:GT( "DONE" ) )
										MAUploadProfile.btn:SetEnabled( true )
									else
										MAUploadProfile.name:SetText( MoveAny:GT( "STATUS" ) .. ": " .. WebStatus .. "%")
										MAUploadProfile.btn:SetEnabled( false )
									end
									C_Timer.After( 0.1, MAUploadProfile.UpdateStatus )
								end
								MAUploadProfile:UpdateStatus()

								MAUploadProfile.CloseButton:SetScript( "OnClick", function()
									MAUploadProfile:Hide()
								end )
							else
								MAUploadProfile:Show()
							end
						end )
					end

					MAShareProfile.lines[id].name:SetText( MoveAny:GT( "PLAYER" ) .. ": " .. source )
				end
				
				-- Receive Buyers
				local function GetProfiles()
					if MAShareProfile:IsVisible() then
						MAShareProfile.lines = MAShareProfile.lines or {}
						local id = 0
						for name, tab in pairs( IAWantProfiles ) do
							AddLine( id, name, tab.profile )
							id = id + 1
						end
						C_Timer.After( 1, GetProfiles )
					end
				end
				GetProfiles()

				-- Send out Profile Shop
				local function ShareProfile()
					if MAShareProfile:IsVisible() then
						C_ChatInfo.SendAddonMessage( PREFIX, "SP;" .. name, "PARTY" )
						
						C_Timer.After( 4, ShareProfile )
					end
				end
				ShareProfile()
			end )

			if name ~= "DEFAULT" then
				btnRen = CreateFrame( "Button", name, MAProfiles.SC, "UIPanelButtonTemplate" )
				btnRen:SetPoint( "TOPLEFT", MAProfiles.SC, "TOPLEFT", br + 160 + br + 80 + br, -index * 40 - br )
				btnRen:SetSize( 100, 24 )
				btnRen:SetText( MoveAny:GT( "RENAME" ) )
				btnRen:SetScript( "OnClick", function()
					if MARenameProfile == nil then
						MARenameProfile = CreateFrame( "Frame", "MARenameProfile", UIParent, "BasicFrameTemplate" )
						MARenameProfile:SetSize( 300, 130 )
						MARenameProfile:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )

						MARenameProfile:SetFrameStrata( "HIGH" )
						MARenameProfile:SetFrameLevel( 1010 )

						MARenameProfile:SetClampedToScreen( true )
						MARenameProfile:SetMovable( true )
						MARenameProfile:EnableMouse( true )
						MARenameProfile:RegisterForDrag( "LeftButton" )
						MARenameProfile:SetScript( "OnDragStart", MARenameProfile.StartMoving )
						MARenameProfile:SetScript( "OnDragStop", MARenameProfile.StopMovingOrSizing )
						
						MARenameProfile.TitleText:SetText( MoveAny:GT( "RENAMEROFILE" ) )

						MARenameProfile.CloseButton:SetScript( "OnClick", function()
							MARenameProfile:Hide()
						end )

						MARenameProfile.Name = CreateFrame( "EditBox", "MARenameProfile_Search", MARenameProfile, "InputBoxTemplate" )
						MARenameProfile.Name:SetPoint( "TOPLEFT", MARenameProfile, "TOPLEFT", 12, -26 )
						MARenameProfile.Name:SetSize( 300 - 24, 24 )
						MARenameProfile.Name:SetAutoFocus( false )
						MARenameProfile.Name:SetScript( "OnTextChanged", function( self, text )
							MARenameProfile.name = MARenameProfile.Name:GetText()
						end )

						MARenameProfile.RenameProfile = CreateFrame( "Button", "MARenameProfile_Profiles", MARenameProfile, "UIPanelButtonTemplate" )
						MARenameProfile.RenameProfile:SetPoint( "TOPLEFT", MARenameProfile, "TOPLEFT", br, -26 - 24 - br - 30 - br )
						MARenameProfile.RenameProfile:SetSize( 160, 24 )
						MARenameProfile.RenameProfile:SetText( MoveAny:GT( "RENAME" ) )
						MARenameProfile.RenameProfile:SetScript( "OnClick", function()
							if MARenameProfile.oldname ~= MARenameProfile.name then
								MoveAny:RenameProfile( MARenameProfile.oldname, MARenameProfile.name )
							else
								MoveAny:MSG( "[RENAME PROFILE] New name is same as old name." )
							end
						end )
					else
						MARenameProfile:Show()
					end
					MARenameProfile.oldname = name
					MARenameProfile.name = name
					MARenameProfile.Name:SetText( name )				
				end )
			end

			if name ~= "DEFAULT" then
				btnRem = CreateFrame( "Button", name, MAProfiles.SC, "UIPanelButtonTemplate" )
				btnRem:SetPoint( "TOPLEFT", MAProfiles.SC, "TOPLEFT", br + 160 + br + 80 + br + 100 + br, -index * 40 - br )
				btnRem:SetSize( 100, 24 )
				btnRem:SetText( MoveAny:GT( "REMOVE" ) )
				btnRem:SetScript( "OnClick", function()
					MoveAny:RemoveProfile( name )
					C_UI.Reload()
				end )
			end

			index = index + 1
		end

		local dbp1, _, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( "MALock" )
		if dbp1 and dbp3 then
			MAProfiles:ClearAllPoints()
			MAProfiles:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
		end
	else
		MAProfiles:Show()
	end
end



local function OnEvent(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, data, channel, source, toPlayer = ...
		if prefix == PREFIX then
			tab = {strsplit( ";", data )}
			
			local name, realm = UnitName( "PLAYER" )
			if realm == nil then
				realm = GetRealmName()
			end

			local cmd = tab[1]
			
			if cmd == "SP" then -- SendProfile
				if source ~= name .. "-" .. realm then
					if not IASendProfiles[source] then
						local ptab = {}
						ptab.name = source
						ptab.profile = tab[2]
						IASendProfiles[source] = ptab
					end
				end
			elseif cmd == "WP" then -- WantProfile
				if source ~= name .. "-" .. realm then
					if not IAWantProfiles[source] then
						local ptab = {}
						ptab.name = source
						ptab.profile = tab[2]
						IAWantProfiles[source] = ptab
					end
				end
			elseif cmd == "UP" then
				local target = tab[2]
				local percent = tab[3]
				if source and target and source == WebOwner and target == WebProfile then
					WebStatus = tonumber( percent )
				end
			elseif cmd == "DL" then
				local target = tab[2]
				local mainIndex = tab[3]
				local subIndex = tab[4]
				local index = tab[5]
				local typ = tab[6]
				local val = tab[7]
				if source and target and source == WebOwner and target == WebProfile then
					WebProfileData = WebProfileData or {}
					WebProfileData[mainIndex] = WebProfileData[mainIndex] or {}
					WebProfileData[mainIndex][subIndex] = WebProfileData[mainIndex][subIndex] or {}
					if typ == "boolean" then
						if val == "1" then
							val = true
						else
							val = false
						end
					elseif typ == "number" then
						val = tonumber( val )
					elseif typ == "string" then
						
					elseif typ == "table" then
						
					end
					WebProfileData[mainIndex][subIndex][index] = val
				end
			end
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isInitialLogin, isReloadingUi = ...
		if isInitialLogin or isReloadingUi then
			C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)
