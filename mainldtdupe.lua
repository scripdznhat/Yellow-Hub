local plr = game.Players.LocalPlayer
local pg = plr:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

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

-- 1. DUPE PET (Tạo thú cưng ảo TỰ ĐI DẠO KHI THẢ)
btn("DUPE PET", Color3.fromRGB(0, 100, 200)).MouseButton1Click:Connect(function()
    local char = plr.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    if tool then
        local petId = tool:GetAttribute("PetId")
        local petName = tool:GetAttribute("Pet")
        
        if petId or petName then
            local clonedTool = tool:Clone()
            if petId then clonedTool:SetAttribute("PetId", petId .. "_FAKE_PROP") end
            
            -- Sự kiện kích hoạt khi bấm chuột xuống mặt đất
            clonedTool.Activated:Connect(function()
                local mouse = plr:GetMouse()
                local targetPos = mouse.Hit.p
                
                -- Tạo Model chứa con Pet ngoài đời
                local fakePetModel = Instance.new("Model", workspace)
                fakePetModel.Name = (petName or tool.Name) .. " (Ảo)"
                
                local primaryPart = nil
                local parts = {}
                
                -- Lấy toàn bộ linh kiện của Pet ra
                for _, child in pairs(clonedTool:GetDescendants()) do
                    if child:IsA("BasePart") or child:IsA("MeshPart") then
                        local partClone = child:Clone()
                        partClone.Parent = fakePetModel
                        partClone.Anchored = false -- Tắt neo để các bộ phận dính vào nhau
                        partClone.CanCollide = false -- Xuyên thấu để không cản đường
                        table.insert(parts, partClone)
                        
                        if child.Name == "Handle" or not primaryPart then
                            primaryPart = partClone
                        end
                    end
                end
                
                if primaryPart then
                    fakePetModel.PrimaryPart = primaryPart
                    primaryPart.Anchored = true -- Chỉ neo đúng cái tâm của Pet
                    
                    -- Dán (Weld) tất cả các bộ phận khác vào tâm để nó không bị rơi rụng
                    for _, p in ipairs(parts) do
                        if p ~= primaryPart then
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = primaryPart
                            weld.Part1 = p
                            weld.Parent = primaryPart
                        end
                    end
                    
                    -- Đặt vị trí xuất hiện (bay trên đất 1 chút)
                    local startY = targetPos.Y + 1.2
                    local centerPos = Vector3.new(targetPos.X, startY, targetPos.Z)
                    fakePetModel:SetPrimaryPartCFrame(CFrame.new(centerPos))
                    
                    -- TẠO TRÍ TUỆ NHÂN TẠO (AI) TỰ ĐI DẠO CHO PET
                    task.spawn(function()
                        while fakePetModel.Parent and primaryPart.Parent do
                            -- 1. Tìm một điểm ngẫu nhiên xung quanh khu vực thả (bán kính 15 stud)
                            local rX = math.random(-15, 15)
                            local rZ = math.random(-15, 15)
                            local nextPos = centerPos + Vector3.new(rX, 0, rZ)
                            
                            local currentPos = primaryPart.Position
                            -- Giữ nguyên độ cao Y để Pet không bị cắm mặt xuống đất hay ngửa lên trời
                            local lookPos = Vector3.new(nextPos.X, currentPos.Y, nextPos.Z)
                            local lookCFrame = CFrame.lookAt(currentPos, lookPos)
                            
                            -- 2. Xoay người về phía cần đi
                            local turnTween = TweenService:Create(primaryPart, TweenInfo.new(0.3), {CFrame = lookCFrame})
                            turnTween:Play()
                            turnTween.Completed:Wait()
                            
                            if not fakePetModel.Parent then break end
                            
                            -- 3. Di chuyển tới điểm đó
                            local finalCFrame = CFrame.lookAt(nextPos, nextPos + lookCFrame.LookVector)
                            local dist = (nextPos - currentPos).Magnitude
                            local speed = 6 -- Tốc độ đi dạo
                            
                            local walkTween = TweenService:Create(primaryPart, TweenInfo.new(dist / speed, Enum.EasingStyle.Linear), {CFrame = finalCFrame})
                            walkTween:Play()
                            walkTween.Completed:Wait()
                            
                            if not fakePetModel.Parent then break end
                            
                            -- 4. Đứng chơi vài giây rồi đi tiếp
                            task.wait(math.random(1, 4))
                        end
                    end)
                end
                
                -- Bấm xong thì xóa Pet ảo trên tay
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
