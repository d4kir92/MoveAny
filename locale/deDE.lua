-- deDE German Deutsch

local AddOnName, MoveAny = ...

function MoveAny:LangdeDE()
	local tab = {
		["MMBTNLEFT"] = "Linksklick => Sperren/Entsperren + Optionen",
		["MMBTNRIGHT"] = "Shift + Rechtsklick => Minimapknopf verstecken",

		["GENERAL"] = "Allgemein",
		["SHOWMINIMAPBUTTON"] = "Minimapknopf anzeigen",
		["GRIDSIZE"] = "Rastergröße (Grid)",
		["MOVEFRAMES"] = "Fenster bewegen",
		["SAVEFRAMEPOSITION"] = "Fenster Position abspeichern",
		["SAVEFRAMESCALE"] = "Fenster Skalierung abspeichern",
		["FRAMESSHIFTDRAG"] = "Fenster mit Shift + Linksklick-ziehen bewegen",
		["FRAMESSHIFTSCALE"] = "Fenster mit Shift + Rechtsklick-ziehen skalieren",
		["FRAMESSHIFTRESET"] = "Fenster mit Shift + Mausradklick resetten",

		["TOPLEFT"] = "Oben Links",
		["PLAYERFRAME"] = "Spielerfenster",
		["PETFRAME"] = "Begleiterfenster",
		["TARGETFRAME"] = "Zielfenster",
		["TARGETOFTARGETFRAME"] = "Ziel des Zielfenster",
		["TARGETFRAMESPELLBAR"] = "Zauberleiste vom Ziel",
		["FOCUSFRAME"] = "Fokusfenster",
		["FOCUSFRAMESPELLBAR"] = "Zauberleiste vom Fokus",
		["TARGETOFFOCUSFRAME"] = "Ziel des Fokusfenster",
		["RUNEFRAME"] = "Todesritter - Runen Fenster",
		["TOTEMFRAME"] = "Totem Zähler (Auch von anderen Klassen benutzt)",
		["WARLOCKPOWERFRAME"] = "Hexenmeister Macht Fenster",
		["MONKHARMONYBARFRAME"] = "Mönch Harmonie Fenster (Chi)",
		["MONKSTAGGERBAR"] = "Monk Staffeln Leiste  (Chi)",
		["MAGEARCANECHARGESFRAME"] = "Magier Arkane Ladungen Fenster",
		["ESSENCEPLAYERFRAME"] = "Essenz Spieler Fenster (Rufer)",
		["PALADINPOWERBARFRAME"] = "Paladin Machtleiste",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "Oben",

		["TOPRIGHT"] = "Oben Rechts",
		["MINIMAP"] = "Minimap",
		["BUFFS"] = "Stärkungszauber",
		["DEBUFFS"] = "Schwächungszauber",
		["VEHICLESEATINDICATOR"] = "Fahrzeugsitzanzeige",
		["ARENAENEMYFRAMES"] = "Arena Gegner Fenster",
		["ARENAPREPFRAMES"] = "Arena Vorbereitungs Fenster",
		["QUESTTRACKER"] = "Questverfolgung",

		["RIGHT"] = "Rechts",

		["BOTTOMRIGHT"] = "Unten Rechts",
		["MICROMENU"] = "Mikro Menü",
		["BAGS"] = "Taschen",
		["GAMETOOLTIP"] = "Tooltip",
		["GAMETOOLTIP_ONCURSOR"] = "Tooltip am Zeiger",
		["QUEUESTATUSBUTTON"] = "SNG Status (LFG)",

		["BOTTOM"] = "Unten",
		["ACTIONBARS"] = "Aktionsleisten 1-6",
		["ACTIONBAR7"] = "Benutzerdefinierte Aktionsleiste 7",
		["ACTIONBAR8"] = "Benutzerdefinierte Aktionsleiste 8",
		["ACTIONBAR9"] = "Benutzerdefinierte Aktionsleiste 9",
		["ACTIONBAR10"] = "Benutzerdefinierte Aktionsleiste 10",
		["PETBAR"] = "Begleiterleiste",
		["STANCEBAR"] = "Haltungsleiste",
		["TOTEMBAR"] = "Schamane - Totemleiste",
		["LEAVEVEHICLE"] = "Fahrzeug verlassen Taste",
		["GROUPLOOTCONTAINER"] = "Beute-Würfeln Fenster",
		["STATUSTRACKINGBARMANAGER"] = "Statusverfolgungsleiste Manager (EP, Ruf)",
		["ALERTFRAME"] = "Alarmfenster (Bonus Beute, Erfolg, ...)",

		["BOTTOMLEFT"] = "Unten Links",
		["CHAT"] = "Chatfenster %d",
		["CHATBUTTONFRAME"] = "Chat Knöpfe",
		["CHATQUICKJOIN"] = "Chat Schnellbeitritt",
		["CHATEDITBOX"] = "Chat Eingabefeld",

		["LEFT"] = "Links",
		["COMPACTRAIDFRAMEMANAGER"] = "SchlachzugsManager",
		["BATTLENETFRIENDSNOTIFICATION"] = "Benachrichtigungen von Battlenet Freunden",

		["CENTER"] = "Center",
		["SPELLACTIVATIONOVERLAYFRAME"] = "Spell Activation Overlay",

		

		["ZONETEXTFRAME"] = "Zonentext",
		["UIWIDGETTOPCENTER"] = "Widget Oben-Mittig (Status bei BGs/Dungeons)",
		["MIRRORTIMER1"] = "Atemleiste",
		["IASKILLS"] = "Fertigkeitsbalken",
		["UIWIDGETBELOWMINIMAP"] = "Widget Unterhalb der Minimap (Einnehmen-Status)",
		["DURABILITY"] = "Haltbarkeitspuppe",
		["MONEYBAR"] = "Geldleiste",
		["TOKENBAR"] = "Token-Leiste",
		["IAILVLBAR"] = "Gegenstandsstufe-Leiste (ItemLevel)",
		["CASTINGBAR"] = "Zauberleiste",
		["TALKINGHEAD"] = "Redekopf-Dialog",
		["ACTIONBAR1"] = "Aktionsleiste 1 (Hauptleiste)",
		["ACTIONBAR2"] = "Aktionsleiste 2 (2. Seite von Aktionsleiste 1)",
		["ACTIONBAR3"] = "Aktionsleiste 3 (Rechte Leiste)",
		["ACTIONBAR4"] = "Aktionsleiste 4 (Linke Leiste)",
		["ACTIONBAR5"] = "Aktionsleiste 5 (Leiste oben rechts)",
		["ACTIONBAR6"] = "Aktionsleiste 6 (Leiste oben links)",
		["POSSESSBAR"] = "Besitzleiste (NPC/Fahrzeug steuern)",
		["ZONEABILITYFRAME"] = "Zonen-Fähigkeit",
		["EXTRAABILITYCONTAINER"] = "Extra-Fähigkeit (Zauber für Quests, Bosse)",
		["MAINMENUEXPBAR"] = "Erfahrungsleiste",
		["REPUTATIONWATCHBAR"] = "Rufleiste",
		["UIWIDGETPOWERBAR"] = "Machtleiste (Bossleiste, Elanleiste, ...)",

		["ROWS"] = "Reihen",
		["SPACING"] = "Abstand",



		["PROFILE"] = "Profil",
		["PROFILES"] = "Profile",
		["ADDPROFILE"] = "Profil hinzufügen",
		["CURRENT"] = "Derzeitiges",
		["SHARE"] = "Teilen",
		["SHAREPROFILE"] = "Profil teilen",
		["GETPROFILE"] = "Profil erhalten",
		["INHERITFROM"] = "Vererben von",
		["ADD"] = "Hinzufügen",
		["REMOVE"] = "Entfernen",
		["RENAME"] = "Umbenennen",
		["PLAYER"] = "Spieler",
		["DOWNLOAD"] = "Herunterladen",
		["UPLOAD"] = "Hochladen",
		["STATUS"] = "Status",
		["DONE"] = "Fertig",
		["WAITINGFOROWNER"] = "Auf Besitzer warten",
		["WAITFORPLAYERPROFILE"] = "Auf anderen Spieler warten, der auf \"Profile erhalten\" drückt.",
		["WAITFORPLAYERPROFILE2"] = "Auf anderen Spieler warten, der auf \"Teilen\" drückt.",

		["ALPHAINCOMBAT"] = "Sichtbarkeit (im Kampf)",
		["ALPHANOTINCOMBAT"] = "Sichtbarkeit (Nicht im Kampf)",
		["ALPHAINVEHICLE"] = "Sichtbarkeit (im Fahrzeug)",

		["MABUFFLIMIT"] = "Stärkungszauber Grenze",
		["MABUFFSPACINGX"] = "Stärkungszauber Abstand Horizontal",
		["MABUFFSPACINGY"] = "Stärkungszauber Abstand Vertikal",
		["ISENABLEDINEDITMODE"] = "(Deaktiviere es im Bearbeitungsmodus)",
		["CANBREAKBECAUSEOFEDITMODE"] = "(Kann Error verursachen, wegen Bearbeitungsmodus)",

		["HELPTEXT"] = "\"%s\" ist bereits im EditMode aktiviert. Bitte deaktivieren Sie im EditMode oder MoveAny.",
	
		["BUILTIN"] = "Eingebaut",
		["EDITMODE"] = "Bearbeitungsmodus überschreiben",
		["NORMAL"] = "Normal",
		["CLASSSPECIFIC"] = "Klassenspezifisch",
		["ADVANCED"] = "Erweitert",
		["ImproveAny"] = "ImproveAny",

		["MISSINGREQUIREMENT"] = "Fehlende Anforderung: %s",
		["ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Fortschrittsanzeige der archäologischen Ausgrabungsstätte",
		["UIERRORSFRAME"] = "Ui-Fehler Meldungen, Quest Fortschritt",
		["COMBOPOINTPLAYERFRAME"] = "Kombopunkte",

		["PARTYFRAME"] = "Gruppenfenster",
		["PARTYMEMBERFRAME"] = "Gruppenmitgliedfenster %s",
		["BOSSTARGETFRAMECONTAINER"] = "Boss Fenster",

		["FLIPPED"] = "Umgedreht",
		["GHOSTFRAME"] = "Geisterfenster (Teleport zum Friedhof)",
		["TICKETSTATUSFRAME"] = "Ticket Fenster",
		["LOSSOFCONTROLFRAME"] = "Kontrollverlustfenster",

		["MainStatusTrackingBarContainer"] = "Erfahrungsleiste",
		["SecondaryStatusTrackingBarContainer"] = "Rufleiste",

		["ACTIONBAR1R"] = "Aktionsleiste 1 (Hauptleiste)",
		["ACTIONBAR2R"] = "Aktionsleiste 2 (Über Hauptleiste)",
		["ACTIONBAR3R"] = "Aktionsleiste 3 (Über 2. Leiste)",
		["ACTIONBAR4R"] = "Aktionsleiste 4 (Rechte Leiste)",
		["ACTIONBAR5R"] = "Aktionsleiste 5 (Linke Leiste)",
		["ACTIONBAR6R"] = "Aktionsleiste 6",
		["ACTIONBAR7R"] = "Aktionsleiste 7",
		["ACTIONBAR8R"] = "Aktionsleiste 8",
	}

	MoveAny:UpdateLanguageTab( tab )
end
