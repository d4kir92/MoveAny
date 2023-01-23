-- ruRU Russian

local AddOnName, MoveAny = ...

function MoveAny:LangruRU()
	local tab = {
		["LID_MMBTNLEFT"] = "Левый клик => блокировка/разблокировка + опции",
		["LID_MMBTNRIGHT"] = "Shift + правый клик => скрыть кнопку мини-картинки",

		["LID_GENERAL"] = "Общие",
		["LID_SHOWMINIMAPBUTTON"] = "Показать кнопку мини-картинки",
		["LID_GRIDSIZE"] = "Размер сетки",
		["LID_MOVEFRAMES"] = "Переместить кадры/окна",
		["LID_FRAMESSHIFTDRAG"] = "Перемещение рамки с помощью Shift + перетаскивание левой кнопкой мыши",
		["LID_FRAMESSHIFTSCALE"] = "Масштабировать рамку с помощью Shift + перетаскивание вправо",
		["LID_FRAMESSHIFTRESET"] = "Сбросить рамку с помощью Shift + перетаскивание мыши",

		["LID_PLAYERFRAME"] = "Рамка игрока",
		["LID_PETFRAME"] = "Рамка питомца",
		["LID_TARGETFRAME"] = "Рамка цели",
		["LID_TARGETOFTARGETFRAME"] = "Рамка цели",
		["LID_TARGETFRAMESPELLBAR"] = "Кастбар от цели",
		["LID_FOCUSFRAME"] = "Рамка фокуса",
		["LID_FOCUSFRAMESPELLBAR"] = "Затвор от фокуса",
		["LID_TARGETOFFOCUSFRAME"] = "Цель из фокусного кадра",
		["LID_RUNEFRAME"] = "Deathknight - Runes Frame",
		["LID_TOTEMFRAME"] = "Таймеры тотемов",
		["LID_WARLOCKPOWERFRAME"] = "Рамка силы колдуна",
		["LID_MONKHARMONYBARFRAME"] = "Рамка гармонии монаха",
		["LID_MAGEARCANECHARGESFRAME"] = "Рамка Mage Arcane Charges",
		["LID_ESSENCEPLAYERFRAME"] = "Рамка игрока эссенции (эвокера)",
		["LID_MAFPSFrame"] = "FPS",

		["LID_MINIMAP"] = "Мини-карта",
		["LID_BUFFS"] = "Баффы",
		["LID_DEBUFFS"] = "Дебаффы",
		["LID_VEHICLESEATINDICATOR"] = "Индикатор места в автомобиле",
		["LID_ARENAENEMYFRAMES"] = "Рамки врагов арены",
		["LID_ARENAPREPFRAMES"] = "Кадры подготовки арены",
		["LID_QUESTTRACKER"] = "Квесттрекер",

		["LID_MICROMENU"] = "Микроменю",
		["LID_BAGS"] = "Сумки",
		["LID_GAMETOOLTIP"] = "Подсказка",
		["LID_GAMETOOLTIP_ONCURSOR"] = "Всплывающая подсказка на курсоре",
		["LID_QUEUESTATUSBUTTON"] = "Статус LFG",

		["LID_PETBAR"] = "Бар для домашних животных",
		["LID_STANCEBAR"] = "Stance Bar",
		["LID_TOTEMBAR"] = "Shaman - Totem Bar",
		["LID_LEAVEVEHICLE"] = "Кнопка покинуть транспортное средство",
		["LID_GROUPLOOTCONTAINER"] = "Рамка для лута",
		["LID_STATUSTRACKINGBARMANAGER"] = "Менеджер панели отслеживания статуса (XP, репутация)",
		["LID_ALERTFRAME"] = "Рамка оповещения (бонусный лут, достижения, ...)",

		["LID_CHAT"] = "Рамка чата %d",
		["LID_CHATBUTTONFRAME"] = "Кнопки чата",
		["LID_CHATQUICKJOIN"] = "Быстрое присоединение к чату",
		["LID_CHATEDITBOX"] = "Поле ввода чата",

		["LID_COMPACTRAIDFRAMEMANAGER"] = "Менеджер рейдов",
		["LID_BNToastFrame"] = "Уведомления друзей Battlenet",



		["LID_ZONETEXTFRAME"] = "Текст зоны",
		["LID_UIWIDGETTOPCENTER"] = "Верхний центр виджета (статус на BGs/Dungeons)",
		["LID_IASKILLS"] = "Панели умений",
		["LID_UIWIDGETBELOWMINIMAP"] = "Виджет ниже минимальной карты (статус захвата)",
		["LID_DURABILITY"] = "Кукла прочности",
		["LID_MONEYBAR"] = "Money Bar",
		["LID_TOKENBAR"] = "Бар жетонов",
		["LID_IAILVLBAR"] = "Бар уровня предметов",
		["LID_CASTINGBAR"] = "Бар литья",
		["LID_TALKINGHEAD"] = "Диалог говорящей головы",
		["LID_POSSESSBAR"] = "Панель владения (управление NPC/транспортным средством)",
		["LID_ZONEABILITYFRAME"] = "Способность зоны",
		["LID_EXTRAABILITYCONTAINER"] = "Дополнительная способность",
		["LID_MAINMENUEXPBAR"] = "Exp Bar",
		["LID_REPUTATIONWATCHBAR"] = "Бар репутации",
		["LID_UIWIDGETPOWERBAR"] = "Бар энергии",

		["LID_ROWS"] = "Строки",
		["LID_SPACING"] = "Промежутки",
		
		

		["LID_PROFILE"] = "Профиль",
		["LID_PROFILES"] = "Профили",
		["LID_ADDPROFILE"] = "Добавить профиль",
		["LID_CURRENT"] = "Текущий",
		["LID_SHARE"] = "Поделиться",
		["LID_SHAREPROFILE"] = "Поделиться профилем",
		["LID_GETPROFILE"] = "Получить профиль",
		["LID_INHERITFROM"] = "Наследовать от",
		["LID_ADD"] = "Добавить",
		["LID_REMOVE"] = "Удалить",
		["LID_RENAME"] = "Переименовать",
		["LID_PLAYER"] = "Проигрыватель",
		["LID_DOWNLOAD"] = "Загрузить",
		["LID_UPLOAD"] = "Загрузить",
		["LID_STATUS"] = "Статус",
		["LID_DONE"] = "Выполнено",
		["LID_WAITINGFOROWNER"] = "Ожидание владельца",
		["LID_WAITFORPLAYERPROFILE"] = "Ждать, пока другой игрок нажмет \"Получить профили\"",
		["LID_WAITFORPLAYERPROFILE2"] = "Ждать, пока другой игрок нажмет \"Поделиться\".",

		["LID_ALPHAINCOMBAT"] = "Альфа (в бою)",
		["LID_ALPHANOTINCOMBAT"] = "Альфа (не в бою)",
		["LID_ALPHAINVEHICLE"] = "Альфа (в транспортном средстве)",

		["LID_MABUFFLIMIT"] = "Предел баффа",
		["LID_MABUFFSPACINGX"] = "Горизонтальное расстояние между баффами",
		["LID_MABUFFSPACINGY"] = "Расстояние между буферами по вертикали",
	}

	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		tab["LID_ACTIONBARS"] = "Панели действий 1-6"
		tab["LID_ACTIONBAR1"] = "Панель действий 1 (главная панель)"
		tab["LID_ACTIONBAR2"] = "Панель действий 2 (2. Страница панели действий 1)"
		tab["LID_ACTIONBAR3"] = "Панель действий 3 (правая панель)"
		tab["LID_ACTIONBAR4"] = "Панель действий 4 (левая панель)"
		tab["LID_ACTIONBAR5"] = "Панель действий 5 (правая верхняя панель)"
		tab["LID_ACTIONBAR6"] = "Панель действий 6 (левая верхняя панель)"
		tab["LID_ACTIONBAR7"] = "Панель действий 7 (пользовательская)"
		tab["LID_ACTIONBAR8"] = "Панель действий 8 (пользовательская)"
		tab["LID_ACTIONBAR9"] = "Панель действий 9 (пользовательская)"
		tab["LID_ACTIONBAR10"] = "Панель действий 10 (пользовательская)"
	else
		tab["LID_ACTIONBAR1"] = "Панель действий 1 (главная панель)"
		tab["LID_ACTIONBAR2"] = "Панель действий 2 (Над главным баром)"
		tab["LID_ACTIONBAR3"] = "Панель действий 3 (над второй панелью)"
		tab["LID_ACTIONBAR4"] = "Панель действия 4 (правая панель)"
		tab["LID_ACTIONBAR5"] = "Панель действия 5 (левая панель)"
		tab["LID_ACTIONBAR6"] = "Панель действия 6"
		tab["LID_ACTIONBAR7"] = "Панель действия 7"
		tab["LID_ACTIONBAR8"] = "Панель действий 8"
	end

	MoveAny:UpdateLanguageTab( tab )
end
