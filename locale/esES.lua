-- esES Spanish

local AddOnName, MoveAny = ...

function MoveAny:LangesES()
	local tab = {
		["MMBTNLEFT"] = "Clic izquierdo => Bloquear/Desbloquear + Opciones",
		["MMBTNRIGHT"] = "Mayúsculas + Clic derecho => Ocultar botón del minimapa",

		["GENERAL"] = "General",
		["SHOWMINIMAPBUTTON"] = "Mostrar el botón del mapa mínimo",
		["GRIDSIZE"] = "Tamaño de la cuadrícula",
		["MOVEFRAMES"] = "Mover cuadros/ventanas",
		["FRAMESSHIFTDRAG"] = "Mover marco con Shift + arrastrar con el botón izquierdo",
		["FRAMESSHIFTSCALE"] = "Escalar el marco con Shift + arrastrar con el botón derecho",
		["FRAMESSHIFTRESET"] = "Restablecer el marco con Mayúsculas + arrastrar con la rueda del ratón",

		["TOPLEFT"] = "Parte superior izquierda",
		["PLAYERFRAME"] = "Marco del jugador",
		["PETFRAME"] = "Marco de la mascota",
		["TARGETFRAME"] = "Marco del objetivo",
		["TARGETOFTARGETFRAME"] = "Marco del objetivo",
		["TARGETFRAMESPELLBAR"] = "Barra de colada del objetivo",
		["FOCUSFRAME"] = "Marco de enfoque",
		["FOCUSFRAMESPELLBAR"] = "Barra de fundición del foco",
		["TARGETOFFOCUSFRAME"] = "Objetivo del marco de enfoque",
		["RUNEFRAME"] = "Marco del Caballero de la Muerte - Runas",
		["TOTEMFRAME"] = "Marco de Tótems",
		["WARLOCKPOWERFRAME"] = "Marco de Poder del Brujo",
		["MONKHARMONYBARFRAME"] = "Marco de Armonía del Monje",
		["MAGEARCANECHARGESFRAME"] = "Marco de carga arcana del mago",
		["ESSENCEPLAYERFRAME"] = "Marco de jugador de esencia (evocador)",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "Top",

		["TOPRIGHT"] = "Superior derecha",
		["MINIMAP"] = "Mini Mapa",
		["BUFFS"] = "Buffs",
		["DEBUFFS"] = "Debuffs",
		["VEHICLESEATINDICATOR"] = "Indicador del asiento del vehículo",
		["ARENAENEMYFRAMES"] = "Marcos del enemigo de la arena",
		["ARENAPREPFRAMES"] = "Marcos de preparación de la arena",
		["QUESTTRACKER"] = "Questtracker",

		["RIGHT"] = "Derecha",
	
		["BOTTOMRIGHT"] = "Parte inferior derecha",
		["MICROMENU"] = "Micro Menú",
		["BOLSAS"] = "Bolsas",
		["GAMETOOLTIP"] = "Información sobre herramientas",
		["GAMETOOLTIP_ONCURSOR"] = "Información sobre herramientas en el cursor",
		["QUEUESTATUSBUTTON"] = "Estado de LFG",

		["BOTTOM"] = "Fondo",
		["ACTIONBARS"] = "Barras de acción 1-6",
		["ACTIONBAR7"] = "Barras de acción 7 personalizadas",
		["ACTIONBAR8"] = "Barras de acción 8 personalizadas",
		["ACTIONBAR9"] = "Barras de acción 9 personalizadas",
		["ACTIONBAR10"] = "Barras de acción 10 personalizadas",
		["PETBAR"] = "Barra de mascotas",
		["STANCEBAR"] = "Barra de postura",
		["TOTEMBAR"] = "Chamán - Barra de tótem",
		["LEAVEVEHICLE"] = "Botón de dejar el vehículo",
		["GROUPLOOTCONTAINER"] = "Marco del rollo de botín",
		["STATUSTRACKINGBARMANAGER"] = "Gestor de la barra de seguimiento de estado (XP, reputación)",
		["ALERTFRAME"] = "Marco de alerta (Bonus Loot, Achiements, ...)",

		["BOTTOMLEFT"] = "Parte inferior izquierda",
		["CHAT"] = "Marco de chat %d",
		["CHATBUTTONFRAME"] = "Botones de chat",
		["CHATQUICKJOIN"] = "Chat Quick Join",
		["CHATEDITBOX"] = "Caja de entrada del chat",

		["LEFT"] = "Izquierda",
		["COMPACTRAIDFRAMEMANAGER"] = "Gestor de incursiones",
		["BATTLENETFRIENDSNOTIFICATION"] = "Notificaciones de amigos de Battlenet",



		["ZONETEXTFRAME"] = "Texto de la zona",
		["UIWIDGETTOPCENTER"] = "Widget Top Center (Status on BGs/Dungeons)",
		["IASKILLS"] = "Barras de habilidades",
		["UIWIDGETBELOWMINIMAP"] = "Widget Below Minimap (Estado de captura)",
		["DURABILIDAD"] = "Muñeca de durabilidad",
		["MONEYBAR"] = "Barra de dinero",
		["TOKENBAR"] = "Barra de fichas",
		["IAILVLBAR"] = "Barra de nivel de artículo",
		["CASTINGBAR"] = "Barra de reparto",
		["TALKINGHEAD"] = "Diálogo de la cabeza parlante",
		["ACTIONBAR1"] = "Barra de acción 1 (barra principal)",
		["ACTIONBAR2"] = "Barra de acción 2 (2. Página de la barra de acción 1)",
		["ACTIONBAR3"] = "Barra de acción 3 (Barra derecha)",
		["ACTIONBAR4"] = "Barra de acción 4 (Barra izquierda)",
		["ACTIONBAR5"] = "Barra de acción 5 (Barra superior derecha)",
		["ACTIONBAR6"] = "Barra de acción 6 (Barra superior izquierda)",
		["POSSESSBAR"] = "Barra de posesión (control de NPC/vehículo)",
		["ZONEABILITYFRAME"] = "Habilidad de zona",
		["EXTRAABILITYCONTAINER"] = "Habilidad extra",
		["MAINMENUEXPBAR"] = "Barra de Exp",
		["REPUTATIONWATCHBAR"] = "Barra de reputación",
		["UIWIDGETPOWERBAR"] = "Barra de poder",

		["FILAS"] = "Filas",
		["ESPACIOS"] = "Espacios",
		
		

		["PROFILE"] = "Perfil",
		["PERFILES"] = "Perfiles",
		["ADDPROFILE"] = "Añadir perfil",
		["ACTUAL"] = "Actual",
		["SHARE"] = "Compartir",
		["SHAREPROFILE"] = "Compartir perfil",
		["GETPROFILE"] = "Obtener perfil",
		["INHERITFROM"] = "Heredar de",
		["ADD"] = "Añadir",
		["REMOVE"] = "Eliminar",
		["RENAME"] = "Renombrar",
		["PLAYER"] = "Reproductor",
		["DESCARGAR"] = "Descargar",
		["UPLOAD"] = "Subir",
		["STATUS"] = "Estado",
		["DONE"] = "Hecho",
		["WAITINGFOROWNER"] = "Esperando al propietario",
		["WAITFORPLAYERPROFILE"] = "Esperando a que el otro jugador pulse Obtener perfiles",
		["WAITFORPLAYERPROFILE2"] = "Esperar a que el otro jugador pulse Compartir.",

		["ALPHAINCOMBAT"] = "Alfa (en combate)",
		["ALPHANOTINCOMBAT"] = "Alfa (no en Combate)",
		["ALPHAINVEHICLE"] = "Alfa (en vehículo)",

		["MABUFFLIMIT"] = "Límite de buff",
		["MABUFFSPACINGX"] = "Espacio de buff horizontal",
		["MABUFFSPACINGY"] = "Espaciado de buff vertical",
	}

	MoveAny:UpdateLanguageTab( tab )
end
