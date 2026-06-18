local plr = game.Players.LocalPlayer
local pg = plr:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

if pg:FindFirstChild("LDTDZ_Final_Fix_V4") then pg.LDTDZ_Final_Fix_V4:Destroy() end

local sg = Instance.new("ScreenGui", pg)
sg.Name = "LDTDZ_Final_Fix_V4"
sg.ResetOnSpawn = false

local function r(o, v)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, v or 8)
end

-----------------------------------------------------------
-- [[ MENU CHÍNH - YELLOW HUB ]] --
-----------------------------------------------------------
local mf = Instance.new("Frame", sg)
mf.Size, mf.Position = UDim2.new(0, 190, 0, 275), UDim2.new(0.5, -95, 0.4, -120)
mf.BackgroundColor3, mf.Active, mf.Draggable = Color3.fromRGB(20, 20, 20), true, true
mf.Visible = true 
r(mf, 12)

local mt = Instance.new("TextLabel", mf)
mt.Size, mt.Text = UDim2.new(1, 0, 0, 40), "YELLOW HUB"
mt.BackgroundColor3, mt.TextColor3 = Color3.fromRGB(255, 200, 0), Color3.new(0, 0, 0)
mt.Font = Enum.Font.SourceSansBold
mt.TextSize = 18
r(mt, 12)

local toggleBtn = Instance.new("TextButton", mf)
toggleBtn.Size, toggleBtn.Position = UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5)
toggleBtn.Text, toggleBtn.BackgroundColor3 = "-", Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3, toggleBtn.Font = Color3.new(1, 1, 1), Enum.Font.SourceSansBold
r(toggleBtn, 8)

local ctn = Instance.new("Frame", mf)
ctn.Size, ctn.Position = UDim2.new(1, -20, 1, -50), UDim2.new(0, 10, 0, 45)
ctn.BackgroundTransparency = 1
local ly = Instance.new("UIListLayout", ctn)
ly.Padding = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    local isOpen = (mf.Size.Y.Offset > 50)
    toggleBtn.Text = isOpen and "+" or "-"
    mf:TweenSize(isOpen and UDim2.new(0, 190, 0, 40) or UDim2.new(0, 190, 0, 275), "Out", "Quart", 0.2, true)
    ctn.Visible = not isOpen
end)

local function btn(txt, col)
    local b = Instance.new("TextButton", ctn)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.Text, b.BackgroundColor3 = txt, col
    b.TextColor3, b.Font, b.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 14
    r(b, 8)
    return b
end

-----------------------------------------------------------
-- 1. DUPE PET (CHÍNH XÁC BẢN TỐI THƯỢNG BẠN CUNG CẤP)
-----------------------------------------------------------
btn("DUPE PET", Color3.fromRGB(0, 120, 255)).MouseButton1Click:Connect(function()
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

-----------------------------------------------------------
-- 2. DUPE SEEDS
-----------------------------------------------------------
btn("DUPE SEEDS", Color3.fromRGB(40, 180, 40)).MouseButton1Click:Connect(function()
    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if tool and (tool:GetAttribute("SeedTool") or tool:GetAttribute("MainCategory") == "Seed") then
        tool:SetAttribute("Count", (tool:GetAttribute("Count") or 0) + 10)
    end
end)

-----------------------------------------------------------
-- 3. DUPE COIN
-----------------------------------------------------------
btn("DUPE COIN", Color3.fromRGB(255, 120, 0)).MouseButton1Click:Connect(function()
    local ls = plr:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Sheckles") then
        ls.Sheckles.Value = ls.Sheckles.Value * 2
    end
end)

-----------------------------------------------------------
-- 4. FIX LAG 1
-----------------------------------------------------------
btn("FIX LAG 1", Color3.fromRGB(0, 180, 255)).MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
        elseif v:IsA("ParticleEmitter") then v.Enabled = false end
    end
end)

-----------------------------------------------------------
-- 5. FIX LAG 2
-----------------------------------------------------------
btn("FIX LAG 2", Color3.fromRGB(255, 80, 0)).MouseButton1Click:Connect(function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if plr.Character and not v:IsDescendantOf(plr.Character) and v:IsA("BasePart") then
            v.Transparency = 1
        end
    end
    pcall(function() Workspace.Terrain.WaterTransparency = 1 end)
end)
