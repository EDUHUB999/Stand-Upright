local ScreenGui = Instance.new("ScreenGui")
local Frame_1 = Instance.new("Frame")
local ImageButton_1 = Instance.new("ImageButton")

-- Properties:
ScreenGui.Parent = game.CoreGui

Frame_1.Parent = ScreenGui
Frame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
Frame_1.Position = UDim2.new(0.0496077649, 0,0.134853914, 0)
Frame_1.Size = UDim2.new(0, 33,0, 31)

ImageButton_1.Parent = Frame_1
ImageButton_1.Active = true
ImageButton_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
ImageButton_1.BorderColor3 = Color3.fromRGB(128,17,255)
ImageButton_1.Position = UDim2.new(-0.00698809186, 0,-0.0136182783, 0)
ImageButton_1.Size = UDim2.new(0, 33,0, 31)
ImageButton_1.Image = "http://www.roblox.com/asset/?id=12514663645"
ImageButton_1.MouseButton1Down:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "RightControl" , false , game)
end)

-- โหลด Kavo UI Library และตรวจสอบการโหลด
local success, Library = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/EVILDARKSIDEUPV1/ui/main/README.md")))
if not success or not Library then
    warn("Failed to load Kavo UI Library! Please check your internet connection or the URL. Library value: " .. tostring(Library))
    return
end
print("Library loaded successfully: ", Library)
local Window = Library.CreateLib("Farm & Quest Script by Grok", "DarkTheme")
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
getgenv().BeginFarm = false -- เริ่มต้นเป็น false

-- ฟังก์ชัน Teleport
local function Teleport(part, cframe)
    if part and part:IsA("BasePart") then
        pcall(function()
            part.CFrame = cframe
            part.Velocity = Vector3.new(0, 0, 0)
            print("Teleported " .. part.Name .. " to: " .. tostring(cframe))
        end)
    else
        print("Part not found or invalid: " .. tostring(part))
    end
end

-- ฟังก์ชันรอตัวละคร
local function waitForCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not hrp or not humanoid then
        warn("HumanoidRootPart or Humanoid not found!")
        return nil
    end
    return char
end

-- เริ่มรันสคริปต์: TP เพื่อโหลดแมพก่อนสร้าง UI
local char = waitForCharacter()
if not char then return end
local hrp = char.HumanoidRootPart
local originalPosition = hrp.CFrame

Teleport(hrp, CFrame.new(11927.1, -3.28935, -4488.59))
task.wait(0.2)
Teleport(hrp, CFrame.new(-5234.27051, -449.936951, -3766.07373, 0.958408535, 1.30176289e-07, 0.285399795, 0.000306290051, 0.999999404, -0.0010290168, -0.285399646, 0.00107363367, 0.958407998))
task.wait(0.2)
Teleport(hrp, originalPosition)

-- ตัวแปรสำหรับ Farming
local Disc = 7 -- Y offset
local Disc3 = 0 -- Z offset
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
    local success, err = pcall(function()
        if arg ~= nil then
            remote:FireServer(arg)
            print("Fired: " .. remote.Name .. " with arg: " .. tostring(arg))
        else
            remote:FireServer()
            print("Fired: " .. remote.Name)
        end
    end)
    if not success then
        if Library and Library.CreateNotification then
            Library:CreateNotification("Error firing " .. remote.Name .. ": " .. err, "Error", 5)
        else
            warn("Error firing " .. remote.Name .. ": " .. err)
        end
    end
    return success
end

-- ฟังก์ชันใช้สกิลทั้งหมดแบบคอมโบไว
local function useAllSkills(char)
    if char and char:FindFirstChild("StandEvents") then
        print("Combo Mode: Using all skills at max speed!")
        for _, event in pairs(char.StandEvents:GetChildren()) do
            if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                print("Using skill: " .. event.Name)
                fireServerSafe(event, true)
                task.wait(0.05)
            else
                print("Skipped skill: " .. event.Name)
            end
        end
    else
        warn("StandEvents not found in character!")
    end
