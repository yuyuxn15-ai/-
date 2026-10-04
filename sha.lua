local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--========================= 配置区 =========================
local CONFIG = {
	CreatureContainerName = "CreatureContainer",
	AutoKillInterval      = 0.15,
	ShowHighlight         = true,
	DefaultRange          = 100,
	RingSegments          = 48,

	SpecialCreatures = {
		"Meglabone",
		"TreasureCrab",
		"Seagull",
	},

	FlyScriptURL = "https://raw.githubusercontent.com/FengYu-X/Function/refs/heads/main/fly.lua",

	ValidKeys = { "12345" },
}
--==========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "KillAuraGui"
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
--                          卡密界面
--=====================================================================
local keyPanel = Instance.new("Frame")
keyPanel.Size = UDim2.new(0, 300, 0, 200)
keyPanel.Position = UDim2.new(0.5, -150, 0.5, -100)
keyPanel.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
keyPanel.BorderSizePixel = 0
keyPanel.Active = true
keyPanel.Draggable = true
keyPanel.Parent = gui
Instance.new("UICorner", keyPanel).CornerRadius = UDim.new(0, 12)

local keyGlow = Instance.new("ImageLabel")
keyGlow.Image = "rbxasset://textures/ui/Glow.png"
keyGlow.ImageColor3 = Color3.fromRGB(255, 80, 80)
keyGlow.ImageTransparency = 0.5
keyGlow.BackgroundTransparency = 1
keyGlow.Size = UDim2.new(1, 60, 1, 60)
keyGlow.Position = UDim2.new(0, -30, 0, -30)
keyGlow.ZIndex = 0
keyGlow.Parent = keyPanel
addBreathingGlow(keyGlow, 0.4, 0.7)

local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Color3.fromRGB(255, 80, 80)
keyStroke.Thickness = 1.5
keyStroke.Transparency = 0.2
keyStroke.Parent = keyPanel

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 30)
keyTitle.Position = UDim2.new(0, 0, 0, 14)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔒 卡密验证"
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 18
keyTitle.TextColor3 = Color3.fromRGB(255, 220, 220)
keyTitle.ZIndex = 3
keyTitle.Parent = keyPanel

local keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1, -30, 0, 18)
keySub.Position = UDim2.new(0, 15, 0, 44)
keySub.BackgroundTransparency = 1
keySub.Text = "请输入卡密以使用杀戮脚本"
keySub.Font = Enum.Font.Gotham
keySub.TextSize = 12
keySub.TextColor3 = Color3.fromRGB(180, 150, 150)
keySub.ZIndex = 3
keySub.Parent = keyPanel

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -30, 0, 38)
keyBox.Position = UDim2.new(0, 15, 0, 72)
keyBox.BackgroundColor3 = Color3.fromRGB(40, 28, 28)
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "在此输入卡密"
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.TextColor3 = Color3.fromRGB(255, 240, 240)
keyBox.PlaceholderColor3 = Color3.fromRGB(150, 110, 110)
keyBox.ClearTextOnFocus = false
keyBox.ZIndex = 3
keyBox.Parent = keyPanel
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local keyBoxStroke = Instance.new("UIStroke")
keyBoxStroke.Color = Color3.fromRGB(90, 60, 60)
keyBoxStroke.Thickness = 1
keyBoxStroke.Parent = keyBox

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(1, -30, 0, 16)
keyStatus.Position = UDim2.new(0, 15, 0, 116)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 12
keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
keyStatus.TextXAlignment = Enum.TextXAlignment.Left
keyStatus.ZIndex = 3
keyStatus.Parent = keyPanel

local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(1, -30, 0, 40)
confirmBtn.Position = UDim2.new(0, 15, 0, 142)
confirmBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
confirmBtn.BorderSizePixel = 0
confirmBtn.AutoButtonColor = false
confirmBtn.Text = "验证"
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.TextSize = 14
confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmBtn.ZIndex = 3
confirmBtn.Parent = keyPanel
Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

confirmBtn.MouseEnter:Connect(function()
	TweenService:Create(confirmBtn, TweenInfo.new(0.12), {
		BackgroundColor3 = Color3.fromRGB(230, 70, 70),
	}):Play()
end)
confirmBtn.MouseLeave:Connect(function()
	TweenService:Create(confirmBtn, TweenInfo.new(0.12), {
		BackgroundColor3 = Color3.fromRGB(180, 40, 40),
	}):Play()
end)

