
local AddOnName, MoveAny = ...

local function AddCheckBox( x, y, key, lstr )
	local cb = CreateFrame( "CheckButton", key .. "_CB", MALock, "UICheckButtonTemplate" ) --CreateFrame("CheckButton", "moversettingsmove", mover, "UICheckButtonTemplate")
	cb:SetSize( 24, 24 )
	cb:SetPoint( "TOPLEFT", MALock, "TOPLEFT", x, y )
	cb:SetChecked( MoveAny:IsEnabled( key, true ) )
	cb:SetScript( "OnClick", function( self )
		MoveAny:SetEnabled( key, self:GetChecked() )

		if MALock.save then
			MALock.save:Enable()
		end
	end)

	cb.f = cb:CreateFontString( nil, nil, "GameFontNormal" )
	cb.f:SetPoint( "LEFT", cb, "RIGHT", 0, 0 )
	cb.f:SetText( lstr )
end

function MoveAny:InitMALock()
	MALock = CreateFrame( "FRAME", "MALock", UIParent )
	MALock:SetSize( 420, 500 )
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

	MALock.bg = MALock:CreateTexture( "MALock.bg", "BACKGROUND", nil, 7 )
	MALock.bg:SetAllPoints( MALock )
	MALock.bg:SetColorTexture( 0.03, 0.03, 0.03, 1 )

	MALock.f = MALock:CreateFontString( nil, nil, "GameFontNormal" )
	MALock.f:SetPoint( "TOP", MALock, "TOP", 0, -6 )
	MALock.f:SetText( "MoveAny" )

	local sh = 24
	local py = -sh
	AddCheckBox( 10, py, "ACTIONBARS", "ActionBars (+PetBar +StanceBar +TotemBar +LeaveVehicle)" )
	py = py - sh
	AddCheckBox( 30, py, "ACTIONBAR7", "ActionBar 7" )
	py = py - sh
	AddCheckBox( 30, py, "ACTIONBAR8", "ActionBar 8" )
	py = py - sh
	AddCheckBox( 30, py, "ACTIONBAR9", "ActionBar 9" )
	py = py - sh
	AddCheckBox( 30, py, "ACTIONBAR10", "ActionBar 10" )
	py = py - sh

	AddCheckBox( 10, py, "MICROMENU", "MicroMenu" )
	py = py - sh
	AddCheckBox( 10, py, "BAGS", "Bags" )
	py = py - sh

	AddCheckBox( 10, py, "MINIMAP", "Minimap" )
	py = py - sh
	AddCheckBox( 10, py, "BUFFS", "Buffs/Debuffs" )
	py = py - sh
	AddCheckBox( 10, py, "QUESTLOG", "QuestLog" )
	py = py - sh

	AddCheckBox( 10, py, "CHAT", "Chat" )
	py = py - sh

	AddCheckBox( 10, py, "PLAYERFRAME", "Playerframe" )
	py = py - sh
	AddCheckBox( 10, py, "TARGETFRAME", "Targetframe" )
	py = py - sh
	AddCheckBox( 10, py, "FOCUSFRAME", "Focusframe" )
	py = py - sh

	AddCheckBox( 10, py, "RUNEFRAME", "DK - RuneFrame" )
	py = py - sh

	AddCheckBox( 10, py, "GROUPLOOTCONTAINER", "GroupLootContainer" )
	py = py - sh
	
	MALock.save = CreateFrame( "BUTTON", "MALock" .. ".opt.close", MALock, "UIPanelButtonTemplate" )
	MALock.save:SetSize( 120, 24 )
	MALock.save:SetPoint( "TOPLEFT", MALock, "TOPLEFT", 10, -MALock:GetHeight() + 24 + 10 + 24 + 10 )
	MALock.save:SetText( SAVE )
	MALock.save:SetScript("OnClick", function()
		C_UI.Reload()
	end)
	MALock.save:Disable()

	MALock.close = CreateFrame( "BUTTON", "MALock" .. ".opt.close", MALock, "UIPanelButtonTemplate" )
	MALock.close:SetSize( 120, 24 )
	MALock.close:SetPoint( "TOPLEFT", MALock, "TOPLEFT", 10, -MALock:GetHeight() + 24 + 10 )
	MALock.close:SetText( LOCK )
	MALock.close:SetScript("OnClick", function()
		if MADrag then
			MoveAny:ToggleDrag()
		end
	end)






	MAGridFrame = CreateFrame( "FRAME", "MAGridFrame", UIParent )
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