end

-- ฟังก์ชันหามอนสเตอร์ที่ใกล้ที่สุด (ใช้สำหรับเควสต์และเลเวล ไม่ใช้ในบอส)
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
        
        local distance = (hrp.Position - hoverPos).Magnitude
        if distance > 5 then
            Teleport(hrp, targetCFrame)
            char.Humanoid.Sit = true
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
                else
                    if char:FindFirstChild("StandEvents") then
                        for _, event in pairs(char.StandEvents:GetChildren()) do
                            if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                                fireServerSafe(event, true)
                            end
                        end
                    end
                end
            end
        else
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then
                char.Humanoid.Sit = false
                local resetPosition = char.HumanoidRootPart.CFrame + Vector3.new(0, 10, 400)
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
    print("Selected quest: " .. selectedQuest)
end)

FarmSection:NewSlider("Y Offset", "Adjust hover height", -30, 30, function(value)
    Disc = value
end, 7)

FarmSection:NewSlider("Z Offset", "Adjust forward/backward distance", -30, 30, function(value)
    Disc3 = value
end, 0)

FarmSection:NewToggle("Use All Skills", "Toggle using all skills", function(state)
    isUsingAllSkills = state
    print("Use All Skills: " .. tostring(isUsingAllSkills))
end)

FarmSection:NewButton("Refresh Character", "Reset character state", function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
        print("Character refreshed!")
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
                    else
                        if char:FindFirstChild("StandEvents") then
                            for _, event in pairs(char.StandEvents:GetChildren()) do
                                if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                                    fireServerSafe(event, true)
                                end
                            end
                        end
                    end
                end
            else
                if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                local char = waitForCharacter()
                if char then
                    char.Humanoid.Sit = false
                    local resetPosition = char.HumanoidRootPart.CFrame + Vector3.new(0, 10, 400)
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
        
        -- ตรวจสอบบอสจาก Workspace.Living โดยตรง ไม่ใช้ findNearestMonster
        local boss = Workspace.Living:FindFirstChild(selectedBoss)
        if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
            teleportToTarget(boss) -- วาร์ปไปเมื่อบอสเกิด
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
                else
                    if char:FindFirstChild("StandEvents") then
                        for _, event in pairs(char.StandEvents:GetChildren()) do
                            if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                                fireServerSafe(event, true)
                            end
                        end
                    end
                end
            end
        else
            -- ถ้าบอสยังไม่เกิด ให้ยืนนิ่งๆ โดยไม่วาร์ป
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then
                char.Humanoid.Sit = false -- รีเซ็ตสถานะนอน
            end
            task.wait(1) -- รอจนกว่าบอสจะเกิด
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
local StandTab = Window:NewTab("Stand Farm")
local StandCheckSection = StandTab:NewSection("Check Stand-Attri")
local CheckStand, CheckAttri = false, false
StandCheckSection:NewToggle("Stand Check", "Toggle Stand Check", function() CheckStand = not CheckStand end)
StandCheckSection:NewToggle("Attribute Check", "Toggle Attribute Check", function() CheckAttri = not CheckAttri end)

local StorageSection = StandTab:NewSection("Open Stand Storage")
StorageSection:NewButton("Open Stand Storage", "Click to Open", function()
    fireServerSafe(Workspace.Map.NPCs.admpn.Done)
end)

local ItemSection = StandTab:NewSection("Use Item Farm Stand")
local ArrowToUse = "Stand Arrow"
ItemSection:NewButton("Use Stand Arrows", "Set to Stand Arrow", function()
    ArrowToUse = "Stand Arrow"
    if Library and Library.CreateNotification then
        Library:CreateNotification("Farm set to Use Stand Arrow", "Info", 3)
    end
    task.wait(1.5)
end)
ItemSection:NewButton("Use Charged Arrows", "Set to Charged Arrow", function()
    ArrowToUse = "Charged Arrow"
    if Library and Library.CreateNotification then
        Library:CreateNotification("Farm set to Use Charged Arrow", "Info", 3)
    end
    task.wait(1.5)
end)
ItemSection:NewButton("Use Kars Mask", "Set to Kars Mask", function()
    ArrowToUse = "Kars Mask"
    if Library and Library.CreateNotification then
        Library:CreateNotification("Farm set to Use Kars Mask", "Info", 3)
    end
    task.wait(1.5)
end)

local StandSection = StandTab:NewSection("Stand")
local Added, Whitelisted, Blacklisted = {}, {}, {
    "Rapture", "True Star Platinum: The World", "Diego's The World: High Voltage", "True Star Platinum: The World",
    "Premier Macho", "Stab Platinum: The World", "King Crimson Requiem", "Silver Chariot Requiem",
    "Eclispe Dio's The World Over Heaven", "Headless Star Platinum", "Tusk Act 2", "Tusk Act 3",
    "Putrid Whine", "Star Platinum The World: Requiem", "Tusk Act 4", "Star Platinum OVA Over Heaven",
    "Star Platinum The World", "Star Platinum Over Heaven", "Crazy Diamond: Over Heaven", "The World's Greatest High",
    "C-Moon", "Shadow The World", "Main In Heaven", "Silver Chariot Requiem OVA", "The World OVA Over Heaven",
    "Kars", "Cauldron Black", "Stab Platinum", "Dio's The World Over Heaven", "The World Over Heaven",
    "Halal Goku", "Gold Experience Requiem Requiem", "Gold Experience Requiem", "Killer Queen Bites The Dust",
    "Celebratory Soft & Wet", "Anubis", "The World Alternate Universe: Executioner", "The World Alternate Universe: Electrocutioner",
    "King Crimson: Requiem", "Brainy's The World", "TAMIH", "ABDSTW", "Made In Hell", "Jotaro's Star Platinum Over Heaven",
    "The World Over Heaven OVA", "Golden Experience: Reality Bender", "Ultimate Life Form", "Ben", "Made In Heaven",
    "Snowglobe Made In Heaven", "Premier Macho Requiem", "Halal Vegeta", "HalalGoku", "IBM", "Festive The World",
    "The Universe", "Dirty Deeds Done Dirt Cheap: Love Train"
}
for _, v in ipairs(ReplicatedStorage.StandNameConvert:GetChildren()) do
    if v:IsA("StringValue") and not table.find(Added, v.Value) and not table.find(Blacklisted, v.Value) then
        table.insert(Added, v.Value)
        StandSection:NewToggle(v.Value, "Toggle Stand", function()
            if table.find(Whitelisted, v.Value) then
                table.remove(Whitelisted, table.find(Whitelisted, v.Value))
            else
                table.insert(Whitelisted, v.Value)
            end
        end)
    end
end

local AttriSection = StandTab:NewSection("Attri")
local WhitelistedAttributes = {}
local attributes = {"None", "Godly", "Daemon", "Glass Cannon", "Invincible", "Tragic", "Hacker", "Legendary"}
for _, attr in ipairs(attributes) do
    AttriSection:NewToggle(attr, "Toggle Attribute", function()
        if table.find(WhitelistedAttributes, attr) then
            table.remove(WhitelistedAttributes, table.find(WhitelistedAttributes, attr))
        else
            table.insert(WhitelistedAttributes, attr)
        end
    end)
end

local WebhookSection = StandTab:NewSection("Webhook/Buy-Auto")
local webhookurl, UseWebhook = "", false
WebhookSection:NewToggle("Enable Webhook", "Toggle Webhook", function() UseWebhook = not UseWebhook end)
WebhookSection:NewTextBox("Set Webhook", "Enter Webhook URL", function(input) webhookurl = input end)

local StartFarmSection = StandTab:NewSection("Start Farm")

local function CheckInfo()
    local success, playerGui = pcall(function() return LocalPlayer.PlayerGui.PlayerGUI.ingame.Stats.StandName end)
    local PlayerStand = success and playerGui:FindFirstChild("Name_") and playerGui.Name_.TextLabel.Text or "None"
    local PlayerAttri = LocalPlayer.Data.Attri.Value or "None"
    print("Debug - PlayerStand:", PlayerStand, "PlayerAttri:", PlayerAttri) -- ดีบั๊ก
    local standMatch = CheckStand and table.find(Whitelisted, PlayerStand)
    local attriMatch = CheckAttri and table.find(WhitelistedAttributes, PlayerAttri)

    if CheckStand and CheckAttri then
        return standMatch and attriMatch
    elseif CheckStand then
        return standMatch
    elseif CheckAttri then
        return attriMatch
    else
        return false
    end
end

local function CycleStand()
    local char = waitForCharacter()
    if not char then return end
    local stand = LocalPlayer.Data.Stand.Value or "None"

    if stand == "None" then
        local arrow = LocalPlayer.Backpack:FindFirstChild(ArrowToUse)
        if not arrow then
            if Library and Library.CreateNotification then
                Library:CreateNotification("Error: No " .. ArrowToUse .. " in Backpack!", "Error", 5)
            end
            return
        end
        char.Humanoid:EquipTool(arrow)
        task.wait(0.2)
        if char:FindFirstChild(ArrowToUse) then
            char[ArrowToUse]:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            if Library and Library.CreateNotification then
                Library:CreateNotification("Using " .. ArrowToUse, "Info", 3)
            end
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value ~= "None" or not getgenv().BeginFarm
        end
    elseif CheckInfo() then
        local stored = false
        for i = 1, 2 do
            if LocalPlayer.Data["Slot" .. i .. "Stand"].Value == "None" then
                if Library and Library.CreateNotification then
                    Library:CreateNotification("Storing " .. stand .. " to Slot " .. i, "Info", 3)
                end
                fireServerSafe(ReplicatedStorage.Events.SwitchStand, "Slot" .. i)
                repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not getgenv().BeginFarm
                if LocalPlayer.Data.Stand.Value == "None" then
                    if Library and Library.CreateNotification then
                        Library:CreateNotification("Stored " .. stand .. " Successfully", "Success", 3)
                    end
                    if UseWebhook and webhookurl ~= "" then
                        pcall(function()
                            HttpService:PostAsync(webhookurl, HttpService:JSONEncode({
                                content = "Stored Stand: " .. stand .. " in Slot " .. i .. " with Attribute: " .. LocalPlayer.Data.Attri.Value
                            }))
                        end)
                    end
                    stored = true
                end
                break
            end
        end
        if not stored then
            if Library and Library.CreateNotification then
                Library:CreateNotification("Storage Full: No empty slots available!", "Error", 5)
            end
            return
        end
    else
        local rokakaka = LocalPlayer.Backpack:FindFirstChild("Rokakaka")
        if not rokakaka then
            if Library and Library.CreateNotification then
                Library:CreateNotification("Error: No Rokakaka in Backpack!", "Error", 5)
            end
            return
        end
        char.Humanoid:EquipTool(rokakaka)
        task.wait(0.2)
        if char:FindFirstChild("Rokakaka") then
            char.Rokakaka:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            if Library and Library.CreateNotification then
                Library:CreateNotification("Using Rokakaka to reset Stand", "Info", 3)
            end
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not getgenv().BeginFarm
        end
    end
end

StartFarmSection:NewToggle("Start Stand Farm", "Toggle Stand Farm", function(state)
    getgenv().BeginFarm = state
    if getgenv().BeginFarm then
        if not CheckStand and not CheckAttri then
            if Library and Library.CreateNotification then
                Library:CreateNotification("Please enable Stand Check or Attribute Check!", "Error", 5)
            end
            getgenv().BeginFarm = false
            return
        end
        if #Whitelisted == 0 and CheckStand then
            if Library and Library.CreateNotification then
                Library:CreateNotification("No Stands selected in Whitelist!", "Error", 5)
            end
            getgenv().BeginFarm = false
            return
        end
        if #WhitelistedAttributes == 0 and CheckAttri then
            if Library and Library.CreateNotification then
                Library:CreateNotification("No Attributes selected in Whitelist!", "Error", 5)
            end
            getgenv().BeginFarm = false
            return
        end
        if Library and Library.CreateNotification then
            Library:CreateNotification("Stand Farm Started", "Info", 3)
        end
        task.spawn(function()
            while getgenv().BeginFarm do
                CycleStand()
                task.wait(0.5)
            end
            if Library and Library.CreateNotification then
                Library:CreateNotification("Stand Farm Stopped", "Info", 3)
            end
        end)
    else
        if Library and Library.CreateNotification then
            Library:CreateNotification("Stand Farm Stopped", "Info", 3)
        end
    end
end)

-- Auto Buy Item Tab (ส่วนที่ใช้งานได้แล้ว)
local BuyTab = Window:NewTab("Auto Buy Item")
local BuySection = BuyTab:NewSection("Stand near NPC and set amount before buying")

local Amount = 1 -- ค่าเริ่มต้น

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
            task.wait(0.2)
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
    ["Dungeon [Lvl.15+]"] = {npcMonster = "i_stabman [Lvl. 15+]", bossName = "Bad Gi Boss"},
    ["Dungeon [Lvl.40+]"] = {npcMonster = "i_stabman [Lvl. 40+]", bossName = "Dio [Dungeon]"},
    ["Dungeon [Lvl.80+]"] = {npcMonster = "i_stabman [Lvl. 80+]", bossName = "Homeless Lord"},
    ["Dungeon [Lvl.100+]"] = {npcMonster = "i_stabman [Lvl. 100+]", bossName = "Diavolo [Dungeon]"},
    ["Dungeon [Lvl.200+]"] = {npcMonster = "i_stabman [Lvl. 200+]", bossName = "Jotaro P6 [Dungeon]"}
}