--=====================================================================
--                          主面板
--=====================================================================
local panel, circle, notifLayer
local mainUIReady = false

local ringParts = {}
local currentRange = CONFIG.DefaultRange

local function destroyRing()
	for _, p in ipairs(ringParts) do
		if p and p.Parent then p:Destroy() end
	end
	ringParts = {}
end

local function createRing(radius)
	destroyRing()
	local thickness = 0.4
	local stepAngle = (math.pi * 2) / CONFIG.RingSegments
	local segLen = 2 * radius * math.sin(stepAngle / 2)

	for i = 1, CONFIG.RingSegments do
		local angle = (i - 1) * stepAngle
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius

		local seg = Instance.new("Part")
		seg.Name = "__KillAuraRingSeg"
		seg.Anchored = true
		seg.CanCollide = false
		seg.CanQuery = false
		seg.CanTouch = false
		seg.Material = Enum.Material.Neon
		seg.Color = Color3.fromRGB(255, 60, 60)
		seg.Transparency = 0.15
		seg.Size = Vector3.new(segLen + 0.05, thickness, thickness)
		seg.CFrame = CFrame.new(x, -1000, z) * CFrame.Angles(0, -angle, 0)
		seg.Parent = workspace
		table.insert(ringParts, seg)
	end
end

local function updateRingPosition(pos)
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

