-- สร้าง ScreenGui อย่างปลอดภัย
local success, ScreenGui = pcall(function()
    return Instance.new("ScreenGui")
end)
if not success or not ScreenGui then
    warn("Failed to create ScreenGui!")
    return
end
ScreenGui.Parent = game.CoreGui

local Frame_1 = Instance.new("Frame")
local ImageButton_1 = Instance.new("ImageButton")

Frame_1.Parent = ScreenGui
Frame_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame_1.Position = UDim2.new(0.0496077649, 0, 0.134853914, 0)
Frame_1.Size = UDim2.new(0, 33, 0, 31)

ImageButton_1.Parent = Frame_1
ImageButton_1.Active = true
ImageButton_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton_1.BorderColor3 = Color3.fromRGB(128, 17, 255)
ImageButton_1.Position = UDim2.new(-0.00698809186, 0, -0.0136182783, 0)
ImageButton_1.Size = UDim2.new(0, 33, 0, 31)
ImageButton_1.Image = "http://www.roblox.com/asset/?id=12514663645"
ImageButton_1.MouseButton1Down:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "RightControl", false, game)
end)

-- โหลด Kavo UI Library
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EVILDARKSIDEUPV1/ui/main/README.md"))()
end)
if not success or not Library then
    warn("Failed to load Kavo UI Library! Please check your internet connection or the URL.")
    return
end

if not Library.CreateNotification then
    warn("CreateNotification function not found in Kavo UI Library! Using fallback notification.")
    Library.CreateNotification = function(message, title, duration)
        if debugMode then
            print("Notification (Fallback): " .. title .. " - " .. tostring(message) .. " (Duration: " .. duration .. "s)")
        end
    end
end

local Window = Library.CreateLib("EDU HUB : Stand Upright : Rebooted", "BloodTheme")
if not Window then
    warn("Failed to create Window! Check Library compatibility.")
    return
end

-- ตัวแปรทั่วไป
local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
getgenv().BeginFarm = false
local debugMode = false

-- ฟังก์ชัน Teleport
local function Teleport(part, cframe)
    if part and part:IsA("BasePart") then
        pcall(function()
            part.CFrame = cframe
            part.Velocity = Vector3.new(0, 0, 0)
        end)
    end
end

-- ฟังก์ชันรอตัวละคร
local function waitForCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not hrp or not humanoid then
        return nil
    end
    return char
end

-- โหลดแมพก่อนสร้าง UI
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

-- ตัวแปรสำหรับ Farming
local Disc = 7
local Disc3 = 0
local bodyPosition = nil
local bodyGyro = nil
local isUsingAllSkills = false

-- ฟังก์ชันสร้าง BodyPosition และ BodyGyro
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

-- ฟังก์ชันเรียก RemoteEvent อย่างปลอดภัย
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

-- ฟังก์ชันใช้สกิลทั้งหมด
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

-- ฟังก์ชันหามอนสเตอร์ที่ใกล้ที่สุด
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

-- ฟังก์ชันวาร์ปและล็อกตำแหน่ง
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
local FarmTab = Window:NewTab("Farming & Quests")
local FarmSection = FarmTab:NewSection("Auto Farm & Quest Settings")
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

FarmSection:NewToggle("Auto Farm & Quests", "Toggle auto farming and quests", function(state)
    isFarming = state
    if isFarming then
        task.spawn(startFarming)
    else
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
end)

FarmSection:NewDropdown("Select Quest/Monster", "Choose a quest to farm", questList, function(selected)
    selectedQuest = selected
end)

FarmSection:NewSlider("Y Offset", "Adjust hover height", -30, 30, function(value)
    Disc = value
end, 7)

FarmSection:NewSlider("Z Offset", "Adjust forward/backward distance", -30, 30, function(value)
    Disc3 = value
end, 0)

FarmSection:NewToggle("Use All Skills", "Toggle using all skills", function(state)
    isUsingAllSkills = state
end)

FarmSection:NewButton("Refresh Character", "Reset character state", function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
    end
end)

-- Tab: Auto Farm All Levels
local FarmLevelTab = Window:NewTab("Auto Farm All Levels")
local FarmLevelSection = FarmLevelTab:NewSection("Auto Farm by Level Settings")
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
        else
            task.wait(1)
        end
    end)
end

