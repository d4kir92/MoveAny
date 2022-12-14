-- enUS English

local AddOnName, MoveAny = ...

function MoveAny:UpdateLanguageTab( tab )
	for i, v in pairs( tab ) do
		MoveAny:GetLangTab()[i] = v
	end
end

function MoveAny:LangenUS()
	local tab = {
		["MMBTNLEFT"] = "Left Click => Locks/Unlocks + Options",
		["MMBTNRIGHT"] = "Shift + Right Click => Hide Minimap Button",

		["GENERAL"] = "General",
		["SHOWMINIMAPBUTTON"] = "Show Minimap Button",
		["GRIDSIZE"] = "Gridsize",
		["MOVEFRAMES"] = "Move Windows",
		["SAVEFRAMEPOSITION"] = "Save Frame Position",
		["SAVEFRAMESCALE"] = "Save Frame Scale",
		["FRAMESSHIFTDRAG"] = "Move Frame with Shift + Leftclick-drag",
		["FRAMESSHIFTSCALE"] = "Scale Frame with Shift + Rightclick-drag",
		["FRAMESSHIFTRESET"] = "Reset Frame with Shift + Mousewheelclick",

		["TOPLEFT"] = "Top Left",
		["PLAYERFRAME"] = "Player Frame",
		["PETFRAME"] = "Pet Frame",
		["TARGETFRAME"] = "Target Frame",
		["TARGETOFTARGETFRAME"] = "Target of Target Frame",
		["TARGETFRAMESPELLBAR"] = "Castbar from Target",
		["FOCUSFRAME"] = "Focus Frame",
		["FOCUSFRAMESPELLBAR"] = "Castbar from Focus",
		["TARGETOFFOCUSFRAME"] = "Target of Focus Frame",
		["RUNEFRAME"] = "Deathknight - Runes Frame",
		["TOTEMFRAME"] = "Totem Timers (Also used by other classes)",
		["WARLOCKPOWERFRAME"] = "Warlock Power frame",
		["MONKHARMONYBARFRAME"] = "Monk Harmony frame  (Chi)",
		["MONKSTAGGERBAR"] = "Monk Stagger bar  (Chi)",
		["MAGEARCANECHARGESFRAME"] = "Mage Arcane Charges frame",
		["ESSENCEPLAYERFRAME"] = "Essence Player Frame (Evoker)",
		["PALADINPOWERBARFRAME"] = "Paladin Power Bar",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "Top",

		["TOPRIGHT"] = "Top Right",
		["MINIMAP"] = "Mini Map",
		["BUFFS"] = "Buffs",
		["DEBUFFS"] = "Debuffs",
		["VEHICLESEATINDICATOR"] = "Vehicle Seat Indicator",
		["ARENAENEMYFRAMES"] = "Arena Enemy Frames",
		["ARENAPREPFRAMES"] = "Arena Prep Frames",
		["QUESTTRACKER"] = "Questtracker",

		["RIGHT"] = "Right",
	
		["BOTTOMRIGHT"] = "Bottom Right",
		["MICROMENU"] = "Micro Menu",
		["BAGS"] = "Bags",
		["GAMETOOLTIP"] = "Tooltip",
		["GAMETOOLTIP_ONCURSOR"] = "Tooltip on Cursor",
		["QUEUESTATUSBUTTON"] = "LFG Status",

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
		["STATUSTRACKINGBARMANAGER"] = "Status Tracking Bar Manager (XP, Reputation)",
		["ALERTFRAME"] = "Alert Frame (Bonus Loot, Achiements, ...)",

		["BOTTOMLEFT"] = "Bottom Left",
		["CHAT"] = "Chatframe %d",
		["CHATBUTTONFRAME"] = "Chat Buttons",
		["CHATQUICKJOIN"] = "Chat Quick Join",
		["CHATEDITBOX"] = "Chat Inputbox",

		["LEFT"] = "Left",
		["COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",
		["BATTLENETFRIENDSNOTIFICATION"] = "Battlenet Friends Notifications",

		["CENTER"] = "Center",
		["SPELLACTIVATIONOVERLAYFRAME"] = "Spell Activation Overlay",


		
		["ZONETEXTFRAME"] = "Zone Text",
		["UIWIDGETTOPCENTER"] = "Widget Top Center (Status on BGs/Dungeons)",
		["MIRRORTIMER1"] = "Breathbar",
		["IASKILLS"] = "Skillbars",
		["UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (Capture Status)",
		["DURABILITY"] = "Durability Doll",
		["MONEYBAR"] = "Money Bar",
		["TOKENBAR"] = "Token Bar",
		["IAILVLBAR"] = "ItemLevel Bar",
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
		["EXTRAABILITYCONTAINER"] = "Extra Ability (Spells for Quest, Boss)",
		["MAINMENUEXPBAR"] = "Exp Bar",
		["REPUTATIONWATCHBAR"] = "Reputation Bar",
		["UIWIDGETPOWERBAR"] = "Power Bar (Boss Bar, Vigor Bar, ...)",

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

		["ALPHAINCOMBAT"] = "Alpha (in Combat)",
		["ALPHANOTINCOMBAT"] = "Alpha (not in Combat)",
		["ALPHAINVEHICLE"] = "Alpha (in Vehicle)",

		["MABUFFLIMIT"] = "Buff limit",
		["MABUFFSPACINGX"] = "Buff Spacing Horizontal",
		["MABUFFSPACINGY"] = "Buff Spacing Vertical",
		["ISENABLEDINEDITMODE"] = "(Disable it in EditMode)",
		["CANBREAKBECAUSEOFEDITMODE"] = "(May cause error due to edit mode)",

		["HELPTEXT"] = "\"%s\" is already enabled in EditMode. Please deactivate in EditMode or MoveAny.",
	
		["BUILTIN"] = "Built-In",
		["EDITMODE"] = "Overwrite Edit Mode",
		["NORMAL"] = "Normal",
		["CLASSSPECIFIC"] = "Class Specific",
		["ADVANCED"] = "Advanced",
		["ImproveAny"] = "ImproveAny",

		["MISSINGREQUIREMENT"] = "Missing Checkbox: %s",
		["ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Archeology digsite progress bar",
		["UIERRORSFRAME"] = "Ui Error Messages, Quest Progress",
		["COMBOPOINTPLAYERFRAME"] = "Combo Points",

		["PARTYFRAME"] = "Party Frame",
		["PARTYMEMBERFRAME"] = "Party Member Frame %s",
		["BOSSTARGETFRAMECONTAINER"] = "Boss Frames",

		["FLIPPED"] = "Flipped",
		["GHOSTFRAME"] = "Ghost Frame (Teleport to Graveyard)",
		["TICKETSTATUSFRAME"] = "Ticket Frame",
		["LOSSOFCONTROLFRAME"] = "Loss of Control Frame",

		["MainStatusTrackingBarContainer"] = "Exp Bar",
		["SecondaryStatusTrackingBarContainer"] = "Reputation Bar",

		["ACTIONBAR1R"] = "Actionbar 1 (Main Bar)",
		["ACTIONBAR2R"] = "Actionbar 2 (Above Main Bar)",
		["ACTIONBAR3R"] = "Actionbar 3 (Above Second Bar)",
		["ACTIONBAR4R"] = "Actionbar 4 (Right Bar)",
		["ACTIONBAR5R"] = "Actionbar 5 (Left Bar)",
		["ACTIONBAR6R"] = "Actionbar 6",
		["ACTIONBAR7R"] = "Actionbar 7",
		["ACTIONBAR8R"] = "Actionbar 8",
	}

	MoveAny:UpdateLanguageTab( tab )
end
