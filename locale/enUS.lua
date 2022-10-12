-- enUS English

LANG_MA = LANG_MA or {}

function MAUpdateLanguageTab( tab )
	for i, v in pairs( tab ) do
		LANG_MA[i] = v
	end
end

function MALang_enUS()
	local tab = {
		["MMBTNLEFT"] = "Left Click => Locks/Unlocks + Options",
		["MMBTNRIGHT"] = "Shift + Right Click => Hide Minimap Button",

		["GENERAL"] = "General",
		["SHOWMINIMAPBUTTON"] = "Show Minimap Button",
		["FRAMESSHIFTDRAG"] = "Move Frame with Shift + Leftclick",
		["FRAMESSHIFTSCALE"] = "Scale Frame with Shift + Rightclick",
		["FRAMESSHIFTRESET"] = "Reset Frame with Mousewheelclick",

		["TOPLEFT"] = "Top Left",
		["PLAYERFRAME"] = "Player Frame",
		["PETFRAME"] = "Pet Frame",
		["TARGETFRAME"] = "Target Frame",
		["TARGETOFTARGETFRAME"] = "Target of Target Frame",
		["TARGETFRAMESPELLBAR"] = "Castbar from Target",
		["FOCUSFRAME"] = "Focus Frame",
		["FOCUSFRAMESPELLBAR"] = "Castbar from Focus",
		["RUNEFRAME"] = "Deathknight - Runes Frame",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "Top",

		["TOPRIGHT"] = "Top Right",
		["MINIMAP"] = "Mini Map",
		["BUFFS"] = "Buffs",
		["DEBUFFS"] = "Debuffs",

		["RIGHT"] = "Right",
		["QUESTTRACKER"] = "Questtracker",

		["BOTTOMRIGHT"] = "Bottom Right",
		["MICROMENU"] = "Micro Menu",
		["BAGS"] = "Bags",
		["GAMETOOLTIP"] = "Tooltip",
		["GAMETOOLTIP_ONCURSOR"] = "Tooltip on Cursor",

		["BOTTOM"] = "Bottom",
		["ACTIONBARS"] = "Actionbars 1-6",
		["ACTIONBAR7"] = "Custom Actionbars 7",
		["ACTIONBAR8"] = "Custom Actionbars 8",
		["ACTIONBAR9"] = "Custom Actionbars 9",
		["ACTIONBAR10"] = "Custom Actionbars 10",
		["PETBAR"] = "Pet Bar",
		["STANCEBAR"] = "Stance Bar",
		["TOTEMBAR"] = "Shaman - Totem Bar",
		["LEAVEVEHICLE"] = "Leave Vehicle Button",
		["GROUPLOOTCONTAINER"] = "Loot Roll frame",

		["BOTTOMLEFT"] = "Bottom Left",
		["CHAT"] = "Chatframe",

		["LEFT"] = "Left",
		["COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",



		["ZONETEXTFRAME"] = "Zone Text",
		["UIWIDGETTOPCENTER"] = "Widget Top Center (Status on BGs/Dungeons)",
		["IASKILLS"] = "Skillbars",
		["UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (Capture Status)",
		["DURABILITY"] = "Durability Doll",
		["MONEYBAR"] = "Money Bar",
		["TOKENBAR"] = "Token Bar",
		["CASTINGBAR"] = "Casting Bar",
		["TALKINGHEAD"] = "Talking Head Dialog",
		["ACTIONBAR1"] = "Actionbar 1 (Main Bar)",
		["ACTIONBAR2"] = "Actionbar 2 (2. Page of Actionbar 1)",
		["ACTIONBAR3"] = "Actionbar 3 (Right Bar)",
		["ACTIONBAR4"] = "Actionbar 4 (Left Bar)",
		["ACTIONBAR5"] = "Actionbar 5 (Top Right Bar)",
		["ACTIONBAR6"] = "Actionbar 6 (Top Left Bar)",
		["POSSESSBAR"] = "Possess Bar (Controlling NPC/Vehicle)",
		["ZONEABILITYFRAME"] = "Zone Ability",
		["EXTRAABILITYCONTAINER"] = "Extra Ability",
		["MAINMENUEXPBAR"] = "Exp Bar",
		["REPUTATIONWATCHBAR"] = "Reputation Bar",
		["UIWIDGETPOWERBAR"] = "Power Bar",

		["ROWS"] = "Rows",
		["SPACING"] = "Spacing",
		
		

		["PROFILE"] = "Profile",
		["PROFILES"] = "Profiles",
		["ADDPROFILE"] = "Add Profile",
		["CURRENT"] = "Current",
		["SHARE"] = "Share",
		["SHAREPROFILE"] = "Share Profile",
		["GETPROFILE"] = "Get Profile",
		["INHERITFROM"] = "Inherit from",
		["ADD"] = "Add",
		["REMOVE"] = "Remove",
		["RENAME"] = "Rename",
		["PLAYER"] = "Player",
		["DOWNLOAD"] = "Download",
		["UPLOAD"] = "Upload",
		["STATUS"] = "Status",
		["DONE"] = "Done",
		["WAITINGFOROWNER"] = "Waiting for Owner",
		["WAITFORPLAYERPROFILE"] = "Wait for other player to press \"Get Profiles\".",
		["WAITFORPLAYERPROFILE2"] = "Wait for other player to press \"Share\".",
	}

	MAUpdateLanguageTab( tab )
end
