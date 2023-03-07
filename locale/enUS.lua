-- enUS English

local AddOnName, MoveAny = ...

function MoveAny:UpdateLanguageTab( tab )
	for i, v in pairs( tab ) do
		MoveAny:GetLangTab()[i] = v
	end
end

function MoveAny:LangenUS()
	local tab = {
		["LID_MMBTNLEFT"] = "Left Click => Locks/Unlocks + Options",
		["LID_MMBTNRIGHT"] = "Shift + Right Click => Hide Minimap Button",

		["LID_GENERAL"] = "General",
		["LID_SHOWMINIMAPBUTTON"] = "Show Minimap Button",
		["LID_GRIDSIZE"] = "Gridsize",
		["LID_MOVEFRAMES"] = "Move Windows",
		["LID_SAVEFRAMEPOSITION"] = "Save Frame Position",
		["LID_SAVEFRAMESCALE"] = "Save Frame Scale",
		["LID_FRAMESSHIFTDRAG"] = "Move Frame with Shift + Leftclick-drag",
		["LID_FRAMESSHIFTSCALE"] = "Scale Frame with Shift + Rightclick-drag",
		["LID_FRAMESSHIFTRESET"] = "Reset Frame with Shift + Mousewheelclick",

		["LID_PLAYERFRAME"] = "Player Frame",
		["LID_PETFRAME"] = "Pet Frame",
		["LID_TARGETFRAME"] = "Target Frame",
		["LID_TARGETOFTARGETFRAME"] = "Target of Target Frame",
		["LID_TARGETFRAMESPELLBAR"] = "Castbar from Target",
		["LID_FOCUSFRAME"] = "Focus Frame",
		["LID_FOCUSFRAMESPELLBAR"] = "Castbar from Focus",
		["LID_TARGETOFFOCUSFRAME"] = "Target of Focus Frame",
		["LID_RUNEFRAME"] = "Deathknight - Runes Frame",
		["LID_TOTEMFRAME"] = "Totem Timers (Also used by other classes)",
		["LID_WARLOCKPOWERFRAME"] = "Warlock Power frame",
		["LID_MONKHARMONYBARFRAME"] = "Monk Harmony frame  (Chi)",
		["LID_MONKSTAGGERBAR"] = "Monk Stagger bar  (Chi)",
		["LID_MAGEARCANECHARGESFRAME"] = "Mage Arcane Charges frame",
		["LID_ESSENCEPLAYERFRAME"] = "Essence Player Frame (Evoker)",
		["LID_PALADINPOWERBARFRAME"] = "Paladin Power Bar",
		["LID_MAFPSFrame"] = "FPS",
		["LID_IAPingFrame"] = "Ping",
		["LID_IACoordsFrame"] = "Coords Frame",

		["LID_MINIMAP"] = "Mini Map",
		["LID_BUFFS"] = "Buffs",
		["LID_DEBUFFS"] = "Debuffs",
		["LID_VEHICLESEATINDICATOR"] = "Vehicle Seat Indicator",
		["LID_ARENAENEMYFRAMES"] = "Arena Enemy Frames",
		["LID_ARENAPREPFRAMES"] = "Arena Prep Frames",
		["LID_QUESTTRACKER"] = "Questtracker",

		["LID_MICROMENU"] = "Micro Menu",
		["LID_BAGS"] = "Bags",
		["LID_GAMETOOLTIP"] = "Tooltip",
		["LID_GAMETOOLTIP_ONCURSOR"] = "Tooltip on Cursor",
		["LID_QUEUESTATUSBUTTON"] = "LFG Status",
		["LID_QUEUESTATUSFRAME"] = "LFG Status Tooltip",

		["LID_PETBAR"] = "Pet Bar",
		["LID_STANCEBAR"] = "Stance Bar",
		["LID_TOTEMBAR"] = "Shaman - Totem Bar",
		["LID_LEAVEVEHICLE"] = "Leave Vehicle Button",
		["LID_GROUPLOOTFRAME1"] = "Loot Roll Frame 1 (Loot)",
		["LID_GROUPLOOTCONTAINER"] = "Loot Roll Frame (Loot)",
		["LID_BONUSROLLFRAME"] = "Bonus Roll Frame (Loot)",
		["LID_STATUSTRACKINGBARMANAGER"] = "Status Tracking Bar Manager (XP, Reputation)",
		["LID_ALERTFRAME"] = "Alert Frame (Bonus Loot, Achiements, ...) (Loot)",

		["LID_CHAT"] = "Chatframe %d",
		["LID_CHATBUTTONFRAME"] = "Chat Buttons",
		["LID_CHATQUICKJOIN"] = "Chat Quick Join",
		["LID_CHATEDITBOX"] = "Chat Inputbox",

		["LID_COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",
		["LID_BNToastFrame"] = "Battlenet Friends Notifications",

		["LID_SPELLACTIVATIONOVERLAYFRAME"] = "Spell Activation Overlay",

		["LID_ZONETEXTFRAME"] = "Zone Text",
		["LID_UIWIDGETTOPCENTER"] = "Widget Top Center (Status on BGs/Dungeons)",
		["LID_MIRRORTIMER1"] = "Breathbar",
		["LID_IASKILLS"] = "Skillbars",
		["LID_UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (Capture Status)",
		["LID_DURABILITY"] = "Durability Doll",
		["LID_MONEYBAR"] = "Money Bar",
		["LID_TOKENBAR"] = "Token Bar",
		["LID_IAILVLBAR"] = "ItemLevel Bar",
		["LID_CASTINGBAR"] = "Casting Bar",
		["LID_TALKINGHEAD"] = "Talking Head Dialog",
		["LID_POSSESSBAR"] = "Possess Bar (Controlling NPC/Vehicle)",
		["LID_ZONEABILITYFRAME"] = "Zone Ability",
		["LID_EXTRAABILITYCONTAINER"] = "Extra Ability (Spells for Quest, Boss)",
		["LID_MAINMENUEXPBAR"] = "Exp Bar",
		["LID_REPUTATIONWATCHBAR"] = "Reputation Bar",
		["LID_UIWIDGETPOWERBAR"] = "Power Bar (Boss Bar, Vigor Bar, Darkmoon faire, ...)",
		["LID_POWERBAR"] = "Power Bar (Encounters, ...)",

		["LID_COUNT"] = "Count",
		["LID_ROWS"] = "Rows",
		["LID_SPACING"] = "Spacing",
		
		

		["LID_PROFILE"] = "Profile",
		["LID_PROFILES"] = "Profiles",
		["LID_ADDPROFILE"] = "Add Profile",
		["LID_CURRENT"] = "Current",
		["LID_SHARE"] = "Share",
		["LID_SHAREPROFILE"] = "Share Profile",
		["LID_GETPROFILE"] = "Get Profile",
		["LID_INHERITFROM"] = "Inherit from",
		["LID_ADD"] = "Add",
		["LID_REMOVE"] = "Remove",
		["LID_RENAME"] = "Rename",
		["LID_PLAYER"] = "Player",
		["LID_DOWNLOAD"] = "Download",
		["LID_UPLOAD"] = "Upload",
		["LID_STATUS"] = "Status",
		["LID_DONE"] = "Done",
		["LID_WAITINGFOROWNER"] = "Waiting for Owner",
		["LID_WAITFORPLAYERPROFILE"] = "Wait for other player to press \"Get Profiles\".",
		["LID_WAITFORPLAYERPROFILE2"] = "Wait for other player to press \"Share\".",

		["LID_ALPHAINCOMBAT"] = "Alpha (in Combat)",
		["LID_ALPHANOTINCOMBAT"] = "Alpha (not in Combat)",
		["LID_ALPHAINVEHICLE"] = "Alpha (in Vehicle)",
		["LID_ALPHAINRESTEDAREA"] = "Alpha (in Rested)",
		["LID_ALPHAISMOUNTED"] = "Alpha (in Mounted)",

		["LID_MABUFFLIMIT"] = "Buff limit",
		["LID_MABUFFSPACINGX"] = "Buff Spacing Horizontal",
		["LID_MABUFFSPACINGY"] = "Buff Spacing Vertical",
		["LID_ISENABLEDINEDITMODE"] = "(Disable it in EditMode)",
		["LID_CANBREAKBECAUSEOFEDITMODE"] = "(May cause error due to edit mode)",

		["LID_HELPTEXT"] = "\"%s\" is already enabled in EditMode. Please deactivate in EditMode or MoveAny.",
	
		["LID_BUILTIN"] = "Built-In",
		["LID_EDITMODE"] = "Overwrite Edit Mode",
		["LID_NORMAL"] = "Normal",
		["LID_CLASSSPECIFIC"] = "Class Specific",
		["LID_ADVANCED"] = "Advanced",
		["LID_ImproveAny"] = "ImproveAny",

		["LID_MISSINGREQUIREMENT"] = "Missing Checkbox: %s",
		["LID_ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Archeology digsite progress bar",
		["LID_UIERRORSFRAME"] = "Ui Error Messages, Quest Progress",
		["LID_COMBOPOINTPLAYERFRAME"] = "Combo Points",

		["LID_PARTYFRAME"] = "Party Frame",
		["LID_PARTYMEMBERFRAME"] = "Party Member Frame %s",
		["LID_BOSSTARGETFRAMECONTAINER"] = "Boss Frames",

		["LID_FLIPPED"] = "Flipped",
		["LID_GHOSTFRAME"] = "Ghost Frame (Teleport to Graveyard)",
		["LID_TICKETSTATUSFRAME"] = "Ticket Frame",
		["LID_LOSSOFCONTROLFRAME"] = "Loss of Control Frame",

		["LID_MainStatusTrackingBarContainer"] = "Exp Bar",
		["LID_SecondaryStatusTrackingBarContainer"] = "Reputation Bar",

		["LID_TargetFrameNumericalThreat"] = "Threat Percentage",

		["LID_EventToastManagerFrame"] = "EventToastManagerFrame (Levelup, Zonetext)",
		["LID_BUFFTIMER1"] = "Buff Timer",

		["LID_!KalielsTracker"] = "!KalielsTracker",
		["LID_!KalielsTrackerButtons"] = "!KalielsTrackerButtons",
	}

	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		tab["LID_ACTIONBARS"] = "Actionbars 1 + 5 + 6"
		tab["LID_ACTIONBAR1"] = "Actionbars 1 (Main Bar)"
		tab["LID_ACTIONBAR2"] = "Actionbars 2 (2. Page of Actionbar 1)"
		tab["LID_ACTIONBAR3"] = "Actionbars 3 (Right Bar)"
		tab["LID_ACTIONBAR4"] = "Actionbars 4 (Left Bar)"
		tab["LID_ACTIONBAR5"] = "Actionbars 5 (Top Right Bar)"
		tab["LID_ACTIONBAR6"] = "Actionbars 6 (Top Left Bar)"
		tab["LID_ACTIONBAR7"] = "Actionbars 7 (Custom)"
		tab["LID_ACTIONBAR8"] = "Actionbars 8 (Custom)"
		tab["LID_ACTIONBAR9"] = "Actionbars 9 (Custom)"
		tab["LID_ACTIONBAR10"] = "Actionbars 10 (Custom)"
	else
		tab["LID_ACTIONBAR1"] = "Actionbars 1 (Main Bar)"
		tab["LID_ACTIONBAR2"] = "Actionbars 2 (Above Main Bar)"
		tab["LID_ACTIONBAR3"] = "Actionbars 3 (Above Second Bar)"
		tab["LID_ACTIONBAR4"] = "Actionbars 4 (Right Bar)"
		tab["LID_ACTIONBAR5"] = "Actionbars 5 (Left Bar)"
		tab["LID_ACTIONBAR6"] = "Actionbars 6"
		tab["LID_ACTIONBAR7"] = "Actionbars 7"
		tab["LID_ACTIONBAR8"] = "Actionbars 8"
	end

	MoveAny:UpdateLanguageTab( tab )
end
