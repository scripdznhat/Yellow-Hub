local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- [TỐI ƯU HÓA] CACHING SERVICES VÀ BỘ NHỚ
local TargetGui = (game:GetService("CoreGui") or player:WaitForChild("PlayerGui"))
local AnimIn = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local AnimOut = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

-- URL Host của bạn
local BASE_URL = "https://yellowhub.ldtroblox.site"
local SAVE_FILE = "scripttest.txt"

-- ==========================================
-- TỰ ĐỘNG LẤY HWID CHUẨN XÁC
-- ==========================================
local function getHWID()
    local ok, val = pcall(function() return getexecutorinfo().hwid end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function() return syn.get_hwid() end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function() return HWID end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function() return fluxus.get_hwid() end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function() return evon.get_hwid() end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function() return solara.get_hwid() end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function() return wave.get_hwid() end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function()
        local info = getexecutorinfo()
        return info.hwid or info.id or info.fingerprint
    end)
    if ok and val and val ~= "" then return tostring(val) end

    ok, val = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if ok and val and val ~= "" then return tostring(val) end

    return tostring(player.UserId)
end

-- ==========================================
-- HỆ THỐNG THÔNG BÁO (NOTIFY UI)
-- ==========================================
local function showNotify(title, message, link, duration)
    local ng = Instance.new("ScreenGui")
    ng.Name = "YellowNotify"
    ng.ResetOnSpawn = false
    ng.IgnoreGuiInset = true 
    ng.ZIndexBehavior = Enum.ZIndexBehavior.Sibling 
    ng.Parent = TargetGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 90)
    frame.Position = UDim2.new(1, 10, 1, -110)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = ng
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Thickness = 2
    stroke.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Text = message
    msgLabel.Size = UDim2.new(1, -10, 0, 25)
    msgLabel.Position = UDim2.new(0, 10, 0, 28)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.Parent = frame

    if link then
        local clickBtn = Instance.new("TextButton")
        clickBtn.Text = "🔗 Click to copy link"
        clickBtn.Size = UDim2.new(1, -20, 0, 22)
        clickBtn.Position = UDim2.new(0, 10, 0, 60)
        clickBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        clickBtn.TextColor3 = Color3.fromRGB(100, 180, 255)
        clickBtn.TextSize = 11
        clickBtn.Font = Enum.Font.Gotham
        clickBtn.BorderSizePixel = 0
        clickBtn.Parent = frame
        Instance.new("UICorner", clickBtn).CornerRadius = UDim.new(0, 6)
        clickBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(link)
                clickBtn.Text = "✅ Copied!"
                clickBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
            end
        end)
    end

    TweenService:Create(frame, AnimIn, { Position = UDim2.new(1, -290, 1, -110) }):Play()
    task.wait(duration or 3)
    TweenService:Create(frame, AnimOut, { Position = UDim2.new(1, 10, 1, -110) }):Play()
    task.wait(0.4)
    ng:Destroy()
end

-- ==========================================
-- HỆ THỐNG LƯU VÀ ĐỌC KEY
-- ==========================================
local function saveKey(key, hwid)
    pcall(function()
        if writefile then writefile(SAVE_FILE, key .. "|" .. hwid) end
    end)
end

local function loadKey(hwid)
    local ok, result = pcall(function()
        if isfile and readfile and isfile(SAVE_FILE) then
            return readfile(SAVE_FILE)
        end
        return nil
    end)
    if not ok or not result or result == "" then return nil end
    local savedKey, savedHwid = result:match("^(.+)|(.+)$")
    if not savedKey then return result end
    if savedHwid ~= hwid then return nil end
    return savedKey
end

local function clearKey()
    pcall(function()
        if isfile and delfile and isfile(SAVE_FILE) then
            delfile(SAVE_FILE)
        end
    end)
end

-- ==========================================
-- CHECK KEY TỪ HOST LDTROBLOX
-- ==========================================
local function validateKey(key, hwid)
    key = string.gsub(key, "^%s*(.-)%s*$", "%1")
    if key == "" then return false, "Key trống!" end

    local success, phanHoiTuHost = pcall(function()
        local linkCheck = BASE_URL .. "/check.php?key=" .. key .. "&hwid=" .. hwid
        return game:HttpGet(linkCheck)
    end)

    if success then
        local realResponse = string.gsub(phanHoiTuHost, "^%s*(.-)%s*$", "%1")
        
        if realResponse == "DUNG" then
            return true, "Key Valid"
        elseif realResponse == "SAI" then
            clearKey()
            return false, "Key Sai Hoặc Chưa Vượt Link!"
        elseif realResponse == "BANNED" then
            clearKey()
            return false, "Key Này Đã Bị Admin Khóa!"
        elseif realResponse == "EXPIRED" then
            clearKey()
            return false, "Key Đã Hết Hạn 24H!"
        elseif realResponse == "SAI_HWID" then
            clearKey()
            return false, "Key Này Của Thiết Bị Khác!"
        else
            return false, "Lỗi Máy Chủ: " .. tostring(realResponse)
        end
    else
        return false, "Lỗi Kết Nối Host!"
    end
