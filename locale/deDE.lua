-- deDE German Deutsch

local AddOnName, MoveAny = ...

function MoveAny:LangdeDE()
	local tab = {
		["LID_MMBTNLEFT"] = "Linksklick => Sperren/Entsperren + Optionen",
		["LID_MMBTNRIGHT"] = "Shift + Rechtsklick => Minimapknopf verstecken",

		["LID_GENERAL"] = "Allgemein",
		["LID_SHOWMINIMAPBUTTON"] = "Minimapknopf anzeigen",
		["LID_GRIDSIZE"] = "Rastergröße (Grid)",
		["LID_MOVEFRAMES"] = "Fenster bewegen",
		["LID_SAVEFRAMEPOSITION"] = "Fenster Position abspeichern",
		["LID_SAVEFRAMESCALE"] = "Fenster Skalierung abspeichern",
		["LID_FRAMESSHIFTDRAG"] = "Fenster mit Shift + Linksklick-ziehen bewegen",
		["LID_FRAMESSHIFTSCALE"] = "Fenster mit Shift + Rechtsklick-ziehen skalieren",
		["LID_FRAMESSHIFTRESET"] = "Fenster mit Shift + Mausradklick resetten",

		["LID_PLAYERFRAME"] = "Spielerfenster",
		["LID_PETFRAME"] = "Begleiterfenster",
		["LID_TARGETFRAME"] = "Zielfenster",
		["LID_TARGETOFTARGETFRAME"] = "Ziel des Zielfenster",
		["LID_TARGETFRAMESPELLBAR"] = "Zauberleiste vom Ziel",
		["LID_FOCUSFRAME"] = "Fokusfenster",
		["LID_FOCUSFRAMESPELLBAR"] = "Zauberleiste vom Fokus",
		["LID_TARGETOFFOCUSFRAME"] = "Ziel des Fokusfenster",
		["LID_RUNEFRAME"] = "Todesritter - Runen Fenster",
		["LID_TOTEMFRAME"] = "Totem Zähler (Auch von anderen Klassen benutzt)",
		["LID_WARLOCKPOWERFRAME"] = "Hexenmeister Macht Fenster",
		["LID_MONKHARMONYBARFRAME"] = "Mönch Harmonie Fenster (Chi)",
		["LID_MONKSTAGGERBAR"] = "Monk Staffeln Leiste  (Chi)",
		["LID_MAGEARCANECHARGESFRAME"] = "Magier Arkane Ladungen Fenster",
		["LID_ESSENCEPLAYERFRAME"] = "Essenz Spieler Fenster (Rufer)",
		["LID_PALADINPOWERBARFRAME"] = "Paladin Machtleiste",
		["LID_MAFPSFrame"] = "FPS",
		["LID_IAPingFrame"] = "Ping",
		["LID_IACoordsFrame"] = "Koordinatenfenster",

		["LID_MINIMAP"] = "Minimap",
		["LID_BUFFS"] = "Stärkungszauber",
		["LID_DEBUFFS"] = "Schwächungszauber",
		["LID_VEHICLESEATINDICATOR"] = "Fahrzeugsitzanzeige",
		["LID_ARENAENEMYFRAMES"] = "Arena Gegner Fenster",
		["LID_ARENAPREPFRAMES"] = "Arena Vorbereitungs Fenster",
		["LID_QUESTTRACKER"] = "Questverfolgung",

		["LID_MICROMENU"] = "Mikro Menü",
		["LID_BAGS"] = "Taschen",
		["LID_GAMETOOLTIP"] = "Tooltip",
		["LID_GAMETOOLTIP_ONCURSOR"] = "Tooltip am Zeiger",
		["LID_QUEUESTATUSBUTTON"] = "SNG Status (LFG)",
		["LID_QUEUESTATUSFRAME"] = "SNG Status (LFG) Tooltip",

		["LID_PETBAR"] = "Begleiterleiste",
		["LID_STANCEBAR"] = "Haltungsleiste",
		["LID_TOTEMBAR"] = "Schamane - Totemleiste",
		["LID_LEAVEVEHICLE"] = "Fahrzeug verlassen Taste",
		["LID_GROUPLOOTFRAME1"] = "Beute-Würfeln Fenster 1 (Loot)",
		["LID_GROUPLOOTCONTAINER"] = "Beute-Würfeln Fenster (Loot)",
		["LID_BONUSROLLFRAME"] = "Bonus-Würfeln Fenster (Loot)",
		["LID_STATUSTRACKINGBARMANAGER"] = "Statusverfolgungsleiste Manager (EP, Ruf)",
		["LID_ALERTFRAME"] = "Alarmfenster (Bonus Beute, Erfolg, ...) (Loot)",

		["LID_CHAT"] = "Chatfenster %d",
		["LID_CHATBUTTONFRAME"] = "Chat Knöpfe",
		["LID_CHATQUICKJOIN"] = "Chat Schnellbeitritt",
		["LID_CHATEDITBOX"] = "Chat Eingabefeld",

		["LID_COMPACTRAIDFRAMEMANAGER"] = "SchlachzugsManager",
		["LID_BNToastFrame"] = "Benachrichtigungen von Battlenet Freunden",

		["LID_SPELLACTIVATIONOVERLAYFRAME"] = "Zauber-Aktivierungs-Overlay",

		["LID_ZONETEXTFRAME"] = "Zonentext",
		["LID_UIWIDGETTOPCENTER"] = "Widget Oben-Mittig (Status bei BGs/Dungeons)",
		["LID_MIRRORTIMER1"] = "Atemleiste",
		["LID_IASKILLS"] = "Fertigkeitsbalken",
		["LID_UIWIDGETBELOWMINIMAP"] = "Widget Unterhalb der Minimap (Einnehmen-Status)",
		["LID_DURABILITY"] = "Haltbarkeitspuppe",
		["LID_MONEYBAR"] = "Geldleiste",
		["LID_TOKENBAR"] = "Token-Leiste",
		["LID_IAILVLBAR"] = "Gegenstandsstufe-Leiste (ItemLevel)",
		["LID_CASTINGBAR"] = "Zauberleiste",
		["LID_TALKINGHEAD"] = "Redekopf-Dialog",
		["LID_POSSESSBAR"] = "Besitzleiste (NPC/Fahrzeug steuern)",
		["LID_ZONEABILITYFRAME"] = "Zonen-Fähigkeit",
		["LID_EXTRAABILITYCONTAINER"] = "Extra-Fähigkeit (Zauber für Quests, Bosse)",
		["LID_MAINMENUEXPBAR"] = "Erfahrungsleiste",
		["LID_REPUTATIONWATCHBAR"] = "Rufleiste",
		["LID_UIWIDGETPOWERBAR"] = "Machtleiste (Bossleiste, Elanleiste, Dunkelmond-Jahrmarkt, ...)",
		["LID_POWERBAR"] = "Power Bar (Encounters, ...)",

		["LID_COUNT"] = "Anzahl",
		["LID_ROWS"] = "Reihen",
		["LID_SPACING"] = "Abstand",



		["LID_PROFILE"] = "Profil",
		["LID_PROFILES"] = "Profile",
		["LID_ADDPROFILE"] = "Profil hinzufügen",
		["LID_CURRENT"] = "Derzeitiges",
		["LID_SHARE"] = "Teilen",
		["LID_SHAREPROFILE"] = "Profil teilen",
		["LID_GETPROFILE"] = "Profil erhalten",
		["LID_INHERITFROM"] = "Vererben von",
		["LID_ADD"] = "Hinzufügen",
		["LID_REMOVE"] = "Entfernen",
		["LID_RENAME"] = "Umbenennen",
		["LID_PLAYER"] = "Spieler",
		["LID_DOWNLOAD"] = "Herunterladen",
		["LID_UPLOAD"] = "Hochladen",
		["LID_STATUS"] = "Status",
		["LID_DONE"] = "Fertig",
		["LID_WAITINGFOROWNER"] = "Auf Besitzer warten",
		["LID_WAITFORPLAYERPROFILE"] = "Auf anderen Spieler warten, der auf \"Profile erhalten\" drückt.",
		["LID_WAITFORPLAYERPROFILE2"] = "Auf anderen Spieler warten, der auf \"Teilen\" drückt.",

		["LID_ALPHAINCOMBAT"] = "Sichtbarkeit (im Kampf)",
		["LID_ALPHANOTINCOMBAT"] = "Sichtbarkeit (Nicht im Kampf)",
		["LID_ALPHAINVEHICLE"] = "Sichtbarkeit (im Fahrzeug)",
		["LID_ALPHAINRESTEDAREA"] = "Sichtbarkeit (in Erholung)",
		["LID_ALPHAISMOUNTED"] = "Sichtbarkeit (auf Mount)",

		["LID_MABUFFLIMIT"] = "Stärkungszauber Grenze",
		["LID_MABUFFSPACINGX"] = "Stärkungszauber Abstand Horizontal",
		["LID_MABUFFSPACINGY"] = "Stärkungszauber Abstand Vertikal",
		["LID_ISENABLEDINEDITMODE"] = "(Deaktiviere es im Bearbeitungsmodus)",
		["LID_CANBREAKBECAUSEOFEDITMODE"] = "(Kann Error verursachen, wegen Bearbeitungsmodus)",

		["LID_HELPTEXT"] = "\"%s\" ist bereits im EditMode aktiviert. Bitte deaktivieren Sie im EditMode oder MoveAny.",
	
		["LID_BUILTIN"] = "Eingebaut",
		["LID_EDITMODE"] = "Bearbeitungsmodus überschreiben",
		["LID_NORMAL"] = "Normal",
		["LID_CLASSSPECIFIC"] = "Klassenspezifisch",
		["LID_ADVANCED"] = "Erweitert",
		["LID_ImproveAny"] = "ImproveAny",

		["LID_MISSINGREQUIREMENT"] = "Fehlende Anforderung: %s",
		["LID_ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Fortschrittsanzeige der archäologischen Ausgrabungsstätte",
		["LID_UIERRORSFRAME"] = "Ui-Fehler Meldungen, Quest Fortschritt",
		["LID_COMBOPOINTPLAYERFRAME"] = "Kombopunkte",

		["LID_PARTYFRAME"] = "Gruppenfenster",
		["LID_PARTYMEMBERFRAME"] = "Gruppenmitgliedfenster %s",
		["LID_BOSSTARGETFRAMECONTAINER"] = "Boss Fenster",

		["LID_FLIPPED"] = "Umgedreht",
		["LID_GHOSTFRAME"] = "Geisterfenster (Teleport zum Friedhof)",
		["LID_TICKETSTATUSFRAME"] = "Ticket Fenster",
		["LID_LOSSOFCONTROLFRAME"] = "Kontrollverlustfenster",

		["LID_MainStatusTrackingBarContainer"] = "Erfahrungsleiste",
		["LID_SecondaryStatusTrackingBarContainer"] = "Rufleiste",

		["LID_TargetFrameNumericalThreat"] = "Bedrohungs Prozente",

		["LID_EventToastManagerFrame"] = "EventToastManagerFrame (Stufenaufstieg, Zonentext)",
		["LID_BUFFTIMER1"] = "Stärkungsanzeige",

		["LID_!KalielsTracker"] = "!KalielsTracker",
		["LID_!KalielsTrackerButtons"] = "!KalielsTrackerButtons",
	}

	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		tab["LID_ACTIONBARS"] = "Aktionsleisten 1 + 5 + 6"
		tab["LID_ACTIONBAR1"] = "Aktionsleiste 1 (Hauptleiste)"
		tab["LID_ACTIONBAR2"] = "Aktionsleiste 2 (2. Seite von Aktionsleiste 1)"
		tab["LID_ACTIONBAR3"] = "Aktionsleiste 3 (Rechte Leiste)"
		tab["LID_ACTIONBAR4"] = "Aktionsleiste 4 (Linke Leiste)"
		tab["LID_ACTIONBAR5"] = "Aktionsleiste 5 (Leiste oben rechts)"
		tab["LID_ACTIONBAR6"] = "Aktionsleiste 6 (Leiste oben links)"
		tab["LID_ACTIONBAR7"] = "Aktionsleiste 7 (Benutzerdefinierte)"
		tab["LID_ACTIONBAR8"] = "Aktionsleiste 8 (Benutzerdefinierte)"
		tab["LID_ACTIONBAR9"] = "Aktionsleiste 9 (Benutzerdefinierte)"
		tab["LID_ACTIONBAR10"] = "Aktionsleiste 10 (Benutzerdefinierte)"
	else
		tab["LID_ACTIONBAR1"] = "Aktionsleiste 1 (Hauptleiste)"
		tab["LID_ACTIONBAR2"] = "Aktionsleiste 2 (Zweite Leiste)"
		tab["LID_ACTIONBAR3"] = "Aktionsleiste 3 (Dritte Leiste)"
		tab["LID_ACTIONBAR4"] = "Aktionsleiste 4 (Rechte Leiste)"
		tab["LID_ACTIONBAR5"] = "Aktionsleiste 5 (Linke Leiste)"
		tab["LID_ACTIONBAR6"] = "Aktionsleiste 6 (Extra)"
		tab["LID_ACTIONBAR7"] = "Aktionsleiste 7 (Extra)"
		tab["LID_ACTIONBAR8"] = "Aktionsleiste 8 (Extra)"
	end

	MoveAny:UpdateLanguageTab( tab )
end
