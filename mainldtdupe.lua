local plr = game.Players.LocalPlayer
local pg = plr:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

if pg:FindFirstChild("LDTDZ_Final_Fix_V4") then pg.LDTDZ_Final_Fix_V4:Destroy() end

local sg = Instance.new("ScreenGui", pg)
sg.Name = "LDTDZ_Final_Fix_V4"
sg.ResetOnSpawn = false

local function r(o, v)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, v or 6)
end

-----------------------------------------------------------
-- [[ MENU CHÍNH ]] --
-----------------------------------------------------------
local mf = Instance.new("Frame", sg)
mf.Size, mf.Position = UDim2.new(0, 180, 0, 245), UDim2.new(0.5, -90, 0.4, -120)
mf.BackgroundColor3, mf.Active, mf.Draggable = Color3.fromRGB(15, 15, 15), true, true
mf.Visible = true 
r(mf, 8)

local mt = Instance.new("TextLabel", mf)
mt.Size, mt.Text = UDim2.new(1, 0, 0, 30), "LDTDZ HUB"
mt.BackgroundColor3, mt.TextColor3 = Color3.fromRGB(80, 0, 200), Color3.new(1, 1, 1)
mt.Font = Enum.Font.SourceSansBold
mt.TextSize = 14
r(mt, 8)

local toggleBtn = Instance.new("TextButton", mf)
toggleBtn.Size, toggleBtn.Position = UDim2.new(0, 25, 0, 25), UDim2.new(1, -30, 0, 2.5)
toggleBtn.Text, toggleBtn.BackgroundColor3 = "-", Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3, toggleBtn.Font = Color3.new(1, 1, 1), Enum.Font.SourceSansBold
r(toggleBtn, 5)

local ctn = Instance.new("Frame", mf)
ctn.Size, ctn.Position = UDim2.new(1, -14, 1, -40), UDim2.new(0, 7, 0, 35)
ctn.BackgroundTransparency = 1
local ly = Instance.new("UIListLayout", ctn)
ly.Padding = UDim.new(0, 4)

local isOpen = true
toggleBtn.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    toggleBtn.Text = isOpen and "-" or "+"
    mf:TweenSize(isOpen and UDim2.new(0, 180, 0, 245) or UDim2.new(0, 180, 0, 30), "Out", "Quart", 0.2, true)
    ctn.Visible = isOpen
end)

-----------------------------------------------------------
-- LOGIC BAY & TELE 
-----------------------------------------------------------
local P1, P2, SPEED = Vector3.new(152.30, 3.23, -136.38), Vector3.new(2409.65, 3.28, -137.5), 2
local noclip = false

local teleLocations = {
    Vector3.new(201.6, -3.5, 6.7),
    Vector3.new(290.1, -3.5, 16.4),
    Vector3.new(395.4, -3.5, -16.8),
    Vector3.new(537.7, -3.5, 36.8),
    Vector3.new(761.5, -3.5, 6.7),
    Vector3.new(1081.1, -3.5, -1.4),
    Vector3.new(1558.6, -3.5, -41.3),
    Vector3.new(2240.5, -3.5, -0.8),
    Vector3.new(2616.6, -3.5, -58.0)
}
local currentIdx = 1 

