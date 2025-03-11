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
local RunService = game:GetService("RunService")

-- ข้อมูลดันเจี้ยนจากสคริปต์ต้นฉบับ
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

-- ตัวแปรควบคุม
local ChDun = "Dungeon [Lvl.15+]"
local isDungeonFarming = false
local dungeonConnection
local lastTeleport = 0
local currentTarget = nil
local safePosition = nil
local teleportPositionIndex = 1 -- ใช้สำหรับสลับตำแหน่ง (หน้า, ข้าง, หลัง)

-- ฟังก์ชันแจ้งเตือน
local function notify(title, description, duration)
    if Library and Library.CreateNotification then
        Library:CreateNotification(title, description, duration)
    else
        warn("Notification: " .. title .. " - " .. description)
    end
end

-- ฟังก์ชันตรวจสอบเควส
local function isQuestActive()
    local questGui = LocalPlayer.PlayerGui:FindFirstChild("QuestGui")
    return questGui and questGui:FindFirstChild("Active") and questGui.Active.Value or false
end

-- ฟังก์ชันค้นหา NPC
local function findDungeonNPC()
    for _, npc in pairs(Workspace.Map.NPCs:GetChildren()) do
        if npc.Name:find("i_stabman") then
            local head = npc:FindFirstChild("Head")
            local main = head and head:FindFirstChild("Main")
            local text = main and main:FindFirstChild("Text")
            if text and text.Text == dungeonSettings[ChDun].npcMonster then
                local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                if npcHRP then
                    safePosition = npcHRP.CFrame + Vector3.new(0, 0, 5)
                    if debugMode then print("Found NPC: " .. npc.Name .. " at " .. tostring(safePosition)) end
                    return npc
                end
            end
        end
    end
    if debugMode then print("NPC not found for " .. dungeonSettings[ChDun].npcMonster) end
    return nil
end

-- ฟังก์ชันค้นหาบอส
local function findDungeonBoss()
    for _, boss in pairs(Workspace.Living:GetChildren()) do
        if boss.Name == "Boss" then
            local humanoid = boss:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local head = boss:FindFirstChild("Head")
                local display = head and head:FindFirstChild("Display")
                local frame = display and display:FindFirstChild("Frame")
                local text = frame and (frame:FindFirstChild("TextLabel") or frame:FindFirstChild("t"))
                if text and text.Text == dungeonSettings[ChDun].bossName then
                    local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                    if bossHRP then
                        if debugMode then print("Found Boss: " .. boss.Name .. " - " .. text.Text .. " at Y: " .. bossHRP.Position.Y) end
                        return boss
                    else
                        if debugMode then print("Boss found but no HumanoidRootPart, waiting...") end
                        task.wait(0.5)
                    end
                end
            end
        end
    end
    if debugMode then print("Boss not found for " .. dungeonSettings[ChDun].bossName) end
    return nil
end

-- ฟังก์ชันโจมตีบอส
local function attackBoss(boss)
    local char = waitForCharacter()
    if not char or not boss then return end

    if char:FindFirstChild("Aura") and not char.Aura.Value then
        fireServerSafe(char.StandEvents.Summon)
        task.wait(0.1)
    end

    if char:FindFirstChild("StandEvents") then
        if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
            for i = 1, 15 do
                fireServerSafe(char.StandEvents.M1)
                task.wait(0.05)
            end
        end
        for _, event in pairs(char.StandEvents:GetChildren()) do
            if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                fireServerSafe(event, true)
                task.wait(0.1)
            end
        end
    end

    pcall(function()
        local bossHRP = boss:FindFirstChild("HumanoidRootPart")
        if bossHRP then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(math.random(-20, 20), math.random(10, 20), math.random(-20, 20))
            bv.MaxForce = Vector3.new(5000, 5000, 5000)
            bv.Parent = bossHRP
            task.delay(0.2, function() bv:Destroy() end)
        end
    end)
end

-- ฟังก์ชันวาร์ปผ่านพื้น/กำแพง
local function teleportThroughWalls(charHRP, targetPos)
    local humanoid = charHRP.Parent:FindFirstChild("Humanoid")
    if humanoid then
        -- บังคับวาร์ปโดยตั้งค่า CanCollide ชั่วคราว (ถ้าเกมอนุญาต)
        local rootPart = charHRP
        local originalCanCollide = rootPart.CanCollide
        rootPart.CanCollide = false
        Teleport(charHRP, CFrame.new(targetPos))
        task.wait(0.1) -- รอให้วาร์ปเสร็จ
        rootPart.CanCollide = originalCanCollide
    end
