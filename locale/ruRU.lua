-- ruRU Russian

local AddOnName, MoveAny = ...

function MoveAny:LangruRU()
	local tab = {
		["MMBTNLEFT"] = "Левый клик => блокировка/разблокировка + опции",
		["MMBTNRIGHT"] = "Shift + правый клик => скрыть кнопку мини-картинки",

		["GENERAL"] = "Общие",
		["SHOWMINIMAPBUTTON"] = "Показать кнопку мини-картинки",
		["GRIDSIZE"] = "Размер сетки",
		["MOVEFRAMES"] = "Переместить кадры/окна",
		["FRAMESSHIFTDRAG"] = "Перемещение рамки с помощью Shift + перетаскивание левой кнопкой мыши",
		["FRAMESSHIFTSCALE"] = "Масштабировать рамку с помощью Shift + перетаскивание вправо",
		["FRAMESSHIFTRESET"] = "Сбросить рамку с помощью Shift + перетаскивание мыши",

		["TOPLEFT"] = "Верхний левый",
		["PLAYERFRAME"] = "Рамка игрока",
		["PETFRAME"] = "Рамка питомца",
		["TARGETFRAME"] = "Рамка цели",
		["TARGETOFTARGETFRAME"] = "Рамка цели",
		["TARGETFRAMESPELLBAR"] = "Кастбар от цели",
		["FOCUSFRAME"] = "Рамка фокуса",
		["FOCUSFRAMESPELLBAR"] = "Затвор от фокуса",
		["TARGETOFFOCUSFRAME"] = "Цель из фокусного кадра",
		["RUNEFRAME"] = "Deathknight - Runes Frame",
		["TOTEMFRAME"] = "Таймеры тотемов",
		["WARLOCKPOWERFRAME"] = "Рамка силы колдуна",
		["MONKHARMONYBARFRAME"] = "Рамка гармонии монаха",
		["MAGEARCANECHARGESFRAME"] = "Рамка Mage Arcane Charges",
		["ESSENCEPLAYERFRAME"] = "Рамка игрока эссенции (эвокера)",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "Верх",

		["TOPRIGHT"] = "Верхний правый",
		["MINIMAP"] = "Мини-карта",
		["BUFFS"] = "Баффы",
		["DEBUFFS"] = "Дебаффы",
		["VEHICLESEATINDICATOR"] = "Индикатор места в автомобиле",
		["ARENAENEMYFRAMES"] = "Рамки врагов арены",
		["ARENAPREPFRAMES"] = "Кадры подготовки арены",
		["QUESTTRACKER"] = "Квесттрекер",

		["RIGHT"] = "Справа",
	
		["BOTTOMRIGHT"] = "Внизу справа",
		["MICROMENU"] = "Микроменю",
		["BAGS"] = "Сумки",
		["GAMETOOLTIP"] = "Подсказка",
		["GAMETOOLTIP_ONCURSOR"] = "Всплывающая подсказка на курсоре",
		["QUEUESTATUSBUTTON"] = "Статус LFG",

		["BOTTOM"] = "Внизу",
		["ACTIONBARS"] = "Панели действий 1-6",
		["ACTIONBAR7"] = "Пользовательские панели действий 7",
		["ACTIONBAR8"] = "Пользовательские панели действий 8",
		["ACTIONBAR9"] = "Пользовательские панели действий 9",
		["ACTIONBAR10"] = "Пользовательский Actionbars 10",
		["PETBAR"] = "Бар для домашних животных",
		["STANCEBAR"] = "Stance Bar",
		["TOTEMBAR"] = "Shaman - Totem Bar",
		["LEAVEVEHICLE"] = "Кнопка покинуть транспортное средство",
		["GROUPLOOTCONTAINER"] = "Рамка для лута",
		["STATUSTRACKINGBARMANAGER"] = "Менеджер панели отслеживания статуса (XP, репутация)",
		["ALERTFRAME"] = "Рамка оповещения (бонусный лут, достижения, ...)",

		["BOTTOMLEFT"] = "Нижний левый",
		["CHAT"] = "Рамка чата %d",
		["CHATBUTTONFRAME"] = "Кнопки чата",
		["CHATQUICKJOIN"] = "Быстрое присоединение к чату",
		["CHATEDITBOX"] = "Поле ввода чата",

		["LEFT"] = "Слева",
		["COMPACTRAIDFRAMEMANAGER"] = "Менеджер рейдов",
		["BATTLENETFRIENDSNOTIFICATION"] = "Уведомления друзей Battlenet",



		["ZONETEXTFRAME"] = "Текст зоны",
		["UIWIDGETTOPCENTER"] = "Верхний центр виджета (статус на BGs/Dungeons)",
		["IASKILLS"] = "Панели умений",
		["UIWIDGETBELOWMINIMAP"] = "Виджет ниже минимальной карты (статус захвата)",
		["DURABILITY"] = "Кукла прочности",
		["MONEYBAR"] = "Money Bar",
		["TOKENBAR"] = "Бар жетонов",
		["IAILVLBAR"] = "Бар уровня предметов",
		["CASTINGBAR"] = "Бар литья",
		["TALKINGHEAD"] = "Диалог говорящей головы",
		["ACTIONBAR1"] = "Панель действий 1 (главная панель)",
		["ACTIONBAR2"] = "Панель действий 2 (2. Страница панели действий 1)",
		["ACTIONBAR3"] = "Actionbar 3 (правая панель)",
		["ACTIONBAR4"] = "Панель действий 4 (левая панель)",
		["ACTIONBAR5"] = "Панель действия 5 (правая верхняя панель)",
		["ACTIONBAR6"] = "Панель действия 6 (верхняя левая панель)",
		["POSSESSBAR"] = "Панель владения (управление NPC/транспортным средством)",
		["ZONEABILITYFRAME"] = "Способность зоны",
		["EXTRAABILITYCONTAINER"] = "Дополнительная способность",
		["MAINMENUEXPBAR"] = "Exp Bar",
		["REPUTATIONWATCHBAR"] = "Бар репутации",
		["UIWIDGETPOWERBAR"] = "Бар энергии",

		["ROWS"] = "Строки",
		["SPACING"] = "Промежутки",
		
		

		["PROFILE"] = "Профиль",
		["PROFILES"] = "Профили",
		["ADDPROFILE"] = "Добавить профиль",
		["CURRENT"] = "Текущий",
		["SHARE"] = "Поделиться",
		["SHAREPROFILE"] = "Поделиться профилем",
		["GETPROFILE"] = "Получить профиль",
		["INHERITFROM"] = "Наследовать от",
		["ADD"] = "Добавить",
		["REMOVE"] = "Удалить",
		["RENAME"] = "Переименовать",
		["PLAYER"] = "Проигрыватель",
		["DOWNLOAD"] = "Загрузить",
		["UPLOAD"] = "Загрузить",
		["STATUS"] = "Статус",
		["DONE"] = "Выполнено",
		["WAITINGFOROWNER"] = "Ожидание владельца",
		["WAITFORPLAYERPROFILE"] = "Ждать, пока другой игрок нажмет \"Получить профили\"",
		["WAITFORPLAYERPROFILE2"] = "Ждать, пока другой игрок нажмет \"Поделиться\".",

		["ALPHAINCOMBAT"] = "Альфа (в бою)",
		["ALPHANOTINCOMBAT"] = "Альфа (не в бою)",
		["ALPHAINVEHICLE"] = "Альфа (в транспортном средстве)",

		["MABUFFLIMIT"] = "Предел баффа",
		["MABUFFSPACINGX"] = "Горизонтальное расстояние между баффами",
		["MABUFFSPACINGY"] = "Расстояние между буферами по вертикали",
		["ISENABLEDINEDITMODE"] = "(Включено в режиме редактирования)",
	}

	MoveAny:UpdateLanguageTab( tab )
end
