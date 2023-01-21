-- ptBR Brazilian Portuguese

local AddOnName, MoveAny = ...

function MoveAny:LangptBR()
	local tab = {
		["MMBTNLEFT"] = "Clique esquerdo => Bloqueios/Desbloqueio + Opções",
		["MMBTNRIGHT"] = "Shift + Right Click => Hide Minimap Button",

		["GERAL"] = "Geral",
		["SHOWMINIMAPBUTTON"] = "Show Minimap Button",
		["GRIDSIZE"] = "Gridsize",
		["MOVEFRAMES"] = "Move Frames/Windows",
		["FRAMESSHIFTDRAG"] = "Move Frame with Shift + Leftclick-drag",
		["FRAMESSHIFTSCALE"] = "Balança com Turno + Arrastar com o Botão Direito",
		["FRAMESSHIFTRESET"] = "Reset Frame with Shift + Mousewheelclick-drag",

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
		["TOTEMFRAME"] = "Totem Timers",
		["WARLOCKPOWERFRAME"] = "Warlock Power frame",
		["MONKHARMONYBARFRAME"] = "Monk Harmony frame",
		["MAGEARCANECHARGESFRAME"] = "Mage Arcane Charges frame",
		["ESSENCEPLAYERFRAME"] = "Essence Player Frame (Evoker)",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "Top",

		["TOPRIGHT"] = "Top Right",
		["MINIMAP"] = "Mini Mapa",
		["BUFFS"] = "Buffs",
		["DEBUFFS"] = "Debuffs",
		["VEHICLESEATINDICATOR"] = "Vehicle Seat Indicator",
		["ARENAENEMYFRAMES"] = "Arena Enemy Frames",
		["ARENAPREPFRAMES"] = "Arena Prep Frames",
		["QUESTTRACKER"] = "Questtracker",

		["DIREITO"] = "Certo",
	
		["BOTTOMRIGHT"] = "Bottom Right",
		["MICROMENU"] = "Micro Menu",
		["BAGS"] = "Bags",
		["GAMETOOLTIP"] = "Tooltip",
		["GAMETOOLTIP_ONCURSOR"] = "Tooltip on Cursor",
		["QUEUESTATUSBUTTON"] = "LFG Status",

		["BOTTOM"] = "Bottom",
		["ACTIONBARS"] = "Actionbars 1-6",
		["ACTIONBAR7"] = "Barras de Ação Personalizadas 7",
		["ACTIONBAR8"] = "Barras de Ação Personalizadas 8",
		["ACTIONBAR9"] = "Barras de Ação Personalizadas 9",
		["ACTIONBAR10"] = "Barras de Ação Personalizadas 10",
		["PETBAR"] = "Pet Bar",
		["STANCEBAR"] = "Stance Bar",
		["TOTEMBAR"] = "Shaman - Barra Totem",
		["LEAVEVEHICLE"] = "Leave Vehicle Button",
		["GROUPLOOTCONTAINER"] = "Loot Roll frame",
		["STATUSTRACKINGBARMANAGER"] = "Status Tracking Bar Manager (XP, Reputation)",
		["ALERTFRAME"] = "Alert Frame (Bonus Loot, Achiements, ...)",

		["BOTTOMLEFT"] = "Bottom Left",
		["CHAT"] = "Chatframe %d",
		["CHATBUTTONFRAME"] = "Botões de Chat",
		["CHATQUICKJOIN"] = "Chat Quick Join",
		["CHATEDITBOX"] = "Chat Inputbox",

		["ESQUERDA"] = "Esquerda",
		["COMPACTRAIDFRAMEMANAGER"] = "Gerente de Raid",
		["BNToastFrame"] = "Battlenet Friends Notifications",



		["ZONETEXTFRAME"] = "Texto da zona",
		["UIWIDGETTOPCENTER"] = "Widget Top Center (Status on BGs/Dungeons)",
		["IASKILLS"] = "Skillbars",
		["UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (Capture Status)",
		["DURABILIDADE"] = "Boneca de Durabilidade",
		["MONEYBAR"] = "Money Bar",
		["TOKENBAR"] = "Token Bar",
		["IAILVLBAR"] = "ItemLevel Bar",
		["CASTINGBAR"] = "Casting Bar",
		["TALKINGHEAD"] = "Talking Head Dialog",
		["ACTIONBAR1"] = "Barra de ação 1 (Barra principal)",
		["ACTIONBAR2"] = "Barra de ação 2 (2. Página da barra de ação 1)",
		["ACTIONBAR3"] = "Barra de ação 3 (Barra direita)",
		["ACTIONBAR4"] = "Barra de Ação 4 (Barra Esquerda)",
		["ACTIONBAR5"] = "Barra de ação 5 (Barra superior direita)",
		["ACTIONBAR6"] = "Barra de ação 6 (Barra superior esquerda)",
		["POSSESSBAR"] = "Possess Bar (Controlling NPC/Vehicle)",
		["ZONEABILITYFRAME"] = "Zone Ability",
		["EXTRAABILITYCONTAINER"] = "Extra Ability (Capacidade Extra)",
		["MAINMENUEXPBAR"] = "Exp Bar",
		["REPUTATIONWATCHBAR"] = "Barra de Reputação",
		["UIWIDGETPOWERBAR"] = "Barra de alimentação",

		["ROWS"] = "Linhas",
		["SPACING"] = "Espaçamento",
		
		

		["PERFIL"] = "Perfil",
		["PERFILES"] = "Profiles",
		["ADDPROFILE"] = "Adicionar Perfil",
		["CORRENTE"] = "Atual",
		["SHARE"] = "Compartilhar",
		["SHAREPROFILE"] = "Share Profile",
		["GETPROFILE"] = "Get Profile",
		["INHERITFROM"] = "Herdar de",
		["ADD"] = "Adicionar",
		["REMOVER"] = "Remover",
		["RENAME"] = "Renomear",
		["PLAYER"] = "Jogador",
		["DOWNLOAD"] = "Download",
		["UPLOAD"] = "Upload",
		["STATUS"] = "Status",
		["FEITO"] = "Feito",
		["ESPERANDO DO PROPRIETÁRIO"] = "Esperando pelo Proprietário",
		["WAITFORPLAYERPROFILE"] = "Aguarde que outro jogador pressione \"Obter Perfis\"",
		["WAITFORPLAYERPROFILE2"] = "Aguarde que outro jogador pressione \"Compartilhe\"",

		["ALPHAINCOMBAT"] = "Alpha (in Combat)",
		["ALPHANOTINCOMBAT"] = "Alpha (não em Combate)",
		["ALPHAINVEHICLE"] = "Alfa (no veículo)",

		["MABUFFLIMIT"] = "Buff limit",
		["MABUFFSPACINGX"] = "Buff Spacing Horizontal",
		["MABUFFSPACINGY"] = "Buff Spacing Vertical",
	}

	MoveAny:UpdateLanguageTab( tab )
end