end

-- ฟังก์ชันหลักสำหรับฟาร์มดันเจี้ยน
local function startDungeonFarming()
    if dungeonConnection then dungeonConnection:Disconnect() end
    dungeonConnection = RunService.Heartbeat:Connect(function()
        local now = tick()
        if not isDungeonFarming then
            dungeonConnection:Disconnect()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            currentTarget = nil
            safePosition = nil
            notify("Dungeon Farm Stopped", "Info", 3)
            return
        end

        local char = waitForCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            task.wait(0.5)
            return
        end
        local hrp = char.HumanoidRootPart
        local stand = char:FindFirstChild("Stand")
        local standHRP = stand and stand:FindFirstChild("HumanoidRootPart")

        -- ขั้นตอนที่ 1: หา NPC และเริ่มเควส
        if not currentTarget or currentTarget == "NPC" then
            if isQuestActive() then
                if debugMode then print("Quest still active, waiting...") end
                task.wait(1)
                return
            end

            local npc = findDungeonNPC()
            if npc then
                if now - lastTeleport > 1 then
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                    if npcHRP then
                        local distance = (hrp.Position - npcHRP.Position).Magnitude
                        if distance > 5 then
                            local targetCFrame = npcHRP.CFrame + Vector3.new(0, 0, 5)
                            teleportThroughWalls(hrp, targetCFrame.Position)
                            if standHRP then
                                teleportThroughWalls(standHRP, (targetCFrame + Vector3.new(0, 0, -2)).Position)
                            end
                            lastTeleport = now
                            if debugMode then print("Teleported to NPC") end
                        end

                        local prompt = npcHRP:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt, 20)
                            if debugMode then print("Fired ProximityPrompt") end
                        end
                        local done = npc:FindFirstChild("Done")
                        if done then
                            fireServerSafe(done)
                            if debugMode then print("Fired Done event") end
                            notify("Starting Dungeon", "Info", 2)
                            task.wait(3)
                            currentTarget = "Boss"
                        end
                    end
                end
            else
                notify("Could not find NPC!", "Warning", 2)
                task.wait(0.5)
            end
        end

        -- ขั้นตอนที่ 2: ฟาร์มบอส
        if currentTarget == "Boss" then
            local boss = findDungeonBoss()
            if boss and boss:FindFirstChild("HumanoidRootPart") then
                local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                if bossHRP and now - lastTeleport > 3 then
                    local distance = (hrp.Position - bossHRP.Position).Magnitude
                    if distance > 15 then
                        -- กำหนดตำแหน่งรอบมอน (หน้า, ข้าง, หลัง)
                        local positions = {
                            Vector3.new(0, 0, 15), -- ด้านหน้า
                            Vector3.new(15, 0, 0), -- ด้านขวา
                            Vector3.new(-15, 0, 0), -- ด้านซ้าย
                            Vector3.new(0, 0, -15) -- ด้านหลัง
                        }
                        local offset = positions[teleportPositionIndex]
                        teleportPositionIndex = (teleportPositionIndex % 4) + 1

                        -- วาร์ปในระดับ Y เดียวกับมอน + ลอย 2 หน่วย
                        local targetPos = Vector3.new(bossHRP.Position.X + offset.X, bossHRP.Position.Y + 2, bossHRP.Position.Z + offset.Z)
                        local lookAtCFrame = CFrame.new(targetPos, bossHRP.Position)
                        teleportThroughWalls(hrp, lookAtCFrame.Position)
                        if standHRP then
                            teleportThroughWalls(standHRP, (lookAtCFrame * CFrame.new(0, 0, -2)).Position)
                        end
                        lastTeleport = now
                        if debugMode then print("Teleported around Boss at position " .. tostring(offset) .. " with Y: " .. (bossHRP.Position.Y + 2)) end
                    end
                    attackBoss(boss)
                end

                local humanoid = boss:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health <= 0 then
                    if safePosition then
                        Teleport(hrp, safePosition)
                        if standHRP then
                            Teleport(standHRP, safePosition + Vector3.new(0, 0, -2))
                        end
                    else
                        Teleport(hrp, hrp.CFrame + Vector3.new(0, 10, 0))
                    end
                    notify("Boss Defeated!", "Success", 2)
                    local npc = findDungeonNPC()
                    if npc then
                        local questDone = npc:FindFirstChild("QuestDone")
                        if questDone then
                            fireServerSafe(questDone)
                            if debugMode then print("Fired QuestDone event") end
                        end
                    end
                    currentTarget = nil
                    task.wait(2)
                end
            else
                if now - lastTeleport > 5 then
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

        task.wait(0.1)
    end)
