-- deDE German Deutsch
local _, MoveAny = ...
function MoveAny:LangdeDE()
	local tab = {
		["LID_LEFTCLICK"] = "Linksklick",
		["LID_RIGHTCLICK"] = "Rechtsklick",
		["LID_MMBTNLEFT"] = "Sperren/Entsperren + Optionen",
		["LID_MMBTNRIGHT"] = "Minimapknopf verstecken",
		["LID_GENERAL"] = "Allgemein",
		["LID_SHOWMINIMAPBUTTON"] = "Minimapknopf anzeigen",
		["LID_GRIDSIZE"] = "Rastergröße (Grid)",
		["LID_SNAPSIZE"] = "Snapgröße (Grid)",
		["LID_MOVEFRAMES"] = "Fenster bewegen",
		["LID_SAVEFRAMEPOSITION"] = "Fenster Position abspeichern",
		["LID_SAVEFRAMESCALE"] = "Fenster Skalierung abspeichern",
		["LID_SHIFT"] = "SHIFT",
		["LID_CTRL"] = "STRG",
		["LID_ALT"] = "ALT",
		["LID_FRAMESKEYDRAG"] = "Fenster mit %s + Linksklick-ziehen bewegen",
		["LID_FRAMESKEYSCALE"] = "Fenster mit %s + Rechtsklick-ziehen skalieren",
		["LID_FRAMESKEYRESET"] = "Fenster mit %s + Mausradklick resetten",
		["LID_PLAYERFRAME"] = "Spielerfenster",
		["LID_PLAYERLEVELTEXT"] = "Spielerfenster-Level",
		["LID_PLAYERFRAMEBACKGROUND"] = "Spielerfenster Hintergrund",
		["LID_PETFRAME"] = "Begleiterfenster",
		["LID_MAPETFRAME"] = "Begleiterfenster",
		["LID_PETFRAMEHAPPINESS"] = "Begleiterfenster Glücklichkeit",
		["LID_TARGETFRAME"] = "Zielfenster",
		["LID_TARGETFRAMENAMEBACKGROUND"] = "Zielfenster Namen-Hintergrund",
		["LID_TARGETFRAMEBUFF1"] = "Zielfenster Buff 1",
		["LID_TARGETFRAMETOTDEBUFF1"] = "Ziel des Zielfenster Debuff 1",
		["LID_TARGETOFTARGETFRAME"] = "Ziel des Zielfenster",
		["LID_TARGETFRAMESPELLBAR"] = "Zauberleiste vom Ziel",
		["LID_FOCUSFRAME"] = "Fokusfenster",
		["LID_FOCUSFRAMEBUFF1"] = "Fokusfenster Buff 1",
		["LID_FOCUSFRAMESPELLBAR"] = "Zauberleiste vom Fokus",
		["LID_TARGETOFFOCUSFRAME"] = "Ziel des Fokusfenster",
		["LID_RUNEFRAME"] = "Todesritter - Runen Fenster",
		["LID_TOTEMFRAME"] = "Totem Zähler (Auch von anderen Klassen benutzt)",
		["LID_WARLOCKPOWERFRAME"] = "Hexenmeister Macht Fenster (Splitter)",
		["LID_MONKHARMONYBARFRAME"] = "Mönch Harmonie Fenster (Chi)",
		["LID_MONKSTAGGERBAR"] = "Monk Staffeln Leiste  (Chi)",
		["LID_MAGEARCANECHARGESFRAME"] = "Magier Arkane Ladungen Fenster",
		["LID_ESSENCEPLAYERFRAME"] = "Essenz Spieler Fenster (Rufer)",
		["LID_PALADINPOWERBARFRAME"] = "Paladin Machtleiste (Heilige Macht)",
		["LID_MAFPSFrame"] = "FPS (Neuer FPS-Zähler)",
		["LID_IAPingFrame"] = "Ping",
		["LID_IACoordsFrame"] = "Koordinatenfenster",
		["LID_MINIMAP"] = "Minimap",
		["LID_MINIMAPZONETEXT"] = "Minimap Zonen Text",
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
		["LID_GROUPLOOTFRAME1"] = "Beute-Würfeln Fenster 1 (Beute/Loot)",
		["LID_GROUPLOOTCONTAINER"] = "Beute-Würfeln Fenster (Beute/Loot)",
		["LID_BONUSROLLFRAME"] = "Bonus-Würfeln Fenster (Beute/Loot)",
		["LID_STATUSTRACKINGBARMANAGER"] = "Statusverfolgungsleiste Manager (EP, Ruf)",
		["LID_ALERTFRAME"] = "Alarmfenster (Bonus Beute, Erfolg, ...) (Beute/Loot)",
		["LID_CHAT"] = "Chatfenster %d",
		["LID_CHATBUTTONFRAME1"] = "Chat Knöpfe für Tab 1",
		["LID_CHATBUTTONFRAME2"] = "Chat Knöpfe für Tab 2",
		["LID_CHATBUTTONFRAME3"] = "Chat Knöpfe für Tab 3",
		["LID_CHATBUTTONFRAME4"] = "Chat Knöpfe für Tab 4",
		["LID_CHATBUTTONFRAME5"] = "Chat Knöpfe für Tab 5",
		["LID_CHATBUTTONFRAME6"] = "Chat Knöpfe für Tab 6",
		["LID_CHATBUTTONFRAME7"] = "Chat Knöpfe für Tab 7",
		["LID_CHATBUTTONFRAME8"] = "Chat Knöpfe für Tab 8",
		["LID_CHATBUTTONFRAME9"] = "Chat Knöpfe für Tab 9",
		["LID_CHATBUTTONFRAME10"] = "Chat Knöpfe für Tab 10",
		["LID_CHATQUICKJOIN"] = "Chat Schnellbeitritt",
		["LID_CHATEDITBOX"] = "Chat Eingabefeld %s",
		["LID_COMPACTRAIDFRAMEMANAGER"] = "SchlachtzugsManager",
		["LID_BNToastFrame"] = "Benachrichtigungen von Battlenet Freunden",
		["LID_SPELLACTIVATIONOVERLAYFRAME"] = "Zauber-Aktivierungs-Overlay (Class Proc)",
		["LID_ZONETEXTFRAME"] = "Zonentext",
		["LID_UIWIDGETTOPCENTER"] = "Widget Oben-Mittig (Status/Statistik von Schlachtfeldern/Dungeons/Raids)",
		["LID_MIRRORTIMER1"] = "Atemleiste",
		["LID_IASKILLS"] = "Fertigkeitsbalken",
		["LID_UIWIDGETBELOWMINIMAP"] = "Widget Unterhalb der Minimap (Einnehmen-Status)",
		["LID_DURABILITY"] = "Haltbarkeitspuppe",
		["LID_MONEYBAR"] = "Geldleiste",
		["LID_TOKENBAR"] = "Token-Leiste",
		["LID_IAILVLBAR"] = "Gegenstandsstufe-Leiste (ItemLevel)",
		["LID_CASTINGBAR"] = "Zauberleiste",
		["LID_CASTINGBARTIMER"] = "Zauberleiste Timer",
		["LID_TALKINGHEAD"] = "Weltquestfenster (\"Redekopf\")",
		["LID_POSSESSBAR"] = "Besitzleiste (NPC/Fahrzeug steuern)",
		["LID_ZONEABILITYFRAME"] = "Zonen-Fähigkeit",
		["LID_EXTRAABILITYCONTAINER"] = "Extra-Fähigkeit (Zauber für Quests, Bosse)",
		["LID_MAINMENUEXPBAR"] = "Erfahrungsleiste",
		["LID_REPUTATIONWATCHBAR"] = "Rufleiste",
		["LID_UIWIDGETPOWERBAR"] = "Machtleiste (Bossleiste, Elanleiste, Dunkelmond-Jahrmarkt, ...)",
		["LID_POWERBAR"] = "Machtleiste (Boss Begegnungen, ...)",
		["LID_COUNT"] = "Anzahl",
		["LID_ROWS"] = "Reihen",
		["LID_SPACING"] = "Abstand (Lücke)",
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
		["LID_ALPHAISSTEALTHED"] = "Sichtbarkeit (Unsichtbar)",
		["LID_MABUFFLIMIT"] = "Stärkungszauber Grenze",
		["LID_MABUFFSPACINGX"] = "Stärkungszauber Abstand Horizontal",
		["LID_MABUFFSPACINGY"] = "Stärkungszauber Abstand Vertikal",
		["LID_ISENABLEDINEDITMODE"] = "(Deaktiviere es im Spielmenü-Bearbeitungsmodus)",
		["LID_CANBREAKBECAUSEOFEDITMODE"] = "(Kann Error verursachen, wegen Bearbeitungsmodus)",
		["LID_HELPTEXT"] = "\"%s\" ist bereits im EditMode aktiviert. Bitte deaktivieren Sie im EditMode oder MoveAny.",
		["LID_BUILTIN"] = "Eingebaut",
		["LID_EDITMODE"] = "Bearbeitungsmodus überschreiben",
		["LID_NORMAL"] = "Normal",
		["LID_CLASSSPECIFIC"] = "Klassenspezifisch",
		["LID_ADVANCED"] = "Erweitert",
		["LID_ImproveAny"] = "ImproveAny",
		["LID_ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Fortschrittsanzeige der archäologischen Ausgrabungsstätte",
		["LID_UIERRORSFRAME"] = "Ui-Fehler Meldungen, Quest Fortschritt",
		["LID_COMBOPOINTPLAYERFRAME"] = "Kombopunkte",
		["LID_PARTYFRAME"] = "Gruppenfenster",
		["LID_PARTYMEMBERFRAME"] = "Gruppenmitgliedfenster %s",
		["LID_COMPACTRAIDFRAMECONTAINER"] = "Schlachtzugfenster",
		["LID_BOSSTARGETFRAMECONTAINER"] = "Boss Fenster (Bossfenster)",
		["LID_FLIPPED"] = "Umgedreht",
		["LID_GHOSTFRAME"] = "Geisterfenster (Teleport zum Friedhof)",
		["LID_TICKETSTATUSFRAME"] = "Ticket Fenster",
		["LID_LOSSOFCONTROLFRAME"] = "Kontrollverlustfenster",
		["LID_MainStatusTrackingBarContainer"] = "StatusBar1 (Erfahrungsleiste/Rufleiste)",
		["LID_SecondaryStatusTrackingBarContainer"] = "StatusBar2 (Rufleiste)",
		["LID_TargetFrameNumericalThreat"] = "Bedrohungs Prozente",
		["LID_EventToastManagerFrame"] = "EventToastManagerFrame (Stufenaufstieg, Zonentext)",
		["LID_BUFFTIMER1"] = "Stärkungsanzeige",
		["LID_!KalielsTracker"] = "!KalielsTracker",
		["LID_!KalielsTrackerButtons"] = "!KalielsTrackerButtons",
		["LID_ENDCAPLEFT"] = "Abschlusskappe links (Greif)",
		["LID_ENDCAPRIGHT"] = "Abschlusskappe rechts (Greif)",
		["LID_ENDCAPS"] = "Abschlusskappen (Greifen)",
		["LID_BLIZZARDACTIONBUTTONSART"] = "Aktionsleiste 1 Blizzard-Kunst",
		["LID_OBJECTIVETRACKERBONUSBANNERFRAME"] = "Objektiv Tracker Fenster (World Quest Titel)",
		["LID_MOVESMALLBAGS"] = "Bewegen/Skalieren von kleinen Taschen",
		["LID_MOVELOOTFRAME"] = "Bewegen von Beutefenster (Loot)",
		["LID_SCALELOOTFRAME"] = "Skalieren von Beutefenster (Loot)",
		["LID_NEEDSARELOAD"] = "Braucht ein Neu laden",
		["LID_RAIDBOSSEMOTEFRAME"] = "Raid Boss Emotionen Fenster",
		["LID_STARTHELP"] = "Klicken Sie auf die MoveAny Minimap-Schaltfläche, um die Einstellungen zu öffnen",
		["LID_STARTHELP2"] = "Oder tippe im Chat auf /move oder /moveany, um die Einstellungen zu öffnen.",
		["LID_STARTHELP3"] = "Um diese Nachrichten zu verstecken deaktiviere Tipps im MoveAny Menü.",
		["LID_SHOWTIPS"] = "Tipps anzeigen",
		["LID_OVERRIDEACTIONBAR"] = "\"Überschreiben\" Aktionsleiste (Fahrzeugleiste)",
		["LID_BOSSBANNER"] = "Boss-Banner (Abgelegte Beute/Loot, Boss Titel)",
		["LID_COMPACTARENAFRAME"] = "Kompaktes Arena Fenster",
		["LID_ROLEPOLLPOPUP"] = "Rollenabfrage-Popup",
		["LID_READYCHECKLISTENERFRAME"] = "Bereitschaftsprüfung-Popup",
		["LID_DISABLEMOVEMENT"] = "Bewegungstastenbelegung deaktivieren, wenn im MoveAny-EditMode",
		["LID_CLICKTHROUGH"] = "Durchklicken",
		["LID_MABUFFMODE"] = "Stärkungszauber-Ausrichtung",
		["LID_MADEBUFFLIMIT"] = "Schwächungszauber Grenze",
		["LID_MADEBUFFSPACINGX"] = "Schwächungszauber Abstand Horizontal",
		["LID_MADEBUFFSPACINGY"] = "Schwächungszauber Abstand Vertikal",
		["LID_MADEBUFFMODE"] = "Schwächungszauber-Ausrichtung",
		["LID_SEARCH"] = "Suche",
		["LID_COMBOFRAME"] = "Komboleiste",
		["LID_WIDTH"] = "Weite",
		["LID_HEIGHT"] = "Höhe",
		["LID_ALPHAISFULLHEALTH"] = "Sichtbarkeit (Volle Gesundheit)",
		["LID_ALPHAISINPETBATTLE"] = "Sichtbarkeit (Ist in Haustierkampf)",
		["LID_KEYBINDWINDOW"] = "Keybind für Fenster",
		["LID_SNAPWINDOWSIZE"] = "Snapgröße (Fenster)",
		["LID_BOSS1"] = "Boss 1",
		["LID_BOSS2"] = "Boss 2",
		["LID_BOSS3"] = "Boss 3",
		["LID_BOSS4"] = "Boss 4",
		["LID_BOSS5"] = "Boss 5",
		["LID_BOSS6"] = "Boss 6",
		["LID_MAPAGES"] = "Aktionsleisten-Seiten",
		["LID_HIDEHIDDENFRAMES"] = "Verstecke versteckte Elemente",
		["LID_TIMERTRACKER1"] = "Zeitmesser (erst sichtbar wenn verfügbar)",
		["LID_PALADINPOWERBAR"] = "Paladin Machtleiste (Heilige Macht)",
		["LID_SHARDBARFRAME"] = "Hexenmeister Macht Fenster (Splitter)",
		["LID_OFFSET"] = "Versatz (Offset)",
		["LID_EclipseBarFrame"] = "Eclipseleiste (Druide)",
		["LID_REQUIRESFOR"] = "Benötigt: %s",
		["LID_REQUIREDFOR"] = "Benötigt für: %s",
		["LID_RESETELEMENT"] = "Element resetten",
		["LID_TARGETFRAMEDEBUFF1"] = "Zielfenster Debuff 1",
		["LID_FOCUSFRAMEDEBUFF1"] = "Fokusfenster Debuff 1",
		["LID_TARGETFRAMETOTBUFF1"] = "Ziel des Zielfenster Buff 1",
		["LID_MINIMAPFLAG"] = "Minimap Flagge",
		["LID_MiniMapInstanceDifficulty"] = "Minimap Flagge Instanz Schwierigkeit",
		["LID_MiniMapChallengeMode"] = "Minimap Flagge Herausforderungsmodus",
		["LID_GuildInstanceDifficulty"] = "Minimap Flagge Gilden-Instanz Schwierigkeit",
		["LID_POWERBARCOUNTERBAR"] = "Machtleiste Gegenleiste",
		["LID_BUFFTIMER1"] = "Stärkungszeit 1",
		["LID_FRAMES"] = "Fenster",
		["LID_SCALEFRAMES"] = "Fenster skalieren",
		["LID_RESETFRAMES"] = "Fenster resetten",
		["LID_ExpansionLandingPageMinimapButton"] = "ExpansionLandingPageMinimapButton",
		["LID_MOVEANYINFO"] = "Wählen Sie die Dinge aus, die Sie ändern möchten",
		["LID_PLEASESWITCHPROFILE1"] = "Bitte wechsel das LAYOUT im Bearbeitungsmodus (von Blizzard) zu einem BENUTZERDEFINIERTEN Layout.",
		["LID_PLEASESWITCHPROFILE2"] = "MoveAny funktioniert nicht mit einem voreingestellten Layout, es ist meist schreibgeschützt.",
		["LID_PLEASESWITCHPROFILE3"] = "ESC -> Bearbeitungsmodus -> Layout: [BENUTZERDEFINIERTES-LAYOUT] (Kein Voreingestelltes Layout)",
		["LID_LFGMinimapFrame"] = "LFG Minimapknopf",
		["LID_QUESTTIMERFRAME"] = "Questzeit-Fenster",
		["LID_BATTLEFIELDMAPFRAME"] = "Schlachtfeld Karte",
		["LID_EXTRAACTIONBARFRAME"] = "Extra Aktionsleiste (ExtraActionButton1)",
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

	MoveAny:UpdateLanguageTab(tab)
end
