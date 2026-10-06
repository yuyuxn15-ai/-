-- ============================================
--   Raygun Kill Panel + UI
-- ============================================

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--========================= 配置区 =========================
local CONFIG = {
	TokenMode    = "fixed",        -- "fixed" 或 "auto"
	FixedToken   = 620323,         -- 抓包里的 token

	ToolName     = "~sGun",
	Action       = "~sShoot",
	ToolRealName = "Raygun",       -- 武器在游戏里的名字
	CFrameSuffix = "-1",           -- CFrame 结尾标记

	AttackInterval = 0.05,         -- 射击间隔

	DefaultRange   = 100,
	RingSegments   = 48,

	CreatureContainerName = "CreatureContainer",

	SpecialCreatures = {
		"Meglabone", "TreasureCrab", "Seagull", "Shark",
	},
}
--==========================================================

-- Token 生成
local tokenCounter = 600000
local function makeToken()
	if CONFIG.TokenMode == "fixed" then
		return CONFIG.FixedToken
	end
	tokenCounter = tokenCounter + math.random(1, 1000)
	if tokenCounter > 5000000 then
		tokenCounter = 600000
	end
	return tokenCounter
end

--=====================================================================
--              自动查找 RemoteFunction
--=====================================================================
local RemoteFunc = nil
local RemoteServiceName = "?"

local function findRemoteFunction()
	local serviceNames = {
		"LogService", "SocialService", "Chat", "LocalizationService", "ReplicatedStorage",
	}
	for _, name in ipairs(serviceNames) do
		local ok, svc = pcall(function() return game:GetService(name) end)
		if ok and svc then
			local rf = svc:FindFirstChild("RemoteFunction")
			if rf and rf:IsA("RemoteFunction") then
				return rf, name
			end
		end
	end
	for _, svc in ipairs(game:GetChildren()) do
		local ok, rf = pcall(function() return svc:FindFirstChild("RemoteFunction") end)
		if ok and rf and rf:IsA("RemoteFunction") then
			return rf, svc.Name
		end
	end
	return nil, nil
end

RemoteFunc, RemoteServiceName = findRemoteFunction()

--=====================================================================
--                           UI
--=====================================================================
local gui = Instance.new("ScreenGui")
gui.Name = "RaygunKillGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local function addBreathingGlow(imageLabel, minT, maxT)
	task.spawn(function()
		while imageLabel.Parent do
			TweenService:Create(imageLabel, TweenInfo.new(1.5), { ImageTransparency = minT }):Play()
			task.wait(1.5)
			if not imageLabel.Parent then break end
			TweenService:Create(imageLabel, TweenInfo.new(1.5), { ImageTransparency = maxT }):Play()
			task.wait(1.5)
		end
	end)
end