end

-- UI Elements
DungeonSection:NewDropdown("Choose Dungeon", "Select a dungeon to farm", DunLvl, function(AuDun)
    if not AuDun or not dungeonSettings[AuDun] then
        notify("Invalid Selection!", "Error", 3)
        return
    end
    ChDun = AuDun
    currentTarget = nil
    safePosition = nil
    notify("Selected Dungeon: " .. AuDun, "Success", 2)
end)

DungeonSection:NewToggle("Auto Farm Dungeon", "Toggle dungeon farming", function(AuFDun)
    isDungeonFarming = AuFDun
    if isDungeonFarming then
        if isFarming or isLevelFarming or isBossFarming then
            notify("Error", "Please disable other farming modes first!", 5)
            isDungeonFarming = false
            return
        end
        if not dungeonSettings[ChDun] then
            notify("Error", "No valid dungeon selected!", 5)
            isDungeonFarming = false
            return
        end
        local farmVar = dungeonSettings[ChDun].farmVar:gsub("_G.", "")
        _G[farmVar] = isDungeonFarming
        notify("Dungeon Farm Started", "Success", 3)
        task.spawn(startDungeonFarming)
    else
        local farmVar = dungeonSettings[ChDun].farmVar:gsub("_G.", "")
        _G[farmVar] = false
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
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
        currentTarget = nil
        safePosition = nil
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

-- Tab: Player Farm
local PlayerFarmTab = Window:NewTab("Player Farm")
local PlayerFarmSection = PlayerFarmTab:NewSection("Auto Farm Players (Chaos Mode)")
local isPlayerFarming = false
local playerFarmConnection
local invisibilityEnabled = false
local selectedPlayer = nil

-- สร้างรายชื่อผู้เล่นสำหรับ Dropdown
local function getPlayerList()
    local playerList = {}
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- ฟังก์ชันทำให้ไม่มีตัวตน
local function toggleInvisibility(state)
    local char = waitForCharacter()
    if not char then return end
    
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CanCollide = false
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 1
            end
        end
        if char:FindFirstChild("Head") and char.Head:FindFirstChild("Nametag") then
            char.Head.Nametag.Enabled = false
        end
        if char:FindFirstChild("Aura") then
            char.Aura.Value = false
        end
        if char:FindFirstChild("Stand") then
            char.Stand:Destroy()
        end
        Library:CreateNotification("Invisibility Enabled - You are a phantom!", "Success", 3)
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0
            end
        end
        if char:FindFirstChild("Head") and char.Head:FindFirstChild("Nametag") then
            char.Head.Nametag.Enabled = true
        end
        Library:CreateNotification("Invisibility Disabled - You are visible!", "Info", 3)
    end
    invisibilityEnabled = state
end

-- ฟังก์ชันวาร์ปแบบสุ่มรอบเป้าหมาย
local function randomTeleportAroundTarget(target)
    local char = waitForCharacter()
    if not char or not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local targetHRP = target.HumanoidRootPart

    -- สุ่มตำแหน่งรอบเป้าหมายในรัศมี 10-20 studs
    local angle = math.random(0, 360)
    local distance = math.random(10, 20)
    local offset = Vector3.new(math.cos(angle) * distance, Disc, math.sin(angle) * distance)
    local randomPos = targetHRP.Position + offset
    local lookAtCFrame = CFrame.new(randomPos, targetHRP.Position) -- จับทิศทางไปยังเป้าหมาย

    Teleport(hrp, lookAtCFrame)
    if debugMode then print("Random teleported to: " .. tostring(lookAtCFrame)) end
end

-- ฟังก์ชันโจมตีแบบโหดสุดขีด
local function chaosAttack(target)
    local char = waitForCharacter()
    if not char or not target or not target:FindFirstChild("HumanoidRootPart") then return end
    local targetHRP = target.HumanoidRootPart

    -- เรียก Stand
    if char:FindFirstChild("Aura") and not char.Aura.Value then
        fireServerSafe(char.StandEvents.Summon)
    end

    -- โจมตีแบบคลั่ง
    if char:FindFirstChild("StandEvents") then
        -- M1 Spam ความเร็วสูง
        if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
            for i = 1, 10 do
                fireServerSafe(char.StandEvents.M1)
                task.wait(0.02) -- ความเร็วสูงสุด
            end
        end
        -- ใช้ทุกสกิลแบบต่อเนื่อง
        for _, event in pairs(char.StandEvents:GetChildren()) do
            if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                fireServerSafe(event, true)
                task.wait(0.05)
            end
        end
    end

    -- รบกวนเป้าหมายด้วย BodyVelocity และ BodyGyro
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = targetHRP
        task.delay(0.5, function() bv:Destroy() end)
        
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)))
        bg.Parent = targetHRP
        task.delay(0.5, function() bg:Destroy() end)
    end)
