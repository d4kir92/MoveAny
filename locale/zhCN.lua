-- zhTW Simplified Chinese

local AddOnName, MoveAny = ...

function MoveAny:Lang_zhCN()
	local tab = {
		["MMBTNLEFT"] = "左键 => 锁定/解锁 + 选项",
		["MMBTNRIGHT"] = "Shift + 右键 => 隐藏迷你地图按钮",

		["GENERAL"] = "一般",
		["SHOWMINIMAPBUTTON"] = "显示迷你地图按钮",
		["GRIDSIZE"] = "网格大小",
		["MOVEFRAMES"] = "移动图框/窗口",
		["FRAMESSHIFTDRAG"] = "用Shift+左键拖动移动框架",
		["FRAMESSHIFTSC"] = "用Shift+右键拖动缩放框架",
		["FRAMESSHIFTRESET"] = "用Shift + 鼠标滚轮点击拖动来重置框架",

		["TOPLEFT"] = "左上角",
		["PLAYERFRAME"] = "玩家框架",
		["PETFRAME"] = "宠物框架",
		["TARGETFRAME"] = "目标框架",
		["TARGETOFTARGETFRAME"] = "目标框架的目标",
		["TARGETFRAMESPELLBAR"] = "来自目标的铸币栏",
		["FOCUSFRAME"] = "焦点框架",
		["FOCUSFRAMESPELLBAR"] = "来自焦点的柱状物",
		["TARGETOFFOCUSFRAME"] = "焦点框架的目标",
		["RUNEFRAME"] = "死亡骑士-符文框架",
		["TOTEMFRAME"] = "图腾计时器",
		["WARLOCKPOWERFRAME"] = "术士力量框架",
		["MONKHARMONYBARFRAME"] = "僧侣和谐框架",
		["MAGEARCANECHARGESFRAME"] = "法师奥术收费框架",
		["ESSENCEPLAYERFRAME"] = "精华玩家框架 (Evoker)",
		["MAFPSFrame"] = "FPS",

		["TOP"] = "顶部",

		["TOPRIGHT"] = "右上方",
		["MINIMAP"] = "迷你地图",
		["BUFFS"] = "布夫",
		["DEBUFFS"] = "减轻伤害",
		["VEHICLESEATINDICATOR"] = "车辆座位指示器",
		["ARENAENEMYFRAMES"] = "竞技场敌人帧数",
		["ARENAPREPFRAMES"] = "竞技场准备框架",
		["QUESTTRACKER"] = "搜索引擎",

		["RIGHT"] = "对",
	
		["BOTTOMRIGHT"] = "右下方",
		["MICROMENU"] = "微型菜单",
		["BAGS"] = "袋子",
		["GAMETOOLTIP"] = "工具提示",
		["GAMETOOLTIP_ONCURSOR"] = "光标上的工具提示",
		["QUEUESTATUSBUTTON" ] = "LFG状态",

		["BOTTOM"] = "底部",
		["ACTIONBARS"] = "动作条1-6",
		["ACTIONBAR7"] = "自定义动作条7",
		["ACTIONBAR8"] = "自定义动作条8",
		["ACTIONBAR9"] = "自定义动作条9",
		["ACTIONBAR10"] = "自定义动作条10",
		["PETBAR"] = "宠物栏",
		["STANCEBAR"] = "站立杆",
		["TOTEMBAR"] = "萨满-图腾栏",
		["LEAVEHICLE"] = "离开车辆按钮",
		["GROUPLOOTCONTAINER"] = "战利品滚动框架",
		["STATUSTRACKINGBARMANAGER"] = "状态跟踪条管理器 (XP，信誉)",
		["ALERTFRAME"] = "警报框 (奖励战利品，成就，...)",

		["BOTTOMLEFT"] = "左下角",
		["CHAT"] = "Chatframe %d",
		["CHATBUTTONFRAME"] = "聊天按钮",
		["CHATQUICKJOIN"] = "聊天快速加入",
		["CHATEDITBOX"] = "聊天输入框",

		["LEFT"] = "左",
		["COMPACTRAIDFRAMEMANAGER"] = "突击队经理",
		["BATTLENETFRIENDSNOTIFICATION"] = "Battlenet朋友的通知",



		["ZONETEXTFRAME"] = "区域文本",
		["UIWIDGETTOPCENTER" ] = "小工具顶部中心 (BG/Dungeons的状态)",
		["IASKILLS"] = "技能栏",
		["UIWIDGETBELOWMINIMAP"] = "迷你地图下面的小工具 (捕获状态)",
		["DURABILITY"] = "耐用性娃娃",
		["MONEYBAR"] = "钱吧",
		["TOKENBAR"] = "代币栏",
		["IAILVLBAR"] = "项目级别栏",
		["CASTINGBAR"] = "铸造栏",
		["TALKINGHEAD"] = "说话的头像对话",
		["ACTIONBAR1"] = "动作栏1 (主栏)",
		["ACTIONBAR2"] = "行动栏2 (行动栏1的第2页)",
		["ACTIONBAR3"] = "动作栏3 (右栏)",
		["ACTIONBAR4"] = "动作栏4 (左栏)",
		["ACTIONBAR5"] = "动作栏5 (右上栏)",
		["ACTIONBAR6"] = "动作栏6 (左上栏)",
		["POSSESSBAR"] = "拥有栏 (控制NPC/车辆)",
		["ZONEABILITYFRAME"] = "区域能力",
		["EXTRAABILITYCONTAINER"] = "额外能力",
		["MAINMENUEXPBAR"] = "Exp Bar",
		["REPUTATIONWATCHBAR"] = "声誉栏",
		["UIWIDGETPOWERBAR"] = "能量条",

		["ROWS"] = "行数",
		["SPACING"] = "间距",
		
		

		["PROFILE"] = "轮廓",
		["PROFILES"] = "配置文件",
		["ADDPROFILE"] = "添加简介",
		["CURRENT"] = "目前",
		["SHARE"] = "共享",
		["SHAREPROFILE"] = "共享资料",
		["GETPROFILE"] = "获取资料",
		["INHERITFROM"] = "继承自",
		["ADD"] = "添加",
		["REMOVE"] = "删除",
		["RENAME"] = "重命名",
		["PLAYER"] = "队员",
		["DOWNLOAD"] = "下载",
		["UPLOAD"] = "上传",
		["STATUS"] = "状态",
		["DONE"] = "已完成",
		["WAITINGFOROWNER"] = "等待主人",
		["WAITFORPLAYERPROFILE"] = "等待其他玩家按下 \"获取配置文件\.",
		["WAITFORPLAYERPROFILE2"] = "等待其他玩家按下 \"分享\".",

		["ALPHAINCOMBAT"] = "阿尔法 (在战斗中)",
		["ALPHANOTINCOMBAT"] = "阿尔法 (未参加战斗)",
		["ALPHAINVEHICLE"] = "阿尔法 (车辆中)",

		["MABUFFLIMIT" ] = "缓冲限制",
		["MABUFFSPACINGX"] = "缓冲间隔水平",
		["MABUFFSPACINGY"] = "缓冲间隔 垂直",
		["ISENABLEDINEDITMODE"] = "(在编辑模式下启用)",
	}

	MoveAny:UpdateLanguageTab( tab )
end
