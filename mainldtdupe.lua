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
    c.CornerRadius = UDim.new(0, v or 6)
end

-----------------------------------------------------------
-- [[ MENU CHÍNH ]] --
-----------------------------------------------------------
local mf = Instance.new("Frame", sg)
mf.Size, mf.Position = UDim2.new(0, 180, 0, 320), UDim2.new(0.5, -90, 0.4, -120)
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

toggleBtn.MouseButton1Click:Connect(function()
    local isOpen = (mf.Size.Y.Offset > 50)
    toggleBtn.Text = isOpen and "+" or "-"
    mf:TweenSize(isOpen and UDim2.new(0, 180, 0, 30) or UDim2.new(0, 180, 0, 320), "Out", "Quart", 0.2, true)
    ctn.Visible = not isOpen
end)

local function btn(txt, col)
    local b = Instance.new("TextButton", ctn)
    b.Size = UDim2.new(1, 0, 0, 38)
    b.Text, b.BackgroundColor3 = txt, col
    b.TextColor3, b.Font, b.TextSize = Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 13
    r(b, 4)
    return b
end

-----------------------------------------------------------
-- 1. DUPE PET
-----------------------------------------------------------
btn("DUPE PET", Color3.fromRGB(0, 100, 200)).MouseButton1Click:Connect(function()
    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if tool and (tool:GetAttribute("PetId") or tool:GetAttribute("Pet")) then
        local clone = tool:Clone()
        clone:SetAttribute("PetId", "CLONED_FAKE")
        clone.Parent = plr.Backpack
    end
end)

-----------------------------------------------------------
-- 2. DUPE SEEDS
-----------------------------------------------------------
btn("DUPE SEEDS", Color3.fromRGB(40, 140, 40)).MouseButton1Click:Connect(function()
    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    if tool and (tool:GetAttribute("SeedTool") or tool:GetAttribute("MainCategory") == "Seed") then
        tool:SetAttribute("Count", (tool:GetAttribute("Count") or 0) + 10)
    end
end)

-----------------------------------------------------------
-- 3. DUPE COIN
-----------------------------------------------------------
btn("DUPE COIN", Color3.fromRGB(200, 80, 0)).MouseButton1Click:Connect(function()
    local ls = plr:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Sheckles") then
        ls.Sheckles.Value = ls.Sheckles.Value * 2
    end
end)

-----------------------------------------------------------
-- 4. FIX LAG 1
-----------------------------------------------------------
btn("FIX LAG 1", Color3.fromRGB(0, 120, 215)).MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = false end
    end
end)

-----------------------------------------------------------
-- 5. FIX LAG 2
-----------------------------------------------------------
btn("FIX LAG 2", Color3.fromRGB(200, 80, 0)).MouseButton1Click:Connect(function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if plr.Character and not v:IsDescendantOf(plr.Character) then
            if v:IsA("BasePart") then v.Transparency = 1; v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("SurfaceGui") or v:IsA("BillboardGui") then v.Enabled = false end
        end
    end
    pcall(function() Workspace.Terrain.WaterTransparency = 1 end)
end)