FarmLevelSection:NewToggle("Auto Farm All Levels", "Farm based on your level", function(state)
    isLevelFarming = state
    if isLevelFarming then
        if isFarming then
            Library:CreateNotification("Please disable Auto Farm & Quests first!", "Error", 5)
            isLevelFarming = false
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

-- Tab: Boss Farm
local BossTab = Window:NewTab("Boss Farm")
local BossSection = BossTab:NewSection("Boss Farming")
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

BossSection:NewDropdown("Select Boss", "Choose a boss to farm", bossList, function(boss)
    selectedBoss = boss
end)

BossSection:NewToggle("Auto Farm Boss", "Toggle boss farming", function(state)
    isBossFarming = state
    if isBossFarming then
        if not selectedBoss then
            Library:CreateNotification("Please select a boss first!", "Error", 5)
            isBossFarming = false
            return
        end
        if isFarming or isLevelFarming then
            Library:CreateNotification("Please disable other farming modes first!", "Error", 5)
            isBossFarming = false
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

-- Tab: Stand Farm
local StandFarmTab = Window:NewTab("Stand Farm")
local StandSection = StandFarmTab:NewSection("Select Stands")
local AttriSection = StandFarmTab:NewSection("Select Attributes")
local ControlSection = StandFarmTab:NewSection("Farm Control")

-- ตัวแปรสำหรับ Stand และ Attribute
local Added, Whitelisted, Blacklisted = {}, {}, {}
local WhitelistedAttributes = {}
local attributes = {"None", "Godly", "Daemon", "GlassCannon", "Invincible", "Tragic", "Scourge", "Hacker", "Legendary"}
local ArrowToUse = "Stand Arrow"
local CheckStand, CheckAttri = false, false

-- ฟังก์ชันลบช่องวรรคและแปลงเป็นตัวพิมพ์ใหญ่
local function removeSpaces(str)
    if typeof(str) == "string" then
        return str:gsub("%s+", ""):upper()
    end
    return "NONE"
end

-- ฟังก์ชันแสดงแจ้งเตือน (รองรับ Kavo หรือ fallback)
local function showNotification(message, type, duration)
    if typeof(message) ~= "string" then message = tostring(message or "Unknown") end
    if Library and Library.CreateNotification then
        pcall(function() Library:CreateNotification(message, type, duration) end)
    elseif Library and Library.Notify then
        pcall(function() Library:Notify(message, duration, type) end)
    else
        warn("Fallback notification: " .. message)
    end
end

-- ฟังก์ชันค้นหาในตารางอย่างปลอดภัย
local function safeTableFind(tbl, value)
    if not tbl or type(tbl) ~= "table" or #tbl == 0 then
        return nil
    end
    return table.find(tbl, value)
end

-- รายการ Stand
local standList = {
    "WeatherReport", "Rapture", "UltimateLifeForm", "SoftAndWet", "EclispeDiosTheWorldOverHeaven",
    "MagiciansRed", "HeadlessStarPlatinum", "StarPlatinumTheWorldRequiem", "FestiveTheWorld",
    "SnowglobeMadeInHeaven", "HierophantGreenRequiem", "TuskAct2", "DirtyDeedsDoneDirtCheap",
    "TheWorld", "TheHand", "WhiteSnake", "DiverDown", "TuskAct4", "CrazyDiamond", "TuskAct3",
    "StarPlatinumOVAOverHeaven", "StickyFingers", "StarPlatinumStoneOcean", "HierophantGreen",
    "StarPlatinumOverHeaven", "GoldenExperience", "CrazyDiamondOverHeaven", "TheWorldsGreatestHigh",
    "MadeInHeaven", "CMoon", "ShadowTheWorld", "TheWorldAlternateUniverse",
    "DirtyDeedsDoneDirtCheapLoveTrain", "TheHandRequiem", "Ben", "TheEmperor", "StabPlatinumTheWorld",
    "PremierMacho", "Cream", "IBM", "SilverChariotRequiemOVA", "TheWorldOVAOverHeaven", "Kars",
    "StarPlatinumTheWorld", "TheUniverse", "CauldronBlack", "TheWorldOverHeaven",
    "DiosTheWorldOverHeaven", "StabPlatinum", "DiegosTheWorld", "HalalGoku", "StarPlatinum",
    "StarPlatinumOVA", "SilverChariotRequiem", "TheWorldOVA", "SilverChariot", "GoldExperienceRequiemRequiem",
    "PremierMachoRequiem", "GoldExperienceRequiem", "StoneFree", "KingCrimson", "TuskAct1", "Aerosmith",
    "KillerQueenBitesTheDust", "PurpleSmoke", "SilverChariotOVA", "KillerQueen", "CelebratorySoftWet",
    "PutridWhine", "Anubis", "TheWorldAlternateUniverseExecutioner", "StarPlatinumTheWorld",
    "TheWorldAlternateUniverseElectrocutioner", "JotarosStarPlatinum", "HalalVegeta", "KingCrimsonRequiem",
    "BrainysTheWorld", "TrueStarPlatinumTheWorld", "TAMIH", "ABDSTW", "DiegosTheWorldHighVoltage",
    "DiosTheWorld", "JotarosStarPlatinumOverHeaven", "MadeInHell", "TheUniverseOverHeaven",
    "ClownCrimsonRequiem", "Skrunkly", "UltimateCauldron", "HeadlessTheWorld", "LegacyTheHand",
    "TheUniverseOverHeaven", "GoldenExperienceRealityBender"
}

Blacklisted = {
    "PackageLink", "WeatherReport"
}

for _, standName in ipairs(standList) do
    if not safeTableFind(Blacklisted, removeSpaces(standName)) then
        local displayName = standName:gsub("([A-Z])", " %1"):gsub("^%s+", "")
        StandSection:NewToggle(displayName, "Toggle Stand", function(state)
            local normalizedName = removeSpaces(standName)
            if state then
                if not safeTableFind(Whitelisted, normalizedName) then
                    table.insert(Whitelisted, normalizedName)
                end
            else
                local index = safeTableFind(Whitelisted, normalizedName)
                if index then
                    table.remove(Whitelisted, index)
                end
            end
        end, false)
    end
end

for _, attr in ipairs(attributes) do
    AttriSection:NewToggle(attr, "Toggle Attribute", function(state)
        if state then
            if not safeTableFind(WhitelistedAttributes, attr) then
                table.insert(WhitelistedAttributes, attr)
            end
        else
            local index = safeTableFind(WhitelistedAttributes, attr)
            if index then
                table.remove(WhitelistedAttributes, index)
            end
        end
    end, false)
end

local function CheckInfo()
    local stand = LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value or "None"
    local PlayerAttri = LocalPlayer.Data and LocalPlayer.Data.Attri and LocalPlayer.Data.Attri.Value or "None"
    stand = removeSpaces(stand)
    PlayerAttri = tostring(PlayerAttri or "None")

    local standMatch = false
    if CheckStand and Whitelisted and type(Whitelisted) == "table" and #Whitelisted > 0 then
        standMatch = safeTableFind(Whitelisted, stand) ~= nil
    end

    local attriMatch = false
    if CheckAttri and WhitelistedAttributes and type(WhitelistedAttributes) == "table" and #WhitelistedAttributes > 0 then
        attriMatch = safeTableFind(WhitelistedAttributes, PlayerAttri) ~= nil
    end

    return (CheckStand and CheckAttri and standMatch and attriMatch) or
           (CheckStand and standMatch) or
           (CheckAttri and attriMatch) or false
end

local function useRokakaka(char)
    if not char then return end
    local rokakaka = LocalPlayer.Backpack:FindFirstChild("Rokakaka")
    if rokakaka then
        char.Humanoid:EquipTool(rokakaka)
        task.wait(0.2)
        if char:FindFirstChild("Rokakaka") then
            char.Rokakaka:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            local prompt = char.Rokakaka:FindFirstChildOfClass("ProximityPrompt")
            if prompt then fireproximityprompt(prompt, 1) end
            repeat task.wait(0.5) until (LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None") or not getgenv().BeginFarm
        end
    else
        showNotification("Error: No Rokakaka in Backpack!", "Error", 5)
    end
end

local function CycleStand()
    local char = waitForCharacter()
    if not char then return end
    local stand = LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value or "None"
    local attriValue = LocalPlayer.Data and LocalPlayer.Data.Attri and LocalPlayer.Data.Attri.Value or "None"
    stand = removeSpaces(stand)
    attriValue = tostring(attriValue or "None")

    if stand == "NONE" then
        local arrow = LocalPlayer.Backpack:FindFirstChild(ArrowToUse)
        if not arrow then
            showNotification("Error: No " .. ArrowToUse .. " in Backpack!", "Error", 5)
            return
        end
        char.Humanoid:EquipTool(arrow)
        task.wait(0.2)
        if char:FindFirstChild(ArrowToUse) then
            char[ArrowToUse]:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            repeat task.wait(0.5) until (LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value ~= "None") or not getgenv().BeginFarm
        end
    elseif CheckInfo() then
        local stored = false
        for i = 1, 2 do
            if LocalPlayer.Data and LocalPlayer.Data["Slot" .. i .. "Stand"] and LocalPlayer.Data["Slot" .. i .. "Stand"].Value == "None" then
                fireServerSafe(ReplicatedStorage.Events.SwitchStand, "Slot" .. i)
                repeat task.wait(0.5) until (LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None") or not getgenv().BeginFarm
                if LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None" then stored = true end
                break
            end
        end
        if not stored then
            showNotification("Storage Full: No empty slots available!", "Error", 5)
        end
    else
        useRokakaka(char)
    end
end

ControlSection:NewButton("Use Stand Arrows", "Set to Stand Arrow", function()
    ArrowToUse = "Stand Arrow"
end)
ControlSection:NewButton("Use Charged Arrows", "Set to Charged Arrow", function()
    ArrowToUse = "Charged Arrow"
end)
ControlSection:NewButton("Use Kars Mask", "Set to Kars Mask", function()
    ArrowToUse = "Kars Mask"
end)

ControlSection:NewToggle("Stand Check", "Toggle Stand Check", function(state)
    CheckStand = state
end)

ControlSection:NewToggle("Attribute Check", "Toggle Attribute Check", function(state)
    CheckAttri = state
end)

ControlSection:NewButton("Open Stand Storage", "Click to Open", function()
    fireServerSafe(Workspace.Map.NPCs.admpn.Done)
end)

ControlSection:NewToggle("Start Stand Farm", "Toggle Stand Farm", function(state)
    getgenv().BeginFarm = state
    if getgenv().BeginFarm then
        if not CheckStand and not CheckAttri then
            showNotification("Please enable Stand Check or Attribute Check!", "Error", 5)
            getgenv().BeginFarm = false
            return
        end
        if CheckStand and (not Whitelisted or #Whitelisted == 0) then
            showNotification("No Stands selected in Whitelist! Please select at least one Stand.", "Error", 5)
            getgenv().BeginFarm = false
            return
        end
        if CheckAttri and (not WhitelistedAttributes or #WhitelistedAttributes == 0) then
            showNotification("No Attributes selected in Whitelist!", "Error", 5)
            getgenv().BeginFarm = false
            return
        end
        showNotification("Stand Farm Started", "Info", 3)
        task.spawn(function()
            while getgenv().BeginFarm do
                CycleStand()
                task.wait(1)
            end
            showNotification("Stand Farm Stopped", "Info", 3)
        end)
    else
        showNotification("Stand Farm Stopped", "Info", 3)
    end
end)

-- Auto Buy Item Tab
local BuyTab = Window:NewTab("Auto Buy Item")
local BuySection = BuyTab:NewSection("Stand near NPC and set amount before buying")
local Amount = 1

BuySection:NewButton("Teleport to Shop", "Warp to shop location", function()
    local char = waitForCharacter()
    if char then
        Teleport(char.HumanoidRootPart, CFrame.new(11927.1, -3.28935, -4488.59))
        if char:FindFirstChild("Stand") then
            Teleport(char.Stand.HumanoidRootPart, char.HumanoidRootPart.CFrame)
        end
    end
end)

BuySection:NewTextBox("Enter Amount", "Set buy quantity", function(a)
    Amount = tonumber(a) or 1
end)

local buyItems = {
    {"Rokakaka (2,500c)", "MerchantAU", "Option2"},
    {"Stand Arrow (3,500c)", "MerchantAU", "Option4"},
    {"Charged Arrow (50,000c)", "Merchantlvl120", "Option2"},
    {"Dio Diary (1,500,000c)", "Merchantlvl120", "Option3"},
    {"Requiem Arrow (1,500,000c)", "Merchantlvl120", "Option4"}
}
for _, item in ipairs(buyItems) do
    BuySection:NewButton(item[1], "Buy " .. item[1], function()
        for i = 1, Amount do
            ReplicatedStorage.Events.BuyItem:FireServer(item[2], item[3])
        end
    end)
end

-- Tab: Settings
local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("General Settings")
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

SettingsSection:NewToggle("Anti-AFK", "Prevent AFK kick", function(state)
    isAntiAFK = state
    if isAntiAFK then antiAFK() end
end)

SettingsSection:NewToggle("Debug Mode", "Enable debug prints in F9", function(state)
    debugMode = state
    Library:CreateNotification("Debug Mode " .. (debugMode and "Enabled" or "Disabled"), "Info", 3)
end)

SettingsSection:NewKeybind("Toggle UI", "Show/hide UI", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

-- Tab: Dungeon Farm
local DungeonTab = Window:NewTab("Dungeon Farm")
local DungeonSection = DungeonTab:NewSection("Auto Farm Dungeon Settings")

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

DungeonSection:NewDropdown("Choose Dungeon", "Select a dungeon to farm", DunLvl, function(AuDun)
    if not AuDun then return end
    ChDun = AuDun
    currentDistance = dungeonSettings[ChDun].baseDistance
    currentTarget = nil
    safePosition = nil
    lastHealth = 0
    lastDamageCheck = 0
end)

DungeonSection:NewToggle("Auto Farm Dungeon", "Toggle dungeon farming", function(state)
    isDungeonFarming = state
    if isFarming or isLevelFarming or isBossFarming then
        Library:CreateNotification("Please disable other farming modes first!", "Error", 5)
        isDungeonFarming = false
        return
    end
    if not ChDun or not dungeonSettings[ChDun] then
        Library:CreateNotification("No valid dungeon selected!", "Error", 5)
        isDungeonFarming = false
        return
    end

    if isDungeonFarming then
        currentDistance = dungeonSettings[ChDun].baseDistance
        Library:CreateNotification("Dungeon Farm Started", "Info", 3)
        task.spawn(function()
            dungeonConnection = RunService.Heartbeat:Connect(function()
                if not isDungeonFarming then
                    if dungeonConnection then dungeonConnection:Disconnect() end
                    if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                    local char = waitForCharacter()
                    if char then char.Humanoid.Sit = false end
                    Library:CreateNotification("Dungeon Farm Stopped", "Info", 3)
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

DungeonSection:NewSlider("Y Offset", "Adjust hover height", -30, 30, function(value)
    Disc = value
end, 7)

DungeonSection:NewSlider("Z Offset", "Adjust forward/backward distance", -30, 30, function(value)
    Disc3 = value
end, 0)

DungeonSection:NewToggle("Use All Skills", "Toggle using all skills", function(state)
    isUsingAllSkills = state
end)

DungeonSection:NewButton("Refresh Character", "Reset character state", function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
    end
end)

-- Tab: Item Farm
local ItemTab = Window:NewTab("Item Farm")
local ItemSection = ItemTab:NewSection("Auto Farm Items")
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

ItemSection:NewToggle("Farm Items", "Collect nearby items", function(state)
    isItemFarming = state
    _G.On = state

    if isItemFarming and (isFarming or isLevelFarming or isBossFarming or isDungeonFarming) then
        Library:CreateNotification("Please disable other farming modes first!", "Error", 5)
        isItemFarming = false
        _G.On = false
        return
    end

    if itemConnection then
        itemConnection:Disconnect()
    end

    if isItemFarming then
        Library:CreateNotification("Item Farm Started", "Info", 3)
        itemConnection = RunService.Heartbeat:Connect(function()
            if not isItemFarming or not _G.On then
                if itemConnection then itemConnection:Disconnect() end
                local char = waitForCharacter()
                if char then char.Humanoid.Sit = false end
                Library:CreateNotification("Item Farm Stopped", "Info", 3)
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
                            Library:CreateNotification("Teleporting to item at " .. tostring(v.Position), "Info", 2)
                            task.wait(0.5)
                        end
                        if distance <= 5 then
                            fireproximityprompt(prompt, 20)
                            Library:CreateNotification("Picking up item at " .. tostring(v.Position), "Success", 2)
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
                            Library:CreateNotification("Teleporting to item at " .. tostring(item.Position), "Info", 2)
                            task.wait(0.5)
                        end
                        if distance <= 5 then
                            fireproximityprompt(item.ProximityPrompt, 20)
                            Library:CreateNotification("Picking up item at " .. tostring(item.Position), "Success", 2)
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
        Library:CreateNotification("Item Farm Stopped", "Info", 3)
    end
end)
