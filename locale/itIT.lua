-- itIT Italien
local _, MoveAny = ...

function MoveAny:LangitIT()
    local tab = {
        ["LID_MMBTNLEFT"] = "Click sinistro => Blocca/Sblocca + Opzioni",
        ["LID_MMBTNRIGHT"] = "Maiusc + clic destro => Nascondi pulsante Minimap",
        ["LID_GENERAL"] = "Generale",
        ["LID_SHOWMINIMAPBUTTON"] = "Mostra pulsante Minimap",
        ["LID_GRIDSIZE"] = "Gridsize",
        ["LID_MOVEFRAMES"] = "Sposta fotogrammi/finestre",
        ["LID_FRAMESSHIFTDRAG"] = "Sposta fotogramma con Maiusc + trascinamento con il tasto sinistro del mouse",
        ["LID_FRAMESSHIFTSCALE"] = "Scala il fotogramma con Maiusc + trascinamento con il tasto destro del mouse",
        ["LID_FRAMESSHIFTRESET"] = "Azzeramento del riquadro con Shift + clic della rotella del mouse",
        ["LID_PLAYERFRAME"] = "Riquadro giocatore",
        ["LID_PETFRAME"] = "Cornice animale domestico",
        ["LID_TARGETFRAME"] = "Cornice obiettivo",
        ["LID_TARGETOFTARGETFRAME"] = "Cornice di destinazione",
        ["LID_TARGETFRAMESPELLBAR"] = "Castbar del bersaglio",
        ["LID_FOCUSFRAME"] = "Cornice di messa a fuoco",
        ["LID_FOCUSFRAMESPELLBAR"] = "Barra di cast da Focus",
        ["LID_TARGETOFFOCUSFRAME"] = "Riquadro di destinazione del fuoco",
        ["LID_RUNEFRAME"] = "Cornice delle rune del Cavaliere della Morte",
        ["LID_TOTEMFRAME"] = "Totem Timers",
        ["LID_WARLOCKPOWERFRAME"] = "Quadro del potere dello stregone",
        ["LID_MONKHARMONYBARFRAME"] = "Cornice dell'armonia del monaco",
        ["LID_MAGEARCANECHARGESFRAME"] = "Cornice delle cariche arcane del mago",
        ["LID_ESSENCEPLAYERFRAME"] = "Cornice del giocatore d'essenza (evocatore)",
        ["LID_MAFPSFrame"] = "FPS",
        ["LID_MINIMAP"] = "Mini mappa",
        ["LID_BUFFS"] = "Buffs",
        ["LID_DEBUFFS"] = "Debuff",
        ["LID_VEHICLESEATINDICATOR"] = "Indicatore del sedile del veicolo",
        ["LID_ARENAENEMYFRAMES"] = "Cornici nemiche dell'Arena",
        ["LID_ARENAPREPFRAMES"] = "Cornici di preparazione dell'Arena",
        ["LID_QUESTTRACKER"] = "Questtracker",
        ["LID_MICROMENU"] = "Micro Menu",
        ["LID_BAGS"] = "Bags",
        ["LID_GAMETOOLTIP"] = "Tooltip",
        ["LID_GAMETOOLTIP_ONCURSOR"] = "Tooltip sul cursore",
        ["LID_QUEUESTATUSBUTTON"] = "Stato LFG",
        ["LID_PETBAR"] = "Barra degli animali domestici",
        ["LID_STANCEBAR"] = "Stance Bar",
        ["LID_TOTEMBAR"] = "Barra Totem Sciamano",
        ["LID_LEAVEVEHICLE"] = "Pulsante di uscita dal veicolo",
        ["LID_GROUPLOOTCONTAINER"] = "Cornice del rotolo di bottino",
        ["LID_STATUSTRACKINGBARMANAGER"] = "Gestore della barra di monitoraggio dello stato (XP, Reputazione)",
        ["LID_ALERTFRAME"] = "Riquadro degli avvisi (bottino bonus, successi, ...)",
        ["LID_CHAT"] = "Chatframe %d",
        ["LID_CHATBUTTONFRAME"] = "Pulsanti di chat",
        ["LID_CHATQUICKJOIN"] = "Partecipazione rapida alla chat",
        ["LID_CHATEDITBOX"] = "Chat Inputbox",
        ["LID_COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",
        ["LID_BNToastFrame"] = "Notifiche amici Battlenet",
        ["LID_ZONETEXTFRAME"] = "Testo zona",
        ["LID_UIWIDGETTOPCENTER"] = "Widget Top Center (Stato su BG/Dungeon)",
        ["LID_IASKILLS"] = "Barre delle abilità",
        ["LID_UIWIDGETBELOWMINIMAP"] = "Widget sotto la minimappa (stato di cattura)",
        ["LID_DURABILITY"] = "Bambola della durata",
        ["LID_MONEYBAR"] = "Barra del denaro",
        ["LID_TOKENBAR"] = "Barra dei gettoni",
        ["LID_IAILVLBAR"] = "Barra livello articolo",
        ["LID_CASTINGBAR"] = "Barra dei lanci",
        ["LID_TALKINGHEAD"] = "Dialogo testa parlante",
        ["LID_POSSESSBAR"] = "Barra del possesso (controllo PNG/veicolo)",
        ["LID_ZONEABILITYFRAME"] = "Capacità di zona",
        ["LID_EXTRAABILITYCONTAINER"] = "Capacità extra",
        ["LID_MAINMENUEXPBAR"] = "Barra Exp",
        ["LID_REPUTATIONWATCHBAR"] = "Barra della reputazione",
        ["LID_UIWIDGETPOWERBAR"] = "Barra del potere",
        ["LID_ROWS"] = "Righe",
        ["LID_SPACING"] = "Spaziatura",
        ["LID_PROFILE"] = "Profilo",
        ["LID_PROFILES"] = "Profili",
        ["LID_ADDPROFILE"] = "Aggiungi profilo",
        ["LID_CURRENT"] = "Current",
        ["LID_SHARE"] = "Condividi",
        ["LID_SHAREPROFILE"] = "Profilo condiviso",
        ["LID_GETPROFILE"] = "Ottieni profilo",
        ["LID_INHERITFROM"] = "Eredita da",
        ["LID_ADD"] = "Aggiungi",
        ["LID_REMOVE"] = "Rimuovi",
        ["LID_RENAME"] = "Rinomina",
        ["LID_PLAYER"] = "Player",
        ["LID_DOWNLOAD"] = "Scarica",
        ["LID_UPLOAD"] = "Carica",
        ["LID_STATUS"] = "Stato",
        ["LID_DONE"] = "Fatto",
        ["LID_WAITINGFOROWNER"] = "In attesa del proprietario",
        ["LID_WAITFORPLAYERPROFILE"] = "Attendere che l'altro giocatore prema \"Ottieni profili\"",
        ["LID_WAITFORPLAYERPROFILE2"] = "Attendere che l'altro giocatore prema \"Condividi\"",
        ["LID_ALPHAINCOMBAT"] = "Alfa (in combattimento)",
        ["LID_ALPHANOTINCOMBAT"] = "Alfa (non in combattimento)",
        ["LID_ALPHAINVEHICLE"] = "Alfa (in veicolo)",
        ["LID_MABUFFLIMIT"] = "Limite Buff",
        ["LID_MABUFFSPACINGX"] = "Spaziatura orizzontale dei buffer",
        ["LID_MABUFFSPACINGY"] = "Spaziatura buffer verticale",
        ["LID_ISENABLEDINEDITMODE"] = "(Disabilita in EditMode)",
        ["LID_CANBREAKBECAUSEOFEDITMODE"] = "(Può causare errori dovuti alla modalità di modifica)",
        ["LID_HELPTEXT"] = "\"%s\" è già abilitato in EditMode. Si prega di disattivare la modalità di modifica o MoveAny.",
        ["LID_BUILTIN"] = "Integrato",
        ["LID_EDITMODE"] = "Modalità di modifica sovrascritta",
        ["LID_NORMAL"] = "Normal",
        ["LID_CLASSSPECIFIC"] = "Classe specifica",
        ["LID_ADVANCED"] = "Avanzato",
        ["LID_ImproveAny"] = "ImproveAny",
        ["LID_MISSINGREQUIREMENT"] = "Casella di controllo mancante: %s",
        ["LID_ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Barra di avanzamento del sito archeologico",
        ["LID_UIERRORSFRAME"] = "Messaggi di errore dell'interfaccia utente, avanzamento della ricerca",
        ["LID_COMBOPOINTPLAYERFRAME"] = "Punti combo",
        ["LID_PARTYFRAME"] = "Cornice del partito",
        ["LID_PARTYMEMBERFRAME"] = "Cornice membro del partito %s",
        ["LID_BOSSTARGETFRAMECONTAINER"] = "Cornice del boss",
        ["LID_FLIPPED"] = "Capovolto",
        ["LID_GHOSTFRAME"] = "Cornice fantasma (teletrasporto al cimitero)",
        ["LID_TICKETSTATUSFRAME"] = "Cornice biglietto",
        ["LID_LOSSOFCONTROLFRAME"] = "Quadro di perdita di controllo",
        ["LID_MainStatusTrackingBarContainer"] = "Barra Exp",
        ["LID_SecondaryStatusTrackingBarContainer"] = "Barra della reputazione",
        ["LID_TargetFrameNumericalThreat"] = "Percentuale di minaccia",
    }

    if MoveAny:GetWoWBuild() ~= "RETAIL" then
        tab["LID_ACTIONBARS"] = "Barra d'azioni 1 + 5 + 6"
        tab["LID_ACTIONBAR1"] = "Barra d'azioni 1 (barra principale)"
        tab["LID_ACTIONBAR2"] = "Barra d'azioni 2 (2. Pagina della barra d'azioni 1)"
        tab["LID_ACTIONBAR3"] = "Barra d'azione 3 (barra destra)"
        tab["LID_ACTIONBAR4"] = "Barra d'azione 4 (barra sinistra)"
        tab["LID_ACTIONBAR5"] = "Barra d'azione 5 (barra superiore destra)"
        tab["LID_ACTIONBAR6"] = "Barra d'azione 6 (barra in alto a sinistra)"
        tab["LID_ACTIONBAR7"] = "Barra d'azione 7 (personalizzata)"
        tab["LID_ACTIONBAR8"] = "Barra d'azione 8 (personalizzata)"
        tab["LID_ACTIONBAR9"] = "Barra d'azione 9 (personalizzata)"
        tab["LID_ACTIONBAR10"] = "Barra d'azioni 10 (personalizzata)"
    else
        tab["LID_ACTIONBAR1"] = "Barra d'azioni 1 (barra principale)"
        tab["LID_ACTIONBAR2"] = "Barra d'azioni 2 (sopra la barra principale)"
        tab["LID_ACTIONBAR3"] = "Barra d'azione 3 (sopra la seconda barra)"
        tab["LID_ACTIONBAR4"] = "Barra d'azione 4 (barra destra)"
        tab["LID_ACTIONBAR5"] = "Barra d'azione 5 (barra sinistra)"
        tab["LID_ACTIONBAR6"] = "Barra d'azione 6"
        tab["LID_ACTIONBAR7"] = "Barra d'azione 7"
        tab["LID_ACTIONBAR8"] = "Barra d'azione 8"
    end

    MoveAny:UpdateLanguageTab(tab)
end