end

-- ==========================================
-- HÀM SAFELOAD MỚI GỌN GÀNG VÀ CHỐNG ĐƠ
-- ==========================================
local function SafeLoad(url)
    task.spawn(function()
        showNotify("Yellow Hub", "⏳ Đang tải Hub, vui lòng chờ...", nil, 2)
        
        local success, code = pcall(function()
            return game:HttpGet(url .. "?v=" .. tostring(tick()))
        end)

        if success and code and code ~= "" then
            local execSuccess, execErr = pcall(function()
                getgenv().team = "Pirates" -- Gán team mặc định
                local func = loadstring(code)
                if func then
                    task.spawn(func)
                else
                    error("Loadstring bị từ chối")
                end
            end)
            
            if execSuccess then
                showNotify("Yellow Hub", "✅ Kích hoạt Script thành công!", nil, 3)
            else
                warn("Yellow Hub Execute Error: " .. tostring(execErr))
                showNotify("Yellow Hub", "❌ Lỗi kích hoạt bên trong Script!", nil, 5)
            end
        else
            warn("Yellow Hub HTTP Error: " .. tostring(code))
            showNotify("Yellow Hub", "❌ Lỗi tải file từ Server. Vui lòng thử lại!", nil, 5)
        end
    end)
end

-- ==========================================
-- GIAO DIỆN GET KEY
-- ==========================================
local function createUI(hwid)
    local GET_KEY_URL = BASE_URL .. "/index.php?hwid=" .. hwid

    local gui = Instance.new("ScreenGui")
    gui.Name = "YellowKeySystem"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = TargetGui

    task.spawn(function()
        showNotify("Yellow Hub", "Get key link copied! Paste in browser.", GET_KEY_URL, 5)
    end)

    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 380, 0, 300)
    MainContainer.Position = UDim2.new(0.5, -190, 0.5, -150)
    MainContainer.BackgroundTransparency = 1
    MainContainer.Parent = gui

    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Image = "rbxassetid://115080933887415"
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Parent = MainContainer
    Instance.new("UICorner", BackgroundImage).CornerRadius = UDim.new(0, 10)

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 0.5
    Overlay.Parent = BackgroundImage
    Instance.new("UICorner", Overlay).CornerRadius = UDim.new(0, 10)

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundTransparency = 1
    MainFrame.Parent = BackgroundImage

    local Title = Instance.new("TextLabel")
    Title.Text = "Yellow Hub  |  Key System"
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 8)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 17
    Title.Font = Enum.Font.GothamBold
    Title.TextStrokeTransparency = 0.5
    Title.Parent = MainFrame

    local Step1Label = Instance.new("TextLabel")
    Step1Label.Text = "Step 1 : Press [Get Key] → Paste Link In Browser"
    Step1Label.Size = UDim2.new(1, -20, 0, 22)
    Step1Label.Position = UDim2.new(0, 10, 0, 45)
    Step1Label.BackgroundTransparency = 1
    Step1Label.TextColor3 = Color3.fromRGB(255, 200, 80)
    Step1Label.TextSize = 12
    Step1Label.Font = Enum.Font.GothamBold
    Step1Label.TextXAlignment = Enum.TextXAlignment.Left
    Step1Label.TextWrapped = true
    Step1Label.Parent = MainFrame

    local Step2Label = Instance.new("TextLabel")
    Step2Label.Text = "Step 2 : Complete Link → Get Key → Enter Key"
    Step2Label.Size = UDim2.new(1, -20, 0, 22)
    Step2Label.Position = UDim2.new(0, 10, 0, 70)
    Step2Label.BackgroundTransparency = 1
    Step2Label.TextColor3 = Color3.fromRGB(255, 200, 80)
    Step2Label.TextSize = 12
    Step2Label.Font = Enum.Font.GothamBold
    Step2Label.TextXAlignment = Enum.TextXAlignment.Left
    Step2Label.TextWrapped = true
    Step2Label.Parent = MainFrame

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -20, 0, 1)
    Divider.Position = UDim2.new(0, 10, 0, 100)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    Divider.BackgroundTransparency = 0.6
    Divider.BorderSizePixel = 0
    Divider.Parent = MainFrame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = "Status : Waiting for key..."
    StatusLabel.Size = UDim2.new(1, -20, 0, 22)
    StatusLabel.Position = UDim2.new(0, 10, 0, 108)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame

    local InputBox = Instance.new("TextBox")
    InputBox.PlaceholderText = "Enter your key here..."
    InputBox.Text = ""
    InputBox.ClearTextOnFocus = false
    InputBox.Size = UDim2.new(0, 340, 0, 35)
    InputBox.Position = UDim2.new(0.5, -170, 0, 140)
    InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    InputBox.BackgroundTransparency = 0.4
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Font = Enum.Font.GothamMedium
    InputBox.TextSize = 13
    InputBox.Parent = MainFrame
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
    local inputStroke = Instance.new("UIStroke", InputBox)
    inputStroke.Color = Color3.fromRGB(255, 215, 0)
    inputStroke.Thickness = 1.5

    local ButtonHolder = Instance.new("Frame")
    ButtonHolder.Size = UDim2.new(0, 340, 0, 40)
    ButtonHolder.Position = UDim2.new(0.5, -170, 0, 188)
    ButtonHolder.BackgroundTransparency = 1
    ButtonHolder.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.Padding = UDim.new(0, 15)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.Parent = ButtonHolder

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.Size = UDim2.new(0, 155, 1, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    GetKeyBtn.BackgroundTransparency = 0.3
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextSize = 13
    GetKeyBtn.Parent = ButtonHolder
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)
    local btnStroke1 = Instance.new("UIStroke", GetKeyBtn)
    btnStroke1.Color = Color3.fromRGB(255, 215, 0)
    btnStroke1.Thickness = 1.5

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Text = "Verify Key"
    VerifyBtn.Size = UDim2.new(0, 155, 1, 0)
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    VerifyBtn.BackgroundTransparency = 0.2
    VerifyBtn.TextColor3 = Color3.fromRGB(30, 30, 30)
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.TextSize = 13
    VerifyBtn.Parent = ButtonHolder
    Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)
    local btnStroke2 = Instance.new("UIStroke", VerifyBtn)
    btnStroke2.Color = Color3.fromRGB(255, 255, 255)
    btnStroke2.Thickness = 1.5

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Text = "Press [Get Key] to start!"
    MessageLabel.Size = UDim2.new(1, -20, 0, 25)
    MessageLabel.Position = UDim2.new(0, 10, 0, 248)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    MessageLabel.TextSize = 11
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = MainFrame

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(GET_KEY_URL)
            StatusLabel.Text = "Status : Link copied! Paste in browser."
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            MessageLabel.Text = "✅ Link copied! Open browser and paste it."
            MessageLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            task.spawn(function()
                showNotify("Yellow Hub", "Link copied! Paste in browser.", GET_KEY_URL, 4)
            end)
            task.wait(2)
            StatusLabel.Text = "Status : Waiting for key..."
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            MessageLabel.Text = "After getting key, paste it above & verify."
            MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        else
            MessageLabel.Text = GET_KEY_URL
            MessageLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        end
    end)

    VerifyBtn.MouseButton1Click:Connect(function()
        local key = InputBox.Text
        if key == "" then
            MessageLabel.Text = "❌ Key cannot be empty!"
            MessageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end

        VerifyBtn.Text = "Checking..."
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 0)
        StatusLabel.Text = "Status : Verifying key..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        MessageLabel.Text = "Please wait..."
        MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

        task.spawn(function()
            local success, msg = validateKey(key, hwid)

            if success then
                saveKey(key, hwid)
                StatusLabel.Text = "Status : Key Active!"
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                MessageLabel.Text = "✅ Key verified! Loading Hub..."
                MessageLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                
                task.spawn(function()
                    showNotify("Yellow Hub", "✅ Key verified! Launching...", nil, 3)
                end)
                
                task.wait(1)
                gui:Destroy()
                
                -- SỬ DỤNG HÀM SAFELOAD NHƯ BẠN YÊU CẦU
                SafeLoad("https://raw.githubusercontent.com/scripdznhat/Yellow-Hub/refs/heads/main/mainldtdupe.lua")
            else
                StatusLabel.Text = "Status : Verification failed!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                MessageLabel.Text = "❌ Error: " .. msg
                MessageLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                VerifyBtn.Text = "✅ Verify Key"
                VerifyBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
                task.spawn(function()
                    showNotify("Yellow Hub", "❌ " .. msg, nil, 3)
                end)
            end
        end)
    end)
end

-- ==================== STARTUP ====================
local HWID = getHWID()
local savedKey = loadKey(HWID)

if savedKey then
    task.spawn(function()
        local ok, msg = validateKey(savedKey, HWID)
        if ok then
            task.spawn(function()
                showNotify("Yellow Hub", "Welcome back! Launching...", nil, 2)
            end)
            task.wait(0.5)
            
            -- SỬ DỤNG HÀM SAFELOAD NHƯ BẠN YÊU CẦU
            SafeLoad("https://raw.githubusercontent.com/scripdznhat/Yellow-Hub/refs/heads/main/mainldtdupe.lua")
        else
            clearKey()
            task.spawn(function()
                showNotify("Yellow Hub", "Key expired or invalid! Please get a new key.", nil, 4)
            end)
            task.wait(1)
            createUI(HWID)
        end
    end)
else
    createUI(HWID)
end
