local _, MoveAny = ...
MoveAny:SetAddonOutput("MoveAny", 135994)
function MoveAny:MathC(val, vmin, vmax)
	if val == nil then return 0 end
	if vmin == nil then return 0 end
	if vmax == nil then return 1 end
	if val < vmin then
		return vmin
	elseif val > vmax then
		return vmax
	else
		return val
	end
end

function MoveAny:MathR(val, dec)
	val = val or 0
	dec = dec or 0
	return tonumber(string.format("%0." .. dec .. "f", val))
end

function MoveAny:Snap(n, snap)
	n = n or 0
	snap = snap or MoveAny:GetSnapSize()
	local mod = n % snap
	if mod > (snap / 2) then
		return n - mod + snap
	else
		return n - mod
	end
end

function MoveAny:GetScreenPixelHeight()
	local getSize = _G["GetPhysicalScreenSize"]
	if getSize == nil then return nil end
	local ok, _, physH = pcall(getSize)
	if not ok or type(physH) ~= "number" or physH < 1 then return nil end

	return physH
end

function MoveAny:GetPixelUnit(frame)
	local physH = MoveAny:GetScreenPixelHeight()
	if physH == nil then return nil end
	if frame == nil or frame.GetEffectiveScale == nil then return nil end
	local ok, scale = pcall(frame.GetEffectiveScale, frame)
	if not ok or type(scale) ~= "number" or scale <= 0 then return nil end

	return (768 / physH) / scale
end

function MoveAny:PixelSnap(val, unit)
	if type(val) ~= "number" or type(unit) ~= "number" or unit <= 0 then return val end

	return math.floor(val / unit + 0.5) * unit
end

function MoveAny:GetPixelAlignOffset(frame, root, anchor)
	if frame == nil or root == nil or type(anchor) ~= "string" then return 0, 0 end
	local physH = MoveAny:GetScreenPixelHeight()
	if physH == nil then return 0, 0 end
	local ok, dx, dy = pcall(function()
		local l, r, t, b = root:GetLeft(), root:GetRight(), root:GetTop(), root:GetBottom()
		if type(l) ~= "number" or type(r) ~= "number" or type(t) ~= "number" or type(b) ~= "number" then return nil end
		local rootScale = root:GetEffectiveScale()
		local frameScale = frame:GetEffectiveScale()
		if type(rootScale) ~= "number" or rootScale <= 0 then return nil end
		if type(frameScale) ~= "number" or frameScale <= 0 then return nil end
		local toPixel = physH / 768
		local ax = l
		if string.find(anchor, "RIGHT", 1, true) then
			ax = r
		elseif not string.find(anchor, "LEFT", 1, true) then
			ax = (l + r) / 2
		end

		local ay = t
		if string.find(anchor, "BOTTOM", 1, true) then
			ay = b
		elseif not string.find(anchor, "TOP", 1, true) then
			ay = (t + b) / 2
		end

		ax = ax * rootScale * toPixel
		ay = ay * rootScale * toPixel

		return (math.floor(ax + 0.5) - ax) / (frameScale * toPixel), (math.floor(ay + 0.5) - ay) / (frameScale * toPixel)
	end)

	if ok and type(dx) == "number" and type(dy) == "number" then return dx, dy end

	return 0, 0
end