RunService.Stepped:Connect(function()
    if noclip and plr.Character then
        for _, v in pairs(plr.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

local function fly(target)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    noclip = true
    local startPos = hrp.Position
    local steps = (target - startPos).Magnitude / SPEED
    for i = 1, steps do
        hrp.CFrame = CFrame.new(startPos:Lerp(target, i / steps))
        RunService.Heartbeat:Wait()
    end
    hrp.CFrame = CFrame.new(target)
    noclip = false
end

local function btn(txt, col)
    local b = Instance.new("TextButton", ctn)
    b.Size = UDim2.new(1, 0, 0, 38)
    b.Text, b.BackgroundColor3 = txt, col
    b.TextColor3, b.Font, b.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 14
    r(b, 4)
    return b
end

-- 1. DUPE PET (BẢN TỐI THƯỢNG GIỐNG 100%: CHỐNG LỌT ĐẤT & ÉP KHUNG XƯƠNG CHẠY CHÂN)
btn("DUPE PET", Color3.fromRGB(0, 100, 200)).MouseButton1Click:Connect(function()
    local char = plr.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    if tool then
        local petId = tool:GetAttribute("PetId")
        local petName = tool:GetAttribute("Pet")
        
        if petId or petName then
            local clonedTool = tool:Clone()
            if petId then clonedTool:SetAttribute("PetId", petId .. "_FAKE_CLONE") end
            
            clonedTool.Activated:Connect(function()
                local mouse = plr:GetMouse()
                local targetPos = mouse.Hit.p
                
                local petTargetName = petName or tool.Name
                local realPetModel = nil
                
                -- Tìm thực thể pet thật ngoài đời để lấy chuẩn tỉ lệ cơ thể
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name == petTargetName or obj:GetAttribute("PetId")) and obj ~= char then
                        realPetModel = obj
                        break
                    end
                end
                
                if realPetModel then
                    local clonedPet = realPetModel:Clone()
                    clonedPet:SetAttribute("PetId", "CLONED_VISUAL") 
                    
                    local rootPart = clonedPet.PrimaryPart or clonedPet:FindFirstChild("HumanoidRootPart") or clonedPet:FindFirstChildWhichIsA("BasePart")
                    
                    if rootPart then
                        -- Loại bỏ hệ thần kinh lỗi vật lý của Roblox để tự lái bằng Code
                        local oldHum = clonedPet:FindFirstChildWhichIsA("Humanoid")
                        if oldHum then oldHum:Destroy() end
                        
                        -- Quét kích thước chiều cao của Pet
                        local _, size = clonedPet:GetBoundingBox()
                        local petHeight = size.Y / 2
                        
                        -- Quét và lưu lại toàn bộ khớp xương chân (Motor6D) của Pet
                        local joints = {}
                        for _, v in pairs(clonedPet:GetDescendants()) do
                            if v:IsA("Motor6D") then
                                joints[v] = v.C0 -- Lưu tư thế gốc
                            end
                            if v:IsA("BasePart") then
                                v.Anchored = false
                                v.CanCollide = false
                            end
                        end
                        
                        -- Khóa chặt thân chính bằng lệnh ghim để CHỐNG LỌT ĐẤT TUYỆT ĐỐI
                        rootPart.Anchored = true
                        clonedPet.Parent = workspace
                        
                        -- CÀI ĐẶT TRÍ TUỆ NHÂN TẠO CHẠY CHÂN & DÒ ĐỊA HÌNH 
                        task.spawn(function()
                            local currentPos = targetPos + Vector3.new(0, petHeight, 0)
                            local centerPos = currentPos
                            
                            -- Thiết lập tia quét tránh vật cản nền đất
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                            raycastParams.FilterDescendantsInstances = {clonedPet, char}
                            
                            while clonedPet.Parent do
                                -- Chọn 1 điểm đi dạo ngẫu nhiên
                                local targetNode = centerPos + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
                                local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetNode.X, 0, targetNode.Z)).Magnitude
                                
                                if dist > 2 then
                                    local walkSpeed = 7 -- Tốc độ đi bước chân
                                    local duration = dist / walkSpeed
                                    local startTime = tick()
                                    local startPos = currentPos
                                    
                                    -- VÒNG LẶP DI CHUYỂN
                                    while tick() - startTime < duration and clonedPet.Parent do
                                        local t = (tick() - startTime) / duration
                                        local lerpPos = startPos:Lerp(targetNode, t)
                                        
                                        -- Bắn tia laser xuống đất để lấy độ cao bề mặt cỏ (Chống lún nền)
                                        local rayResult = workspace:Raycast(lerpPos + Vector3.new(0, 15, 0), Vector3.new(0, -30, 0), raycastParams)
                                        local groundY = rayResult and rayResult.Position.Y or lerpPos.Y
                                        
                                        currentPos = Vector3.new(lerpPos.X, groundY + petHeight, lerpPos.Z)
                                        
                                        -- Xoay mặt nhìn về hướng đi
                                        local lookAtPos = Vector3.new(targetNode.X, currentPos.Y, targetNode.Z)
                                        if (lookAtPos - currentPos).Magnitude > 0.1 then
                                            rootPart.CFrame = CFrame.lookAt(currentPos, lookAtPos)
                                        end
                                        
                                        -- [QUYẾT ĐỊNH]: ÉP KHUNG XƯƠNG CHÂN NGOÁY BƯỚC ĐI NHƯ THẬT
                                        for joint, originalC0 in pairs(joints) do
                                            -- Đảo chiều chân trái/phải để tạo nhịp bước đi so le
                                            local sidePhase = (joint.Name:find("Left") or joint.Name:find("1") or joint.Name:find("Front")) and 1 or -1
                                            local swingAngle = math.sin(tick() * 14) * 0.45 * sidePhase
                                            joint.C0 = originalC0 * CFrame.Angles(swingAngle, 0, 0)
                                        end
                                        
                                        RunService.Heartbeat:Wait()
                                    end
                                end
                                
                                -- TRẠNG THÁI ĐỨNG IM (Nghỉ ngơi thở phập phồng)
                                local idleStart = tick()
                                local idleTime = math.random(2, 4)
                                while tick() - idleStart < idleTime and clonedPet.Parent do
                                    -- Reset chân về vị trí đứng im và tạo độ nhún nhẩy nhịp thở
                                    for joint, originalC0 in pairs(joints) do
                                        joint.C0 = originalC0
                                    end
                                    local rayResult = workspace:Raycast(currentPos + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), raycastParams)
                                    local groundY = rayResult and rayResult.Position.Y or currentPos.Y
                                    
                                    -- Người phập phồng lên xuống nhẹ nhàng như sinh vật thật
                                    local breatheEffect = math.sin(tick() * 3) * 0.04
                                    rootPart.CFrame = (rootPart.CFrame - rootPart.CFrame.Position) + Vector3.new(currentPos.X, groundY + petHeight + breatheEffect, currentPos.Z)
                                    
                                    RunService.Heartbeat:Wait()
                                end
                            end
                        end)
                    end
                end
                
                clonedTool:Destroy()
            end)
            
            clonedTool.Parent = plr.Backpack
        end
    end