-- ตัวแปร
local ChDun = "Dungeon [Lvl.15+]"
local isDungeonFarming = false
local dungeonConnection
local lastTeleport = 0
local currentTarget = nil -- ควบคุมเป้าหมาย (nil, "NPC", "Boss")
local safePosition = nil -- เก็บตำแหน่งปลอดภัย (เช่น ตำแหน่ง NPC)

-- ฟังก์ชันหา NPC (เพิ่มการ retry)
local function findDungeonNPC(maxAttempts)
    maxAttempts = maxAttempts or 3
    for attempt = 1, maxAttempts do
        local npcs = Workspace.Map.NPCs:GetChildren()
        for _, npc in ipairs(npcs) do
            if npc.Name:find("i_stabman") and npc:FindFirstChild("Head") and npc.Head:FindFirstChild("Main") and npc.Head.Main:FindFirstChild("Text") then
                if npc.Head.Main.Text.Text == dungeonSettings[ChDun].npcMonster then
                    print("Found NPC: " .. npc.Name .. " (Attempt " .. attempt .. ")")
                    -- เก็บตำแหน่ง NPC เป็นตำแหน่งปลอดภัย
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                    if npcHRP then
                        safePosition = npcHRP.CFrame + Vector3.new(0, 3, 5)
                        print("Safe position set to: " .. tostring(safePosition))
                    end
                    return npc
                end
            end
        end
        print("Dungeon NPC not found: " .. dungeonSettings[ChDun].npcMonster .. " (Attempt " .. attempt .. "/" .. maxAttempts .. ")")
        task.wait(1) -- รอ 1 วินาทีก่อนลองใหม่
    end
    return nil
