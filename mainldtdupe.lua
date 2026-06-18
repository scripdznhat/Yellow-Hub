local plr = game.Players.LocalPlayer
local pg = plr:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

if pg:FindFirstChild("LDTDZ_Final_Fix_V4") then pg.LDTDZ_Final_Fix_V4:Destroy() end

local sg = Instance.new("ScreenGui", pg)
sg.Name = "LDTDZ_Final_Fix_V4"
sg.ResetOnSpawn = false

-- Các hàm hỗ trợ giao diện & logic
local function r(o, v)
    local c = Instance.new("UICorner", o)
    c.CornerRadius = UDim.new(0, v or 8)
end

local function debounce(key, time, callback)
    _G.db = _G.db or {}
    if _G.db[key] then return end
    _G.db[key] = true
    callback()
    task.wait(time)
    _G.db[key] = nil
end

local function flashBtn(btn, col)
    local oldColor = btn.BackgroundColor3
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    task.wait(0.2)
    btn.BackgroundColor3 = oldColor
end

-----------------------------------------------------------
-- [[ GIAO DIỆN MÀN HÌNH CHÍNH ]] --
-----------------------------------------------------------
local mf = Instance.new("Frame", sg)
mf.Size, mf.Position = UDim2.new(0, 190, 0, 275), UDim2.new(0.5, -95, 0.4, -120)
mf.BackgroundColor3, mf.Active, mf.Draggable = Color3.fromRGB(20, 20, 20), true, true
r(mf, 12)

local mt = Instance.new("TextLabel", mf)
mt.Size, mt.Text = UDim2.new(1, 0, 0, 40), "YELLOW HUB"
mt.BackgroundColor3, mt.TextColor3 = Color3.fromRGB(255, 170, 0), Color3.new(0, 0, 0)
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
    return b, col
end

-----------------------------------------------------------
-- [[ HỆ THỐNG LOGIC PET NÂNG CAO ]] --
-----------------------------------------------------------
local SKILL_KW = {"skill","ability","attack","damage","combat","shoot","fire","cast","spell","aura","projectile","special"}

local function isSkillScript(s)
    local n = s.Name:lower()
    for _, kw in ipairs(SKILL_KW) do
        if n:find(kw, 1, true) then return true end
    end
    return false
end

local function getGroundY(worldPos, excludeList)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = excludeList or {}
    local hit = Workspace:Raycast(worldPos + Vector3.new(0, 60, 0), Vector3.new(0, -150, 0), rp)
    return hit and hit.Position.Y or worldPos.Y
end

local function findPet()
    local char = plr.Character
    if not char then return nil end
    local charRoot = char:FindFirstChild("HumanoidRootPart")

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char then
            local oid = obj:GetAttribute("OwnerId")
            local onm = obj:GetAttribute("PetOwner") or obj:GetAttribute("Owner")
            if oid == plr.UserId or onm == plr.Name then
                return obj
            end
        end
    end

    if charRoot then
        local best, bestD = nil, 10
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local r = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                if r then
                    local d = (r.Position - charRoot.Position).Magnitude
                    if d < bestD then bestD = d; best = obj end
                end
            end
        end
        return best
    end
    return nil
end