local function buildMainUI()
	if mainUIReady then return end
	mainUIReady = true

	panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 260, 0, 520)
	panel.Position = UDim2.new(0, 20, 0, 50)
	panel.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Draggable = true
	panel.Parent = gui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

	local panelGlow = Instance.new("ImageLabel")
	panelGlow.Image = "rbxasset://textures/ui/Glow.png"
	panelGlow.ImageColor3 = Color3.fromRGB(255, 80, 80)
	panelGlow.ImageTransparency = 0.55
	panelGlow.BackgroundTransparency = 1
	panelGlow.Size = UDim2.new(1, 40, 1, 40)
	panelGlow.Position = UDim2.new(0, -20, 0, -20)
	panelGlow.ZIndex = 0
	panelGlow.Parent = panel
	addBreathingGlow(panelGlow, 0.45, 0.7)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 80, 80)
	stroke.Thickness = 1
	stroke.Transparency = 0.3
	stroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -70, 0, 26)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "杀戮面板"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextColor3 = Color3.fromRGB(255, 220, 220)
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
	minBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 50)
	minBtn.BorderSizePixel = 0
	minBtn.AutoButtonColor = false
	minBtn.Text = "−"
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 16
	minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minBtn.ZIndex = 3
	minBtn.Parent = panel
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

	-- 悬浮圆球
	circle = Instance.new("TextButton")
	circle.Size = UDim2.new(0, 56, 0, 56)
	circle.Position = UDim2.new(1, -80, 0, 100)
	circle.BackgroundColor3 = Color3.fromRGB(110, 40, 40)
	circle.BorderSizePixel = 0
	circle.AutoButtonColor = false
	circle.Text = "kill"
	circle.Font = Enum.Font.GothamBold
	circle.TextSize = 16
	circle.TextColor3 = Color3.fromRGB(255, 240, 240)
	circle.Visible = false
	circle.Active = true
	circle.ZIndex = 4
	circle.Parent = gui
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

	local circleGlow = Instance.new("ImageLabel")
	circleGlow.Image = "rbxasset://textures/ui/Glow.png"
	circleGlow.ImageColor3 = Color3.fromRGB(255, 80, 80)
	circleGlow.ImageTransparency = 0.4
	circleGlow.BackgroundTransparency = 1
	circleGlow.Size = UDim2.new(1, 36, 1, 36)
	circleGlow.Position = UDim2.new(0, -18, 0, -18)
	circleGlow.ZIndex = 0
	circleGlow.Parent = circle
	addBreathingGlow(circleGlow, 0.25, 0.55)

	local circleStroke = Instance.new("UIStroke")
	circleStroke.Color = Color3.fromRGB(255, 120, 120)
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

	--============ Tab 栏 ============
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -24, 0, 26)
	tabBar.Position = UDim2.new(0, 12, 0, 28)
	tabBar.BackgroundColor3 = Color3.fromRGB(40, 28, 28)
	tabBar.BorderSizePixel = 0
	tabBar.ZIndex = 3
	tabBar.Parent = panel
	Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 8)

	local killTab = Instance.new("TextButton")
	killTab.Size = UDim2.new(0.5, 0, 1, 0)
	killTab.Position = UDim2.new(0, 0, 0, 0)
	killTab.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	killTab.BorderSizePixel = 0
	killTab.AutoButtonColor = false
	killTab.Text = "杀戮"
	killTab.Font = Enum.Font.GothamBold
	killTab.TextSize = 12
	killTab.TextColor3 = Color3.fromRGB(255, 240, 240)
	killTab.ZIndex = 4
	killTab.Parent = tabBar
	Instance.new("UICorner", killTab).CornerRadius = UDim.new(0, 8)

	local flyTab = Instance.new("TextButton")
	flyTab.Size = UDim2.new(0.5, 0, 1, 0)
	flyTab.Position = UDim2.new(0.5, 0, 0, 0)
	flyTab.BackgroundColor3 = Color3.fromRGB(40, 28, 28)
	flyTab.BorderSizePixel = 0
	flyTab.AutoButtonColor = false
	flyTab.Text = "飞行"
	flyTab.Font = Enum.Font.GothamBold
	flyTab.TextSize = 12
	flyTab.TextColor3 = Color3.fromRGB(180, 150, 150)
	flyTab.ZIndex = 4
	flyTab.Parent = tabBar
	Instance.new("UICorner", flyTab).CornerRadius = UDim.new(0, 8)

	--============ 杀戮 Tab 内容容器 ============
	local killContent = Instance.new("Frame")
	killContent.Size = UDim2.new(1, 0, 1, -60)
	killContent.Position = UDim2.new(0, 0, 0, 60)
	killContent.BackgroundTransparency = 1
	killContent.Visible = true
	killContent.ZIndex = 3
	killContent.Parent = panel

	--============ 飞行 Tab 内容容器 ============
	local flyContent = Instance.new("Frame")
	flyContent.Size = UDim2.new(1, 0, 1, -60)
	flyContent.Position = UDim2.new(0, 0, 0, 60)
	flyContent.BackgroundTransparency = 1
	flyContent.Visible = false
	flyContent.ZIndex = 3
	flyContent.Parent = panel

	-- 切换 Tab
	local function switchTab(name)
		if name == "kill" then
			killContent.Visible = true
			flyContent.Visible = false
			TweenService:Create(killTab, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(180, 40, 40),
				TextColor3 = Color3.fromRGB(255, 240, 240),
			}):Play()
			TweenService:Create(flyTab, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(40, 28, 28),
				TextColor3 = Color3.fromRGB(180, 150, 150),
			}):Play()
		else
			killContent.Visible = false
			flyContent.Visible = true
			TweenService:Create(flyTab, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(90, 60, 140),
				TextColor3 = Color3.fromRGB(240, 230, 255),
			}):Play()
			TweenService:Create(killTab, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(40, 28, 28),
				TextColor3 = Color3.fromRGB(180, 150, 150),
			}):Play()
		end
	end

	killTab.MouseButton1Click:Connect(function() switchTab("kill") end)
	flyTab.MouseButton1Click:Connect(function() switchTab("fly") end)

	--=====================================================================
	--                          通知层
	--=====================================================================
	notifLayer = Instance.new("Frame")
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
		accent = accent or Color3.fromRGB(230, 80, 80)
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
		n.BackgroundColor3 = Color3.fromRGB(30, 22, 22)
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
		label.TextColor3 = Color3.fromRGB(255, 235, 235)
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
	--                     飞行 Tab 内容（只有 1 个按钮）
	--=====================================================================
	local flyHint = Instance.new("TextLabel")
	flyHint.Size = UDim2.new(1, -24, 0, 40)
	flyHint.Position = UDim2.new(0, 12, 0, 20)
	flyHint.BackgroundTransparency = 1
	flyHint.Text = "点击下方按钮开启飞行\n加载后请按提示操作"
	flyHint.Font = Enum.Font.Gotham
	flyHint.TextSize = 12
	flyHint.TextColor3 = Color3.fromRGB(200, 180, 220)
	flyHint.TextXAlignment = Enum.TextXAlignment.Center
	flyHint.TextWrapped = true
	flyHint.ZIndex = 4
	flyHint.Parent = flyContent

	local flyBtn = Instance.new("TextButton")
	flyBtn.Size = UDim2.new(1, -48, 0, 60)
	flyBtn.Position = UDim2.new(0, 24, 0, 90)
	flyBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 140)
	flyBtn.BorderSizePixel = 0
	flyBtn.AutoButtonColor = false
	flyBtn.Text = "开启飞行"
	flyBtn.Font = Enum.Font.GothamBold
	flyBtn.TextSize = 18
	flyBtn.TextColor3 = Color3.fromRGB(240, 230, 255)
	flyBtn.ZIndex = 4
	flyBtn.Parent = flyContent
	Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 12)

	local flyBtnStroke = Instance.new("UIStroke")
	flyBtnStroke.Color = Color3.fromRGB(150, 120, 220)
	flyBtnStroke.Thickness = 2
	flyBtnStroke.Transparency = 0.2
	flyBtnStroke.Parent = flyBtn

	flyBtn.MouseEnter:Connect(function()
		TweenService:Create(flyBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(120, 85, 180),
		}):Play()
		TweenService:Create(flyBtnStroke, TweenInfo.new(0.15), {
			Transparency = 0,
		}):Play()
	end)
	flyBtn.MouseLeave:Connect(function()
		TweenService:Create(flyBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(90, 60, 140),
		}):Play()
		TweenService:Create(flyBtnStroke, TweenInfo.new(0.15), {
			Transparency = 0.2,
		}):Play()
	end)

	local flyStatus = Instance.new("TextLabel")
	flyStatus.Size = UDim2.new(1, -24, 0, 20)
	flyStatus.Position = UDim2.new(0, 12, 0, 162)
	flyStatus.BackgroundTransparency = 1
	flyStatus.Text = ""
	flyStatus.Font = Enum.Font.Gotham
	flyStatus.TextSize = 12
	flyStatus.TextColor3 = Color3.fromRGB(180, 220, 180)
	flyStatus.TextXAlignment = Enum.TextXAlignment.Center
	flyStatus.ZIndex = 4
	flyStatus.Parent = flyContent

	local flyLoading = false
	flyBtn.MouseButton1Click:Connect(function()
		if flyLoading then return end
		flyLoading = true
		flyStatus.Text = "加载中..."
		flyStatus.TextColor3 = Color3.fromRGB(220, 200, 150)

		task.spawn(function()
			local ok, err = pcall(function()
				loadstring(game:HttpGet(CONFIG.FlyScriptURL))()
			end)
			if ok then
				flyStatus.Text = "✓ 飞行已加载"
				flyStatus.TextColor3 = Color3.fromRGB(120, 220, 120)
				pushNotify("飞行脚本已加载", Color3.fromRGB(150, 120, 220))
			else
				flyStatus.Text = "✗ 加载失败"
				flyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
				pushNotify("飞行脚本加载失败", Color3.fromRGB(230, 90, 90))
				warn("[Fly] " .. tostring(err))
			end
			task.wait(1)
			flyLoading = false
		end)
	end)

	--=====================================================================
	--                        杀戮核心
	--=====================================================================
	local function getCreatures()
		local list = {}
		local container = workspace:FindFirstChild(CONFIG.CreatureContainerName)
		if not container then return list end
		for _, child in ipairs(container:GetChildren()) do
			table.insert(list, child)
		end
		return list
	end

	local function findHumanoid(creature)
		if not creature then return nil end
		local hum = creature:FindFirstChildOfClass("Humanoid")
		if hum then return hum end
		for _, d in ipairs(creature:GetDescendants()) do
			if d:IsA("Humanoid") then return d end
		end
		return nil
	end

	local function findHealthObject(creature)
		if not creature then return nil end
		local h = creature:FindFirstChild("Health")
		if h and (h:IsA("NumberValue") or h:IsA("IntValue")) then
			return h
		end
		for _, d in ipairs(creature:GetDescendants()) do
			if d.Name == "Health" and (d:IsA("NumberValue") or d:IsA("IntValue")) then
				return d
			end
		end
		return nil
	end

	local function findBodyPart(creature)
		if not creature then return nil end
		local head = creature:FindFirstChild("Head")
		if head and head:IsA("BasePart") then return head end
		local root = creature:FindFirstChild("Root")
		if root and root:IsA("BasePart") then return root end
		for _, d in ipairs(creature:GetDescendants()) do
			if d:IsA("BasePart") then return d end
		end
		return nil
	end

	local function isInRange(creature)
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return false end
		local part = findBodyPart(creature)
		if not part then return false end
		return (part.Position - hrp.Position).Magnitude <= currentRange
	end

	local function killCreature(creature)
		local hum = findHumanoid(creature)
		local healthObj = findHealthObject(creature)
		local didSomething = false

		if hum and hum.Health > 0 then
			local ok = pcall(function() hum.Health = 0 end)
			if not ok then
				pcall(function() hum:TakeDamage(hum.MaxHealth + 9999) end)
			end
			didSomething = true
		end

		if healthObj then
			pcall(function()
				if healthObj.Value > 0 then
					healthObj.Value = 0
					didSomething = true
				end
			end)
		end

		if didSomething and CONFIG.ShowHighlight then
			local part = findBodyPart(creature)
			if part then
				local hl = Instance.new("Highlight")
				hl.Name = "__KillHL"
				hl.Adornee = creature
				hl.FillColor = Color3.fromRGB(255, 30, 30)
				hl.FillTransparency = 0.3
				hl.OutlineColor = Color3.fromRGB(255, 30, 30)
				hl.OutlineTransparency = 0
				hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				hl.Parent = creature
				task.delay(0.4, function()
					if hl and hl.Parent then hl:Destroy() end
				end)
			end
		end

		return didSomething
	end

	local function killInRange()
		local killed = 0
		for _, creature in ipairs(getCreatures()) do
			if isInRange(creature) then
				if killCreature(creature) then
					killed += 1
				end
			end
		end
		return killed
	end

	--=====================================================================
	--                        杀戮 UI 内容
	--=====================================================================
	local function makeSection(text, y)
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -24, 0, 20)
		l.Position = UDim2.new(0, 12, 0, y)
		l.BackgroundTransparency = 1
		l.Text = "— " .. text .. " —"
		l.Font = Enum.Font.GothamBold
		l.TextSize = 12
		l.TextColor3 = Color3.fromRGB(220, 150, 150)
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.ZIndex = 4
		l.Parent = killContent
		return l
	end

	makeSection("状态", 4)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Size = UDim2.new(1, -24, 0, 20)
	statusLabel.Position = UDim2.new(0, 12, 0, 26)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "生物数：--"
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 12
	statusLabel.TextColor3 = Color3.fromRGB(220, 200, 200)
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.ZIndex = 4
	statusLabel.Parent = killContent

	makeSection("杀戮范围", 52)

	local rangeBox = Instance.new("TextBox")
	rangeBox.Size = UDim2.new(0, 100, 0, 30)
	rangeBox.Position = UDim2.new(0, 12, 0, 74)
	rangeBox.BackgroundColor3 = Color3.fromRGB(40, 28, 28)
	rangeBox.BorderSizePixel = 0
	rangeBox.Text = tostring(CONFIG.DefaultRange)
	rangeBox.PlaceholderText = "100"
	rangeBox.Font = Enum.Font.Gotham
	rangeBox.TextSize = 13
	rangeBox.TextColor3 = Color3.fromRGB(255, 235, 235)
	rangeBox.ZIndex = 4
	rangeBox.Parent = killContent
	Instance.new("UICorner", rangeBox).CornerRadius = UDim.new(0, 6)

	local rangeApplyBtn = Instance.new("TextButton")
	rangeApplyBtn.Size = UDim2.new(0, 132, 0, 30)
	rangeApplyBtn.Position = UDim2.new(0, 122, 0, 74)
	rangeApplyBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 50)
	rangeApplyBtn.BorderSizePixel = 0
	rangeApplyBtn.AutoButtonColor = false
	rangeApplyBtn.Text = "应用范围"
	rangeApplyBtn.Font = Enum.Font.GothamBold
	rangeApplyBtn.TextSize = 13
	rangeApplyBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
	rangeApplyBtn.ZIndex = 4
	rangeApplyBtn.Parent = killContent
	Instance.new("UICorner", rangeApplyBtn).CornerRadius = UDim.new(0, 8)

	rangeApplyBtn.MouseButton1Click:Connect(function()
		local v = tonumber(rangeBox.Text)
		if v and v > 0 then
			currentRange = v
			createRing(currentRange)
			pushNotify(("杀戮范围已设为 %d"):format(v),
				Color3.fromRGB(255, 150, 150))
		else
			pushNotify("请输入有效数字", Color3.fromRGB(230, 90, 90))
		end
	end)

	local rangeHint = Instance.new("TextLabel")
	rangeHint.Size = UDim2.new(1, -24, 0, 14)
	rangeHint.Position = UDim2.new(0, 12, 0, 108)
	rangeHint.BackgroundTransparency = 1
	rangeHint.Text = "红圈为杀戮范围"
	rangeHint.Font = Enum.Font.Gotham
	rangeHint.TextSize = 11
	rangeHint.TextColor3 = Color3.fromRGB(180, 150, 150)
	rangeHint.TextXAlignment = Enum.TextXAlignment.Left
	rangeHint.ZIndex = 4
	rangeHint.Parent = killContent

	local killBtn = Instance.new("TextButton")
	killBtn.Size = UDim2.new(1, -24, 0, 34)
	killBtn.Position = UDim2.new(0, 12, 0, 128)
	killBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	killBtn.BorderSizePixel = 0
	killBtn.AutoButtonColor = false
	killBtn.Text = "一键杀戮（范围内）"
	killBtn.Font = Enum.Font.GothamBold
	killBtn.TextSize = 13
	killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	killBtn.ZIndex = 4
	killBtn.Parent = killContent
	Instance.new("UICorner", killBtn).CornerRadius = UDim.new(0, 8)

	local autoBtn = Instance.new("TextButton")
	autoBtn.Size = UDim2.new(1, -24, 0, 32)
	autoBtn.Position = UDim2.new(0, 12, 0, 168)
	autoBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 40)
	autoBtn.BorderSizePixel = 0
	autoBtn.AutoButtonColor = false
	autoBtn.Text = "自动杀戮：已关闭"
	autoBtn.Font = Enum.Font.GothamBold
	autoBtn.TextSize = 12
	autoBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
	autoBtn.ZIndex = 4
	autoBtn.Parent = killContent
	Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 8)

	local ringBtn = Instance.new("TextButton")
	ringBtn.Size = UDim2.new(1, -24, 0, 26)
	ringBtn.Position = UDim2.new(0, 12, 0, 206)
	ringBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 40)
	ringBtn.BorderSizePixel = 0
	ringBtn.AutoButtonColor = false
	ringBtn.Text = "显示范围圈：已开启"
	ringBtn.Font = Enum.Font.GothamBold
	ringBtn.TextSize = 11
	ringBtn.TextColor3 = Color3.fromRGB(220, 200, 200)
	ringBtn.ZIndex = 4
	ringBtn.Parent = killContent
	Instance.new("UICorner", ringBtn).CornerRadius = UDim.new(0, 8)

	makeSection("实时检测", 238)

	local detectToggle = Instance.new("TextButton")
	detectToggle.Size = UDim2.new(1, -24, 0, 28)
	detectToggle.Position = UDim2.new(0, 12, 0, 260)
	detectToggle.BackgroundColor3 = Color3.fromRGB(60, 140, 90)
	detectToggle.BorderSizePixel = 0
	detectToggle.AutoButtonColor = false
	detectToggle.Text = "实时检测：已开启"
	detectToggle.Font = Enum.Font.GothamBold
	detectToggle.TextSize = 12
	detectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	detectToggle.ZIndex = 4
	detectToggle.Parent = killContent
	Instance.new("UICorner", detectToggle).CornerRadius = UDim.new(0, 8)

	local detectScroll = Instance.new("ScrollingFrame")
	detectScroll.Size = UDim2.new(1, -24, 0, 140)
	detectScroll.Position = UDim2.new(0, 12, 0, 294)
	detectScroll.BackgroundColor3 = Color3.fromRGB(20, 14, 14)
	detectScroll.BorderSizePixel = 0
	detectScroll.ScrollBarThickness = 4
	detectScroll.ScrollBarImageColor3 = Color3.fromRGB(120, 60, 60)
	detectScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	detectScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	detectScroll.ZIndex = 4
	detectScroll.Parent = killContent
	Instance.new("UICorner", detectScroll).CornerRadius = UDim.new(0, 8)

	local detectLayout = Instance.new("UIListLayout")
	detectLayout.Padding = UDim.new(0, 2)
	detectLayout.SortOrder = Enum.SortOrder.LayoutOrder
	detectLayout.Parent = detectScroll

	local detectHint = Instance.new("TextLabel")
	detectHint.Size = UDim2.new(1, -16, 0, 24)
	detectHint.Position = UDim2.new(0, 8, 0, 6)
	detectHint.BackgroundTransparency = 1
	detectHint.Text = "开启后实时显示生物血量"
	detectHint.Font = Enum.Font.Gotham
	detectHint.TextSize = 11
	detectHint.TextColor3 = Color3.fromRGB(150, 120, 120)
	detectHint.TextXAlignment = Enum.TextXAlignment.Left
	detectHint.Visible = false
	detectHint.ZIndex = 5
	detectHint.Parent = detectScroll

	--=====================================================================
	--                        按钮逻辑
	--=====================================================================
	killBtn.MouseButton1Click:Connect(function()
		TweenService:Create(killBtn, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(230, 70, 70),
		}):Play()
		task.delay(0.15, function()
			if killBtn.Parent then
				TweenService:Create(killBtn, TweenInfo.new(0.2), {
					BackgroundColor3 = Color3.fromRGB(180, 40, 40),
				}):Play()
			end
		end)

		local n = killInRange()
		pushNotify(("已击杀 %d 个生物（范围 %d）"):format(n, currentRange))
	end)

	local autoOn = false
	local autoThread = nil

	local function startAuto()
		if autoThread then task.cancel(autoThread) end
		autoThread = task.spawn(function()
			while autoOn do
				killInRange()
				task.wait(CONFIG.AutoKillInterval)
			end
		end)
	end

	local function stopAuto()
		autoOn = false
		if autoThread then task.cancel(autoThread); autoThread = nil end
	end

	autoBtn.MouseButton1Click:Connect(function()
		autoOn = not autoOn
		if autoOn then
			autoBtn.Text = "自动杀戮：已开启"
			TweenService:Create(autoBtn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(180, 40, 40),
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
			pushNotify("自动杀戮已开启（范围内）")
			startAuto()
		else
			autoBtn.Text = "自动杀戮：已关闭"
			TweenService:Create(autoBtn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(50, 40, 40),
				TextColor3 = Color3.fromRGB(200, 200, 215),
			}):Play()
			pushNotify("自动杀戮已关闭", Color3.fromRGB(200, 150, 150))
			stopAuto()
		end
	end)

	local ringVisible = true
	ringBtn.MouseButton1Click:Connect(function()
		ringVisible = not ringVisible
		if ringVisible then
			ringBtn.Text = "显示范围圈：已开启"
			createRing(currentRange)
			pushNotify("已显示范围圈", Color3.fromRGB(255, 150, 150))
		else
			ringBtn.Text = "显示范围圈：已关闭"
			destroyRing()
			pushNotify("已隐藏范围圈", Color3.fromRGB(180, 150, 150))
		end
	end)

	local ringUpdateConn = RunService.RenderStepped:Connect(function()
		if not gui.Parent then
			ringUpdateConn:Disconnect()
			return
		end
		if not ringVisible then return end
		if not killContent.Visible then return end
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			updateRingPosition(hrp.Position)
		end
	end)

	--=====================================================================
	--                    实时检测逻辑
	--=====================================================================
	local detectOn = true
	local rowPool = {}

	local function getHealthInfo(creature)
		local hum = findHumanoid(creature)
		if hum then
			return hum.Health, hum.MaxHealth
		end
		local hObj = findHealthObject(creature)
		if hObj then
			return hObj.Value, math.max(hObj.Value, 100)
		end
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

		if not detectOn then
			detectHint.Visible = true
			return
		end
		detectHint.Visible = false

		local list = getCreatures()
		local order = 0

		for i, creature in ipairs(list) do
			local hp, maxHp = getHealthInfo(creature)
			local name = creature.Name
			local special = isSpecial(name)
			local inRange = isInRange(creature)
			local pos = nil
			local part = findBodyPart(creature)
			if part then
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					pos = (part.Position - hrp.Position).Magnitude
				end
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
			local distText = pos and ("%.0fm"):format(pos) or "--"

			row.Text = ("%s %s | %s | %s"):format(idxText, nameText, hpText, distText)

			if hp and hp > 0 then
				row.TextColor3 = inRange and Color3.fromRGB(255, 200, 120)
					or Color3.fromRGB(230, 180, 180)
			else
				row.TextColor3 = Color3.fromRGB(120, 80, 80)
			end
			if special and hp and hp > 0 then
				row.TextColor3 = inRange and Color3.fromRGB(255, 230, 100)
					or Color3.fromRGB(255, 180, 90)
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
			row.TextColor3 = Color3.fromRGB(150, 120, 120)
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
				BackgroundColor3 = Color3.fromRGB(60, 140, 90),
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
			pushNotify("实时检测已开启", Color3.fromRGB(120, 220, 160))
		else
			detectToggle.Text = "实时检测：已关闭"
			TweenService:Create(detectToggle, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(50, 40, 40),
				TextColor3 = Color3.fromRGB(200, 200, 215),
			}):Play()
			pushNotify("实时检测已关闭", Color3.fromRGB(180, 150, 150))
		end
	end)

	task.spawn(function()
		while gui.Parent do
			if detectOn and killContent.Visible then
				refreshDetect()
			end
			task.wait(0.4)
		end
	end)

	task.spawn(function()
		while gui.Parent do
			local list = getCreatures()
			local alive = 0
			local inRangeCount = 0
			for _, c in ipairs(list) do
				local hum = findHumanoid(c)
				local hObj = findHealthObject(c)
				local hp = hum and hum.Health or (hObj and hObj.Value) or 0
				if hp > 0 then
					alive += 1
					if isInRange(c) then
						inRangeCount += 1
					end
				end
			end
			statusLabel.Text = ("总生物：%d | 存活：%d | 范围内：%d")
				:format(#list, alive, inRangeCount)
			task.wait(0.3)
		end
	end)

	createRing(currentRange)
	pushNotify("杀戮脚本已加载", Color3.fromRGB(255, 120, 120))
end

--=====================================================================
--                        卡密验证逻辑
--=====================================================================
local verifying = false

local function tryVerify()
	if verifying then return end
	verifying = true

	local input = keyBox.Text or ""
	input = input:gsub("%s", "")

	local valid = false
	for _, k in ipairs(CONFIG.ValidKeys) do
		if input == k then
			valid = true
			break
		end
	end

	if valid then
		keyStatus.Text = "✓ 验证成功"
		keyStatus.TextColor3 = Color3.fromRGB(120, 220, 120)
		keyBoxStroke.Color = Color3.fromRGB(90, 200, 90)
		TweenService:Create(confirmBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 180, 90),
		}):Play()

		task.wait(0.5)

		TweenService:Create(keyPanel, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
		}):Play()
		for _, d in ipairs(keyPanel:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextBox") then
				TweenService:Create(d, TweenInfo.new(0.3), {
					TextTransparency = 1,
				}):Play()
			elseif d:IsA("TextButton") then
				TweenService:Create(d, TweenInfo.new(0.3), {
					BackgroundTransparency = 1,
					TextTransparency = 1,
				}):Play()
			elseif d:IsA("Frame") and d ~= keyPanel then
				TweenService:Create(d, TweenInfo.new(0.3), {
					BackgroundTransparency = 1,
				}):Play()
			elseif d:IsA("ImageLabel") then
				TweenService:Create(d, TweenInfo.new(0.3), {
					ImageTransparency = 1,
					BackgroundTransparency = 1,
				}):Play()
			elseif d:IsA("UIStroke") then
				TweenService:Create(d, TweenInfo.new(0.3), {
					Transparency = 1,
				}):Play()
			end
		end

		task.wait(0.35)
		keyPanel:Destroy()
		buildMainUI()
	else
		keyStatus.Text = "✗ 卡密错误，请重新输入"
		keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
		keyBoxStroke.Color = Color3.fromRGB(200, 60, 60)

		local origPos = keyPanel.Position
		for i = 1, 4 do
			keyPanel.Position = UDim2.new(
				origPos.X.Scale, origPos.X.Offset + (i % 2 == 0 and 8 or -8),
				origPos.Y.Scale, origPos.Y.Offset
			)
			task.wait(0.04)
		end
		keyPanel.Position = origPos
	end

	task.wait(0.3)
	verifying = false
end

confirmBtn.MouseButton1Click:Connect(tryVerify)

keyBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		tryVerify()
	end
end)

task.defer(function()
	task.wait(0.3)
	keyBox:CaptureFocus()
end)