end

-- ฟังก์ชันหาบอส (เพิ่มการ retry)
local function findDungeonBoss(maxAttempts)
    maxAttempts = maxAttempts or 3
    for attempt = 1, maxAttempts do
        for _, boss in pairs(Workspace.Living:GetChildren()) do
            if boss.Name == "Boss" and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                local display = boss:FindFirstChild("Head") and boss.Head:FindFirstChild("Display")
                local frame = display and display:FindFirstChild("Frame")
                local text = frame and frame:FindFirstChild("t")
                if text and text.Text == dungeonSettings[ChDun].bossName then
                    print("Found Boss: " .. dungeonSettings[ChDun].bossName .. " (Attempt " .. attempt .. ")")
                    return boss
                end
            end
        end
        print("Boss not found: " .. dungeonSettings[ChDun].bossName .. " (Attempt " .. attempt .. "/" .. maxAttempts .. ")")
        task.wait(1) -- รอ 1 วินาทีก่อนลองใหม่
    end
    return nil
end

-- ฟังก์ชันแจ้งเตือน (สำรองถ้า CreateNotification ล้มเหลว)
local function notify(title, description, duration)
    if Library and Library.CreateNotification then
        Library:CreateNotification(title, description, duration)
    else
        warn("Notification failed: " .. title .. " - " .. description)
    end