--=====================================================================
--                        主面板
--=====================================================================
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 260, 0, 500)
panel.Position = UDim2.new(0, 20, 0, 60)
panel.BackgroundColor3 = Color3.fromRGB(18, 24, 30)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local panelGlow = Instance.new("ImageLabel")
panelGlow.Image = "rbxasset://textures/ui/Glow.png"
panelGlow.ImageColor3 = Color3.fromRGB(80, 180, 255)
panelGlow.ImageTransparency = 0.55
panelGlow.BackgroundTransparency = 1
panelGlow.Size = UDim2.new(1, 40, 1, 40)
panelGlow.Position = UDim2.new(0, -20, 0, -20)
panelGlow.ZIndex = 0
panelGlow.Parent = panel
addBreathingGlow(panelGlow, 0.45, 0.7)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 180, 255)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 26)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "光线枪杀戮"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(200, 225, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2
title.Parent = panel

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -24, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.ZIndex = 3
closeBtn.Parent = panel
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 18, 0, 18)
minBtn.Position = UDim2.new(1, -46, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.Text = "−"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.ZIndex = 3
minBtn.Parent = panel
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

local circle = Instance.new("TextButton")
circle.Size = UDim2.new(0, 56, 0, 56)
circle.Position = UDim2.new(1, -80, 0, 100)
circle.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
circle.BorderSizePixel = 0
circle.AutoButtonColor = false
circle.Text = "ray"
circle.Font = Enum.Font.GothamBold
circle.TextSize = 14
circle.TextColor3 = Color3.fromRGB(220, 235, 255)
circle.Visible = false
circle.Active = true
circle.ZIndex = 4
circle.Parent = gui
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

local circleGlow = Instance.new("ImageLabel")
circleGlow.Image = "rbxasset://textures/ui/Glow.png"
circleGlow.ImageColor3 = Color3.fromRGB(80, 180, 255)
circleGlow.ImageTransparency = 0.4
circleGlow.BackgroundTransparency = 1
circleGlow.Size = UDim2.new(1, 36, 1, 36)
circleGlow.Position = UDim2.new(0, -18, 0, -18)
circleGlow.ZIndex = 0
circleGlow.Parent = circle
addBreathingGlow(circleGlow, 0.25, 0.55)

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(140, 200, 255)
circleStroke.Thickness = 2
circleStroke.Transparency = 0.2
circleStroke.Parent = circle

do
	local dragging, dragStart, startPos, moved
	circle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, false
			dragStart, startPos = input.Position, circle.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if not moved then
						circle.Visible = false
						panel.Visible = true
					end
				end
			end)
		end
	end)
	circle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				local delta = input.Position - dragStart
				if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then moved = true end
				circle.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end
	end)
end

minBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
	circle.Visible = true
	destroyRing()
end)
circle:GetPropertyChangedSignal("Visible"):Connect(function()
	if not circle.Visible then
		createRing(currentRange)
	else
		destroyRing()
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	destroyRing()
	gui:Destroy()
end)

--=====================================================================
--                        通知层
--=====================================================================
local notifLayer = Instance.new("Frame")
notifLayer.BackgroundTransparency = 1
notifLayer.AnchorPoint = Vector2.new(1, 1)
notifLayer.Position = UDim2.new(1, -16, 1, -16)
notifLayer.Size = UDim2.new(0, 280, 0, 420)
notifLayer.ZIndex = 100
notifLayer.Parent = gui

local nLayout = Instance.new("UIListLayout")
nLayout.Padding = UDim.new(0, 8)
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
nLayout.SortOrder = Enum.SortOrder.LayoutOrder
nLayout.Parent = notifLayer

