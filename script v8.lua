-- โหลด Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- สร้างหน้าต่างหลัก (Window)
local Window = Rayfield:CreateWindow({
    Name = "Pro Hub | Fixed Aimbot & ESP",
    LoadingTitle = "กำลังโหลดระบบ...",
    LoadingSubtitle = "By User",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ProHubConfig",
        FileName = "Config"
    },
    KeySystem = false,
})

-- สร้างแท็บเมนู
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)

-- ตัวแปรระบบบริการพื้นฐาน
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==========================================
-- ส่วนที่ 1: ระบบ Aimbot & วงกลม FOV
-- ==========================================
_G.ShowFOV = false
_G.AimbotEnabled = false
_G.FOVSize = 100

AimbotTab:CreateToggle({
    Name = "แสดงเส้น FOV",
    CurrentValue = false,
    Flag = "ShowFOVToggle",
    Callback = function(Value)
        _G.ShowFOV = Value
    end,
})

AimbotTab:CreateToggle({
    Name = "เปิดใช้งานล็อคหัว (Aimbot)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        _G.AimbotEnabled = Value
    end,
})

AimbotTab:CreateSlider({
    Name = "ปรับขนาดวงกลม FOV",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 100,
    Flag = "FOVSizeSlider",
    Callback = function(Value)
        _G.FOVSize = Value
    end,
})

-- วาดวงกลม FOV บนหน้าจอ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Transparency = 0.7
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

-- ฟังก์ชันหาเป้าหมายที่อยู่ใกล้ที่สุดในวงกลม FOV
local function GetClosestPlayerInFOV()
    local target = nil
    local shortestDist = _G.FOVSize

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local head = v.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                if dist < shortestDist then
                    shortestDist = dist
                    target = head
                end
            end
        end
    end
    return target
end

-- ลูปการทำงาน Aimbot และ FOV Circle
RunService.RenderStepped:Connect(function()
    -- จัดการแสดงผลวงกลม FOV
    if _G.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = _G.FOVSize
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        FOVCircle.Visible = false
    end

    -- จัดการระบบล็อคหัว
    if _G.AimbotEnabled then
        local targetHead = GetClosestPlayerInFOV()
        if targetHead then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
        end
    end
end)


-- ==========================================
-- ส่วนที่ 2: ระบบ ESP (ชื่อ และ กรอบตัวละคร - แก้ไขให้ใช้งานได้จริง)
-- ==========================================
_G.ESPName = false
_G.ESPBox = false

ESPTab:CreateToggle({
    Name = "แสดงชื่อผู้เล่น (Name ESP)",
    CurrentValue = false,
    Flag = "ESPNameToggle",
    Callback = function(Value)
        _G.ESPName = Value
    end,
})

ESPTab:CreateToggle({
    Name = "แสดงกรอบตัวละคร (Box ESP)",
    CurrentValue = false,
    Flag = "ESPBoxToggle",
    Callback = function(Value)
        _G.ESPBox = Value
    end,
})

-- ระบบเก็บแคช ESP ของผู้เล่นแต่ละคน
local ESPCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].NameText then ESPCache[player].NameText:Remove() end
        ESPCache[player] = nil
    end
end

Players.PlayerRemoving:Connect(RemoveESP)

-- ลูปการทำงาน ESP แสดงผลชื่อและกรอบ
RunService.RenderStepped:Connect(function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            if not ESPCache[v] then
                -- สร้างกล่อง (Box)
                local box = Drawing.new("Square")
                box.Visible = false
                box.Color = Color3.fromRGB(0, 255, 0)
                box.Thickness = 1
                box.Filled = false

                -- สร้างข้อความชื่อ (Name)
                local nameText = Drawing.new("Text")
                nameText.Visible = false
                nameText.Color = Color3.fromRGB(255, 255, 255)
                nameText.Size = 14
                nameText.Center = true
                nameText.Outline = true

                ESPCache[v] = {Box = box, NameText = nameText}
            end

            local cache = ESPCache[v]
            local char = v.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")

            if char and hrp and humanoid and humanoid.Health > 0 then
                local rootPos, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)

                if rootOnScreen then
                    -- คำนวณขนาดกรอบตามระยะทาง
                    local topPos = Camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(0, 3, 0)).Position)
                    local bottomPos = Camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(0, -3.5, 0)).Position)
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height / 2

                    -- ควบคุมการแสดงผล Box ESP
                    if _G.ESPBox then
                        cache.Box.Size = Vector2.new(width, height)
                        cache.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                        cache.Box.Visible = true
                    else
                        cache.Box.Visible = false
                    end

                    -- ควบคุมการแสดงผล Name ESP
                    if _G.ESPName then
                        cache.NameText.Text = v.Name
                        cache.NameText.Position = Vector2.new(rootPos.X, rootPos.Y - height / 2 - 18)
                        cache.NameText.Visible = true
                    else
                        cache.NameText.Visible = false
                    end
                else
                    cache.Box.Visible = false
                    cache.NameText.Visible = false
                end
            else
                cache.Box.Visible = false
                cache.NameText.Visible = false
            end
        end
    end
end)