end

-- ฟังก์ชันฟาร์มผู้เล่นแบบโกลาหล
local function startChaosPlayerFarming()
    if playerFarmConnection then playerFarmConnection:Disconnect() end
    playerFarmConnection = RunService.Heartbeat:Connect(function()
        if not isPlayerFarming then
            playerFarmConnection:Disconnect()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            toggleInvisibility(false)
            return
        end

        local targetPlayer = game:GetService("Players"):FindFirstChild(selectedPlayer)
        local target = targetPlayer and targetPlayer.Character
        if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
            if not invisibilityEnabled then
                toggleInvisibility(true)
            end

            -- วาร์ปแบบสุ่มรอบเป้าหมาย
            randomTeleportAroundTarget(target)
            chaosAttack(target)

            -- Webhook Notification
            if UseWebhook and webhookurl ~= "" then
                sendWebhookNotification(
                    "💀 Chaos Hunt: **" .. target.Name .. "**\n" ..
                    "🌌 Random Warp Distance: **" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude) .. " studs**\n" ..
                    "🔥 Status: **Under Assault**",
                    true, -- isStandFarm
                    false -- isFarmLevel
                )
            end
        else
            local char = waitForCharacter()
            if char and char:FindFirstChild("HumanoidRootPart") then
                Library:CreateNotification("Target not found or dead! Waiting...", "Warning", 3)
                local randomOffset = Vector3.new(math.random(-100, 100), 20, math.random(-100, 100))
                Teleport(char.HumanoidRootPart, char.HumanoidRootPart.CFrame + randomOffset)
                task.wait(2)
            end
        end
    end)
end

-- UI Elements
PlayerFarmSection:NewDropdown("Select Player", "Choose your prey", getPlayerList(), function(playerName)
    selectedPlayer = playerName
    Library:CreateNotification("Target set to: " .. playerName, "Info", 3)
    if debugMode then print("Selected player: " .. playerName) end
end)

PlayerFarmSection:NewToggle("Chaos Player Farm", "Toggle chaotic player hunting", function(state)
    isPlayerFarming = state
    if isPlayerFarming then
        if not selectedPlayer then
            Library:CreateNotification("Please select a player first!", "Error", 5)
            isPlayerFarming = false
            return
        end
        if isFarming or isLevelFarming or isBossFarming or isDungeonFarming then
            Library:CreateNotification("Please disable other farming modes first!", "Error", 5)
            isPlayerFarming = false
            return
        end
        Library:CreateNotification("Chaos Player Farm Started - Let the hunt begin!", "Success", 3)
        task.spawn(startChaosPlayerFarming)
    else
        Library:CreateNotification("Chaos Player Farm Stopped", "Info", 3)
        toggleInvisibility(false)
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
end)

PlayerFarmSection:NewSlider("Y Offset", "Adjust hover height", -30, 30, function(value)
    Disc = value
    if debugMode then print("Y Offset set to: " .. Disc) end
end)

PlayerFarmSection:NewSlider("Z Offset", "Adjust forward/backward distance", -30, 30, function(value)
    Disc3 = value
    if debugMode then print("Z Offset set to: " .. Disc3) end
end)

PlayerFarmSection:NewToggle("Use All Skills", "Toggle using all skills", function(state)
    isUsingAllSkills = state
    if debugMode then print("Use All Skills: " .. tostring(isUsingAllSkills)) end
end)

PlayerFarmSection:NewButton("Refresh Character", "Reset character state", function()
    local char = waitForCharacter()
    if char then
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        char.Humanoid.Sit = false
        toggleInvisibility(false)
        if debugMode then print("Character refreshed!") end
    end
end)

PlayerFarmSection:NewButton("Refresh Player List", "Update dropdown with current players", function()
    local playerList = getPlayerList()
    PlayerFarmSection:NewDropdown("Select Player", "Choose your prey", playerList, function(playerName)
        selectedPlayer = playerName
        Library:CreateNotification("Target set to: " .. playerName, "Info", 3)
        if debugMode then print("Selected player: " .. playerName) end
    end)
    Library:CreateNotification("Player list refreshed!", "Info", 3)
end)
