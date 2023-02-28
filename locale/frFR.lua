-- frFR French

local AddOnName, MoveAny = ...

function MoveAny:LangfrFR()
	local tab = {
		["LID_MMBTNLEFT"] = "Clic gauche => Verrouillage/Déverrouillage + Options",
		["LID_MMBTNRIGHT"] = "Shift + Clic droit => Bouton Masquer la Minimap",

		["LID_GENERAL"] = "Général",
		["LID_SHOWMINIMAPBUTTON"] = "Afficher le bouton de Minimap",
		["LID_GRIDSIZE"] = "Taille de la grille",
		["LID_MOVEFRAMES"] = "Déplacer les cadres/fenêtres",
		["LID_FRAMESSHIFTDRAG"] = "Déplacer le cadre avec Shift + clic gauche-glisser",
		["LID_FRAMESSHIFTSCALE"] = "Mettre à l'échelle le cadre avec Shift + clic-droit-glisser",
		["LID_FRAMESSHIFTRESET"] = "Réinitialiser le cadre avec Shift + Mousewheelclick-drag",

		["LID_PLAYERFRAME"] = "Cadre du joueur",
		["LID_PETFRAME"] = "Cadre de l'animal",
		["LID_TARGETFRAME"] = "Cadre de la cible",
		["LID_TARGETOFTARGETFRAME"] = "Cible du cadre cible",
		["LID_TARGETFRAMESPELLBAR"] = "Castbar de la cible",
		["LID_FOCUSFRAME"] = "Cadre de mise au point",
		["LID_FOCUSFRAMESPELLBAR"] = "Barre de rayon de la cible",
		["LID_TARGETOFFOCUSFRAME"] = "Cible du cadre de mise au point",
		["LID_RUNEFRAME"] = "Deathknight - Runes Frame",
		["LID_TOTEMFRAME"] = "Totem Timers",
		["LID_WARLOCKPOWERFRAME"] = "Cadre des pouvoirs du sorcier",
		["LID_MONKHARMONYBARFRAME"] = "Cadre Harmonie du moine",
		["LID_MAGEARCANECHARGESFRAME"] = "Cadre des charges arcaniques du mage",
		["LID_ESSENCEPLAYERFRAME"] = "Cadre de joueur d'essence (Evoker)",
		["LID_MAFPSFrame"] = "Cadre FPS",

		["LID_MINIMAP"] = "Mini Carte",
		["LID_BUFFS"] = "Buffs",
		["LID_DEBUFFS"] = "Débuffs",
		["LID_VEHICLESEATINDICATOR"] = "Indicateur de siège de véhicule",
		["LID_ARENAENEMYFRAMES"] = "Images d'ennemis d'arène",
		["LID_ARENAPREPFRAMES"] = "Cadres de préparation d'arène",
		["LID_QUESTTRACKER"] = "Questtracker",

		["LID_MICROMENU"] = "Micro Menu",
		["LID_BAGS"] = "Bags",
		["LID_GAMETOOLTIP"] = "Tooltip",
		["LID_GAMETOOLTIP_ONCURSOR"] = "Tooltip on Cursor",
		["LID_QUEUESTATUSBUTTON"] = "Statut LFG",

		
		["LID_PETBAR"] = "Pet Bar",
		["LID_STANCEBAR"] = "Stance Bar",
		["LID_TOTEMBAR"] = "Shaman - Totem Bar",
		["LID_LEAVEVEHICLE"] = "Bouton quitter le véhicule",
		["LID_GROUPLOOTCONTAINER"] = "Cadre de rouleau de butin",
		["LID_STATUSTRACKINGBARMANAGER"] = "Gestionnaire de barre de suivi de statut (XP, Réputation)",
		["LID_ALERTFRAME"] = "Cadre d'alerte (Bonus Loot, Achiements, ...)",

		["LID_CHAT"] = "Cadre de chat %d",
		["LID_CHATBUTTONFRAME"] = "Boutons de chat",
		["LID_CHATQUICKJOIN"] = "Participation rapide au chat",
		["LID_CHATEDITBOX"] = "Boîte de saisie du chat",

		
		["LID_COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",
		["LID_BNToastFrame"] = "Notifications des amis Battlenet",

		["LID_ZONETEXTFRAME"] = "Texte de la zone",
		["LID_UIWIDGETTOPCENTER"] = "Widget Top Center (Statut sur BGs/Dungeons)",
		["LID_IASKILLS"] = "Barres de compétences",
		["LID_UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (État des captures)",
		["LID_DURABILITY"] = "Poupée de durabilité",
		["LID_MONEYBAR"] = "Money Bar",
		["LID_TOKENBAR"] = "Token Bar",
		["LID_IAILVLBAR"] = "Barre de niveau d'objet",
		["LID_CASTINGBAR"] = "Casting Bar",
		["LID_TALKINGHEAD"] = "Dialogue de la tête parlante",
		["LID_POSSESSBAR"] = "Barre de possession (contrôle d'un PNJ/véhicule)",
		["LID_ZONEABILITYFRAME"] = "Capacité de zone",
		["LID_EXTRAABILITYCONTAINER"] = "Capacité supplémentaire",
		["LID_MAINMENUEXPBAR"] = "Barre d'exp",
		["LID_REPUTATIONWATCHBAR"] = "Barre de Réputation",
		["LID_UIWIDGETPOWERBAR"] = "Barre de puissance",

		["LID_ROWS"] = "Rows",
		["LID_SPACING"] = "Espacement",

		["LID_PROFILE"] = "Profil",
		["LID_PROFILES"] = "Profils",
		["LID_ADDPROFILE"] = "Ajouter un profil",
		["LID_CURRENT"] = "Actuel",
		["LID_SHARE"] = "Partage",
		["LID_SHAREPROFILE"] = "Profil de partage",
		["LID_GETPROFILE"] = "Obtenir un profil",
		["LID_INHERITFROM"] = "Hériter de",
		["LID_ADD"] = "Ajouter",
		["LID_REMOVE"] = "Supprimer",
		["LID_RENAME"] = "Renommer",
		["LID_PLAYER"] = "Player",
		["LID_DOWNLOAD"] = "Télécharger",
		["LID_UPLOAD"] = "Upload",
		["LID_STATUS"] = "Statut",
		["LID_DONE"] = "Done",
		["LID_WAITINGFOROWNER"] = "En attente du propriétaire",
		["LID_WAITFORPLAYERPROFILE"] = "Attend que l'autre joueur appuie sur \"Get Profiles\".",
		["LID_WAITFORPLAYERPROFILE2"] = "Attend que l'autre joueur appuie sur \"Partager\".",

		["LID_ALPHAINCOMBAT"] = "Alpha (en combat)",
		["LID_ALPHANOTINCOMBAT"] = "Alpha (pas en combat)",
		["LID_ALPHAINVEHICLE"] = "Alpha (en véhicule)",

		["LID_MABUFFLIMIT"] = "Buff limit",
		["LID_MABUFFSPACINGX"] = "Espacement horizontal des buffs",
		["LID_MABUFFSPACINGY"] = "Espacement vertical du tampon",

		["LID_ISENABLEDINEDITMODE"] = "(Désactivez-le en EditMode)",
		["LID_CANBREAKBECAUSEOFEDITMODE"] = "(Peut provoquer une erreur due au mode d'édition)",

		["LID_HELPTEXT"] = "\"%s\" est déjà activé en EditMode. Veuillez le désactiver en EditMode ou MoveAny.",
	
		["LID_BUILTIN"] = "Built-In",
		["LID_EDITMODE"] = "Mode d'édition par écrasement",
		["LID_NORMAL"] = "Normal",
		["LID_CLASSSPECIFIC"] = "Classe spécifique",
		["LID_ADVANCED"] = "Avancé",
		["LID_ImproveAny"] = "ImproveAny",

		["LID_MISSINGREQUIREMENT"] = "Case à cocher manquante : %s",
		["LID_ARCHEOLOGYDIGSITEPROGRESSBAR"] = "Barre de progression du site de fouilles archéologiques",
		["LID_UIERRORSFRAME"] = "Messages d'erreur de l'interface utilisateur, progression de la quête",
		["LID_COMBOPOINTPLAYERFRAME"] = "Points de combo",

		["LID_PARTYFRAME"] = "Cadre de la fête",
		["LID_PARTYMEMBERFRAME"] = "Cadre de membre du groupe %s",
		["LID_BOSSTARGETFRAMECONTAINER"] = "Cadres de Boss",

		["LID_FLIPPED"] = "Renversé",
		["LID_GHOSTFRAME"] = "Cadre fantôme (téléportation au cimetière)",
		["LID_TICKETSTATUSFRAME"] = "Cadre des tickets",
		["LID_LOSSOFCONTROLFRAME"] = "Cadre de perte de contrôle",

		["LID_MainStatusTrackingBarContainer"] = "Barre de contrôle",
		["LID_SecondaryStatusTrackingBarContainer"] = "Barre de réputation",

		["LID_TargetFrameNumericalThreat"] = "Pourcentage de menace",
	}

	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		tab["LID_ACTIONBARS"] = "Barre d'action 1 + 5 + 6"
		tab["LID_ACTIONBAR1"] = "Barre d'action 1 (Barre principale)"
		tab["LID_ACTIONBAR2"] = "Barre d'action 2 (2. Page of Barre d'action 1)"
		tab["LID_ACTIONBAR3"] = "Barre d'action 3 (Barre de droite)"
		tab["LID_ACTIONBAR4"] = "Barre d'action 4 (Barre de gauche)"
		tab["LID_ACTIONBAR5"] = "Barre d'action 5 (Barre supérieure droite)"
		tab["LID_ACTIONBAR6"] = "Barre d'action 6 (barre supérieure gauche)"
		tab["LID_ACTIONBAR7"] = "Barre d'action 7 (personnalisée)"
		tab["LID_ACTIONBAR8"] = "Barre d'action 8 (personnalisée)"
		tab["LID_ACTIONBAR9"] = "Barre d'action 9 (personnalisée)"
		tab["LID_ACTIONBAR10"] = "Barre d'action 10 (personnalisée)"
	else
		tab["LID_ACTIONBAR1"] = "Barre d'action 1 (barre principale)"
		tab["LID_ACTIONBAR2"] = "Barre d'action 2 (au dessus de la barre principale)"
		tab["LID_ACTIONBAR3"] = "Barre d'action 3 (Au-dessus de la deuxième barre)"
		tab["LID_ACTIONBAR4"] = "Barre d'action 4 (barre de droite)"
		tab["LID_ACTIONBAR5"] = "Barre d'action 5 (barre de gauche)"
		tab["LID_ACTIONBAR6"] = "Barre d'action 6"
		tab["LID_ACTIONBAR7"] = "Barre d'action 7 (barre d'action 7)"
		tab["LID_ACTIONBAR8"] = "Barre d'actions 8"
	end

	MoveAny:UpdateLanguageTab( tab )
end
