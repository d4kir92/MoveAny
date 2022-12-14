-- itIT Italien

local AddOnName, MoveAny = ...

function MoveAny:LangitIT()
	local tab = {
		["MMBTNLEFT"] = "Click sinistro => Blocca/Sblocca + Opzioni",
		["MMBTNRIGHT"] = "Maiusc + clic destro => Nascondi pulsante Minimap",

		["GENERAL"] = "Generale",
		["SHOWMINIMAPBUTTON"] = "Mostra pulsante Minimap",
		["GRIDSIZE"] = "Gridsize",
		["MOVEFRAMES"] = "Sposta fotogrammi/finestre",
		["FRAMESSHIFTDRAG"] = "Sposta fotogramma con Maiusc + trascinamento con il tasto sinistro del mouse",
		["FRAMESSHIFTSCALE"] = "Scala il fotogramma con Maiusc + trascinamento con il tasto destro del mouse",
		["FRAMESSHIFTRESET"] = "Azzeramento del riquadro con Shift + clic della rotella del mouse",

		["TOPLEFT"] = "In alto a sinistra",
		["PLAYERFRAME"] = "Riquadro giocatore",
		["PETFRAME"] = "Cornice animale domestico",
		["TARGETFRAME"] = "Cornice obiettivo",
		["TARGETOFTARGETFRAME"] = "Cornice di destinazione",
		["TARGETFRAMESPELLBAR"] = "Castbar del bersaglio",
		["FOCUSFRAME"] = "Cornice di messa a fuoco",
		["FOCUSFRAMESPELLBAR"] = "Barra di cast da Focus",
		["TARGETOFFOCUSFRAME"] = "Riquadro di destinazione del fuoco",
		["RUNEFRAME"] = "Cornice delle rune del Cavaliere della Morte",
		["TOTEMFRAME"] = "Totem Timers",
		["WARLOCKPOWERFRAME"] = "Quadro del potere dello stregone",
		["MONKHARMONYBARFRAME"] = "Cornice dell'armonia del monaco",
		["MAGEARCANECHARGESFRAME"] = "Cornice delle cariche arcane del mago",
		["ESSENCEPLAYERFRAME"] = "Cornice del giocatore d'essenza (evocatore)",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "Top",

		["TOPRIGHT"] = "In alto a destra",
		["MINIMAP"] = "Mini mappa",
		["BUFFS"] = "Buffs",
		["DEBUFFS"] = "Debuff",
		["VEHICLESEATINDICATOR"] = "Indicatore del sedile del veicolo",
		["ARENAENEMYFRAMES"] = "Cornici nemiche dell'Arena",
		["ARENAPREPFRAMES"] = "Cornici di preparazione dell'Arena",
		["QUESTTRACKER"] = "Questtracker",

		["RIGHT"] = "Right",
	
		["BOTTOMRIGHT"] = "In basso a destra",
		["MICROMENU"] = "Micro Menu",
		["BAGS"] = "Bags",
		["GAMETOOLTIP"] = "Tooltip",
		["GAMETOOLTIP_ONCURSOR"] = "Tooltip sul cursore",
		["QUEUESTATUSBUTTON"] = "Stato LFG",

		["BOTTOM"] = "Bottom",
		["ACTIONBARS"] = "Barre d'azione 1-6",
		["ACTIONBAR7"] = "Barre d'azione personalizzate 7",
		["ACTIONBAR8"] = "Barre d'azione personalizzate 8",
		["ACTIONBAR9"] = "Barre d'azione personalizzate 9",
		["ACTIONBAR10"] = "Barre d'azione personalizzate 10",
		["PETBAR"] = "Barra degli animali domestici",
		["STANCEBAR"] = "Stance Bar",
		["TOTEMBAR"] = "Barra Totem Sciamano",
		["LEAVEHICLE"] = "Pulsante di uscita dal veicolo",
		["GROUPLOOTCONTAINER"] = "Cornice del rotolo di bottino",
		["STATUSTRACKINGBARMANAGER"] = "Gestore della barra di monitoraggio dello stato (XP, Reputazione)",
		["ALERTFRAME"] = "Riquadro degli avvisi (bottino bonus, successi, ...)",

		["BOTTOMLEFT"] = "In basso a sinistra",
		["CHAT"] = "Chatframe %d",
		["CHATBUTTONFRAME"] = "Pulsanti di chat",
		["CHATQUICKJOIN"] = "Partecipazione rapida alla chat",
		["CHATEDITBOX"] = "Chat Inputbox",

		["LEFT"] = "Sinistra",
		["COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",
		["BATTLENETFRIENDSNOTIFICATION"] = "Notifiche amici Battlenet",



		["ZONETEXTFRAME"] = "Testo zona",
		["UIWIDGETTOPCENTER"] = "Widget Top Center (Stato su BG/Dungeon)",
		["IASKILLS"] = "Barre delle abilit??",
		["UIWIDGETBELOWMINIMAP"] = "Widget sotto la minimappa (stato di cattura)",
		["DURABILIT??"] = "Bambola della durata",
		["MONEYBAR"] = "Barra del denaro",
		["TOKENBAR"] = "Barra dei gettoni",
		["IAILVLBAR"] = "Barra livello articolo",
		["CASTINGBAR"] = "Barra dei lanci",
		["TALKINGHEAD"] = "Dialogo testa parlante",
		["ACTIONBAR1"] = "Barra delle azioni 1 (barra principale)",
		["ACTIONBAR2"] = "Barra d'azione 2 (2. Pagina della barra d'azione 1)",
		["ACTIONBAR3"] = "Barra d'azione 3 (barra destra)",
		["ACTIONBAR4"] = "Barra d'azione 4 (barra sinistra)",
		["ACTIONBAR5"] = "Barra d'azione 5 (barra superiore destra)",
		["ACTIONBAR6"] = "Barra d'azione 6 (barra in alto a sinistra)",
		["POSSESSBAR"] = "Barra del possesso (controllo PNG/veicolo)",
		["ZONEABILITYFRAME"] = "Capacit?? di zona",
		["EXTRAABILITYCONTAINER"] = "Capacit?? extra",
		["MAINMENUEXPBAR"] = "Barra Exp",
		["REPUTATIONWATCHBAR"] = "Barra della reputazione",
		["UIWIDGETPOWERBAR"] = "Barra del potere",

		["ROWS"] = "Righe",
		["SPACING"] = "Spaziatura",
		
		

		["PROFILE"] = "Profilo",
		["PROFILI"] = "Profili",
		["ADDPROFILE"] = "Aggiungi profilo",
		["CURRENT"] = "Current",
		["SHARE"] = "Condividi",
		["SHAREPROFILE"] = "Profilo condiviso",
		["GETPROFILE"] = "Ottieni profilo",
		["INHERITFROM"] = "Eredita da",
		["ADD"] = "Aggiungi",
		["REMOVE"] = "Rimuovi",
		["RENAME"] = "Rinomina",
		["PLAYER"] = "Player",
		["DOWNLOAD"] = "Scarica",
		["UPLOAD"] = "Carica",
		["STATUS"] = "Stato",
		["DONE"] = "Fatto",
		["WAITINGFOROWNER"] = "In attesa del proprietario",
		["WAITFORPLAYERPROFILE"] = "Attendere che l'altro giocatore prema \"Ottieni profili\"",
		["WAITFORPLAYERPROFILE2"] = "Attendere che l'altro giocatore prema \"Condividi\"",

		["ALPHAINCOMBAT"] = "Alfa (in combattimento)",
		["ALPHANOTINCOMBAT"] = "Alfa (non in combattimento)",
		["ALPHAINVEHICLE"] = "Alfa (in veicolo)",

		["MABUFFLIMIT"] = "Limite Buff",
		["MABUFFSPACINGX"] = "Spaziatura orizzontale dei buffer",
		["MABUFFSPACINGY"] = "Spaziatura buffer verticale",
	}

	MoveAny:UpdateLanguageTab( tab )
end
