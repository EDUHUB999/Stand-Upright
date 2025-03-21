-- โหลด Fluent UI Library และ Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- สร้าง Window
local Window = Fluent:CreateWindow({
    Title = "EDU HUB : Stand Upright : Rebooted",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- สร้าง Tabs
local Tabs = {
    FarmingQuests = Window:AddTab({ Title = "Farming & Quests", Icon = "" }),
    AutoFarmLevels = Window:AddTab({ Title = "Auto Farm All Levels", Icon = "" }),
    BossFarm = Window:AddTab({ Title = "Boss Farm", Icon = "" }),
    StandFarm = Window:AddTab({ Title = "Stand Farm", Icon = "" }),
    AutoBuy = Window:AddTab({ Title = "Auto Buy Item", Icon = "" }),
    DungeonFarm = Window:AddTab({ Title = "Dungeon Farm", Icon = "" }),
    ItemFarm = Window:AddTab({ Title = "Item Farm", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
getgenv().BeginFarm = false
local debugMode = false

local function Teleport(part, cframe)
    if part and part:IsA("BasePart") then
        pcall(function()
            part.CFrame = cframe
            part.Velocity = Vector3.new(0, 0, 0)
        end)
    end
end

local function waitForCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not hrp or not humanoid then
        return nil
    end
    return char
end

local char = waitForCharacter()
if not char then return end
local hrp = char.HumanoidRootPart
local originalPosition = hrp.CFrame

Teleport(hrp, CFrame.new(-727.006897, 67.0773239, -939.000366, 0.422592998, -0, -0.906319618, 0, 1, -0, 0.906319618, 0, 0.422592998))
task.wait(0.6)
Teleport(hrp, CFrame.new(28080.0684, 49.5559769, -237.245163, -0.866007447, 0.00292324182, -0.500022888, 0, 0.999982893, 0.00584611483, 0.500031412, 0.00506277755, -0.865992606))
task.wait(0.6)
Teleport(hrp, CFrame.new(11927.1, -3.28935, -4488.59))
task.wait(0.6)
Teleport(hrp, CFrame.new(-5234.27051, -449.936951, -3766.07373, 0.958408535, 1.30176289e-07, 0.285399795, 0.000306290051, 0.999999404, -0.0010290168, -0.285399646, 0.00107363367, 0.958407998))
task.wait(0.6)
Teleport(hrp, originalPosition)

local Disc = 7
local Disc3 = 0
local bodyPosition = nil
local bodyGyro = nil
local isUsingAllSkills = false

local function createBodyControls(hrp)
    if not bodyPosition then
        bodyPosition = Instance.new("BodyPosition")
        bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyPosition.P = 10000
        bodyPosition.D = 1000
        bodyPosition.Parent = hrp
    end
    if not bodyGyro then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 5000
        bodyGyro.D = 500
        bodyGyro.Parent = hrp
    end
end

local function fireServerSafe(remote, arg)
    local success = pcall(function()
        if arg ~= nil then
            remote:FireServer(arg)
        else
            remote:FireServer()
        end
    end)
    return success
end

local function useAllSkills(char)
    if char and char:FindFirstChild("StandEvents") then
        for _, event in pairs(char.StandEvents:GetChildren()) do
            if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                fireServerSafe(event, true)
                task.wait(0.05)
            end
        end
    end
end

local function findNearestMonster(monsterName)
    local closestMonster = nil
    local shortestDistance = math.huge
    for _, mob in pairs(Workspace.Living:GetChildren()) do
        if mob.Name == monsterName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - mob.PrimaryPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestMonster = mob
            end
        end
    end
    return closestMonster
end

local lastTeleportTime = 0
local function teleportToTarget(target)
    if target and target.PrimaryPart then
        local char = waitForCharacter()
        if not char then return end
        local hrp = char.HumanoidRootPart
        
        local targetPos = target.PrimaryPart.Position
        local hoverPos = targetPos + Vector3.new(0, Disc, Disc3)
        local targetCFrame = CFrame.lookAt(hoverPos, targetPos)
        
        createBodyControls(hrp)
        bodyPosition.Position = hoverPos
        bodyGyro.CFrame = targetCFrame
        
        local currentTime = tick()
        local distance = (hrp.Position - hoverPos).Magnitude
        if distance > 5 and currentTime - lastTeleportTime > 0.5 then
            Teleport(hrp, targetCFrame)
            char.Humanoid.Sit = true
            lastTeleportTime = currentTime
        end
    end
end

-- Tab: Farming & Quests
local isFarming = false
local selectedQuest = "Bad Gi [Lvl. 1+]"
local connection

local questList = {
    "Bad Gi [Lvl. 1+]", "Scary Monster [Lvl. 10+]", "Giorno Giovanna [Lvl. 20+]", "Rker Dummy [Lvl. 30+]",
    "Yoshikage Kira [Lvl. 40+]", "Dio Over Heaven [Lvl. 50+]", "Angelo [Lvl. 75+]", "Alien [Lvl. 100+]",
    "Jotaro Part 4 [Lvl. 125+]", "Kakyoin [Lvl. 150+]", "Sewer Vampire [Lvl. 200+]", "Pillerman [Lvl. 275+]"
}

local questData = {
    ["Bad Gi [Lvl. 1+]"] = {monster = "Bad Gi", npc = "Giorno"},
    ["Scary Monster [Lvl. 10+]"] = {monster = "Scary Monster", npc = "Scared Noob"},
    ["Giorno Giovanna [Lvl. 20+]"] = {monster = "Giorno Giovanna", npc = "Koichi"},
    ["Rker Dummy [Lvl. 30+]"] = {monster = "Rker Dummy", npc = "aLLmemester"},
    ["Yoshikage Kira [Lvl. 40+]"] = {monster = "Yoshikage Kira", npc = "Okayasu"},
    ["Dio Over Heaven [Lvl. 50+]"] = {monster = "Dio Over Heaven", npc = "Joseph Joestar"},
    ["Angelo [Lvl. 75+]"] = {monster = "Angelo", npc = "Josuke"},
    ["Alien [Lvl. 100+]"] = {monster = "Alien", npc = "Rohan"},
    ["Jotaro Part 4 [Lvl. 125+]"] = {monster = "Jotaro Part 4", npc = "DIO"},
    ["Kakyoin [Lvl. 150+]"] = {monster = "Kakyoin", npc = "Muhammed Avdol"},
    ["Sewer Vampire [Lvl. 200+]"] = {monster = "Sewer Vampire", npc = "Zeppeli"},
    ["Pillerman [Lvl. 275+]"] = {monster = "Pillerman", npc = "Young Joseph"}
}

local function startFarming()
    if connection then connection:Disconnect() end
    connection = RunService.Heartbeat:Connect(function()
        if not isFarming then
            connection:Disconnect()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            return
        end
        
        local quest = questData[selectedQuest]
        local target = findNearestMonster(quest.monster)
        if target then
            teleportToTarget(target)
            local npc = Workspace.Map.NPCs:FindFirstChild(quest.npc)
            if npc then
                fireServerSafe(npc.Done)
                fireServerSafe(npc.QuestDone)
            end
            local char = waitForCharacter()
            if char then
                if char:FindFirstChild("Aura") and not char.Aura.Value then
                    fireServerSafe(char.StandEvents.Summon)
                end
                if char:FindFirstChild("StandEvents") and not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                    fireServerSafe(char.StandEvents.M1)
                end
                if isUsingAllSkills then
                    useAllSkills(char)
                end
            end
        else
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then
                char.Humanoid.Sit = false
                local resetPosition = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, 200)
                Teleport(char.HumanoidRootPart, resetPosition)
            end
            task.wait(1)
        end
    end)
end

Tabs.FarmingQuests:AddToggle("AutoFarmQuests", {Title = "Auto Farm & Quests", Description = "Toggle auto farming and quests", Default = false})
Options.AutoFarmQuests:OnChanged(function()
    isFarming = Options.AutoFarmQuests.Value
    if isFarming then
        task.spawn(startFarming)
    else
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
end)

Tabs.FarmingQuests:AddDropdown("SelectQuest", {Title = "Select Quest/Monster", Values = questList, Default = 1})
Options.SelectQuest:OnChanged(function()
    selectedQuest = Options.SelectQuest.Value
end)

Tabs.FarmingQuests:AddSlider("YOffset", {Title = "Y Offset", Description = "Adjust hover height", Default = 7, Min = -30, Max = 30, Rounding = 1})
Options.YOffset:OnChanged(function(Value)
    Disc = Value
end)

Tabs.FarmingQuests:AddSlider("ZOffset", {Title = "Z Offset", Description = "Adjust forward/backward distance", Default = 0, Min = -30, Max = 30, Rounding = 1})
Options.ZOffset:OnChanged(function(Value)
    Disc3 = Value
end)

Tabs.FarmingQuests:AddToggle("UseAllSkills", {Title = "Use All Skills", Description = "Toggle using all skills", Default = false})
Options.UseAllSkills:OnChanged(function()
    isUsingAllSkills = Options.UseAllSkills.Value
end)

Tabs.FarmingQuests:AddButton({Title = "Refresh Character", Description = "Reset character state", Callback = function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
    end
end})

-- Tab: Auto Farm All Levels
local isLevelFarming = false
local levelConnection

local MonSettings = {
    ["Bad Gi [Lvl. 1+]"] = {"Bad Gi", "Giorno"},
    ["Scary Monster [Lvl. 10+]"] = {"Scary Monster", "Scared Noob"},
    ["Giorno Giovanna [Lvl. 20+]"] = {"Giorno Giovanna", "Koichi"},
    ["Rker Dummy [Lvl. 30+]"] = {"Rker Dummy", "aLLmemester"},
    ["Yoshikage Kira [Lvl. 40+]"] = {"Yoshikage Kira", "Okayasu"},
    ["Dio Over Heaven [Lvl. 50+]"] = {"Dio Over Heaven", "Joseph Joestar"},
    ["Angelo [Lvl. 75+]"] = {"Angelo", "Josuke"},
    ["Alien [Lvl. 100+]"] = {"Alien", "Rohan"},
    ["Jotaro Part 4 [Lvl. 125+]"] = {"Jotaro Part 4", "DIO"},
    ["Kakyoin [Lvl. 150+]"] = {"Kakyoin", "Muhammed Avdol"},
    ["Sewer Vampire [Lvl. 200+]"] = {"Sewer Vampire", "Zeppeli"},
    ["Pillerman [Lvl. 275+]"] = {"Pillerman", "Young Joseph"}
}

local levelMap = {
    {minLevel = 1, maxLevel = 10, name = "Bad Gi [Lvl. 1+]"},
    {minLevel = 10, maxLevel = 20, name = "Scary Monster [Lvl. 10+]"},
    {minLevel = 21, maxLevel = 30, name = "Giorno Giovanna [Lvl. 20+]"},
    {minLevel = 31, maxLevel = 40, name = "Rker Dummy [Lvl. 30+]"},
    {minLevel = 41, maxLevel = 50, name = "Yoshikage Kira [Lvl. 40+]"},
    {minLevel = 51, maxLevel = 60, name = "Dio Over Heaven [Lvl. 50+]"},
    {minLevel = 61, maxLevel = 100, name = "Angelo [Lvl. 75+]"},
    {minLevel = 101, maxLevel = 125, name = "Alien [Lvl. 100+]"},
    {minLevel = 126, maxLevel = 150, name = "Jotaro Part 4 [Lvl. 125+]"},
    {minLevel = 151, maxLevel = 200, name = "Kakyoin [Lvl. 150+]"},
    {minLevel = 201, maxLevel = 275, name = "Sewer Vampire [Lvl. 200+]"},
    {minLevel = 276, maxLevel = math.huge, name = "Pillerman [Lvl. 275+]"}
}

local function createInvisiblePlatform(position)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 1, 10)
    platform.Position = position
    platform.Anchored = true
    platform.Transparency = 1
    platform.CanCollide = true
    platform.Name = "InvisiblePlatform"
    platform.Parent = Workspace
    return platform
end

-- ฟังก์ชันใช้สกิลที่เลือก (หลายสกิล)
local function useSelectedSkills(char, selectedSkills)
    if char and char:FindFirstChild("StandEvents") and selectedSkills then
        for skill, enabled in pairs(selectedSkills) do
            if enabled then
                local skillEvent = char.StandEvents:FindFirstChild(skill)
                if skillEvent then
                    fireServerSafe(skillEvent, true)
                    task.wait(0.05) -- หน่วงเล็กน้อยระหว่างสกิล
                end
            end
        end
    end
end

-- ฟังก์ชันดึงสกิลจาก StandEvents
local function getPlayerSkills()
    local char = waitForCharacter()
    local skillList = {"None"} -- เริ่มด้วย "None" เป็นตัวเลือก
    if char and char:FindFirstChild("StandEvents") then
        for _, event in pairs(char.StandEvents:GetChildren()) do
            -- กรองสกิลที่ไม่ต้องการ เช่น Block, Pose, Summon
            if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                table.insert(skillList, event.Name)
            end
        end
    end
    return skillList
end

local function startLevelFarming()
    if levelConnection then levelConnection:Disconnect() end
    levelConnection = RunService.Heartbeat:Connect(function()
        if not isLevelFarming then
            levelConnection:Disconnect()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            return
        end
        
        local level = LocalPlayer.Data.Level.Value or 1
        local matchedSetting = nil
        for _, setting in ipairs(levelMap) do
            if level >= setting.minLevel and level <= setting.maxLevel then
                matchedSetting = MonSettings[setting.name]
                break
            end
        end
        
        if matchedSetting then
            local target = findNearestMonster(matchedSetting[1])
            if target then
                teleportToTarget(target)
                local npc = Workspace.Map.NPCs:FindFirstChild(matchedSetting[2])
                if npc then
                    fireServerSafe(npc.Done)
                    fireServerSafe(npc.QuestDone)
                end
                local char = waitForCharacter()
                if char then
                    if char:FindFirstChild("Aura") and not char.Aura.Value then
                        fireServerSafe(char.StandEvents.Summon)
                    end
                    if char:FindFirstChild("StandEvents") and not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                        fireServerSafe(char.StandEvents.M1)
                    end
                    -- ใช้สกิลที่เลือกจาก Multi Dropdown
                    local selectedSkills = Options.SelectSkills and Options.SelectSkills.Value or {}
                    if next(selectedSkills) then -- ตรวจสอบว่ามีสกิลที่เลือกหรือไม่
                        useSelectedSkills(char, selectedSkills)
                    elseif isUsingAllSkills then
                        useAllSkills(char) -- ใช้สกิลทั้งหมดถ้าไม่ได้เลือก
                    end
                end
            else
                if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                local char = waitForCharacter()
                if char then
                    char.Humanoid.Sit = false
                    local resetPosition = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, 200)
                    local platform = createInvisiblePlatform(resetPosition.Position + Vector3.new(0, -0.5, 0))
                    Teleport(char.HumanoidRootPart, CFrame.new(platform.Position + Vector3.new(0, 1, 0)))
                    task.spawn(function()
                        task.wait(1)
                        if platform and platform.Parent then
                            platform:Destroy()
                        end
                    end)
                end
            end
        else
            task.wait(1)
        end
        
        task.wait(0.1) -- หน่วงเพื่อลดการใช้ทรัพยากร
    end)
end

-- UI สำหรับ Auto Farm All Levels
Tabs.AutoFarmLevels:AddToggle("AutoFarmLevels", {Title = "Auto Farm All Levels", Description = "Farm based on your level", Default = false})
Options.AutoFarmLevels:OnChanged(function()
    isLevelFarming = Options.AutoFarmLevels.Value
    if isLevelFarming then
        if isFarming then
            Fluent:Notify({Title = "Error", Content = "Please disable Auto Farm & Quests first!", Duration = 5})
            isLevelFarming = false
            Options.AutoFarmLevels:SetValue(false)
            return
        end
        task.spawn(startLevelFarming)
    else
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
end)

-- เพิ่ม Multi Dropdown สำหรับเลือกสกิลหลายอัน
Tabs.AutoFarmLevels:AddDropdown("SelectSkills", {
    Title = "Select Skills",
    Description = "Choose multiple skills to use",
    Values = getPlayerSkills(), -- ดึงสกิลจาก StandEvents
    Multi = true, -- เปิดโหมดเลือกหลายอัน
    Default = {} -- ไม่เลือกอะไรเริ่มต้น
})

-- อัปเดต Dropdown เมื่อตัวละครเปลี่ยนหรือโหลดใหม่
LocalPlayer.CharacterAdded:Connect(function()
    if Tabs.AutoFarmLevels then
        Options.SelectSkills:SetValues(getPlayerSkills()) -- อัปเดตรายการสกิล
    end
end)

-- Tab: Boss Farm
local isBossFarming = false
local selectedBoss = nil
local bossConnection

local bossList = {
    "Jotaro Over Heaven", "Alternate Jotaro Part 4", "JohnnyJoestar", "Giorno Giovanna Requiem"
}

local function startBossFarming()
    if bossConnection then bossConnection:Disconnect() end
    bossConnection = RunService.Heartbeat:Connect(function()
        if not isBossFarming then
            bossConnection:Disconnect()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            return
        end
        
        local boss = Workspace.Living:FindFirstChild(selectedBoss)
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            teleportToTarget(boss)
            local char = waitForCharacter()
            if char then
                if char:FindFirstChild("Aura") and not char.Aura.Value then
                    fireServerSafe(char.StandEvents.Summon)
                end
                if char:FindFirstChild("StandEvents") and not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                    fireServerSafe(char.StandEvents.M1)
                end
                if isUsingAllSkills then
                    useAllSkills(char)
                end
            end
        else
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            task.wait(1)
        end
    end)
end

Tabs.BossFarm:AddDropdown("SelectBoss", {Title = "Select Boss", Values = bossList, Default = nil})
Options.SelectBoss:OnChanged(function()
    selectedBoss = Options.SelectBoss.Value
end)

Tabs.BossFarm:AddToggle("AutoFarmBoss", {Title = "Auto Farm Boss", Description = "Toggle boss farming", Default = false})
Options.AutoFarmBoss:OnChanged(function()
    isBossFarming = Options.AutoFarmBoss.Value
    if isBossFarming then
        if not selectedBoss then
            Fluent:Notify({Title = "Error", Content = "Please select a boss first!", Duration = 5})
            isBossFarming = false
            Options.AutoFarmBoss:SetValue(false)
            return
        end
        if isFarming or isLevelFarming then
            Fluent:Notify({Title = "Error", Content = "Please disable other farming modes first!", Duration = 5})
            isBossFarming = false
            Options.AutoFarmBoss:SetValue(false)
            return
        end
        task.spawn(startBossFarming)
    else
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
end)

-- Tab: Stand Farm (อัปเดตใหม่)
do
    -- ข้อมูล Stands และ Attributes
    local StandArrowsList = {
        "Cream", "HierophantGreen", "KillerQueen", "SilverChariot", "StarPlatinum", "StickyFingers",
        "StarPlatinum:StoneOcean", "CrazyDiamond", "Aerosmith", "StoneFree", "TheEmperor", "TheHand",
        "softandwet", "magiciansred", "DiverDown", "PurpleSmoke", "WhiteSnake", "TheWorld", "WeatherReport",
        "D4C", "DirtyDeedsDoneDirtCheap", "GoldenExperience", "KingCrimson", "PremierMacho",
        "SilverChariotOVA", "TheWorldOVA", "Jotaro'sStarPlatinum", "StarPlatinum OVA"
    }

    local ChargedArrowsList = {
        "CrazyDiamond", "SilverChariot", "HierophantGreen", "KillerQueen", "StarPlatinum", "TheHand",
        "D4she", "DirtyDeedsDoneDirtCheap", "GoldenExperience", "KingCrimson", "TheWorld", "TuskAct1",
        "TheWorld:AlternativeUniverse", "Whitesnake", "Dio'sThe World"
    }

    local AttributesList = {
        "None", "Strong", "Tough", "Sloppy", "Powerful", "Manic", "Enrage", "Lethargic", "Godly",
        "Daemon", "Invincible", "Tragic", "Scourge", "Hacker", "Legendary"
    }

    local RokakakaStand = "PutridWhine" -- สแตนที่ได้จาก Rokakaka

    -- ตัวแปรสำหรับ Stand Farm
    local WhitelistedStands = {}
    local WhitelistedAttributes = {}
    local ArrowToUse = "Stand Arrow"
    local CheckStand, CheckAttri = false, false
    local BeginFarm = false

    -- ฟังก์ชันช่วยเหลือ
    local function normalizeString(str)
        return str:gsub("[%s:']", ""):upper()
    end

    local function notify(title, content, duration)
        Fluent:Notify({Title = title, Content = content, Duration = duration or 5})
    end

    local function useItem(itemName, char)
        local item = LocalPlayer.Backpack:FindFirstChild(itemName)
        if not item then
            notify("Error", "No " .. itemName .. " in Backpack!", 5)
            return false
        end
        char.Humanoid:EquipTool(item)
        task.wait(0.2)
        if char:FindFirstChild(itemName) then
            char[itemName]:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            local prompt = char[itemName]:FindFirstChildOfClass("ProximityPrompt")
            if prompt then fireproximityprompt(prompt, 1) end
            return true
        end
        return false
    end

    -- ตรวจสอบ Stand และ Attribute
    local function checkStandAndAttribute()
        local stand = LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value or "None"
        local attribute = LocalPlayer.Data and LocalPlayer.Data.Attri and LocalPlayer.Data.Attri.Value or "None"
        stand = normalizeString(stand)
        attribute = tostring(attribute)

        local standMatch = not CheckStand or (CheckStand and table.find(WhitelistedStands, stand))
        local attriMatch = not CheckAttri or (CheckAttri and table.find(WhitelistedAttributes, attribute))

        return standMatch and attriMatch
    end

    -- ฟังก์ชันหลักสำหรับ Stand Farm
    local function cycleStand()
        local char = waitForCharacter()
        if not char then
            notify("Error", "Character not found!", 5)
            return
        end

        local stand = LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value or "None"
        stand = normalizeString(stand)

        if stand == "NONE" then
            -- ใช้ Arrow ที่เลือก
            if useItem(ArrowToUse, char) then
                repeat task.wait(0.5) until (LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value ~= "None") or not BeginFarm
            end
        elseif checkStandAndAttribute() then
            -- ถ้าเจอ Stand และ Attribute ที่ต้องการ
            local stored = false
            for i = 1, 2 do
                if LocalPlayer.Data and LocalPlayer.Data["Slot" .. i .. "Stand"] and LocalPlayer.Data["Slot" .. i .. "Stand"].Value == "None" then
                    fireServerSafe(ReplicatedStorage.Events.SwitchStand, "Slot" .. i)
                    repeat task.wait(0.5) until (LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None") or not BeginFarm
                    if LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None" then
                        stored = true
                        notify("Success", "Stand stored in Slot " .. i, 3)
                    end
                    break
                end
            end
            if not stored then
                notify("Error", "No empty slots available!", 5)
            end
        else
            -- ใช้ Rokakaka ถ้าไม่ตรงเงื่อนไข
            if useItem("Rokakaka", char) then
                repeat task.wait(0.5) until (LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None") or not BeginFarm
            end
        end
    end

    -- UI สำหรับ Stand Farm
    Tabs.StandFarm:AddDropdown("SelectStands", {
        Title = "Select Stands",
        Description = "Choose stands to farm",
        Values = StandArrowsList,
        Multi = true,
        Default = {}
    })
    Options.SelectStands:OnChanged(function(Value)
        WhitelistedStands = {}
        for stand, state in pairs(Value) do
            if state then
                table.insert(WhitelistedStands, normalizeString(stand))
            end
        end
    end)

    Tabs.StandFarm:AddDropdown("SelectAttributes", {
        Title = "Select Attributes",
        Description = "Choose attributes to farm",
        Values = AttributesList,
        Multi = true,
        Default = {}
    })
    Options.SelectAttributes:OnChanged(function(Value)
        WhitelistedAttributes = {}
        for attr, state in pairs(Value) do
            if state then
                table.insert(WhitelistedAttributes, attr)
            end
        end
    end)

    Tabs.StandFarm:AddButton({Title = "Use Stand Arrows", Callback = function() ArrowToUse = "Stand Arrow" end})
    Tabs.StandFarm:AddButton({Title = "Use Charged Arrows", Callback = function() ArrowToUse = "Charged Arrow" end})

    Tabs.StandFarm:AddToggle("StandCheck", {Title = "Stand Check", Default = false})
    Options.StandCheck:OnChanged(function() CheckStand = Options.StandCheck.Value end)

    Tabs.StandFarm:AddToggle("AttributeCheck", {Title = "Attribute Check", Default = false})
    Options.AttributeCheck:OnChanged(function() CheckAttri = Options.AttributeCheck.Value end)

    Tabs.StandFarm:AddButton({Title = "Open Stand Storage", Callback = function() 
        fireServerSafe(Workspace.Map.NPCs.admpn.Done) 
    end})

    Tabs.StandFarm:AddToggle("StartStandFarm", {Title = "Start Stand Farm", Default = false})
    Options.StartStandFarm:OnChanged(function()
        BeginFarm = Options.StartStandFarm.Value
        if BeginFarm then
            if not CheckStand and not CheckAttri then
                notify("Error", "Enable Stand Check or Attribute Check first!", 5)
                BeginFarm = false
                Options.StartStandFarm:SetValue(false)
                return
            end
            if CheckStand and #WhitelistedStands == 0 then
                notify("Error", "Select at least one Stand!", 5)
                BeginFarm = false
                Options.StartStandFarm:SetValue(false)
                return
            end
            if CheckAttri and #WhitelistedAttributes == 0 then
                notify("Error", "Select at least one Attribute!", 5)
                BeginFarm = false
                Options.StartStandFarm:SetValue(false)
                return
            end
            notify("Info", "Stand Farm Started", 3)
            task.spawn(function()
                while BeginFarm do
                    cycleStand()
                    task.wait(1)
                end
                notify("Info", "Stand Farm Stopped", 3)
            end)
        else
            notify("Info", "Stand Farm Stopped", 3)
        end
    end)
end

-- Tab: Auto Buy Item
local Amount = 1

Tabs.AutoBuy:AddButton({Title = "Teleport to Shop", Callback = function()
    local char = waitForCharacter()
    if char then
        Teleport(char.HumanoidRootPart, CFrame.new(11927.1, -3.28935, -4488.59))
        if char:FindFirstChild("Stand") then
            Teleport(char.Stand.HumanoidRootPart, char.HumanoidRootPart.CFrame)
        end
    end
end})

Tabs.AutoBuy:AddInput("BuyAmount", {Title = "Enter Amount", Default = "1", Numeric = true, Callback = function(Value) Amount = tonumber(Value) or 1 end})

local buyItems = {
    {"Rokakaka (2,500c)", "MerchantAU", "Option2"},
    {"Stand Arrow (3,500c)", "MerchantAU", "Option4"},
    {"Charged Arrow (50,000c)", "Merchantlvl120", "Option2"},
    {"Dio Diary (1,500,000c)", "Merchantlvl120", "Option3"},
    {"Requiem Arrow (1,500,000c)", "Merchantlvl120", "Option4"}
}
for _, item in ipairs(buyItems) do
    Tabs.AutoBuy:AddButton({Title = item[1], Callback = function()
        for i = 1, Amount do
            ReplicatedStorage.Events.BuyItem:FireServer(item[2], item[3])
        end
    end})
end

-- Tab: Dungeon Farm
local DunLvl = {
    "Dungeon [Lvl.15+]", "Dungeon [Lvl.40+]", "Dungeon [Lvl.80+]", "Dungeon [Lvl.100+]", "Dungeon [Lvl.200+]"
}
local dungeonSettings = {
    ["Dungeon [Lvl.15+]"] = {npcMonster = "i_stabman [Lvl. 15+]", bossName = "Bad Gi Boss", baseDistance = 7},
    ["Dungeon [Lvl.40+]"] = {npcMonster = "i_stabman [Lvl. 40+]", bossName = "Dio [Dungeon]", baseDistance = 10},
    ["Dungeon [Lvl.80+]"] = {npcMonster = "i_stabman [Lvl. 80+]", bossName = "Homeless Lord", baseDistance = 12},
    ["Dungeon [Lvl.100+]"] = {npcMonster = "i_stabman [Lvl. 100+]", bossName = "Diavolo [Dungeon]", baseDistance = 10},
    ["Dungeon [Lvl.200+]"] = {npcMonster = "i_stabman [Lvl. 200+]", bossName = "Jotaro P6 [Dungeon]", baseDistance = 15}
}

local ChDun = "Dungeon [Lvl.15+]"
local isDungeonFarming = false
local dungeonConnection
local lastTeleport = 0
local currentTarget = nil
local safePosition = nil
local currentDistance = 7
local minDistance = 3
local maxDistance = 20
local lastHealth = 0
local lastDamageCheck = 0

local function isQuestActive()
    local questGui = LocalPlayer.PlayerGui:FindFirstChild("QuestGui")
    return questGui and questGui:FindFirstChild("Active") and questGui.Active.Value or false
end

local function findDungeonNPC()
    for _, npc in ipairs(Workspace.Map.NPCs:GetChildren()) do
        if npc.Name:find("i_stabman") and npc:FindFirstChild("Head") and npc.Head:FindFirstChild("Main") and npc.Head.Main:FindFirstChild("Text") then
            if npc.Head.Main.Text.Text == dungeonSettings[ChDun].npcMonster then
                local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                if npcHRP then
                    safePosition = npcHRP.CFrame + Vector3.new(0, 3, 5)
                    return npc
                end
            end
        end
    end
    return nil
end

local function findDungeonBoss()
    for _, boss in pairs(Workspace.Living:GetChildren()) do
        if boss.Name == "Boss" and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            local head = boss:FindFirstChild("Head")
            if head and head:FindFirstChild("Display") and head.Display:FindFirstChild("Frame") then
                local text = head.Display.Frame:FindFirstChild("TextLabel") or head.Display.Frame:FindFirstChild("t")
                if text and text.Text == dungeonSettings[ChDun].bossName then
                    return boss
                end
            end
        end
    end
    return nil
end

local function updatePositionToTarget(target)
    local char = waitForCharacter()
    if not char or not target or not target:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = char.HumanoidRootPart
    local targetHRP = target.HumanoidRootPart
    local stand = char:FindFirstChild("Stand")
    local standHRP = stand and stand:FindFirstChild("HumanoidRootPart")

    local targetPos = targetHRP.Position
    local direction = (targetPos - hrp.Position).Unit
    local adjustedPos = targetPos - (direction * currentDistance) + Vector3.new(0, Disc, Disc3)
    local targetCFrame = CFrame.lookAt(adjustedPos, targetPos)

    createBodyControls(hrp)
    bodyPosition.Position = adjustedPos
    bodyGyro.CFrame = targetCFrame

    if (hrp.Position - adjustedPos).Magnitude > 5 then
        Teleport(hrp, targetCFrame)
        if standHRP then Teleport(standHRP, targetCFrame) end
    end
end

local function adjustDistanceIfNoDamage(boss)
    if not boss or not boss:FindFirstChild("Humanoid") then return end
    local now = tick()
    
    if now - lastDamageCheck >= 2 then
        local currentHealth = boss.Humanoid.Health
        if currentHealth >= lastHealth and lastHealth > 0 then
            if currentDistance > minDistance then
                currentDistance = math.max(minDistance, currentDistance - 2)
            end
        end
        lastHealth = currentHealth
        lastDamageCheck = now
    end
end

Tabs.DungeonFarm:AddDropdown("ChooseDungeon", {Title = "Choose Dungeon", Values = DunLvl, Default = 1})
Options.ChooseDungeon:OnChanged(function()
    ChDun = Options.ChooseDungeon.Value
    currentDistance = dungeonSettings[ChDun].baseDistance
    currentTarget = nil
    safePosition = nil
    lastHealth = 0
    lastDamageCheck = 0
end)

Tabs.DungeonFarm:AddToggle("AutoFarmDungeon", {Title = "Auto Farm Dungeon", Default = false})
Options.AutoFarmDungeon:OnChanged(function()
    isDungeonFarming = Options.AutoFarmDungeon.Value
    if isFarming or isLevelFarming or isBossFarming then
        Fluent:Notify({Title = "Error", Content = "Please disable other farming modes first!", Duration = 5})
        isDungeonFarming = false
        Options.AutoFarmDungeon:SetValue(false)
        return
    end
    if not ChDun or not dungeonSettings[ChDun] then
        Fluent:Notify({Title = "Error", Content = "No valid dungeon selected!", Duration = 5})
        isDungeonFarming = false
        Options.AutoFarmDungeon:SetValue(false)
        return
    end

    if isDungeonFarming then
        currentDistance = dungeonSettings[ChDun].baseDistance
        Fluent:Notify({Title = "Info", Content = "Dungeon Farm Started", Duration = 3})
        task.spawn(function()
            dungeonConnection = RunService.Heartbeat:Connect(function()
                if not isDungeonFarming then
                    if dungeonConnection then dungeonConnection:Disconnect() end
                    if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                    local char = waitForCharacter()
                    if char then char.Humanoid.Sit = false end
                    Fluent:Notify({Title = "Info", Content = "Dungeon Farm Stopped", Duration = 3})
                    return
                end

                local char = waitForCharacter()
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    return
                end
                local hrp = char.HumanoidRootPart
                local now = tick()

                if not isQuestActive() and (not currentTarget or currentTarget == "NPC") then
                    local npc = findDungeonNPC()
                    if npc and now - lastTeleport > 1 then
                        local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                        if npcHRP then
                            Teleport(hrp, npcHRP.CFrame + Vector3.new(0, 2, 2))
                            lastTeleport = now
                            local prompt = npcHRP:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then fireproximityprompt(prompt, 20) end
                            local done = npc:FindFirstChild("Done")
                            if done then fireServerSafe(done) end
                            currentTarget = "Boss"
                            task.wait(5)
                        end
                    end
                end

                if currentTarget == "Boss" then
                    local boss = findDungeonBoss()
                    if boss then
                        updatePositionToTarget(boss)
                        adjustDistanceIfNoDamage(boss)
                        if char:FindFirstChild("Aura") and not char.Aura.Value then
                            fireServerSafe(char.StandEvents.Summon)
                        end
                        if char:FindFirstChild("StandEvents") and not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                            fireServerSafe(char.StandEvents.M1)
                        end
                        if isUsingAllSkills then useAllSkills(char) end
                    else
                        if now - lastTeleport > 5 then
                            if safePosition then
                                Teleport(hrp, safePosition)
                                lastTeleport = now
                                local npc = findDungeonNPC()
                                if npc then
                                    local questDone = npc:FindFirstChild("QuestDone")
                                    if questDone then fireServerSafe(questDone) end
                                end
                                currentTarget = "NPC"
                            end
                        end
                    end
                end
                task.wait(0.1)
            end)
        end)
    end
end)

Tabs.DungeonFarm:AddSlider("DungeonYOffset", {Title = "Y Offset", Description = "Adjust hover height", Default = 7, Min = -30, Max = 30, Rounding = 1})
Options.DungeonYOffset:OnChanged(function(Value)
    Disc = Value
end)

Tabs.DungeonFarm:AddSlider("DungeonZOffset", {Title = "Z Offset", Description = "Adjust forward/backward distance", Default = 0, Min = -30, Max = 30, Rounding = 1})
Options.DungeonZOffset:OnChanged(function(Value)
    Disc3 = Value
end)

Tabs.DungeonFarm:AddToggle("DungeonUseAllSkills", {Title = "Use All Skills", Description = "Toggle using all skills", Default = false})
Options.DungeonUseAllSkills:OnChanged(function()
    isUsingAllSkills = Options.DungeonUseAllSkills.Value
end)

Tabs.DungeonFarm:AddButton({Title = "Refresh Character", Callback = function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
    end
end})

-- Tab: Item Farm
local isItemFarming = false
local itemConnection

local function safeTeleport(part, cframe)
    if part and part:IsA("BasePart") then
        pcall(function()
            part.CFrame = cframe
            part.Velocity = Vector3.new(0, 0, 0)
        end)
    end
end

Tabs.ItemFarm:AddToggle("FarmItems", {Title = "Farm Items", Description = "Collect nearby items", Default = false})
Options.FarmItems:OnChanged(function()
    isItemFarming = Options.FarmItems.Value
    _G.On = isItemFarming

    if isItemFarming and (isFarming or isLevelFarming or isBossFarming or isDungeonFarming) then
        isItemFarming = false
        _G.On = false
        Options.FarmItems:SetValue(false)
        return
    end

    if itemConnection then
        itemConnection:Disconnect()
    end

    if isItemFarming then
        itemConnection = RunService.Heartbeat:Connect(function()
            if not isItemFarming or not _G.On then
                if itemConnection then itemConnection:Disconnect() end
                local char = waitForCharacter()
                if char then char.Humanoid.Sit = false end
                return
            end

            local char = waitForCharacter()
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                return
            end
            local hrp = char.HumanoidRootPart

            for _, v in pairs(Workspace.Vfx:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name == "Handle" or v.Name:find("Item")) and v.Parent then
                    local prompt = v.Parent:FindFirstChild("ProximityPrompt") or v:FindFirstChild("ProximityPrompt")
                    if prompt then
                        local distance = (hrp.Position - v.Position).Magnitude
                        if distance > 5 then
                            safeTeleport(hrp, CFrame.new(v.Position + Vector3.new(0, 3, 0)))
                            task.wait(0.5)
                        end
                        if distance <= 5 then
                            fireproximityprompt(prompt, 20)
                            task.wait(0.3)
                        end
                    end
                end
            end

            if Workspace:FindFirstChild("Items") then
                for _, item in pairs(Workspace.Items:GetChildren()) do
                    if item:IsA("BasePart") and item:FindFirstChild("ProximityPrompt") then
                        local distance = (hrp.Position - item.Position).Magnitude
                        if distance > 5 then
                            safeTeleport(hrp, CFrame.new(item.Position + Vector3.new(0, 3, 0)))
                            task.wait(0.5)
                        end
                        if distance <= 5 then
                            fireproximityprompt(item.ProximityPrompt, 20)
                            task.wait(0.3)
                        end
                    end
                end
            end

            task.wait(0.5)
        end)
    else
        if itemConnection then itemConnection:Disconnect() end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
end)

-- Tab: Settings
local isAntiAFK = false

local function antiAFK()
    task.spawn(function()
        while isAntiAFK do
            local char = waitForCharacter()
            if char then
                game:GetService("VirtualInputManager"):SendKeyEvent(true, "W", false, game)
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, "W", false, game)
                task.wait(300)
            else
                task.wait(5)
            end
        end
    end)
end

Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti-AFK", Description = "Prevent AFK kick", Default = false})
Options.AntiAFK:OnChanged(function()
    isAntiAFK = Options.AntiAFK.Value
    if isAntiAFK then antiAFK() end
end)

Window:SelectTab(1)
Fluent:Notify({Title = "EDU HUB", Content = "The script has been loaded.", Duration = 8})
SaveManager:LoadAutoloadConfig()

-- เพิ่มโค้ดสำหรับ Floating Button
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- สร้าง Floating Button
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "FloatingButtonGui"
ScreenGui.ResetOnSpawn = false

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Size = UDim2.new(0, 50, 0, 50) -- ขนาดวงกลมเล็ก
FloatingButton.Position = UDim2.new(0.5, -25, 0.5, -25) -- เริ่มตรงกลางจอ
FloatingButton.BackgroundTransparency = 1
FloatingButton.Image = "http://www.roblox.com/asset/?id=12514663645"
FloatingButton.Parent = ScreenGui

-- ทำให้เป็นวงกลม
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- รัศมีเต็มเพื่อให้เป็นวงกลม
UICorner.Parent = FloatingButton

-- ตัวแปรสำหรับการลาก
local dragging
local dragInput
local dragStart
local startPos

-- ฟังก์ชันลาก
FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatingButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

FloatingButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        local delta = input.Position - dragStart
        FloatingButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ควบคุมการเปิด/ซ่อน UI
local isUIVisible = true
Window.MinimizeKey = Enum.KeyCode.RightControl -- ใช้ MinimizeKey เดียวกับที่กำหนดใน Window

FloatingButton.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    if isUIVisible then
        Window:Minimize(false) -- แสดง UI
        TweenService:Create(FloatingButton, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
    else
        Window:Minimize(true) -- ซ่อน UI
        TweenService:Create(FloatingButton, TweenInfo.new(0.3), {ImageTransparency = 0.5}):Play()
    end
end)

-- ซ่อน UI ตอนเริ่มต้น (ถ้าต้องการ)
Window:Minimize(false)
