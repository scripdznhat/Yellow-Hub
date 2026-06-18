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
-- [[ MENU CHÍNH ]] --
-----------------------------------------------------------
local mf = Instance.new("Frame", sg)
mf.Size, mf.Position = UDim2.new(0, 190, 0, 275), UDim2.new(0.5, -95, 0.4, -120)
mf.BackgroundColor3, mf.Active, mf.Draggable = Color3.fromRGB(20, 20, 20), true, true
mf.Visible = true 
r(mf, 12)

local mt = Instance.new("TextLabel", mf)
mt.Size, mt.Text = UDim2.new(1, 0, 0, 40), "YELLOW HUB"
mt.BackgroundColor3, mt.TextColor3 = Color3.fromRGB(255, 170, 0), Color3.fromRGB(0, 0, 0)
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
    b.TextColor3, b.Font, b.TextSize = Color3.fromRGB(255,255,255), Enum.Font.SourceSansBold, 14
    r(b, 8)
    return b
end

-----------------------------------------------------------
-- NÚT CHỨC NĂNG
-----------------------------------------------------------
btn("DUPE PET", Color3.fromRGB(0, 120, 255)).MouseButton1Click:Connect(function()
    local char = plr.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    
    if tool and (tool:GetAttribute("PetId") or tool:GetAttribute("Pet")) then
        local petName = tool:GetAttribute("Pet") or tool.Name
        local realPet = nil
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name == petName or obj:GetAttribute("PetId")) and obj ~= char then
                realPet = obj; break
            end
        end
        
        if realPet then
            local fakeTool = Instance.new("Tool")
            fakeTool.Name = petName
            fakeTool.TextureId = tool.TextureId 
            fakeTool.RequiresHandle = false -- Tắt tay cầm vật lý để tránh bị lật ngược
            fakeTool.CanBeDropped = false
            
            local displayPet = nil
            local equipConn = nil
            
            -- FIX 1: HIỂN THỊ PET BAY CẠNH BẠN, LUÔN ĐỨNG THẲNG
            fakeTool.Equipped:Connect(function()
                displayPet = realPet:Clone()
                for _, v in pairs(displayPet:GetDescendants()) do
                    if v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
                    if v:IsA("BasePart") then
                        v.Anchored = true
                        v.CanCollide = false
                    end
                end
                displayPet.Parent = Workspace
                
                -- Tạo vòng lặp để Pet bay sát bên cạnh bạn, không bị xoay theo tay
                equipConn = RunService.RenderStepped:Connect(function()
                    if char and char:FindFirstChild("HumanoidRootPart") and displayPet then
                        local hrp = char.HumanoidRootPart
                        local targetCFrame = hrp.CFrame * CFrame.new(3, 0, -2) -- Bay bên phải, xích lên trước 1 xíu
                        displayPet:PivotTo(CFrame.new(targetCFrame.Position, hrp.Position + hrp.CFrame.LookVector * 10))
                    end
                end)
            end)
            
            -- KHI CẤT TOOL ĐI: Xóa pet hiển thị
            fakeTool.Unequipped:Connect(function()
                if equipConn then equipConn:Disconnect(); equipConn = nil end
                if displayPet then displayPet:Destroy(); displayPet = nil end
            end)
            
            -- FIX 2: THẢ PET XUỐNG CHUẨN MẶT ĐẤT
            fakeTool.Activated:Connect(function()
                local mouse = plr:GetMouse()
                local hitPos = mouse.Hit.Position
                
                local dropPet = realPet:Clone()
                for _, v in pairs(dropPet:GetDescendants()) do
                    if v:IsA("Script") or v:IsA("LocalScript") then v:Destroy() end
                    if v:IsA("BasePart") then 
                        v.Anchored = true 
                        v.CanCollide = false 
                    end
                end
                
                dropPet.Parent = Workspace
                local root = dropPet:FindFirstChild("HumanoidRootPart") or dropPet.PrimaryPart or dropPet:FindFirstChildWhichIsA("BasePart")
                
                -- Đo chính xác bằng thân con Pet thay vì hào quang
                local heightOffset = (root and root.Size.Y / 2) or 1
                
                -- Tìm tọa độ cỏ/đất
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {char, dropPet, displayPet}
                local rayResult = Workspace:Raycast(hitPos + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0), rayParams)
                local groundY = rayResult and rayResult.Position.Y or hitPos.Y
                
                -- Đặt xuống
                dropPet:PivotTo(CFrame.new(hitPos.X, groundY + heightOffset, hitPos.Z))
                
                fakeTool:Destroy()
            end)
            
            fakeTool.Parent = plr.Backpack
        end
    end
end)

btn("DUPE SEEDS", Color3.fromRGB(40, 180, 40)).MouseButton1Click:Connect(function()
    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if tool and (tool:GetAttribute("SeedTool") or tool:GetAttribute("MainCategory") == "Seed") then
        tool:SetAttribute("Count", (tool:GetAttribute("Count") or 0) + 10)
    end
end)

btn("DUPE COIN", Color3.fromRGB(255, 120, 0)).MouseButton1Click:Connect(function()
    local ls = plr:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Sheckles") then
        ls.Sheckles.Value = ls.Sheckles.Value * 2
    end
end)

btn("FIX LAG 1", Color3.fromRGB(0, 180, 255)).MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
        elseif v:IsA("ParticleEmitter") then v.Enabled = false end
    end
end)

btn("FIX LAG 2", Color3.fromRGB(255, 80, 0)).MouseButton1Click:Connect(function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if plr.Character and not v:IsDescendantOf(plr.Character) and v:IsA("BasePart") then
            v.Transparency = 1
        end
    end
    pcall(function() Workspace.Terrain.WaterTransparency = 1 end)
end)
