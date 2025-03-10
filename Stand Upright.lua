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

-- Properties:
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

-- โหลด Kavo UI Library และตรวจสอบการโหลด
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/EVILDARKSIDEUPV1/ui/main/README.md"))()
end)
if not success or not Library then
    warn("Failed to load Kavo UI Library! Please check your internet connection or the URL. Library value: " .. tostring(Library))
    return
end

-- ตรวจสอบฟังก์ชัน CreateNotification
if not Library.CreateNotification then
    warn("CreateNotification function not found in Kavo UI Library! Using fallback notification.")
    Library.CreateNotification = function(message, title, duration)
        print("Notification (Fallback): " .. title .. " - " .. (type(message) == "table" and table.concat(message, ", ") or tostring(message)) .. " (Duration: " .. duration .. "s)")
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

-- ฟังก์ชัน Webhook Notification
local webhookurl, UseWebhook = "", false
local function sendWebhookNotification(message, isStandFarm, isFarmLevel)
    if not UseWebhook or webhookurl == "" or (not isStandFarm and not isFarmLevel) then
        if debugMode then
            print("Webhook not sent: UseWebhook is " .. tostring(UseWebhook) .. ", webhookurl is '" .. webhookurl .. "', isStandFarm: " .. tostring(isStandFarm) .. ", isFarmLevel: " .. tostring(isFarmLevel))
        end
        return false
    end

    -- ตรวจสอบและแปลง message เป็น string ถ้าเป็น table
    local msg = type(message) == "table" and table.concat(message, "\n") or tostring(message)
    local success, errorMsg = pcall(function()
        local payload = {
            ["content"] = msg,
            ["username"] = "EDU HUB Bot",
            ["avatar_url"] = "https://www.roblox.com/asset/?id=12514663645"
        }
        local jsonPayload = HttpService:JSONEncode(payload)
        local response = HttpService:PostAsync(webhookurl, jsonPayload, Enum.HttpContentType.ApplicationJson)
        if debugMode then
            print("Webhook sent successfully! Response: " .. tostring(response))
        end
    end)

    if not success then
        warn("Webhook Error: " .. errorMsg)
        Library:CreateNotification("Webhook Error: " .. errorMsg, "Error", 5)
        return false
    end
    return true
end

-- ฟังก์ชัน Teleport
local function Teleport(part, cframe)
    if part and part:IsA("BasePart") then
        pcall(function()
            part.CFrame = cframe
            part.Velocity = Vector3.new(0, 0, 0)
            if debugMode then print("Teleported " .. part.Name .. " to: " .. tostring(cframe)) end
        end)
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
    local success, err = pcall(function()
        if arg ~= nil then
            remote:FireServer(arg)
        else
            remote:FireServer()
        end
    end)
    if not success then
        Library:CreateNotification("Error firing " .. remote.Name .. ": " .. err, "Error", 5)
    end
    return success
end

-- ฟังก์ชันใช้สกิลทั้งหมดแบบคอมโบไว
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
    if debugMode then print("Selected quest: " .. selectedQuest) end
end)

FarmSection:NewSlider("Y Offset", "Adjust hover height", -30, 30, function(value)
    Disc = value
end, 7)

FarmSection:NewSlider("Z Offset", "Adjust forward/backward distance", -30, 30, function(value)
    Disc3 = value
end, 0)

FarmSection:NewToggle("Use All Skills", "Toggle using all skills", function(state)
    isUsingAllSkills = state
    if debugMode then print("Use All Skills: " .. tostring(isUsingAllSkills)) end
end)

