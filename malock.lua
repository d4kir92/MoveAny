
local AddOnName, MoveAny = ...

local config = {
	["title"] = format( "MoveAny |T135994:16:16:0:0|t v|cff3FC7EB%s", "0.5.7" )
}

local searchStr = ""
local posy = -4
local cas = {}
local cbs = {}

local function AddCategory( key )
	if cas[key] == nil then
		cas[key] = CreateFrame( "Frame", key .. "_Category", MALock.SC )
		local ca = cas[key]
		ca:SetSize( 24, 24 )

		ca.f = ca:CreateFontString( nil, nil, "GameFontNormal" )
		ca.f:SetPoint( "LEFT", ca, "LEFT", 0, 0 )
		ca.f:SetText( MAGT( key ) )
	end

	cas[key]:ClearAllPoints()
	if strfind( strlower( key ), strlower( searchStr ) ) then
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

local function AddCheckBox( x, key, val, func )
	if val == nil then
		val = true
	end
	if cbs[key] == nil then
		cbs[key] = CreateFrame( "CheckButton", key .. "_CB", MALock.SC, "UICheckButtonTemplate" ) --CreateFrame( "CheckButton", "moversettingsmove", mover, "UICheckButtonTemplate" )
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
		cb.f:SetText( MAGT( key ) )
	end

	cbs[key]:ClearAllPoints()
	if strfind( strlower( key ), strlower( searchStr ) ) or strfind( strlower( MAGT( key ) ), strlower( searchStr ) ) then
		cbs[key]:Show()

		cbs[key]:SetPoint( "TOPLEFT", MALock.SC, "TOPLEFT", x, posy )
		posy = posy - 24
	else
		cbs[key]:Hide()
	end
end

function MoveAny:InitMALock()
	MALock = CreateFrame( "Frame", "MALock", UIParent, "BasicFrameTemplate" )
	MALock:SetSize( 420, 420 )
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
		p4 = MAGrid( p4 )
		p5 = MAGrid( p5 )
		MoveAny:SetElePoint( "MALock", p1, _, p3, p4, p5 )
	end )

	MALock.TitleText:SetText( config.title )

	MALock.CloseButton:SetScript( "OnClick", function()
		if MADrag then
			MoveAny:ToggleDrag()
		end
	end )

	function MAUpdateElementList()
		local _, class = UnitClass( "PLAYER" )
		
		local sh = 24
		posy = -4

		AddCategory( "GENERAL" )
		AddCheckBox( 4, "SHOWMINIMAPBUTTON", true, MoveAny.UpdateMinimapButton )

		AddCategory( "TOPLEFT" )
		if MABUILDNR < 100000 then
			AddCheckBox( 4, "PLAYERFRAME" )
			AddCheckBox( 24, "PETFRAME" )
			AddCheckBox( 4, "TARGETFRAME" )
			AddCheckBox( 24, "TARGETOFTARGETFRAME" )
			AddCheckBox( 4, "FOCUSFRAME" )
		end
		if class == "DEATHKNIGHT" then
			AddCheckBox( 4, "RUNEFRAME" )
		end

		AddCategory( "TOP" )
		AddCheckBox( 4, "ZONETEXTFRAME" )
		AddCheckBox( 4, "UIWIDGETTOPCENTER" )
		AddCheckBox( 4, "UIWIDGETBELOWMINIMAP" )

		AddCategory( "TOPRIGHT" )
		if MABUILDNR < 100000 then
			AddCheckBox( 4, "MINIMAP" )
			AddCheckBox( 4, "BUFFS" )
			AddCheckBox( 24, "DEBUFFS" )
			AddCheckBox( 4, "UIWIDGETBELOWMINIMAP" )
		end

		AddCategory( "RIGHT" )
		if MABUILDNR < 100000 then
			AddCheckBox( 4, "QUESTTRACKER" )
		end

		AddCategory( "BOTTOMRIGHT" )
		if MABUILDNR < 100000 then
			AddCheckBox( 4, "MICROMENU" )
			AddCheckBox( 4, "BAGS" )
			AddCheckBox( 4, "GAMETOOLTIP" )
		end
		AddCheckBox( 24, "GAMETOOLTIP_ONCURSOR" )


		AddCategory( "BOTTOM" )
		AddCheckBox( 4, "ACTIONBARS" )
		AddCheckBox( 24, "ACTIONBAR7" )
		AddCheckBox( 24, "ACTIONBAR8" )
		AddCheckBox( 24, "ACTIONBAR9" )
		AddCheckBox( 24, "ACTIONBAR10" )
		AddCheckBox( 4, "PETBAR" )
		AddCheckBox( 4, "STANCEBAR" )
		if MABUILD == "WRATH" and class == "SHAMAN" then
			AddCheckBox( 4, "TOTEMBAR" )
		end
		AddCheckBox( 4, "POSSESSBAR" )
		if MABUILDNR < 100000 then
			AddCheckBox( 4, "LEAVEVEHICLE" )
		end
		AddCheckBox( 4, "MAINMENUEXPBAR" )
		AddCheckBox( 4, "REPUTATIONWATCHBAR" )
		AddCheckBox( 4, "GROUPLOOTCONTAINER" )
		AddCheckBox( 4, "CASTINGBAR" )
		AddCheckBox( 4, "TALKINGHEAD" )
		AddCheckBox( 4, "MAFPSFrame" )

		AddCategory( "BOTTOMLEFT" )
		AddCheckBox( 4, "CHAT" )

		AddCategory( "LEFT" )
		AddCheckBox( 4, "COMPACTRAIDFRAMEMANAGER" )
	end

	MALock.Search = CreateFrame( "EditBox", "MALock_Search", MALock, "InputBoxTemplate" )
	MALock.Search:SetPoint( "TOPLEFT", MALock, "TOPLEFT", 12, -26 )
	MALock.Search:SetSize( 400, 24 )
	MALock.Search:SetAutoFocus( false )
	MALock.Search:SetScript( "OnTextChanged", function( self, ... )
		searchStr = MALock.Search:GetText()
		MAUpdateElementList()
	end )

	MALock.SF = CreateFrame( "ScrollFrame", "MALock_SF", MALock, "UIPanelScrollFrameTemplate" )
	MALock.SF:SetPoint( "TOPLEFT", MALock, 8, -30 - 24 )
	MALock.SF:SetPoint( "BOTTOMRIGHT", MALock, -32, 24 + 8 )

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

	local dbp1, dbp2, dbp3, dbp4, dbp5 = MoveAny:GetElePoint( "MALock" )
	if dbp1 and dbp3 then
		MALock:ClearAllPoints()
		MALock:SetPoint( dbp1, UIParent, dbp3, dbp4, dbp5 )
	end
end
