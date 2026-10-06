-- ============================================
--   Beacon 自动检测 + 自动开枪（极简UI）
-- ============================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

--============================ 配置 ============================
local CONFIG = {
    KeyWord = "Beacon",      -- 检测的子物品名
    Radius  = 1000,          -- 搜索半径
    AttackInterval = 0.1,    -- 开枪间隔（别低于0.05，容易被服务器吞包）
    Sniper = {
        Token = 30725992,
        ToolName = "~sGun",
        ToolRealName = "Sniper Rifle",
        CFrameSuffix = "-1",
    },
}

--============================ 获取远程函数 ============================
local RemoteFunc
for _, name in ipairs({ "SocialService", "LogService", "Chat", "LocalizationService" }) do
    local ok, svc = pcall(function() return game:GetService(name) end)
    if ok and svc then
        local rf = svc:FindFirstChild("RemoteFunction")
        if rf then RemoteFunc = rf; break end
    end
end

--============================ 极简 UI ============================
local gui = Instance.new("ScreenGui")
gui.Name = "BeaconAuto"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local box = Instance.new("Frame")
box.Size = UDim2.fromOffset(180, 26)
box.Position = UDim2.fromOffset(20, 100)
box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
box.BorderSizePixel = 0
box.Active = true
box.Parent = gui
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

local txt = Instance.new("TextLabel")
txt.Size = UDim2.new(1, -8, 1, 0)
txt.Position = UDim2.fromOffset(8, 0)
txt.BackgroundTransparency = 1
txt.Font = Enum.Font.GothamBold
txt.TextSize = 12
txt.TextColor3 = Color3.fromRGB(230, 230, 235)
txt.TextXAlignment = Enum.TextXAlignment.Left
txt.Text = "初始化..."
txt.Parent = box

-- 拖动
local drag, s, sp
box.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; s = i.Position; sp = box.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
    if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - s
        box.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end
end)

--============================ 攻击逻辑 ============================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function getHandle(name)
    local c = LP.Character
    if c then
        local t = c:FindFirstChild(name)
        if t then
            local h = t:FindFirstChild("Handle")
            if h then return h, t end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        local t2 = bp:FindFirstChild(name)
        if t2 then return t2:FindFirstChild("Handle"), t2 end
    end
end

local function cframeAttack(targetPos)
    local handle, tool = getHandle(CONFIG.Sniper.ToolRealName)
    if not handle then return false, "未装备武器" end

    -- 如果武器在背包里，自动装备
    if tool and tool.Parent ~= LP.Character then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool) end
    end

    local camera = workspace.CurrentCamera
    if not camera then return false, "无相机" end

    local origin = camera.CFrame.Position
    local dir = targetPos - origin
    if dir.Magnitude < 0.01 then return false, "距离过近" end

    -- 刷新射线过滤（排除自己）
    if LP.Character then rayParams.FilterDescendantsInstances = { LP.Character } end

    local result = workspace:Raycast(origin, dir, rayParams)
    local hitPos = result and result.Position or (origin + dir)

    local lookDir = hitPos - origin
    lookDir = lookDir.Magnitude > 0.01 and lookDir.Unit or Vector3.new(0, 0, 1)

    local cf = string.format("~f%.4f,%.4f,%.4f:%.4f,%.4f,%.4fZ%s",
        hitPos.X, hitPos.Y, hitPos.Z,
        lookDir.X, lookDir.Y, lookDir.Z,
        CONFIG.Sniper.CFrameSuffix)

    if not RemoteFunc then return false, "未找到远程函数" end

    pcall(function()
        RemoteFunc:InvokeServer(
            CONFIG.Sniper.Token,
            "ToolReplicator",
            CONFIG.Sniper.ToolName,
            "~sShoot",
            handle,
            "~t{1=" .. cf .. "}"
        )
    end)
    return true, "开枪"
end

--============================ 主循环 ============================
local lowKW = string.lower(CONFIG.KeyWord)

task.spawn(function()
    while gui.Parent do
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local myPos = hrp and hrp.Position
        
        local target = nil
        local minDist = CONFIG.Radius

        -- 找最近的 Beacon
        for _, d in ipairs(workspace:GetDescendants()) do
            if string.find(string.lower(d.Name), lowKW, 1, true) then
                if d:IsA("BasePart") and myPos then
                    local dist = (d.Position - myPos).Magnitude
                    if dist <= minDist then
                        minDist = dist
                        target = d
                    end
                else
                    -- 如果是 Model/Folder，找里面的 Part
                    if d:IsA("Model") then
                        local p = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart", true)
                        if p and myPos then
                            local dist = (p.Position - myPos).Magnitude
                            if dist <= minDist then
                                minDist = dist
                                target = p
                            end
                        end
                    end
                end
            end
        end

        -- 攻击 / 更新 UI
        if target then
            local ok, msg = cframeAttack(target.Position)
            if ok then
                txt.Text = string.format("%s: %.0fm [开火]", CONFIG.KeyWord, minDist)
                txt.TextColor3 = Color3.fromRGB(90, 220, 130)
            else
                txt.Text = string.format("%s: %.0fm [%s]", CONFIG.KeyWord, minDist, msg)
                txt.TextColor3 = Color3.fromRGB(255, 180, 80)
            end
        else
            txt.Text = string.format("%s: 无目标", CONFIG.KeyWord)
            txt.TextColor3 = Color3.fromRGB(230, 100, 100)
        end

        task.wait(CONFIG.AttackInterval)
    end
end)