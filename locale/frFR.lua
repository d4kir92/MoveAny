-- frFR French

local AddOnName, MoveAny = ...

function MoveAny:LangfrFR()
	local tab = {
		["MMBTNLEFT"] = "Clic gauche => Verrouillage/Déverrouillage + Options",
		["MMBTNRIGHT"] = "Shift + Clic droit => Bouton Masquer la Minimap",

		["GENERAL"] = "Général",
		["SHOWMINIMAPBUTTON"] = "Afficher le bouton de Minimap",
		["GRIDSIZE"] = "Taille de la grille",
		["MOVEFRAMES"] = "Déplacer les cadres/fenêtres",
		["FRAMESSHIFTDRAG"] = "Déplacer le cadre avec Shift + clic gauche-glisser",
		["FRAMESSHIFTSCALE"] = "Mettre à l'échelle le cadre avec Shift + clic-droit-glisser",
		["FRAMESSHIFTRESET"] = "Réinitialiser le cadre avec Shift + Mousewheelclick-drag",

		["TOPLEFT"] = "En haut à gauche",
		["PLAYERFRAME"] = "Cadre du joueur",
		["PETFRAME"] = "Cadre de l'animal",
		["TARGETFRAME"] = "Cadre de la cible",
		["TARGETOFTARGETFRAME"] = "Cible du cadre cible",
		["TARGETFRAMESPELLBAR"] = "Castbar de la cible",
		["FOCUSFRAME"] = "Cadre de mise au point",
		["FOCUSFRAMESPELLBAR"] = "Barre de rayon de la cible",
		["TARGETOFFOCUSFRAME"] = "Cible du cadre de mise au point",
		["RUNEFRAME"] = "Deathknight - Runes Frame",
		["TOTEMFRAME"] = "Totem Timers",
		["WARLOCKPOWERFRAME"] = "Cadre des pouvoirs du sorcier",
		["MONKHARMONYBARFRAME"] = "Cadre Harmonie du moine",
		["MAGEARCANECHARGESFRAME"] = "Cadre des charges arcaniques du mage",
		["ESSENCEPLAYERFRAME"] = "Cadre de joueur d'essence (Evoker)",
		["MAFPSFrame"] = "Cadre FPS",

		["TOP"] = "Top",

		["TOPRIGHT"] = "En haut à droite",
		["MINIMAP"] = "Mini Carte",
		["BUFFS"] = "Buffs",
		["DEBUFFS"] = "Débuffs",
		["VEHICLESEATINDICATOR"] = "Indicateur de siège de véhicule",
		["ARENAENEMYFRAMES"] = "Images d'ennemis d'arène",
		["ARENAPREPFRAMES"] = "Cadres de préparation d'arène",
		["QUESTTRACKER"] = "Questtracker",

		["RIGHT"] = "Right",
	
		["BOTTOMRIGHT"] = "En bas à droite",
		["MICROMENU"] = "Micro Menu",
		["BAGS"] = "Bags",
		["GAMETOOLTIP"] = "Tooltip",
		["GAMETOOLTIP_ONCURSOR"] = "Tooltip on Cursor",
		["QUEUESTATUSBUTTON"] = "Statut LFG",

		["BOTTOM"] = "Bottom",
		["ACTIONBARS"] = "Barres d'action 1-6",
		["ACTIONBAR7"] = "Barres d'actions personnalisées 7",
		["ACTIONBAR8"] = "Barres d'actions personnalisées 8",
		["ACTIONBAR9"] = "Barres d'action personnalisées 9",
		["ACTIONBAR10"] = "Barres d'action personnalisées 10",
		["PETBAR"] = "Pet Bar",
		["STANCEBAR"] = "Stance Bar",
		["TOTEMBAR"] = "Shaman - Totem Bar",
		["LEAVEVEHICLE"] = "Bouton quitter le véhicule",
		["CONTENEUR DE LOTS DE GROUPE"] = "Cadre de rouleau de butin",
		["STATUSTRACKINGBARMANAGER"] = "Gestionnaire de barre de suivi de statut (XP, Réputation)",
		["ALERTFRAME"] = "Cadre d'alerte (Bonus Loot, Achiements, ...)",

		["BOTTOMLEFT"] = "En bas à gauche",
		["CHAT"] = "Cadre de chat %d",
		["CHATBUTTONFRAME"] = "Boutons de chat",
		["CHATQUICKJOIN"] = "Participation rapide au chat",
		["CHATEDITBOX"] = "Boîte de saisie du chat",

		["LEFT"] = "Left",
		["COMPACTRAIDFRAMEMANAGER"] = "Raid Manager",
		["BATTLENETFRIENDSNOTIFICATION"] = "Notifications des amis Battlenet",



		["ZONETEXTFRAME"] = "Texte de la zone",
		["UIWIDGETTOPCENTER"] = "Widget Top Center (Statut sur BGs/Dungeons)",
		["IASKILLS"] = "Barres de compétences",
		["UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (État des captures)",
		["DURABILITY"] = "Poupée de durabilité",
		["MONEYBAR"] = "Money Bar",
		["TOKENBAR"] = "Token Bar",
		["IAILVLBAR"] = "Barre de niveau d'objet",
		["CASTINGBAR"] = "Casting Bar",
		["TALKINGHEAD"] = "Dialogue de la tête parlante",
		["ACTIONBAR1"] = "Actionbar 1 (Main Bar)",
		["ACTIONBAR2"] = "Actionbar 2 (2. Page of Actionbar 1)",
		["ACTIONBAR3"] = "Barre d'action 3 (Barre de droite)",
		["ACTIONBAR4"] = "Barre d'action 4 (barre de gauche)",
		["ACTIONBAR5"] = "Barre d'action 5 (barre supérieure droite)",
		["ACTIONBAR6"] = "Barre d'action 6 (barre supérieure gauche)",
		["POSSESSBAR"] = "Barre de possession (contrôle d'un PNJ/véhicule)",
		["ZONEABILITYFRAME"] = "Capacité de zone",
		["EXTRAABILITYCONTAINER"] = "Capacité supplémentaire",
		["MAINMENUEXPBAR"] = "Barre d'exp",
		["REPUTATIONWATCHBAR"] = "Barre de Réputation",
		["UIWIDGETPOWERBAR"] = "Barre de puissance",

		["ROWS"] = "Rows",
		["SPACING"] = "Espacement",
		
		

		["PROFIL"] = "Profil",
		["PROFILES"] = "Profils",
		["ADDPROFILE"] = "Ajouter un profil",
		["CURRENT"] = "Actuel",
		["PARTAGE"] = "Partage",
		["SHAREPROFILE"] = "Profil de partage",
		["GETPROFILE"] = "Obtenir un profil",
		["INHERITFROM"] = "Hériter de",
		["ADD"] = "Ajouter",
		["REMOVE"] = "Supprimer",
		["RENAME"] = "Renommer",
		["PLAYER"] = "Player",
		["TELECHARGER"] = "Télécharger",
		["UPLOAD"] = "Upload",
		["STATUS"] = "Statut",
		["DONE"] = "Done",
		["WAITINGFOROWNER"] = "En attente du propriétaire",
		["WAITFORPLAYERPROFILE"] = "Attend que l'autre joueur appuie sur \"Get Profiles\".",
		["WAITFORPLAYERPROFILE2"] = "Attend que l'autre joueur appuie sur \"Partager\".",

		["ALPHAINCOMBAT"] = "Alpha (en combat)",
		["ALPHANOTINCOMBAT"] = "Alpha (pas en combat)",
		["ALPHAINVEHICLE"] = "Alpha (en véhicule)",

		["MABUFFLIMIT"] = "Buff limit",
		["MABUFFSPACINGX"] = "Espacement horizontal des buffs",
		["MABUFFSPACINGY"] = "Espacement vertical du tampon",
		["ISENABLEDINEDITMODE"] = "(Is Enabled in Edit Mode)",
	}

	MoveAny:UpdateLanguageTab( tab )
end