FarmSection:NewButton("Refresh Character", "Reset character state", function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
        if debugMode then print("Character refreshed!") end
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
        local money = LocalPlayer.Data.Money.Value or 0
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
                    sendWebhookNotification(
                        "🏆 Quest Reward: **" .. matchedSetting[1] .. " Quest**\n" ..
                        "🔥 Current Level: **" .. level .. "**\n" ..
                        "💰 Current Money: **" .. money .. "**",
                        false, -- isStandFarm
                        true   -- isFarmLevel
                    )
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
            end
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
    Library:CreateNotification("Farm set to Use Stand Arrow", "Info", 3)
    task.wait(1.5)
end)
ItemSection:NewButton("Use Charged Arrows", "Set to Charged Arrow", function()
    ArrowToUse = "Charged Arrow"
    Library:CreateNotification("Farm set to Use Charged Arrow", "Info", 3)
    task.wait(1.5)
end)
ItemSection:NewButton("Use Kars Mask", "Set to Kars Mask", function()
    ArrowToUse = "Kars Mask"
    Library:CreateNotification("Farm set to Use Kars Mask", "Info", 3)
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

local WebhookSection = StandTab:NewSection("Webhook Settings")
WebhookSection:NewToggle("Enable Webhook", "Toggle Webhook notifications", function(state)
    UseWebhook = state
    Library:CreateNotification("Webhook " .. (state and "Enabled" or "Disabled"), "Info", 3)
    if debugMode then
        print("UseWebhook set to: " .. tostring(UseWebhook))
    end
end)
WebhookSection:NewTextBox("Set Webhook URL", "Enter Discord Webhook URL", function(input)
    webhookurl = input
    Library:CreateNotification("Webhook URL set to: " .. input, "Info", 3)
    if debugMode then
        print("Webhook URL set to: " .. webhookurl)
    end
end)

local StartFarmSection = StandTab:NewSection("Start Farm")

local function CheckInfo()
    local success, playerGui = pcall(function() return LocalPlayer.PlayerGui.PlayerGUI.ingame.Stats.StandName end)
    local PlayerStand = success and playerGui:FindFirstChild("Name_") and playerGui.Name_.TextLabel.Text or "None"
    local PlayerAttri = LocalPlayer.Data.Attri.Value or "None"
    if debugMode then print("Debug - PlayerStand:", PlayerStand, "PlayerAttri:", PlayerAttri) end
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
            Library:CreateNotification("Error: No " .. ArrowToUse .. " in Backpack!", "Error", 5)
            return
        end
        char.Humanoid:EquipTool(arrow)
        task.wait(0.2)
        if char:FindFirstChild(ArrowToUse) then
            char[ArrowToUse]:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            Library:CreateNotification("Using " .. ArrowToUse, "Info", 3)
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value ~= "None" or not getgenv().BeginFarm
        end
    elseif CheckInfo() then
        local stored = false
        for i = 1, 2 do
            if LocalPlayer.Data["Slot" .. i .. "Stand"].Value == "None" then
                Library:CreateNotification("Storing " .. stand .. " to Slot " .. i, "Info", 3)
                fireServerSafe(ReplicatedStorage.Events.SwitchStand, "Slot" .. i)
                repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not getgenv().BeginFarm
                if LocalPlayer.Data.Stand.Value == "None" then
                    Library:CreateNotification("Stored " .. stand .. " Successfully", "Success", 3)
                    local attribute = LocalPlayer.Data.Attri.Value or "None"
                    sendWebhookNotification(
                        "✨ Stand Obtained: **" .. stand .. "**\n" ..
                        "⚡ Attribute: **" .. attribute .. "**\n" ..
                        "🎉 Stored in Slot " .. i,
                        true,  -- isStandFarm
                        false  -- isFarmLevel
                    )
                    stored = true
                end
                break
            end
        end
        if not stored then
            Library:CreateNotification("Storage Full: No empty slots available!", "Error", 5)
            return
        end
    else
        local rokakaka = LocalPlayer.Backpack:FindFirstChild("Rokakaka")
        if not rokakaka then
            Library:CreateNotification("Error: No Rokakaka in Backpack!", "Error", 5)
            return
        end
        char.Humanoid:EquipTool(rokakaka)
        task.wait(0.2)
        if char:FindFirstChild("Rokakaka") then
            char.Rokakaka:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            Library:CreateNotification("Using Rokakaka to reset Stand", "Info", 3)
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not getgenv().BeginFarm
        end
    end
end

StartFarmSection:NewToggle("Start Stand Farm", "Toggle Stand Farm", function(state)
    getgenv().BeginFarm = state
    if getgenv().BeginFarm then
        if not CheckStand and not CheckAttri then
            Library:CreateNotification("Please enable Stand Check or Attribute Check!", "Error", 5)
            getgenv().BeginFarm = false
            return
        end
        if #Whitelisted == 0 and CheckStand then
            Library:CreateNotification("No Stands selected in Whitelist!", "Error", 5)
            getgenv().BeginFarm = false
            return
        end
        if #WhitelistedAttributes == 0 and CheckAttri then
            Library:CreateNotification("No Attributes selected in Whitelist!", "Error", 5)
            getgenv().BeginFarm = false
            return
        end
        Library:CreateNotification("Stand Farm Started", "Info", 3)
        task.spawn(function()
            while getgenv().BeginFarm do
                CycleStand()
                task.wait(0.5)
            end
            Library:CreateNotification("Stand Farm Stopped", "Info", 3)
        end)
    else
        Library:CreateNotification("Stand Farm Stopped", "Info", 3)
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
    if debugMode then
        print("Debug Mode activated. Check F9 for details.")
    end
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
    ["Dungeon [Lvl.15+]"] = {npcMonster = "i_stabman [Lvl. 15+]", bossName = "Bad Gi Boss", farmVar = "_G.AutoFarm1"},
    ["Dungeon [Lvl.40+]"] = {npcMonster = "i_stabman [Lvl. 40+]", bossName = "Dio [Dungeon]", farmVar = "_G.AutoFarm3"},
    ["Dungeon [Lvl.80+]"] = {npcMonster = "i_stabman [Lvl. 80+]", bossName = "Homeless Lord", farmVar = "_G.AutoFarm4"},
    ["Dungeon [Lvl.100+]"] = {npcMonster = "i_stabman [Lvl. 100+]", bossName = "Diavolo [Dungeon]", farmVar = "_G.AutoFarm4"},
    ["Dungeon [Lvl.200+]"] = {npcMonster = "i_stabman [Lvl. 200+]", bossName = "Jotaro P6 [Dungeon]", farmVar = "_G.AutoFarm5"}
}

local ChDun = "Dungeon [Lvl.15+]"
local isDungeonFarming = false
local dungeonConnection
local lastTeleport = 0
local currentTarget = nil
local safePosition = nil

local function isQuestActive()
    local questGui = LocalPlayer.PlayerGui:FindFirstChild("QuestGui") -- เปลี่ยนชื่อตามเกม
    if questGui and questGui:FindFirstChild("Active") and questGui.Active.Value then
        return true
    end
    return false
end

local function findDungeonNPC(maxAttempts)
    maxAttempts = maxAttempts or 3
    for attempt = 1, maxAttempts do
        local npcs = Workspace.Map.NPCs:GetChildren()
        for _, npc in ipairs(npcs) do
            if npc.Name:find("i_stabman") and npc:FindFirstChild("Head") and npc.Head:FindFirstChild("Main") and npc.Head.Main:FindFirstChild("Text") then
                if npc.Head.Main.Text.Text == dungeonSettings[ChDun].npcMonster then
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                    if npcHRP then
                        safePosition = npcHRP.CFrame + Vector3.new(0, 3, 5)
                    end
                    return npc
                end
            end
        end
        task.wait(1)
    end
    return nil
end

local function findDungeonBoss(maxAttempts)
    maxAttempts = maxAttempts or 5
    for attempt = 1, maxAttempts do
        if not Workspace:FindFirstChild("Living") then
            print("Workspace.Living not found, attempt " .. attempt .. " of " .. maxAttempts) -- ดีบั๊ก
            task.wait(1)
            continue
        end

        for _, boss in pairs(Workspace.Living:GetChildren()) do
            if not boss or boss.Name ~= "Boss" then
                continue
            end

            local humanoid = boss:FindFirstChild("Humanoid")
            if not humanoid then
                print("Boss has no Humanoid: " .. tostring(boss.Name)) -- ดีบั๊ก
                continue
            end

            if humanoid.Health <= 0 then
                print("Boss is dead: " .. tostring(boss.Name) .. " (Health: " .. humanoid.Health .. ")") -- ดีบั๊ก
                continue
            end

            local head = boss:FindFirstChild("Head")
            if not head then
                print("Boss has no Head: " .. tostring(boss.Name)) -- ดีบั๊ก
                continue
            end

            local display = head:FindFirstChild("Display")
            if not display then
                print("Boss has no Display: " .. tostring(boss.Name)) -- ดีบั๊ก
                continue
            end

            local frame = display:FindFirstChild("Frame")
            if not frame then
                print("Boss has no Frame: " .. tostring(boss.Name)) -- ดีบั๊ก
                continue
            end

            local text = frame:FindFirstChild("TextLabel") or frame:FindFirstChild("t") -- รองรับทั้ง "TextLabel" และ "t"
            if not text then
                print("Boss has no text label: " .. tostring(boss.Name)) -- ดีบั๊ก
                continue
            end

            if not text:IsA("TextLabel") then
                print("Boss text is not a TextLabel: " .. tostring(boss.Name) .. " (Type: " .. text.ClassName .. ")") -- ดีบั๊ก
                continue
            end

            if not text.Text then
                print("Boss text has no Text property: " .. tostring(boss.Name)) -- ดีบั๊ก
                continue
            end

            if text.Text == dungeonSettings[ChDun].bossName then
                print("Found Boss: " .. dungeonSettings[ChDun].bossName .. " (Text: " .. text.Text .. ")") -- ดีบั๊ก
                return boss
            else
                print("Boss display text does not match: " .. tostring(text.Text) .. " (expected: " .. dungeonSettings[ChDun].bossName .. ")") -- ดีบั๊ก
            end
        end
        print("Boss not found, attempt " .. attempt .. " of " .. maxAttempts) -- ดีบั๊ก
        task.wait(1)
    end
    notify("Error: Boss not found after " .. maxAttempts .. " attempts!", "Error", 5)
    return nil
end

local function notify(title, description, duration)
    if Library and Library.CreateNotification then
        Library:CreateNotification(title, description, duration)
    end
end

DungeonSection:NewDropdown("Choose Dungeon", "Select a dungeon to farm", DunLvl, function(AuDun)
    if not AuDun or AuDun == "" then
        notify("Invalid Selection!", "Please choose a valid dungeon.", 3)
        return
    end
    notify("Selected Dungeon: " .. AuDun, "Saving selection...", 2)
    task.wait(0.2)
    ChDun = AuDun
    currentTarget = nil
    safePosition = nil
end)

DungeonSection:NewToggle("Auto Farm Dungeon", "Toggle dungeon farming", function(AuFDun)
    isDungeonFarming = AuFDun
    if isFarming or isLevelFarming or isBossFarming then
        notify("Error", "Please disable other farming modes first!", 5)
        isDungeonFarming = false
        return
    end
    if not ChDun or not dungeonSettings[ChDun] then
        notify("Error", "No valid dungeon selected!", 5)
        isDungeonFarming = false
        return
    end

    local farmVar = dungeonSettings[ChDun].farmVar:gsub("_G.", "")
    _G[farmVar] = isDungeonFarming

    task.spawn(function()
        if dungeonConnection then
            dungeonConnection:Disconnect()
        end
        dungeonConnection = RunService.RenderStepped:Connect(function()
            local now = tick()
            if not isDungeonFarming or not _G[farmVar] then
                dungeonConnection:Disconnect()
                if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                local char = waitForCharacter()
                if char then char.Humanoid.Sit = false end
                _G[farmVar] = false
                return
            end

            local char = waitForCharacter()
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
                return
            end
            local hrp = char.HumanoidRootPart
            local stand = char:FindFirstChild("Stand")
            local standHRP = stand and stand:FindFirstChild("HumanoidRootPart")

            if not currentTarget or currentTarget == "NPC" then
                if isQuestActive() then
                    print("Quest still active, waiting to reset...") -- ดีบั๊ก
                    notify("Quest still active, waiting to reset...", "Warning", 3)
                    task.wait(2)
                    return
                end
                print("Starting new quest cycle, currentTarget reset to nil") -- ดีบั๊ก
                currentTarget = nil
                safePosition = nil
                local npc = findDungeonNPC()
                if npc then
                    print("Found NPC: " .. npc.Name) -- ดีบั๊ก
                    if now - lastTeleport > 1 then
                        local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                        if npcHRP and hrp then
                            local distance = (hrp.Position - npcHRP.Position).Magnitude
                            print("Distance to NPC: " .. distance) -- ดีบั๊ก
                            if distance > 3 then
                                Teleport(hrp, npcHRP.CFrame + Vector3.new(0, 2, 2))
                                if standHRP then
                                    Teleport(standHRP, hrp.CFrame + Vector3.new(0, 0, -2))
                                end
                                lastTeleport = now
                                notify("Teleporting to NPC", "Info", 2)
                            end
                            local prompt = npcHRP:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                fireproximityprompt(prompt, 20)
                                print("Fired ProximityPrompt for NPC") -- ดีบั๊ก
                                notify("Interacting with NPC via ProximityPrompt", "Info", 2)
                            end
                            local done = npc:FindFirstChild("Done")
                            if done then
                                fireServerSafe(done)
                                print("Fired Done event for NPC") -- ดีบั๊ก
                                notify("Fired Done event", "Info", 2)
                                task.wait(5) -- เพิ่มการหน่วงเวลาเป็น 5 วินาทีให้เซิร์ฟเวอร์โหลดบอส
                            end
                            currentTarget = "Boss"
                            task.wait(2) -- เพิ่มการหน่วงเวลาเพิ่มเติมก่อนค้นหาบอส
                        end
                    end
                else
                    print("No matching NPC found") -- ดีบั๊ก
                    notify("Error: Could not find NPC!", "Error", 5)
                end
            end

            if currentTarget == "Boss" then
                if not game:GetService("RunService"):IsRunning() then
                    print("Gameplay is paused, pausing dungeon farm") -- ดีบั๊ก
                    notify("Gameplay Paused: Pausing dungeon farm, waiting for content to load", "Warning", 5)
                    task.wait(2)
                    return
                end

                if not Workspace:FindFirstChild("Living") then
                    print("Workspace.Living not found, waiting before searching for boss") -- ดีบั๊ก
                    task.wait(2)
                    return
                end

                local boss = findDungeonBoss()
                if boss and boss:FindFirstChild("HumanoidRootPart") then
                    local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                    if bossHRP and hrp and now - lastTeleport > 1 then
                        repeat
                            task.wait(0.2)
                            if isDungeonFarming and hrp then
                                Teleport(hrp, bossHRP.CFrame * CFrame.new(0, Disc, Disc3))
                                if standHRP then
                                    Teleport(standHRP, bossHRP.CFrame * CFrame.new(0, Disc, Disc3 - 4))
                                end
                                lastTeleport = now
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
                        until (not boss or not boss:FindFirstChild("Humanoid") or boss.Humanoid.Health <= 0) or not _G[farmVar]

                        if isDungeonFarming and hrp then
                            if safePosition then
                                Teleport(hrp, safePosition)
                                if standHRP then
                                    Teleport(standHRP, safePosition + Vector3.new(0, 0, -2))
                                end
                            else
                                Teleport(hrp, hrp.CFrame + Vector3.new(0, 10, 0))
                            end
                            notify("Boss Defeated!", "Success", 3)
                            local npc = findDungeonNPC()
                            if npc then
                                local questDone = npc:FindFirstChild("QuestDone")
                                if questDone then
                                    fireServerSafe(questDone)
                                    print("Fired QuestDone event for NPC") -- ดีบั๊ก
                                    notify("Quest marked as completed", "Info", 2)
                                end
                            end
                            currentTarget = nil
                            task.wait(3)
                        end
                    else
                        print("Boss HumanoidRootPart not found, resetting to NPC") -- ดีบั๊ก
                        if hrp and now - lastTeleport > 5 then
                            if safePosition then
                                Teleport(hrp, safePosition)
                                if standHRP then
                                    Teleport(standHRP, safePosition + Vector3.new(0, 0, -2))
                                end
                                lastTeleport = now
                                notify("Boss HRP not found, returning to NPC", "Warning", 2)
                                currentTarget = "NPC"
                            end
                        end
                    end
                else
                    if hrp and now - lastTeleport > 5 then
                        if safePosition then
                            Teleport(hrp, safePosition)
                            if standHRP then
                                Teleport(standHRP, safePosition + Vector3.new(0, 0, -2))
                            end
                            lastTeleport = now
                            notify("Boss not found, returning to NPC", "Warning", 2)
                            currentTarget = "NPC"
                        end
                    end
                end
            end

            task.wait(1)
        end)
    end)
end)

DungeonSection:NewSlider("Y Offset", "Adjust hover height", -30, 30, function(value)
    Disc = value
    if debugMode then print("Y Offset set to: " .. Disc) end
end)

DungeonSection:NewSlider("Z Offset", "Adjust forward/backward distance", -30, 30, function(value)
    Disc3 = value
    if debugMode then print("Z Offset set to: " .. Disc3) end
end)

DungeonSection:NewToggle("Use All Skills", "Toggle using all skills", function(state)
    isUsingAllSkills = state
    if debugMode then print("Use All Skills: " .. tostring(isUsingAllSkills)) end
end)

DungeonSection:NewButton("Refresh Character", "Reset character state", function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
        if debugMode then print("Character refreshed!") end
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
            if debugMode then print("Teleported " .. part.Name .. " to: " .. tostring(cframe)) end
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

    task.spawn(function()
        if itemConnection then itemConnection:Disconnect() end
        itemConnection = RunService.Heartbeat:Connect(function()
            if not isItemFarming or not _G.On then
                itemConnection:Disconnect()
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
                if v.Name == "Handle" and hrp then
                    safeTeleport(hrp, v.CFrame)
                elseif v.Name == "ProximityPrompt" then
                    fireproximityprompt(v, 20)
                end
                task.wait(0.1)
            end
            task.wait(0.2)
        end)
    end)
end)