local notifOrder = 0
local function pushNotify(text, accent)
	accent = accent or Color3.fromRGB(100, 180, 255)
	notifOrder += 1
	local kids = notifLayer:GetChildren()
	local count = 0
	for _, v in ipairs(kids) do
		if v:IsA("Frame") then count += 1 end
	end
	if count >= 5 then
		for _, v in ipairs(kids) do
			if v:IsA("Frame") then v:Destroy() break end
		end
	end

	local n = Instance.new("Frame")
	n.Size = UDim2.new(1, 0, 0, 44)
	n.BackgroundColor3 = Color3.fromRGB(20, 26, 34)
	n.BackgroundTransparency = 1
	n.BorderSizePixel = 0
	n.LayoutOrder = notifOrder
	n.ZIndex = 100
	n.Parent = notifLayer
	Instance.new("UICorner", n).CornerRadius = UDim.new(0, 10)

	local s = Instance.new("UIStroke")
	s.Color = accent
	s.Transparency = 1
	s.Thickness = 1
	s.Parent = n

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 4, 1, -16)
	bar.Position = UDim2.new(0, 9, 0, 8)
	bar.BackgroundColor3 = accent
	bar.BackgroundTransparency = 1
	bar.BorderSizePixel = 0
	bar.ZIndex = 101
	bar.Parent = n
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Position = UDim2.new(0, 22, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(220, 235, 255)
	label.TextTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.ZIndex = 101
	label.Parent = n

	TweenService:Create(n, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(s, TweenInfo.new(0.25), { Transparency = 0.55 }):Play()
	TweenService:Create(bar, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
	TweenService:Create(label, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()

	task.delay(3, function()
		if not n.Parent then return end
		TweenService:Create(n, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(s, TweenInfo.new(0.3), { Transparency = 1 }):Play()
		TweenService:Create(bar, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
		task.wait(0.35)
		n:Destroy()
	end)
end

--=====================================================================
--                        范围圈
--=====================================================================
local ringParts = {}
local currentRange = CONFIG.DefaultRange

function destroyRing()
	for _, p in ipairs(ringParts) do
		if p and p.Parent then p:Destroy() end
	end
	ringParts = {}
end

function createRing(radius)
	destroyRing()
	local thickness = 0.4
	local stepAngle = (math.pi * 2) / CONFIG.RingSegments
	local segLen = 2 * radius * math.sin(stepAngle / 2)

	for i = 1, CONFIG.RingSegments do
		local angle = (i - 1) * stepAngle
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius

		local seg = Instance.new("Part")
		seg.Name = "__RaygunRingSeg"
		seg.Anchored = true
		seg.CanCollide = false
		seg.CanQuery = false
		seg.CanTouch = false
		seg.Material = Enum.Material.Neon
		seg.Color = Color3.fromRGB(80, 180, 255)
		seg.Transparency = 0.15
		seg.Size = Vector3.new(segLen + 0.05, thickness, thickness)
		seg.CFrame = CFrame.new(x, -1000, z) * CFrame.Angles(0, -angle, 0)
		seg.Parent = workspace
		table.insert(ringParts, seg)
	end
end

function updateRingPosition(pos)
	local stepAngle = (math.pi * 2) / CONFIG.RingSegments
	for i, seg in ipairs(ringParts) do
		if seg and seg.Parent then
			local angle = (i - 1) * stepAngle
			local x = math.cos(angle) * currentRange
			local z = math.sin(angle) * currentRange
			seg.CFrame = CFrame.new(pos.X + x, pos.Y + 0.1, pos.Z + z)
				* CFrame.Angles(0, -angle, 0)
		end
	end
end

--=====================================================================
--                        UI 内容
--=====================================================================
local function makeSection(text, y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -24, 0, 20)
	l.Position = UDim2.new(0, 12, 0, y)
	l.BackgroundTransparency = 1
	l.Text = "— " .. text .. " —"
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(140, 190, 240)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 3
	l.Parent = panel
	return l
end

makeSection("状态", 34)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 20)
statusLabel.Position = UDim2.new(0, 12, 0, 56)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "总生物：--"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(200, 220, 240)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 3
statusLabel.Parent = panel

makeSection("攻击范围", 80)

local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0, 100, 0, 30)
rangeBox.Position = UDim2.new(0, 12, 0, 102)
rangeBox.BackgroundColor3 = Color3.fromRGB(30, 40, 52)
rangeBox.BorderSizePixel = 0
rangeBox.Text = tostring(CONFIG.DefaultRange)
rangeBox.PlaceholderText = "100"
rangeBox.Font = Enum.Font.Gotham
rangeBox.TextSize = 13
rangeBox.TextColor3 = Color3.fromRGB(220, 235, 255)
rangeBox.ZIndex = 3
rangeBox.Parent = panel
Instance.new("UICorner", rangeBox).CornerRadius = UDim.new(0, 6)

local rangeApplyBtn = Instance.new("TextButton")
rangeApplyBtn.Size = UDim2.new(0, 132, 0, 30)
rangeApplyBtn.Position = UDim2.new(0, 122, 0, 102)
rangeApplyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
rangeApplyBtn.BorderSizePixel = 0
rangeApplyBtn.AutoButtonColor = false
rangeApplyBtn.Text = "应用范围"
rangeApplyBtn.Font = Enum.Font.GothamBold
rangeApplyBtn.TextSize = 13
rangeApplyBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
rangeApplyBtn.ZIndex = 3
rangeApplyBtn.Parent = panel
Instance.new("UICorner", rangeApplyBtn).CornerRadius = UDim.new(0, 8)

rangeApplyBtn.MouseButton1Click:Connect(function()
	local v = tonumber(rangeBox.Text)
	if v and v > 0 then
		currentRange = v
		createRing(currentRange)
		pushNotify(("范围已设为 %d"):format(v))
	else
		pushNotify("请输入有效数字", Color3.fromRGB(230, 90, 90))
	end
end)

makeSection("攻击", 144)

local attackBtn = Instance.new("TextButton")
attackBtn.Size = UDim2.new(1, -24, 0, 40)
attackBtn.Position = UDim2.new(0, 12, 0, 166)
attackBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 200)
attackBtn.BorderSizePixel = 0
attackBtn.AutoButtonColor = false
attackBtn.Text = "自动杀戮：已关闭"
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 14
attackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
attackBtn.ZIndex = 3
attackBtn.Parent = panel
Instance.new("UICorner", attackBtn).CornerRadius = UDim.new(0, 8)

local ringBtn = Instance.new("TextButton")
ringBtn.Size = UDim2.new(1, -24, 0, 26)
ringBtn.Position = UDim2.new(0, 12, 0, 210)
ringBtn.BackgroundColor3 = Color3.fromRGB(30, 42, 56)
ringBtn.BorderSizePixel = 0
ringBtn.AutoButtonColor = false
ringBtn.Text = "显示范围圈：已开启"
ringBtn.Font = Enum.Font.GothamBold
ringBtn.TextSize = 11
ringBtn.TextColor3 = Color3.fromRGB(200, 220, 240)
ringBtn.ZIndex = 3
ringBtn.Parent = panel
Instance.new("UICorner", ringBtn).CornerRadius = UDim.new(0, 8)

makeSection("实时检测", 242)

local detectToggle = Instance.new("TextButton")
detectToggle.Size = UDim2.new(1, -24, 0, 28)
detectToggle.Position = UDim2.new(0, 12, 0, 264)
detectToggle.BackgroundColor3 = Color3.fromRGB(40, 130, 90)
detectToggle.BorderSizePixel = 0
detectToggle.AutoButtonColor = false
detectToggle.Text = "实时检测：已开启"
detectToggle.Font = Enum.Font.GothamBold
detectToggle.TextSize = 12
detectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
detectToggle.ZIndex = 3
detectToggle.Parent = panel
Instance.new("UICorner", detectToggle).CornerRadius = UDim.new(0, 8)

local detectScroll = Instance.new("ScrollingFrame")
detectScroll.Size = UDim2.new(1, -24, 0, 200)
detectScroll.Position = UDim2.new(0, 12, 0, 298)
detectScroll.BackgroundColor3 = Color3.fromRGB(14, 20, 26)
detectScroll.BorderSizePixel = 0
detectScroll.ScrollBarThickness = 4
detectScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 140, 200)
detectScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
detectScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
detectScroll.ZIndex = 3
detectScroll.Parent = panel
Instance.new("UICorner", detectScroll).CornerRadius = UDim.new(0, 8)

local detectLayout = Instance.new("UIListLayout")
detectLayout.Padding = UDim.new(0, 2)
detectLayout.SortOrder = Enum.SortOrder.LayoutOrder
detectLayout.Parent = detectScroll

--=====================================================================
--                        核心逻辑
--=====================================================================
local function getHRP()
	local c = LocalPlayer.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHandle()
	local char = LocalPlayer.Character
	if char then
		local tool = char:FindFirstChild(CONFIG.ToolRealName)
		if tool then
			local h = tool:FindFirstChild("Handle")
			if h then return h end
		end
	end
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if bp then
		local tool = bp:FindFirstChild(CONFIG.ToolRealName)
		if tool then
			local h = tool:FindFirstChild("Handle")
			if h then return h end
		end
	end
	return nil
end

local function getCreatures()
	local list = {}
	local container = workspace:FindFirstChild(CONFIG.CreatureContainerName)
	if not container then return list end
	for _, c in ipairs(container:GetChildren()) do
		if c:FindFirstChild("CreatureID") then
			table.insert(list, c)
		end
	end
	return list
end

local function findBodyPart(creature)
	if not creature then return nil end
	local h = creature:FindFirstChild("Head")
	if h and h:IsA("BasePart") then return h end
	local r = creature:FindFirstChild("Root")
	if r and r:IsA("BasePart") then return r end
	for _, d in ipairs(creature:GetDescendants()) do
		if d:IsA("BasePart") then return d end
	end
	return nil
end

local function isInRange(creature)
	local hrp = getHRP()
	if not hrp then return false end
	local part = findBodyPart(creature)
	if not part then return false end
	return (part.Position - hrp.Position).Magnitude <= currentRange
end

local sharedParams = RaycastParams.new()
sharedParams.FilterType = Enum.RaycastFilterType.Include
sharedParams.IgnoreWater = true

local cachedHandle = nil
local function getCachedHandle()
	if cachedHandle and cachedHandle.Parent then
		return cachedHandle
	end
	cachedHandle = getHandle()
	return cachedHandle
end

local function attackCreature(creature)
	if not creature or not creature.Parent then return false end
	if not RemoteFunc then return false end

	local handle = getCachedHandle()
	if not handle then return false end

	local part = findBodyPart(creature)
	if not part then return false end

	local camera = workspace.CurrentCamera
	if not camera then return false end

	local origin = camera.CFrame.Position
	local targetPos = part.Position
	local direction = targetPos - origin

	if direction.Magnitude < 0.01 then return false end

	local container = workspace:FindFirstChild(CONFIG.CreatureContainerName)
	if container then
		sharedParams.FilterDescendantsInstances = { container }
	end

	local result = workspace:Raycast(origin, direction, sharedParams)
	local hitPos
	if result then
		hitPos = result.Position
	else
		hitPos = origin + direction
	end

	local lookDir = (hitPos - origin)
	if lookDir.Magnitude < 0.01 then
		lookDir = Vector3.new(0, 0, 1)
	else
		lookDir = lookDir.Unit
	end

	local cframeStr = string.format(
		"~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ%s",
		hitPos.X, hitPos.Y, hitPos.Z,
		lookDir.X, lookDir.Y, lookDir.Z,
		CONFIG.CFrameSuffix
	)

	local ok = pcall(function()
		RemoteFunc:InvokeServer(
			makeToken(),
			"ToolReplicator",
			CONFIG.ToolName,
			CONFIG.Action,
			handle,
			"~t{1=" .. cframeStr .. "}"
		)
	end)
	return ok
end

local function attackInRange()
	local count = 0
	for _, creature in ipairs(getCreatures()) do
		if isInRange(creature) then
			task.spawn(attackCreature, creature)
			count += 1
		end
	end
	return count
end

local attackOn = false
local attackThread = nil

local function startAttack()
	if attackThread then task.cancel(attackThread) end
	attackThread = task.spawn(function()
		while attackOn do
			if RemoteFunc then
				attackInRange()
			end
			task.wait(CONFIG.AttackInterval)
		end
	end)
end

local function stopAttack()
	attackOn = false
	if attackThread then
		task.cancel(attackThread)
		attackThread = nil
	end
end

attackBtn.MouseButton1Click:Connect(function()
	attackOn = not attackOn
	if attackOn then
		if not RemoteFunc then
			pushNotify("未找到 RemoteFunction", Color3.fromRGB(230, 90, 90))
			attackOn = false
			return
		end
		attackBtn.Text = "自动杀戮：已开启"
		TweenService:Create(attackBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(90, 170, 240),
		}):Play()
		pushNotify("光线枪自动杀戮已开启")
		startAttack()
	else
		attackBtn.Text = "自动杀戮：已关闭"
		TweenService:Create(attackBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 130, 200),
		}):Play()
		pushNotify("已关闭", Color3.fromRGB(180, 190, 210))
		stopAttack()
	end
