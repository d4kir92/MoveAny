-- zhTW Simplified Chinese

local AddOnName, MoveAny = ...

function MoveAny:LangzhCN()
	local tab = {
		["LID_MMBTNLEFT"] = "左键 => 锁定/解锁 + 选项",
		["LID_MMBTNRIGHT"] = "Shift + 右键 => 隐藏迷你地图按钮",

		["LID_GENERAL"] = "一般",
		["LID_SHOWMINIMAPBUTTON"] = "显示迷你地图按钮",
		["LID_GRIDSIZE"] = "网格大小",
		["LID_MOVEFRAMES"] = "移动图框/窗口",
		["LID_FRAMESSHIFTDRAG"] = "用Shift+左键拖动移动框架",
		["FRAMESSHIFTSC"] = "用Shift+右键拖动缩放框架",
		["LID_FRAMESSHIFTRESET"] = "用Shift + 鼠标滚轮点击拖动来重置框架",

		["LID_PLAYERFRAME"] = "玩家框架",
		["LID_PETFRAME"] = "宠物框架",
		["LID_TARGETFRAME"] = "目标框架",
		["LID_TARGETOFTARGETFRAME"] = "目标框架的目标",
		["LID_TARGETFRAMESPELLBAR"] = "来自目标的铸币栏",
		["LID_FOCUSFRAME"] = "焦点框架",
		["LID_FOCUSFRAMESPELLBAR"] = "来自焦点的柱状物",
		["LID_TARGETOFFOCUSFRAME"] = "焦点框架的目标",
		["LID_RUNEFRAME"] = "死亡骑士-符文框架",
		["LID_TOTEMFRAME"] = "图腾计时器",
		["LID_WARLOCKPOWERFRAME"] = "术士力量框架",
		["LID_MONKHARMONYBARFRAME"] = "僧侣和谐框架",
		["LID_MAGEARCANECHARGESFRAME"] = "法师奥术收费框架",
		["LID_ESSENCEPLAYERFRAME"] = "精华玩家框架 (Evoker)",
		["LID_MAFPSFrame"] = "FPS",

		["LID_MINIMAP"] = "迷你地图",
		["LID_BUFFS"] = "布夫",
		["LID_DEBUFFS"] = "减轻伤害",
		["LID_VEHICLESEATINDICATOR"] = "车辆座位指示器",
		["LID_ARENAENEMYFRAMES"] = "竞技场敌人帧数",
		["LID_ARENAPREPFRAMES"] = "竞技场准备框架",
		["LID_QUESTTRACKER"] = "搜索引擎",
	
		["LID_MICROMENU"] = "微型菜单",
		["LID_BAGS"] = "袋子",
		["LID_GAMETOOLTIP"] = "工具提示",
		["LID_GAMETOOLTIP_ONCURSOR"] = "光标上的工具提示",
		["LID_QUEUESTATUSBUTTON" ] = "LFG状态",

		["LID_PETBAR"] = "宠物栏",
		["LID_STANCEBAR"] = "站立杆",
		["LID_TOTEMBAR"] = "萨满-图腾栏",
		["LID_LEAVEVEHICLE"] = "离开车辆按钮",
		["LID_GROUPLOOTCONTAINER"] = "战利品滚动框架",
		["LID_STATUSTRACKINGBARMANAGER"] = "状态跟踪条管理器 (XP，信誉)",
		["LID_ALERTFRAME"] = "警报框 (奖励战利品，成就，...)",

		["LID_CHAT"] = "Chatframe %d",
		["LID_CHATBUTTONFRAME"] = "聊天按钮",
		["LID_CHATQUICKJOIN"] = "聊天快速加入",
		["LID_CHATEDITBOX"] = "聊天输入框",

		["LID_COMPACTRAIDFRAMEMANAGER"] = "突击队经理",
		["LID_BNToastFrame"] = "Battlenet朋友的通知",

		["LID_ZONETEXTFRAME"] = "区域文本",
		["LID_UIWIDGETTOPCENTER" ] = "小工具顶部中心 (BG/Dungeons的状态)",
		["LID_IASKILLS"] = "技能栏",
		["LID_UIWIDGETBELOWMINIMAP"] = "迷你地图下面的小工具 (捕获状态)",
		["LID_DURABILITY"] = "耐用性娃娃",
		["LID_MONEYBAR"] = "钱吧",
		["LID_TOKENBAR"] = "代币栏",
		["LID_IAILVLBAR"] = "项目级别栏",
		["LID_CASTINGBAR"] = "铸造栏",
		["LID_TALKINGHEAD"] = "说话的头像对话",
		["LID_POSSESSBAR"] = "拥有栏 (控制NPC/车辆)",
		["LID_ZONEABILITYFRAME"] = "区域能力",
		["LID_EXTRAABILITYCONTAINER"] = "额外能力",
		["LID_MAINMENUEXPBAR"] = "Exp Bar",
		["LID_REPUTATIONWATCHBAR"] = "声誉栏",
		["LID_UIWIDGETPOWERBAR"] = "能量条",

		["LID_ROWS"] = "行数",
		["LID_SPACING"] = "间距",
		
		

		["LID_PROFILE"] = "轮廓",
		["LID_PROFILES"] = "配置文件",
		["LID_ADDPROFILE"] = "添加简介",
		["LID_CURRENT"] = "目前",
		["LID_SHARE"] = "共享",
		["LID_SHAREPROFILE"] = "共享资料",
		["LID_GETPROFILE"] = "获取资料",
		["LID_INHERITFROM"] = "继承自",
		["LID_ADD"] = "添加",
		["LID_REMOVE"] = "删除",
		["LID_RENAME"] = "重命名",
		["LID_PLAYER"] = "队员",
		["LID_DOWNLOAD"] = "下载",
		["LID_UPLOAD"] = "上传",
		["LID_STATUS"] = "状态",
		["LID_DONE"] = "已完成",
		["LID_WAITINGFOROWNER"] = "等待主人",
		["LID_WAITFORPLAYERPROFILE"] = "等待其他玩家按下 \"获取配置文件\.",
		["LID_WAITFORPLAYERPROFILE2"] = "等待其他玩家按下 \"分享\".",

		["LID_ALPHAINCOMBAT"] = "阿尔法 (在战斗中)",
		["LID_ALPHANOTINCOMBAT"] = "阿尔法 (未参加战斗)",
		["LID_ALPHAINVEHICLE"] = "阿尔法 (车辆中)",

		["LID_MABUFFLIMIT" ] = "缓冲限制",
		["LID_MABUFFSPACINGX"] = "缓冲间隔水平",
		["LID_MABUFFSPACINGY"] = "缓冲间隔 垂直",
	}

	if MoveAny:GetWoWBuild() ~= "RETAIL" then
		tab["LID_ACTIONBARS"] = "动作栏1-6"
		tab["LID_ACTIONBAR1"] = "动作栏1（主栏）"
		tab["LID_ACTIONBAR2"] = "动作条2（动作条1的第2页）"
		tab["LID_ACTIONBAR3"] = "动作栏3（右栏）"
		tab["LID_ACTIONBAR4"] = "动作栏4（左栏）"
		tab["LID_ACTIONBAR5"] = "动作栏5（右上栏）"
		tab["LID_ACTIONBAR6"] = "动作栏6（左上栏）"
		tab["LID_ACTIONBAR7"] = "动作条7（自定义）"
		tab["LID_ACTIONBAR8"] = "动作条8（自定义）"
		tab["LID_ACTIONBAR9"] = "Actionbar 9 (自定义)"
		tab["LID_ACTIONBAR10"] = "Actionbar 10 (自定义)"
	else
		tab["LID_ACTIONBAR1"] = "动作栏1（主栏）"
		tab["LID_ACTIONBAR2"] = "动作栏2（主栏上方）"
		tab["LID_ACTIONBAR3"] = "动作条3（第二条上面）"
		tab["LID_ACTIONBAR4"] = "动作栏4（右栏）"
		tab["LID_ACTIONBAR5"] = "动作栏5（左栏）"
		tab["LID_ACTIONBAR6"] = "动作条6"
		tab["LID_ACTIONBAR7"] = "动作条7"
		tab["LID_ACTIONBAR8"] = "动作栏8"
	end

	MoveAny:UpdateLanguageTab( tab )
end
