-- enUS English
local _, MoveAny = ...
function MoveAny:UpdateLanguageTab(tab)
	for i, v in pairs(tab) do
		MoveAny:GetLangTab()[i] = v
	end
end

function MoveAny:LangenUS()
	local tab = {
		["LID_LEFTCLICK"] = "Leftclick",
		["LID_RIGHTCLICK"] = "Rightclick",
		["LID_MMBTNLEFT"] = "Locks/Unlocks + Options",
		["LID_MMBTNRIGHT"] = "Hide Minimap Button",
		["LID_GENERAL"] = "General",
		["LID_SHOWMINIMAPBUTTON"] = "Show Minimap Button",
		["LID_GRIDSIZE"] = "Gridsize (Grid)",
		["LID_SNAPSIZE"] = "Snapsize (Grid)",
		["LID_MOVEFRAMES"] = "Move Windows",
		["LID_SAVEFRAMEPOSITION"] = "Save Frame Position",
		["LID_SAVEFRAMESCALE"] = "Save Frame Scale",
		["LID_SHIFT"] = "SHIFT",
		["LID_CTRL"] = "CTRL",
		["LID_ALT"] = "ALT",
		["LID_FRAMESKEYDRAG"] = "Move Frame with %s + Leftclick-drag",
		["LID_FRAMESKEYSCALE"] = "Scale Frame with %s + Rightclick-drag",
		["LID_FRAMESKEYRESET"] = "Reset Frame with %s + Mousewheelclick",
		["LID_PLAYERFRAME"] = "Player Frame",
		["LID_PLAYERLEVELTEXT"] = "Player Frame-Level",
		["LID_PLAYERFRAMEBACKGROUND"] = "Player Frame Background",
		["LID_PETFRAME"] = "Pet Frame",
		["LID_MAPETFRAME"] = "Pet Frame",
		["LID_PETFRAMEHAPPINESS"] = "Pet Frame Happiness",
		["LID_TARGETFRAME"] = "Target Frame",
		["LID_TARGETFRAMENAMEBACKGROUND"] = "Target Frame Namen-Background",
		["LID_TARGETFRAMEBUFF1"] = "Target Frame Buff 1",
		["LID_TARGETFRAMETOTDEBUFF1"] = "Target of Target Frame Debuff 1",
		["LID_TARGETOFTARGETFRAME"] = "Target of Target Frame",
		["LID_TARGETFRAMESPELLBAR"] = "Castbar from Target",
		["LID_FOCUSFRAME"] = "Focus Frame",
		["LID_FOCUSFRAMEBUFF1"] = "Focus Frame Buff 1",
		["LID_FOCUSFRAMESPELLBAR"] = "Castbar from Focus",
		["LID_TARGETOFFOCUSFRAME"] = "Target of Focus Frame",
		["LID_RUNEFRAME"] = "Deathknight - Runes Frame",
		["LID_TOTEMFRAME"] = "Totem Timers (Also used by other classes)",
		["LID_WARLOCKPOWERFRAME"] = "Warlock Power Frame (Shards)",
		["LID_MONKHARMONYBARFRAME"] = "Monk Harmony frame  (Chi)",
		["LID_MONKSTAGGERBAR"] = "Monk Stagger bar  (Chi)",
		["LID_MAGEARCANECHARGESFRAME"] = "Mage Arcane Charges frame",
		["LID_ESSENCEPLAYERFRAME"] = "Essence Player Frame (Evoker)",
		["LID_PALADINPOWERBARFRAME"] = "Paladin Power Bar (Holy Power)",
		["LID_MAFPSFrame"] = "FPS (New FPS-Counter)",
		["LID_IAPingFrame"] = "Ping",
		["LID_IACoordsFrame"] = "Coords Frame",
		["LID_MINIMAP"] = "Mini Map",
		["LID_MINIMAPZONETEXT"] = "Mini Map Zone Text",
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
		["LID_CHATBUTTONFRAME1"] = "Chat Buttons for Tab 1",
		["LID_CHATBUTTONFRAME2"] = "Chat Buttons for Tab 2",
		["LID_CHATBUTTONFRAME3"] = "Chat Buttons for Tab 3",
		["LID_CHATBUTTONFRAME4"] = "Chat Buttons for Tab 4",
		["LID_CHATBUTTONFRAME5"] = "Chat Buttons for Tab 5",
		["LID_CHATBUTTONFRAME6"] = "Chat Buttons for Tab 6",
		["LID_CHATBUTTONFRAME7"] = "Chat Buttons for Tab 7",
		["LID_CHATBUTTONFRAME8"] = "Chat Buttons for Tab 8",
		["LID_CHATBUTTONFRAME9"] = "Chat Buttons for Tab 9",
		["LID_CHATBUTTONFRAME10"] = "Chat Buttons for Tab 10",
		["LID_CHATQUICKJOIN"] = "Chat Quick Join",
		["LID_CHATEDITBOX"] = "Chat Inputbox",
		["LID_COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",
		["LID_BNToastFrame"] = "Battlenet Friends Notifications",
		["LID_SPELLACTIVATIONOVERLAYFRAME"] = "Spell Activation Overlay (Class Proc)",
		["LID_ZONETEXTFRAME"] = "Zone Text",
		["LID_UIWIDGETTOPCENTER"] = "Widget Top Center (Status/Stats on Battlegrounds/Dungeons/Raids)",
		["LID_MIRRORTIMER1"] = "Breathbar",
		["LID_IASKILLS"] = "Skillbars",
		["LID_UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (Capture Status)",
		["LID_DURABILITY"] = "Durability Doll",
		["LID_MONEYBAR"] = "Money Bar",
		["LID_TOKENBAR"] = "Token Bar",
		["LID_IAILVLBAR"] = "ItemLevel Bar",
		["LID_CASTINGBAR"] = "Casting Bar",
		["LID_CASTINGBARTIMER"] = "Casting Bar Timer",
		["LID_TALKINGHEAD"] = "Talking Head Dialog",
		["LID_POSSESSBAR"] = "Possess Bar (Controlling NPC/Vehicle)",
		["LID_ZONEABILITYFRAME"] = "Zone Ability",
		["LID_EXTRAABILITYCONTAINER"] = "Extra Ability (Spells for Quest, Boss)",
		["LID_MAINMENUEXPBAR"] = "Exp Bar",
		["LID_REPUTATIONWATCHBAR"] = "Reputation Bar",
		["LID_UIWIDGETPOWERBAR"] = "Power Bar (Boss Bar, Vigor Bar, Darkmoon faire, ...)",
		["LID_POWERBAR"] = "Power Bar (Boss Encounters, ...)",
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
		["LID_ALPHAISSTEALTHED"] = "Alpha (Stealthed)",
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
		["LID_ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Archeology digsite progress bar",
		["LID_UIERRORSFRAME"] = "Ui Error Messages, Quest Progress",
		["LID_COMBOPOINTPLAYERFRAME"] = "Combo Points",
		["LID_PARTYFRAME"] = "Party Frame",
		["LID_PARTYMEMBERFRAME"] = "Party Member Frame %s",
		["LID_COMPACTRAIDFRAMECONTAINER"] = "RaidFrame",
		["LID_BOSSTARGETFRAMECONTAINER"] = "Boss Frames (Bossframes)",
		["LID_FLIPPED"] = "Flipped",
		["LID_GHOSTFRAME"] = "Ghost Frame (Teleport to Graveyard)",
		["LID_TICKETSTATUSFRAME"] = "Ticket Frame",
		["LID_LOSSOFCONTROLFRAME"] = "Loss of Control Frame",
		["LID_MainStatusTrackingBarContainer"] = "StatusBar1 (Exp Bar, Reputation Bar)",
		["LID_SecondaryStatusTrackingBarContainer"] = "StatusBar2 (Reputation Bar)",
		["LID_TargetFrameNumericalThreat"] = "Threat Percentage",
		["LID_EventToastManagerFrame"] = "EventToastManagerFrame (Levelup, Zonetext)",
		["LID_BUFFTIMER1"] = "Buff Timer",
		["LID_!KalielsTracker"] = "!KalielsTracker",
		["LID_!KalielsTrackerButtons"] = "!KalielsTrackerButtons",
		["LID_ENDCAPLEFT"] = "End Cap Left (Gryphon)",
		["LID_ENDCAPRIGHT"] = "End Cap Right (Gryphon)",
		["LID_ENDCAPS"] = "End Caps (Gryphons)",
		["LID_BLIZZARDACTIONBUTTONSART"] = "Actionbar 1 Blizzard-Art",
		["LID_OBJECTIVETRACKERBONUSBANNERFRAME"] = "Objective Tracker Frame (World Quest Title)",
		["LID_MOVESMALLBAGS"] = "Move/Scale Small Bags",
		["LID_MOVELOOTFRAME"] = "Move Lootframe",
		["LID_SCALELOOTFRAME"] = "Scale Lootframe",
		["LID_NEEDSARELOAD"] = "Needs a Reload",
		["LID_RAIDBOSSEMOTEFRAME"] = "Raid Boss Emote Frame",
		["LID_STARTHELP"] = "Click the MoveAny Minimap Button to open the settings.",
		["LID_STARTHELP2"] = "Or type /move or /moveany in chat to open the settings.",
		["LID_STARTHELP3"] = "To hide these messages deactivate tips in the MoveAny menu.",
		["LID_SHOWTIPS"] = "Show Tips",
		["LID_OVERRIDEACTIONBAR"] = "Override Action Bar (Vehicle Bar)",
		["LID_BOSSBANNER"] = "Boss Banner (Dropped Loot, Boss Title)",
		["LID_COMPACTARENAFRAME"] = "Compact Arena Frame",
		["LID_ROLEPOLLPOPUP"] = "Role Poll Popup",
		["LID_READYCHECKLISTENERFRAME"] = "Ready Check Popup",
		["LID_DISABLEMOVEMENT"] = "Disable Movement keybinds, when in MoveAny-EditMode",
		["LID_CLICKTHROUGH"] = "Clickthrough",
		["LID_MABUFFMODE"] = "Buff-Alignment",
		["LID_MADEBUFFLIMIT"] = "Debuff limit",
		["LID_MADEBUFFSPACINGX"] = "Debuff Spacing Horizontal",
		["LID_MADEBUFFSPACINGY"] = "Debuff Spacing Vertical",
		["LID_MADEBUFFMODE"] = "Debuff-Alignment",
		["LID_SEARCH"] = "Search",
		["LID_COMBOFRAME"] = "Combo Bar",
		["LID_WIDTH"] = "Width",
		["LID_HEIGHT"] = "Height",
		["LID_ALPHAISFULLHEALTH"] = "Alpha (Full Health)",
		["LID_ALPHAISINPETBATTLE"] = "Alpha (Is In Pet Battle)",
		["LID_KEYBINDWINDOW"] = "Keybind for Windows",
		["LID_SNAPWINDOWSIZE"] = "Snapsize (Windows)",
		["LID_BOSS1"] = "Boss 1",
		["LID_BOSS2"] = "Boss 2",
		["LID_BOSS3"] = "Boss 3",
		["LID_BOSS4"] = "Boss 4",
		["LID_BOSS5"] = "Boss 5",
		["LID_BOSS6"] = "Boss 6",
		["LID_MAPAGES"] = "Actionbar Pages",
		["LID_HIDEHIDDENFRAMES"] = "Hide hidden Elements",
		["LID_TIMERTRACKER1"] = "Timer Tracker (only visible when available)",
		["LID_PALADINPOWERBAR"] = "Paladin Power Bar (Holy Power)",
		["LID_SHARDBARFRAME"] = "Warlock Power Frame (Shards)",
		["LID_OFFSET"] = "Offset",
		["LID_EclipseBarFrame"] = "Eclipse Bar Frame (Druid)",
		["LID_REQUIRESFOR"] = "Requires: %s",
		["LID_REQUIREDFOR"] = "Required for: %s",
		["LID_RESETELEMENT"] = "Reset Element",
		["LID_TARGETFRAMEDEBUFF1"] = "Target Frame Debuff 1",
		["LID_FOCUSFRAMEDEBUFF1"] = "Focus Frame Debuff 1",
		["LID_TARGETFRAMETOTBUFF1"] = "Target of Target Frame Buff 1",
		["LID_MINIMAPFLAG"] = "Minimap Flag",
		["LID_MiniMapInstanceDifficulty"] = "Minimap Flag Instance Difficulty",
		["LID_MiniMapChallengeMode"] = "Minimap Flag Challenge Mode",
		["LID_GuildInstanceDifficulty"] = "Minimap Flag Guild-Instance Difficulty",
		["LID_POWERBARCOUNTERBAR"] = "Powerbar Counterbar",
		["LID_BUFFTIMER1"] = "BuffTimer 1",
		["LID_FRAMES"] = "Windows",
		["LID_SCALEFRAMES"] = "Scale Windows",
		["LID_RESETFRAMES"] = "Reset Windows",
		["LID_ExpansionLandingPageMinimapButton"] = "ExpansionLandingPageMinimapButton",
		["LID_MOVEANYINFO"] = "Select the things you want to modify",
		["LID_PLEASESWITCHPROFILE1"] = "Please Switch Profile in Editmode (from Blizzard) to a CUSTOM one.",
		["LID_PLEASESWITCHPROFILE2"] = "MoveAny don't work with a Preset Profile, its mostly readonly.",
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

	MoveAny:UpdateLanguageTab(tab)
end