end)

local ringVisible = true
ringBtn.MouseButton1Click:Connect(function()
	ringVisible = not ringVisible
	if ringVisible then
		ringBtn.Text = "显示范围圈：已开启"
		createRing(currentRange)
	else
		ringBtn.Text = "显示范围圈：已关闭"
		destroyRing()
	end
end)

local ringConn = RunService.RenderStepped:Connect(function()
	if not gui.Parent then ringConn:Disconnect(); return end
	if not ringVisible then return end
	local hrp = getHRP()
	if hrp then updateRingPosition(hrp.Position) end
end)

--============== 实时检测 ==============
local detectOn = true
local rowPool = {}

local function getHealthInfo(creature)
	local hum = creature:FindFirstChildOfClass("Humanoid")
	if hum then return hum.Health, hum.MaxHealth end
	local h = creature:FindFirstChild("Health")
	if h and h:IsA("ValueBase") then return h.Value, 100 end
	return nil, nil
end

local function isSpecial(name)
	for _, s in ipairs(CONFIG.SpecialCreatures) do
		if name == s then return true end
	end
	return false
end

local function refreshDetect()
	for _, row in ipairs(rowPool) do
		if row and row.Parent then row:Destroy() end
	end
	rowPool = {}

	if not detectOn then return end

	local list = getCreatures()
	local hrp = getHRP()
	local order = 0

	for i, creature in ipairs(list) do
		local hp, maxHp = getHealthInfo(creature)
		local name = creature.Name
		local special = isSpecial(name)
		local inRange = isInRange(creature)
		local dist = nil
		local part = findBodyPart(creature)
		if part and hrp then
			dist = (part.Position - hrp.Position).Magnitude
		end

		order += 1
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, 0, 0, 18)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Font = Enum.Font.Code
		row.TextSize = 11
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.ZIndex = 5
		row.Parent = detectScroll

		local idxText = ("[%d]"):format(i)
		local nameText = special and ("★" .. name) or name
		local hpText
		if hp and maxHp then
			hpText = ("%d/%d"):format(math.floor(hp), math.floor(maxHp))
		else
			hpText = "无血量"
		end
		local distText = dist and ("%.0fm"):format(dist) or "--"

		row.Text = ("%s %s | %s | %s"):format(idxText, nameText, hpText, distText)

		if special and hp and hp > 0 then
			row.TextColor3 = inRange and Color3.fromRGB(255, 230, 100)
				or Color3.fromRGB(255, 180, 90)
		elseif hp and hp > 0 then
			row.TextColor3 = inRange and Color3.fromRGB(140, 210, 255)
				or Color3.fromRGB(180, 200, 220)
		else
			row.TextColor3 = Color3.fromRGB(90, 100, 110)
		end

		table.insert(rowPool, row)
	end

	if #list == 0 then
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, 0, 0, 18)
		row.BackgroundTransparency = 1
		row.LayoutOrder = 1
		row.Font = Enum.Font.Gotham
		row.TextSize = 11
		row.TextColor3 = Color3.fromRGB(120, 140, 160)
		row.Text = "（未找到生物）"
		row.ZIndex = 5
		row.Parent = detectScroll
		table.insert(rowPool, row)
	end
