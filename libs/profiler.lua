local addonName, MoveAny = ...
local P = {}
MoveAny.Profiler = P
local enabled = false
local stats = {}
local depth = 0
local childTime = {}
local frameStamp = nil
local frameTotal = 0
local frameSelf = {}
local frameCount = {}
local spikes = {}
local spikeLimit = 3
local maxSpikes = 40
local startTime = 0
local function OnError(err)
	local handler = geterrorhandler and geterrorhandler()
	if handler then handler(err) end
end

local function FlushFrame()
	if frameStamp and frameTotal >= spikeLimit then
		local top = {}
		for label, ms in pairs(frameSelf) do
			table.insert(top, {label, ms, frameCount[label] or 0})
		end

		table.sort(top, function(a, b) return a[2] > b[2] end)
		local parts = {}
		for i = 1, math.min(5, #top) do
			table.insert(parts, string.format("%s %.2fms x%d", top[i][1], top[i][2], top[i][3]))
		end

		table.insert(spikes, string.format("t=%.1f %.2fms: %s", frameStamp - startTime, frameTotal, table.concat(parts, " | ")))
		if #spikes > maxSpikes then table.remove(spikes, 1) end
	end

	frameTotal = 0
	wipe(frameSelf)
	wipe(frameCount)
end

local function Record(label, incl, own)
	local s = stats[label]
	if s == nil then
		s = {
			n = 0,
			incl = 0,
			own = 0,
			max = 0,
			o1 = 0,
			o5 = 0
		}

		stats[label] = s
	end

	s.n = s.n + 1
	s.incl = s.incl + incl
	s.own = s.own + own
	if incl > s.max then s.max = incl end
	if incl > 1 then s.o1 = s.o1 + 1 end
	if incl > 5 then s.o5 = s.o5 + 1 end
	frameSelf[label] = (frameSelf[label] or 0) + own
	frameCount[label] = (frameCount[label] or 0) + 1
	frameTotal = frameTotal + own
end

local function Run(label, fn, ...)
	local stamp = GetTime()
	if stamp ~= frameStamp then
		FlushFrame()
		frameStamp = stamp
	end

	depth = depth + 1
	local myDepth = depth
	childTime[myDepth] = 0
	local t0 = debugprofilestop()
	xpcall(fn, OnError, ...)
	local incl = debugprofilestop() - t0
	depth = myDepth - 1
	if depth > 0 then childTime[depth] = childTime[depth] + incl end
	Record(label, incl, incl - childTime[myDepth])
end

function P.Wrap(label, fn)
	if type(fn) ~= "function" then return fn end

	return function(...)
		if not enabled then return fn(...) end
		Run(label, fn, ...)
	end
end

local wrapCache = {}
function P.WrapOnce(label, fn)
	if type(fn) ~= "function" then return fn end
	local key = label .. tostring(fn)
	if wrapCache[key] == nil then wrapCache[key] = P.Wrap(label, fn) end

	return wrapCache[key]
end

function P.WrapEvent(label, fn)
	if type(fn) ~= "function" then return fn end

	return function(sel, event, ...)
		if not enabled then return fn(sel, event, ...) end
		Run(label .. " " .. tostring(event), fn, sel, event, ...)
	end
end

local function Caller()
	local stack = debugstack and debugstack(3, 4, 0) or ""
	local file, line = string.match(stack, "([%w_]+%.lua)[^:\n]*:(%d+)")
	if file then return file .. ":" .. line end

	return "?"
end

local function ObjName(obj)
	if type(obj) ~= "table" then return tostring(obj) end
	if type(obj.IsObjectType) == "function" and type(obj.GetName) == "function" then
		local ok, name = pcall(obj.GetName, obj)
		if ok and type(name) == "string" then return name end
	end

	return "table"
end

function MoveAny.hooksecurefunc(a, b, c)
	if type(a) == "string" then return hooksecurefunc(a, P.Wrap("hook " .. a .. " @" .. Caller(), b)) end

	return hooksecurefunc(a, b, P.Wrap("hook " .. ObjName(a) .. ":" .. tostring(b) .. " @" .. Caller(), c))
end

local origOnEvent = MoveAny.OnEvent
function MoveAny:OnEvent(frame, callback, from)
	return origOnEvent(self, frame, P.WrapEvent("event " .. tostring(from), callback), from)
end

local origAfter = MoveAny.After
function MoveAny:After(time, callback, from)
	if enabled then callback = P.Wrap("timer " .. tostring(from), callback) end

	return origAfter(self, time, callback, from)
end

local function Out(...)
	print("|cff55d2ff[MoveAny Profiler]|r", ...)
end

function P.Reset()
	wipe(stats)
	wipe(spikes)
	FlushFrame()
	frameStamp = nil
	startTime = GetTime()
end

function P.SetEnabled(on)
	enabled = on and true or false
	if enabled then P.Reset() end
	MATAB = MATAB or {}
	MATAB["PROFILER"] = MATAB["PROFILER"] or {}
	MATAB["PROFILER"].enabled = enabled
end

function P.IsEnabled()
	return enabled
end

function P.BuildReport(count, sortKey)
	FlushFrame()
	sortKey = sortKey or "own"
	local list = {}
	for label, s in pairs(stats) do
		table.insert(list, {label, s})
	end

	table.sort(list, function(a, b) return a[2][sortKey] > b[2][sortKey] end)
	local seconds = math.max(GetTime() - startTime, 0.001)
	local lines = {}
	table.insert(lines, string.format("%.1fs measured, %d entries, sorted by %s (ms = self time without nested MoveAny calls)", seconds, #list, sortKey))
	for i = 1, math.min(count or 15, #list) do
		local label, s = list[i][1], list[i][2]
		table.insert(lines, string.format("%2d. %8.2fms self %8.2fms incl %6dx avg %.3f max %.2f >1ms %d >5ms %d %.2fms/s  %s", i, s.own, s.incl, s.n, s.incl / s.n, s.max, s.o1, s.o5, s.own / seconds, label))
	end

	return lines
end

function P.PrintReport(count, sortKey)
	for _, line in ipairs(P.BuildReport(count, sortKey)) do
		Out(line)
	end
end

function P.PrintSpikes(count)
	FlushFrame()
	count = count or 10
	if #spikes == 0 then
		Out(string.format("No frame above %.1fms MoveAny time yet.", spikeLimit))

		return
	end

	for i = math.max(1, #spikes - count + 1), #spikes do
		Out(spikes[i])
	end
end

local function Help()
	Out("/maprof on - start measuring (stays on after /reload)")
	Out("/maprof off - stop measuring")
	Out("/maprof reset - clear the collected data")
	Out("/maprof top [n] - heaviest entries by self time")
	Out("/maprof calls [n] - most frequent entries")
	Out("/maprof max [n] - entries with the biggest single call")
	Out("/maprof spikes [n] - last frames where MoveAny used more than the spike limit")
	Out("/maprof limit <ms> - spike limit per frame (now " .. spikeLimit .. "ms)")
	Out("Data is also written to SavedVariables (MATAB.PROFILER) on /reload or logout.")
end

local function OnSlash(msg)
	local cmd, arg = string.match(msg or "", "^%s*(%S*)%s*(.-)%s*$")
	cmd = string.lower(cmd or "")
	local num = tonumber(arg)
	if cmd == "on" then
		P.SetEnabled(true)
		Out("on")
	elseif cmd == "off" then
		P.SetEnabled(false)
		Out("off")
	elseif cmd == "reset" then
		P.Reset()
		Out("reset")
	elseif cmd == "top" then
		P.PrintReport(num or 15, "own")
	elseif cmd == "calls" then
		P.PrintReport(num or 15, "n")
	elseif cmd == "max" then
		P.PrintReport(num or 15, "max")
	elseif cmd == "spikes" then
		P.PrintSpikes(num or 10)
	elseif cmd == "limit" and num then
		spikeLimit = num
		Out("spike limit " .. spikeLimit .. "ms")
	else
		Out(enabled and "is on" or "is off")
		Help()
	end
end

MoveAny:AddSlash("maprof", OnSlash)
local svFrame = CreateFrame("Frame")
svFrame:RegisterEvent("ADDON_LOADED")
svFrame:RegisterEvent("PLAYER_LOGOUT")
svFrame:SetScript("OnEvent", function(sel, event, name)
	if event == "ADDON_LOADED" then
		if name ~= addonName then return end
		sel:UnregisterEvent("ADDON_LOADED")
		for _, method in ipairs({"UpdateAuraDurations", "StyleAuraDuration", "LayoutAuraGrid", "TryHookAuraDuration", "HookAuraFrames", "UpdateActionBar", "DoUpdateMicroBarNow"}) do
			if type(MoveAny[method]) == "function" then MoveAny[method] = P.Wrap("func " .. method, MoveAny[method]) end
		end
		if MATAB and MATAB["PROFILER"] and MATAB["PROFILER"].enabled then
			P.SetEnabled(true)
			Out("is on - /maprof off to stop")
		end
	elseif event == "PLAYER_LOGOUT" then
		if not MATAB or not MATAB["PROFILER"] then return end
		if not enabled then
			MATAB["PROFILER"].report = nil
			MATAB["PROFILER"].spikes = nil

			return
		end

		MATAB["PROFILER"].report = P.BuildReport(60, "own")
		FlushFrame()
		MATAB["PROFILER"].spikes = {unpack(spikes)}
	end
end)