end)

-- 2. GOD MOD
local bG = btn("GOD MOD: OFF", Color3.fromRGB(40, 40, 40))
local god = false
bG.MouseButton1Click:Connect(function()
    god = not god
    bG.Text = god and "GOD MOD: ON" or "GOD MOD: OFF"
    bG.BackgroundColor3 = god and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(40, 40, 40)
end)
RunService.Heartbeat:Connect(function() if god and plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.Health = 100 end end)

-- 3. AUTO TELE
local bTele = btn("AUTO TELE", Color3.fromRGB(100, 0, 180))
bTele.MouseButton1Click:Connect(function()
    local h = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if h then
        h.CFrame = CFrame.new(teleLocations[currentIdx])
        bTele.Text = "TELE: " .. currentIdx
        currentIdx = currentIdx + 1
        if currentIdx > #teleLocations then currentIdx = 1 end
    end
end)

-- 4. TELE TO END
btn("TELE TO END", Color3.fromRGB(180, 40, 40)).MouseButton1Click:Connect(function()
    local h = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if h then 
        h.CFrame = CFrame.new(P1) 
        task.wait(0.5) 
        fly(P2) 
        setclipboard("2409.65, 3.28, -137.5") 
    end
end)

-- 5. AUTO TELE HOME
btn("AUTO TELE HOME", Color3.fromRGB(0, 120, 60)).MouseButton1Click:Connect(function()
    local h = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if h then 
        h.CFrame = CFrame.new(P2) 
        task.wait(0.5) 
        fly(P1) 
        setclipboard("152.30, 3.23, -136.38") 
    end
end)