end

detectToggle.MouseButton1Click:Connect(function()
	detectOn = not detectOn
	if detectOn then
		detectToggle.Text = "实时检测：已开启"
		TweenService:Create(detectToggle, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(40, 130, 90),
		}):Play()
	else
		detectToggle.Text = "实时检测：已关闭"
		TweenService:Create(detectToggle, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(30, 42, 56),
		}):Play()
		for _, row in ipairs(rowPool) do
			if row and row.Parent then row:Destroy() end
		end
		rowPool = {}
	end
end)

task.spawn(function()
	while gui.Parent do
		if detectOn then refreshDetect() end
		task.wait(0.4)
	end
end)

task.spawn(function()
	while gui.Parent do
		local list = getCreatures()
		local alive, inRange = 0, 0
		for _, c in ipairs(list) do
			local hp = getHealthInfo(c)
			if hp and hp > 0 then
				alive += 1
				if isInRange(c) then inRange += 1 end
			end
		end
		statusLabel.Text = ("总生物：%d | 存活：%d | 范围内：%d")
			:format(#list, alive, inRange)
		task.wait(0.5)
	end
end)

createRing(currentRange)

pushNotify(("光线枪面板已加载 (Remote: %s)"):format(RemoteServiceName),
	Color3.fromRGB(100, 180, 255))