end

-- UI
DungeonSection:NewDropdown("Choose Dungeon", "Select a dungeon to farm", DunLvl, function(AuDun)
    if not AuDun or AuDun == "" then
        warn("Invalid dungeon selection: " .. tostring(AuDun))
        notify("Invalid Selection!", "Please choose a valid dungeon.", 3)
        return
    end
    notify("Selected Dungeon: " .. AuDun, "Saving selection...", 2)
    task.wait(0.2)
    ChDun = AuDun
    currentTarget = nil -- รีเซ็ตเป้าหมายเมื่อเปลี่ยนด่าน
    safePosition = nil -- รีเซ็ตตำแหน่งปลอดภัย
    print("Dungeon selected: " .. ChDun .. ", Settings: " .. tostring(dungeonSettings[ChDun]))
end)

DungeonSection:NewToggle("Auto Farm Dungeon", "Toggle dungeon farming", function(state)
    isDungeonFarming = state
    if isFarming or isLevelFarming or isBossFarming then
        notify("Error", "Please disable other farming modes first!", 5)
        isDungeonFarming = false
        return
    end
    if not ChDun or not dungeonSettings[ChDun] then
        notify("Error", "No valid dungeon selected!", 5)
        isDungeonFarming = false
        warn("No dungeon selected or invalid settings!")
        return
    end

    task.spawn(function()
        if dungeonConnection then
            dungeonConnection:Disconnect()
        end
        dungeonConnection = RunService.RenderStepped:Connect(function()
            local now = tick()
            if not isDungeonFarming then
                dungeonConnection:Disconnect()
                if bodyPosition then
                    bodyPosition:Destroy()
                    bodyPosition = nil
                end
                if bodyGyro then
                    bodyGyro:Destroy()
                    bodyGyro = nil
                end
                local char = waitForCharacter()
                if char then
                    char.Humanoid.Sit = false
                end
                print("Dungeon farming stopped")
                return
            end

            local char = waitForCharacter()
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                print("Waiting for character...")
                task.wait(1)
                return
            end
            local hrp = char.HumanoidRootPart
            local stand = char:FindFirstChild("Stand")
            local standHRP = stand and stand:FindFirstChild("HumanoidRootPart")

            -- ขั้นตอน 1: วาร์ปไปหา NPC และรับเควส (ถ้ายังไม่เสร็จ)
            if not currentTarget or currentTarget == "NPC" then
                local npc = findDungeonNPC()
                if npc and now - lastTeleport > 1 then
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                    if npcHRP and hrp then
                        local distance = (hrp.Position - npcHRP.Position).Magnitude
                        if distance > 5 then
                            print("Teleporting to NPC: " .. npc.Name)
                            Teleport(hrp, npcHRP.CFrame + Vector3.new(0, 3, 5))
                            if standHRP then
                                Teleport(standHRP, hrp.CFrame + Vector3.new(0, 0, -2))
                            end
                            lastTeleport = now
                            notify("Teleporting to NPC", "Info", 2)
                        end
                        local done = npc:FindFirstChild("Done")
                        if done then
                            fireServerSafe(done)
                            print("Interacted with NPC, switching to Boss target")
                            currentTarget = "Boss" -- เปลี่ยนเป้าหมายไปหาบอสหลังรับเควส
                            task.wait(1) -- หน่วงเวลาให้แน่ใจว่าเควสถูกยอมรับ
                        end
                    end
                end
            end

            -- ขั้นตอน 2: วาร์ปไปหาบอสและโจมตี (หลังจากรับเควส)
            if currentTarget == "Boss" then
                local boss = findDungeonBoss()
                if boss then
                    local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                    if bossHRP and hrp and now - lastTeleport > 1 then
                        repeat
                            task.wait(0.2)
                            if isDungeonFarming and hrp then
                                print("Teleporting to Boss: " .. dungeonSettings[ChDun].bossName)
                                Teleport(hrp, bossHRP.CFrame * CFrame.new(0, Disc, Disc3))
                                if standHRP then
                                    Teleport(standHRP, bossHRP.CFrame * CFrame.new(0, Disc, Disc3 - 4))
                                end
                                lastTeleport = now
                                notify("Fighting Boss", "Info", 2)
                            end
                            if char:FindFirstChild("Aura") and not char.Aura.Value then
                                fireServerSafe(char.StandEvents.Summon)
                            end
                            if char:FindFirstChild("StandEvents") and not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                                fireServerSafe(char.StandEvents.M1)
                            end
                            if isUsingAllSkills then
                                useAllSkills(char)
                            end
                        until (not boss or not boss.Humanoid or boss.Humanoid.Health <= 0) or not isDungeonFarming

                        if isDungeonFarming and hrp then
                            print("Boss defeated, returning to safe position")
                            if safePosition then
                                Teleport(hrp, safePosition)
                                if standHRP then
                                    Teleport(standHRP, safePosition + Vector3.new(0, 0, -2))
                                end
                            else
                                print("No safe position set, staying in place")
                            end
                            notify("Boss Defeated!", "Success", 3)
                            currentTarget = nil -- รีเซ็ตเป้าหมายเพื่อเริ่มวงจรใหม่
                            task.wait(2) -- รอสักพักก่อนเริ่มรอบใหม่
                        end
                    end
                else
                    -- ถ้าบอสยังไม่เกิด ให้ยืนนิ่งรอ
                    if hrp then
                        print("Boss not found, waiting at safe position...")
                        if safePosition and now - lastTeleport > 1 then
                            Teleport(hrp, safePosition)
                            if standHRP then
                                Teleport(standHRP, safePosition + Vector3.new(0, 0, -2))
                            end
                            lastTeleport = now
                            notify("Boss not found, waiting", "Warning", 2)
                        end
                        -- หยุดการเคลื่อนไหว
                        if bodyPosition then
                            bodyPosition.Position = hrp.Position
                        end
                        task.wait(2) -- รอ 2 วินาทีก่อนลองหาบอสใหม่
                    end
                end
            end

            task.wait(0.5)
        end)
    end)
end)

-- UI เพิ่มเติม
DungeonSection:NewSlider("Y Offset", "Adjust hover height", -30, 30, function(value)
    Disc = value
    print("Y Offset set to: " .. Disc)
end)

DungeonSection:NewSlider("Z Offset", "Adjust forward/backward distance", -30, 30, function(value)
    Disc3 = value
    print("Z Offset set to: " .. Disc3)
end)

DungeonSection:NewToggle("Use All Skills", "Toggle using all skills", function(state)
    isUsingAllSkills = state
    print("Use All Skills: " .. tostring(isUsingAllSkills))
end)

DungeonSection:NewButton("Refresh Character", "Reset character state", function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then
            bodyPosition:Destroy()
            bodyPosition = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
        char.Humanoid.Sit = false
        print("Character refreshed!")
    end
end)