local function spawnFollowPet(srcModel, char)
    local charRoot = char:FindFirstChild("HumanoidRootPart")
    if not charRoot then return nil, nil end

    local clone = srcModel:Clone()
    clone.Name = srcModel.Name
    clone.Parent = Workspace

    for _, s in ipairs(clone:GetDescendants()) do
        if s:IsA("Script") then s.Disabled = true end
        if s:IsA("LocalScript") and isSkillScript(s) then s:Destroy() end
    end

    local petRoot = clone:FindFirstChild("HumanoidRootPart") or clone.PrimaryPart or clone:FindFirstChildOfClass("BasePart")
    if not petRoot then clone:Destroy(); return nil, nil end
    clone.PrimaryPart = petRoot

    local ok, _, sz = pcall(function() return clone:GetBoundingBox() end)
    local halfH = (ok and sz) and sz.Y / 2 or 2

    local spawnXZ = charRoot.Position + charRoot.CFrame.RightVector * 4
    local groundY = getGroundY(spawnXZ, {clone, char})
    local spawnPos = Vector3.new(spawnXZ.X, groundY + halfH + 0.05, spawnXZ.Z)

    clone:PivotTo(CFrame.new(spawnPos))

    local hum = clone:FindFirstChildOfClass("Humanoid")
    local conn = nil

    if hum then
        for _, p in ipairs(clone:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Anchored = false
                p.CanCollide = false
            end
        end
        petRoot.CanCollide = true 
        petRoot.CFrame = CFrame.new(spawnPos)

        hum.WalkSpeed = 14
        hum.JumpPower = 0
        hum.AutoRotate = true
        hum.NameDisplayDistance = 0
        hum.HealthDisplayDistance = 0

        conn = RunService.Heartbeat:Connect(function()
            if not clone.Parent or not char.Parent then conn:Disconnect(); return end
            local cr = char:FindFirstChild("HumanoidRootPart")
            if not cr then return end

            local diff = cr.Position - petRoot.Position
            if diff.Magnitude > 5 then
                hum:MoveTo(cr.Position - diff.Unit * 3)
            end
        end)
    else
        for _, p in ipairs(clone:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Anchored = false
                p.CanCollide = false
                p.Massless = true
            end
        end
        petRoot.Massless = false

        local bp = Instance.new("BodyPosition", petRoot)
        bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bp.P = 5000; bp.D = 500; bp.Position = spawnPos

        local bg = Instance.new("BodyGyro", petRoot)
        bg.MaxTorque = Vector3.new(0, 1e5, 0)
        bg.P = 5000; bg.D = 400

        local angle = math.random() * math.pi * 2

        conn = RunService.Heartbeat:Connect(function(dt)
            if not clone.Parent or not char.Parent then conn:Disconnect(); return end
            local cr = char:FindFirstChild("HumanoidRootPart")
            if not cr then return end

            -- Đoạn này đã được sửa lỗi thiếu dấu ngoặc
            angle = (angle + dt * 1.0) % (math.pi * 2)
            local target = cr.Position + Vector3.new(math.cos(angle) * 3.5, 2.5, math.sin(angle) * 3.5)
            bp.Position = target
            bg.CFrame = CFrame.new(petRoot.Position, cr.Position)
        end)
    end

    return clone, conn
end

local function createPetTool(srcModel)
    local toolName = "Pet_" .. srcModel.Name
    local old = plr.Backpack:FindFirstChild(toolName)
    if old then old:Destroy() end

    local tool = Instance.new("Tool")
    tool.Name = toolName
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ToolTip = "Trang bị để gọi " .. srcModel.Name

    local handle = Instance.new("Part", tool)
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.1, 0.1, 0.1)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.Massless = true

    local petClone, petConn = nil, nil

    local function despawn()
        if petConn then petConn:Disconnect(); petConn = nil end
        if petClone and petClone.Parent then petClone:Destroy() end
        petClone = nil
    end

    tool.Equipped:Connect(function()
        local char = plr.Character
        if char then petClone, petConn = spawnFollowPet(srcModel, char) end
    end)
    tool.Unequipped:Connect(despawn)
    tool.AncestryChanged:Connect(function() if not tool.Parent then despawn() end end)
    
    tool.Parent = plr.Backpack
end

-----------------------------------------------------------
-- [[ NÚT CHỨC NĂNG CHÍNH ]] --
-----------------------------------------------------------

local bDupePet, cDupePet = btn("DUPE PET", Color3.fromRGB(0, 120, 255))
bDupePet.MouseButton1Click:Connect(function()
    debounce("dupe_pet", 1.5, function()
        flashBtn(bDupePet, cDupePet)
        local pet = findPet()
        if pet then
            createPetTool(pet)
            bDupePet.Text = "✓ VÀO TÚI ĐỒ!"
        else
            bDupePet.Text = "❌ KHÔNG TÌM THẤY"
        end
        task.delay(1.5, function() bDupePet.Text = "DUPE PET" end)
    end)
end)

local bDupeSeeds, cDupeSeeds = btn("DUPE SEEDS", Color3.fromRGB(40, 180, 40))
bDupeSeeds.MouseButton1Click:Connect(function()
    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if tool and (tool:GetAttribute("SeedTool") or tool:GetAttribute("MainCategory") == "Seed") then
        tool:SetAttribute("Count", (tool:GetAttribute("Count") or 0) + 10)
    end
end)

local bDupeCoin, cDupeCoin = btn("DUPE COIN", Color3.fromRGB(255, 120, 0))
bDupeCoin.MouseButton1Click:Connect(function()
    local ls = plr:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Sheckles") then
        ls.Sheckles.Value = ls.Sheckles.Value * 2
    end
end)

local bFixLag1, cFixLag1 = btn("FIX LAG 1", Color3.fromRGB(0, 180, 255))
bFixLag1.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
        elseif v:IsA("ParticleEmitter") then v.Enabled = false end
    end
end)

local bFixLag2, cFixLag2 = btn("FIX LAG 2", Color3.fromRGB(255, 80, 0))
bFixLag2.MouseButton1Click:Connect(function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if plr.Character and not v:IsDescendantOf(plr.Character) and v:IsA("BasePart") then
            v.Transparency = 1
        end
    end
    pcall(function() Workspace.Terrain.WaterTransparency = 1 end)
end)
