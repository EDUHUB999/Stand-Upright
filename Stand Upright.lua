local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- สร้าง Window ขนาดใหญ่ขึ้น
local Window = Fluent:CreateWindow({
    Title = "EDU HUB : Stand Upright Rebooted",
    SubTitle = "v3.0",
    TabWidth = 140,
    Size = UDim2.fromOffset(450, 350), -- ขนาดใหญ่ขึ้น
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Tabs พร้อมไอคอนครบทุก Tab
local Tabs = {
    FarmingQuests = Window:AddTab({ Title = "Farming & Quests", Icon = "sword" }),
    AutoFarmLevels = Window:AddTab({ Title = "Auto Farm", Icon = "binary" }),
    BossFarm = Window:AddTab({ Title = "Boss Farm", Icon = "skull" }),
    StandFarm = Window:AddTab({ Title = "Stand Farm", Icon = "apple" }),
    AutoBuy = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
    DungeonFarm = Window:AddTab({ Title = "Dungeon Farm", Icon = "swords" }),
    ItemFarm = Window:AddTab({ Title = "Items Farm", Icon = "box" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "server-cog" })
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
    if not hrp or not humanoid then return nil end
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

local Disc = 8.5
local Disc3 = 1
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
        if arg ~= nil then remote:FireServer(arg) else remote:FireServer() end
    end)
    return success
end

local function useAllSkills(char)
    if not char or not char:FindFirstChild("StandEvents") then return end
    local m1Event = char.StandEvents:FindFirstChild("M1")
    if m1Event and not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
        fireServerSafe(m1Event, true)
        task.wait(0.05)
    end
    for _, event in pairs(char.StandEvents:GetChildren()) do
        if event:IsA("RemoteEvent") and event.Name ~= "M1" and not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
            fireServerSafe(event, true)
            task.wait(0.05)
        end
    end
end

local function useSelectedSkills(char, selectedSkills)
    if not char or not char:FindFirstChild("StandEvents") or not selectedSkills then return end
    if selectedSkills["M1"] and char.StandEvents:FindFirstChild("M1") and not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
        fireServerSafe(char.StandEvents.M1, true)
        task.wait(0.05)
    end
    for skill, enabled in pairs(selectedSkills) do
        if enabled and skill ~= "M1" then
            local skillEvent = char.StandEvents:FindFirstChild(skill)
            if skillEvent then fireServerSafe(skillEvent, true) task.wait(0.05) end
        end
    end
end

local function getPlayerSkills()
    local char = waitForCharacter()
    local skillList = {"None"}
    if char and char:FindFirstChild("StandEvents") then
        for _, event in pairs(char.StandEvents:GetChildren()) do
            if event:IsA("RemoteEvent") and not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                table.insert(skillList, event.Name)
            end
        end
    end
    return skillList
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
local lastMonsterCount = 0
local monsterRespawnDistance = 30

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

local function countMonsters(monsterName)
    local count = 0
    for _, mob in pairs(Workspace.Living:GetChildren()) do
        if mob.Name == monsterName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            count = count + 1
        end
    end
    return count
end

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
        local currentMonsterCount = countMonsters(quest.monster)
        
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
                local selectedSkills = Options.SelectedSkills and Options.SelectedSkills.Value or {}
                if next(selectedSkills) then
                    useSelectedSkills(char, selectedSkills)
                elseif isUsingAllSkills then
                    useAllSkills(char)
                end
            end
            lastMonsterCount = currentMonsterCount
        else
            if lastMonsterCount > 0 and currentMonsterCount == 0 then
                if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                local char = waitForCharacter()
                if char then
                    char.Humanoid.Sit = false
                    local resetPosition = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, monsterRespawnDistance)
                    Teleport(char.HumanoidRootPart, resetPosition)
                end
                task.wait(2)
            elseif currentMonsterCount > 0 then
                target = findNearestMonster(quest.monster)
                if target then teleportToTarget(target) end
            end
        end
    end)
end

Tabs.FarmingQuests:AddToggle("AutoFarmQuests", {Title = "Auto Farm", Icon = "play", Default = false})
Options.AutoFarmQuests:OnChanged(function()
    isFarming = Options.AutoFarmQuests.Value
    if isFarming then task.spawn(startFarming) else
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
    end
end)

Tabs.FarmingQuests:AddDropdown("SelectQuest", {Title = "Quest", Icon = "list", Values = questList, Default = 1})
Options.SelectQuest:OnChanged(function() selectedQuest = Options.SelectQuest.Value end)

Tabs.FarmingQuests:AddSlider("YOffset", {Title = "Y Offset", Icon = "move-up", Default = 8.5, Min = -30, Max = 30, Rounding = 1})
Options.YOffset:OnChanged(function(Value) Disc = Value end)

Tabs.FarmingQuests:AddSlider("ZOffset", {Title = "Z Offset", Icon = "move-right", Default = 1, Min = -30, Max = 30, Rounding = 1})
Options.ZOffset:OnChanged(function(Value) Disc3 = Value end)

Tabs.FarmingQuests:AddButton({Title = "Refresh", Icon = "refresh-cw", Callback = function()
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
    {minLevel = 11, maxLevel = 20, name = "Scary Monster [Lvl. 10+]"},
    {minLevel = 21, maxLevel = 30, name = "Giorno Giovanna [Lvl. 20+]"},
    {minLevel = 31, maxLevel = 40, name = "Rker Dummy [Lvl. 30+]"},
    {minLevel = 41, maxLevel = 50, name = "Yoshikage Kira [Lvl. 40+]"},
    {minLevel = 51, maxLevel = 75, name = "Dio Over Heaven [Lvl. 50+]"},
    {minLevel = 76, maxLevel = 100, name = "Angelo [Lvl. 75+]"},
    {minLevel = 101, maxLevel = 125, name = "Alien [Lvl. 100+]"},
    {minLevel = 126, maxLevel = 150, name = "Jotaro Part 4 [Lvl. 125+]"},
    {minLevel = 151, maxLevel = 200, name = "Kakyoin [Lvl. 150+]"},
    {minLevel = 201, maxLevel = 275, name = "Sewer Vampire [Lvl. 200+]"},
    {minLevel = 276, maxLevel = math.huge, name = "Pillerman [Lvl. 275+]"}
}

local function findMultipleMonsters(monsterName, maxTargets)
    local targets = {}
    for _, mob in pairs(Workspace.Living:GetChildren()) do
        if mob.Name == monsterName and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            table.insert(targets, mob)
            if #targets >= maxTargets then break end
        end
    end
    return targets
end

local function startLevelFarming()
    if levelConnection then levelConnection:Disconnect() end
    local lastSwitchTime = 0
    local currentTargetIndex = 1
    local switchInterval = 0.2
    
    levelConnection = RunService.Heartbeat:Connect(function()
        if not isLevelFarming then
            levelConnection:Disconnect()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            return
        end
        
        local char = waitForCharacter()
        if not char then return end
        
        local level = LocalPlayer.Data.Level.Value or 1
        local matchedSetting = nil
        for _, setting in ipairs(levelMap) do
            if level >= setting.minLevel and level <= setting.maxLevel then
                matchedSetting = MonSettings[setting.name]
                break
            end
        end
        
        if matchedSetting then
            local targets = findMultipleMonsters(matchedSetting[1], 5)
            if #targets > 0 then
                local currentTime = tick()
                if currentTime - lastSwitchTime >= switchInterval then
                    currentTargetIndex = (currentTargetIndex % #targets) + 1
                    lastSwitchTime = currentTime
                end
                
                local target = targets[currentTargetIndex]
                if target then
                    teleportToTarget(target)
                    local npc = Workspace.Map.NPCs:FindFirstChild(matchedSetting[2])
                    if npc then
                        fireServerSafe(npc.Done)
                        fireServerSafe(npc.QuestDone)
                    end
                    if char:FindFirstChild("Aura") and not char.Aura.Value then
                        fireServerSafe(char.StandEvents.Summon)
                    end
                    local selectedSkills = Options.SelectedSkills and Options.SelectedSkills.Value or {}
                    if next(selectedSkills) then
                        useSelectedSkills(char, selectedSkills)
                    elseif isUsingAllSkills then
                        useAllSkills(char)
                    end
                end
            else
                if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
                if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
                char.Humanoid.Sit = false
                local resetPosition = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, 70)
                Teleport(char.HumanoidRootPart, resetPosition)
                task.wait(1)
            end
        else
            task.wait(1)
        end
    end)
end

Tabs.AutoFarmLevels:AddToggle("AutoFarmLevels", {Title = "Auto Farm All Levels", Icon = "play", Default = false})
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

-- Tab: Boss Farm
local isBossFarming = false
local selectedBosses = {}
local bossConnection
local previousFarmMode = nil
local isFightingBosses = false

local bossList = {
    "Jotaro Over Heaven", "Alternate Jotaro Part 4", "JohnnyJoestar", "Giorno Giovanna Requiem"
}

local bossSpawnLocations = {
    ["Alternate Jotaro Part 4"] = CFrame.new(1234, 567, 890)
}

local function checkAliveBosses()
    local aliveBosses = {}
    for _, entity in pairs(Workspace.Living:GetChildren()) do
        if table.find(selectedBosses, entity.Name) and entity:FindFirstChild("Humanoid") and entity.Humanoid.Health > 0 then
            table.insert(aliveBosses, entity)
        end
    end
    return aliveBosses
end

local function findDungeonMinions()
    local minions = {}
    for _, entity in pairs(Workspace.Living:GetChildren()) do
        if entity.Name:find("Minion") and entity:FindFirstChild("Humanoid") and entity.Humanoid.Health > 0 then
            table.insert(minions, entity)
        end
    end
    return minions
end

local function clearDungeonMinions()
    local char = waitForCharacter()
    if not char then return false end
    local hrp = char.HumanoidRootPart
    local minions = findDungeonMinions()

    if #minions == 0 then return true end

    for _, minion in pairs(minions) do
        teleportToTarget(minion)
        if char:FindFirstChild("Aura") and not char.Aura.Value then
            fireServerSafe(char.StandEvents.Summon)
        end
        local selectedSkills = Options.SelectedSkills and Options.SelectedSkills.Value or {}
        if next(selectedSkills) then
            useSelectedSkills(char, selectedSkills)
        elseif isUsingAllSkills then
            useAllSkills(char)
        end
        task.wait(0.5)
    end
    return #findDungeonMinions() == 0
end

local function teleportToBossSpawn(bossName)
    local char = waitForCharacter()
    if not char or not bossSpawnLocations[bossName] then return end
    Teleport(char.HumanoidRootPart, bossSpawnLocations[bossName])
end

local function startBossFarming()
    if bossConnection then bossConnection:Disconnect() end
    
    bossConnection = RunService.Heartbeat:Connect(function()
        if not isBossFarming then
            bossConnection:Disconnect()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            isFightingBosses = false
            return
        end
        
        local aliveBosses = checkAliveBosses()
        
        if #aliveBosses > 0 and not isFightingBosses then
            if isFarming then
                previousFarmMode = "FarmingQuests"
                isFarming = false
                Options.AutoFarmQuests:SetValue(false)
                if connection then connection:Disconnect() end
            elseif isLevelFarming then
                previousFarmMode = "AutoFarmLevels"
                isLevelFarming = false
                Options.AutoFarmLevels:SetValue(false)
                if levelConnection then levelConnection:Disconnect() end
            end
            isFightingBosses = true
            Fluent:Notify({Title = "Info", Content = "Bosses detected! Starting Boss Farm.", Duration = 3})
        end
        
        if isFightingBosses and #aliveBosses > 0 then
            for _, targetBoss in pairs(aliveBosses) do
                if targetBoss.Name == "Alternate Jotaro Part 4" then
                    if clearDungeonMinions() then teleportToTarget(targetBoss) end
                else
                    teleportToTarget(targetBoss)
                end
                local char = waitForCharacter()
                if char then
                    if char.Humanoid.Health <= 0 then
                        Fluent:Notify({Title = "Warning", Content = "Character died! Pausing Boss Farm.", Duration = 5})
                        isBossFarming = false
                        Options.AutoFarmBoss:SetValue(false)
                        return
                    end
                    if char:FindFirstChild("Aura") and not char.Aura.Value then
                        fireServerSafe(char.StandEvents.Summon)
                    end
                    local selectedSkills = Options.SelectedSkills and Options.SelectedSkills.Value or {}
                    if next(selectedSkills) then
                        useSelectedSkills(char, selectedSkills)
                    elseif isUsingAllSkills then
                        useAllSkills(char)
                    end
                end
            end
        elseif isFightingBosses and #aliveBosses == 0 then
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            local char = waitForCharacter()
            if char then char.Humanoid.Sit = false end
            
            if previousFarmMode == "FarmingQuests" then
                isFarming = true
                Options.AutoFarmQuests:SetValue(true)
                task.spawn(startFarming)
                Fluent:Notify({Title = "Info", Content = "Bosses defeated! Resuming Farming & Quests.", Duration = 3})
            elseif previousFarmMode == "AutoFarmLevels" then
                isLevelFarming = true
                Options.AutoFarmLevels:SetValue(true)
                task.spawn(startLevelFarming)
                Fluent:Notify({Title = "Info", Content = "Bosses defeated! Resuming Auto Farm All Levels.", Duration = 3})
            end
            previousFarmMode = nil
            isFightingBosses = false
        end
        
        if #aliveBosses == 0 and not isFightingBosses then
            if table.find(selectedBosses, "Alternate Jotaro Part 4") then
                teleportToBossSpawn("Alternate Jotaro Part 4")
                Fluent:Notify({Title = "Info", Content = "Teleporting to Alternate Jotaro Part 4 spawn point.", Duration = 3})
            end
            task.wait(1)
        end
    end)
end

Tabs.BossFarm:AddDropdown("SelectBosses", {Title = "Bosses", Icon = "users", Values = bossList, Multi = true, Default = {}})
Options.SelectBosses:OnChanged(function(Value)
    selectedBosses = {}
    for boss, enabled in pairs(Value) do
        if enabled then table.insert(selectedBosses, boss) end
    end
end)

Tabs.BossFarm:AddToggle("AutoFarmBoss", {Title = "Auto Farm", Icon = "play", Default = false})
Options.AutoFarmBoss:OnChanged(function()
    isBossFarming = Options.AutoFarmBoss.Value
    if isBossFarming then
        if #selectedBosses == 0 then
            Fluent:Notify({Title = "Error", Content = "Please select at least one boss first!", Duration = 5})
            isBossFarming = false
            Options.AutoFarmBoss:SetValue(false)
            return
        end
        Fluent:Notify({Title = "Info", Content = "Boss Farm enabled! Waiting for bosses to spawn...", Duration = 3})
        task.spawn(startBossFarming)
    else
        if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
        local char = waitForCharacter()
        if char then char.Humanoid.Sit = false end
        Fluent:Notify({Title = "Info", Content = "Boss Farm disabled!", Duration = 3})
    end
end)

-- Tab: Stand Farm
do
    local StandArrowsList = {
        "Cream", "HierophantGreen", "KillerQueen", "SilverChariot", "StarPlatinum", "StickyFingers",
        "StarPlatinum:StoneOcean", "CrazyDiamond", "Aerosmith", "StoneFree", "TheEmperor", "TheHand",
        "softandwet", "magiciansred", "DiverDown", "PurpleSmoke", "WhiteSnake", "TheWorld", "WeatherReport",
        "D4C", "DirtyDeedsDoneDirtCheap", "GoldenExperience", "KingCrimson", "PremierMacho",
        "SilverChariotOVA", "TheWorldOVA", "Jotaro'sStarPlatinum", "StarPlatinum OVA", "TuskAct1",
        "TheWorld:AlternativeUniverse", "Whitesnake", "Dio'sThe World"
    }

    local ChargedArrowsList = {
        "CrazyDiamond", "SilverChariot", "HierophantGreen", "KillerQueen", "StarPlatinum", "TheHand",
        "D4she", "DirtyDeedsDoneDirtCheap", "GoldenExperience", "KingCrimson", "TheWorld", "TuskAct1",
        "TheWorld:AlternativeUniverse", "Whitesnake", "Dio'sThe World"
    }

    local AttributesList = {
        "None", "Strong", "Tough", "Sloppy", "Powerful", "Manic", "Enrage", "Lethargic", "Godly",
        "Daemon", "Invincible", "Tragic", "Scourge", "GlassCannon", "Hacker", "Legendary"
    }

    local WhitelistedStands = {}
    local WhitelistedAttributes = {}
    local ArrowToUse = "Stand Arrow"
    local CheckStand, CheckAttri = false, false
    local CheckStandOrAttri, CheckStandAndAttri = false, false
    local BeginFarm = false
    local MarketplaceService = game:GetService("MarketplaceService")
    local gamepassId1 = 123456
    local gamepassId2 = 789012

    local function normalizeString(str)
        return str:gsub("[%s:']", ""):upper()
    end

    local function notify(title, content, duration)
        Fluent:Notify({Title = title, Content = content, Duration = duration or 5})
    end

    local function checkGamepass()
        local hasGamepass = false
        pcall(function()
            if MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamepassId1) or 
               MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamepassId2) then
                hasGamepass = true
            end
        end)
        return hasGamepass
    end

    local function useItem(itemName, char)
        local itemInBackpack = LocalPlayer.Backpack:FindFirstChild(itemName)
        local itemInHand = char:FindFirstChild(itemName)
        
        if itemInHand then
            char.Humanoid:UnequipTools()
            task.wait(0.1)
        end
        
        if not itemInBackpack then return false end
        
        char.Humanoid:EquipTool(itemInBackpack)
        task.wait(0.1)
        if char:FindFirstChild(itemName) then
            char[itemName]:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            local prompt = char[itemName]:FindFirstChildOfClass("ProximityPrompt")
            if prompt then fireproximityprompt(prompt, 1) end
            task.wait(0.5)
            return true
        end
        return false
    end

    local function checkStandAndAttribute()
        local stand = LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value or "None"
        local attribute = LocalPlayer.Data and LocalPlayer.Data.Attri and LocalPlayer.Data.Attri.Value or "None"
        stand = normalizeString(stand)
        attribute = tostring(attribute)

        local standMatch = table.find(WhitelistedStands, stand)
        local attriMatch = table.find(WhitelistedAttributes, attribute)

        if CheckStand and not CheckAttri and not CheckStandOrAttri and not CheckStandAndAttri then
            return standMatch
        elseif CheckAttri and not CheckStand and not CheckStandOrAttri and not CheckStandAndAttri then
            return attriMatch
        elseif CheckStandOrAttri then
            return standMatch or attriMatch
        elseif CheckStandAndAttri then
            return standMatch and attriMatch
        else
            return false
        end
    end

    local function resetCharacterState()
        local char = waitForCharacter()
        if char then
            char.Humanoid:UnequipTools()
            if bodyPosition then bodyPosition:Destroy() bodyPosition = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            char.Humanoid.Sit = false
        end
    end

    local function cycleStand()
        local char = waitForCharacter()
        if not char then return false, "no_character" end

        local stand = LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value or "None"
        stand = normalizeString(stand)

        if checkStandAndAttribute() then
            local stored = false
            local level = LocalPlayer.Data and LocalPlayer.Data.Level and LocalPlayer.Data.Level.Value or 1
            local hasGamepass = checkGamepass()
            local slotsToCheck = {1, 2}
            if hasGamepass then
                table.insert(slotsToCheck, 3)
                table.insert(slotsToCheck, 6)
            end
            if level >= 120 then table.insert(slotsToCheck, 5) end

            for _, i in ipairs(slotsToCheck) do
                if i ~= 4 then
                    if LocalPlayer.Data and LocalPlayer.Data["Slot" .. i .. "Stand"] and LocalPlayer.Data["Slot" .. i .. "Stand"].Value == "None" then
                        fireServerSafe(ReplicatedStorage.Events.SwitchStand, "Slot" .. i)
                        local timeout = tick() + 5
                        while tick() < timeout and LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value ~= "None" and BeginFarm do
                            task.wait(0.1)
                        end
                        if LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None" then
                            stored = true
                            notify("Success", "Stand stored in Slot " .. i .. ". Continuing farm...", 3)
                            return true, "stored"
                        end
                        break
                    end
                end
            end
            if stored then return true, "stored" else return false, "no_slots" end
        elseif stand == "NONE" then
            if not useItem(ArrowToUse, char) then return false, "no_arrow" end
            local timeout = tick() + 5
            while tick() < timeout and LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value == "None" and BeginFarm do
                task.wait(0.1)
            end
            return true, "used_arrow"
        else
            if not useItem("Rokakaka", char) then return false, "no_rokakaka" end
            local timeout = tick() + 5
            while tick() < timeout and LocalPlayer.Data and LocalPlayer.Data.Stand and LocalPlayer.Data.Stand.Value ~= "None" and BeginFarm do
                task.wait(0.1)
            end
            return true, "used_rokakaka"
        end
    end

    Tabs.StandFarm:AddDropdown("SelectStands", {Title = "Stands", Icon = "star", Values = StandArrowsList, Multi = true, Default = {}})
    Options.SelectStands:OnChanged(function(Value)
        WhitelistedStands = {}
        for stand, state in pairs(Value) do
            if state then table.insert(WhitelistedStands, normalizeString(stand)) end
        end
    end)

    Tabs.StandFarm:AddDropdown("SelectAttributes", {Title = "Attributes", Icon = "award", Values = AttributesList, Multi = true, Default = {}})
    Options.SelectAttributes:OnChanged(function(Value)
        WhitelistedAttributes = {}
        for attr, state in pairs(Value) do
            if state then table.insert(WhitelistedAttributes, attr) end
        end
    end)

    Tabs.StandFarm:AddButton({Title = "Stand Arrows", Icon = "arrow-right", Callback = function() ArrowToUse = "Stand Arrow" end})
    Tabs.StandFarm:AddButton({Title = "Charged Arrows", Icon = "zap", Callback = function() ArrowToUse = "Charged Arrow" end})

    Tabs.StandFarm:AddToggle("StandCheck", {Title = "Stand Check", Icon = "check", Default = false})
    Options.StandCheck:OnChanged(function() 
        CheckStand = Options.StandCheck.Value 
        if CheckStand then CheckStandOrAttri = false; CheckStandAndAttri = false end
    end)

    Tabs.StandFarm:AddToggle("AttributeCheck", {Title = "Attribute Check", Icon = "check-circle", Default = false})
    Options.AttributeCheck:OnChanged(function() 
        CheckAttri = Options.AttributeCheck.Value 
        if CheckAttri then CheckStandOrAttri = false; CheckStandAndAttri = false end
    end)

    Tabs.StandFarm:AddToggle("StandOrAttriCheck", {Title = "Stand OR Attribute", Icon = "git-branch", Default = false})
    Options.StandOrAttriCheck:OnChanged(function() 
        CheckStandOrAttri = Options.StandOrAttriCheck.Value 
        if CheckStandOrAttri then CheckStand = false; CheckAttri = false; CheckStandAndAttri = false end
    end)

    Tabs.StandFarm:AddToggle("StandAndAttriCheck", {Title = "Stand AND Attribute", Icon = "link", Default = false})
    Options.StandAndAttriCheck:OnChanged(function() 
        CheckStandAndAttri = Options.StandAndAttriCheck.Value 
        if CheckStandAndAttri then CheckStand = false; CheckAttri = false; CheckStandOrAttri = false end
    end)

    Tabs.StandFarm:AddButton({Title = "Open Storage", Icon = "archive", Callback = function() 
        fireServerSafe(Workspace.Map.NPCs.admpn.Done) 
    end})

    Tabs.StandFarm:AddButton({Title = "Reset", Icon = "refresh-cw", Callback = function()
        resetCharacterState()
        notify("Info", "Character state reset!", 3)
    end})

    Tabs.StandFarm:AddToggle("StartStandFarm", {Title = "Start Farm", Icon = "play", Default = false})
    Options.StartStandFarm:OnChanged(function()
        BeginFarm = Options.StartStandFarm.Value
        if BeginFarm then
            if not (CheckStand or CheckAttri or CheckStandOrAttri or CheckStandAndAttri) then
                notify("Error", "Enable at least one check type first!", 5)
                BeginFarm = false
                Options.StartStandFarm:SetValue(false)
                return
            end
            if (CheckStand or CheckStandOrAttri or CheckStandAndAttri) and #WhitelistedStands == 0 then
                notify("Error", "Select at least one Stand!", 5)
                BeginFarm = false
                Options.StartStandFarm:SetValue(false)
                return
            end
            if (CheckAttri or CheckStandOrAttri or CheckStandAndAttri) and #WhitelistedAttributes == 0 then
                notify("Error", "Select at least one Attribute!", 5)
                BeginFarm = false
                Options.StartStandFarm:SetValue(false)
                return
            end
            notify("Info", "Stand Farm Started", 3)
            resetCharacterState()
            task.spawn(function()
                LocalPlayer.CharacterAdded:Connect(function()
                    if BeginFarm then
                        notify("Info", "Character respawned, resuming Stand Farm...", 3)
                        resetCharacterState()
                    end
                end)
                while BeginFarm do
                    if isItemFarming then
                        notify("Warning", "Item Farm is active, waiting to resume Stand Farm...", 5)
                        while isItemFarming and BeginFarm do task.wait(1) end
                        if not BeginFarm then break end
                        notify("Info", "Resuming Stand Farm after Item Farm stopped", 3)
                    end
                    
                    local success, reason = cycleStand()
                    if not success then
                        if reason == "no_character" then
                            notify("Warning", "Character not found, waiting for respawn...", 5)
                            while not LocalPlayer.Character and BeginFarm do task.wait(1) end
                        elseif reason == "no_arrow" then
                            notify("Warning", "Out of " .. ArrowToUse .. ", waiting for more...", 5)
                            while not LocalPlayer.Backpack:FindFirstChild(ArrowToUse) and BeginFarm do task.wait(1) end
                        elseif reason == "no_rokakaka" then
                            notify("Warning", "Out of Rokakaka, waiting for more...", 5)
                            while not LocalPlayer.Backpack:FindFirstChild("Rokakaka") and BeginFarm do task.wait(1) end
                        elseif reason == "no_slots" then
                            notify("Warning", "No empty slots available! Stopping farm...", 5)
                            BeginFarm = false
                            Options.StartStandFarm:SetValue(false)
                            break
                        else
                            notify("Warning", "Unknown issue, retrying...", 5)
                            resetCharacterState()
                        end
                    end
                    task.wait(0.1)
                end
                resetCharacterState()
                notify("Info", "Stand Farm Stopped", 3)
            end)
        else
            notify("Info", "Stand Farm Stopped", 3)
        end
    end)
end

-- Tab: Auto Buy Item
local Amount = 1

Tabs.AutoBuy:AddButton({Title = "Teleport to Shop", Icon = "map-pin", Callback = function()
    local char = waitForCharacter()
    if char then
        Teleport(char.HumanoidRootPart, CFrame.new(11927.1, -3.28935, -4488.59))
        if char:FindFirstChild("Stand") then
            Teleport(char.Stand.HumanoidRootPart, char.HumanoidRootPart.CFrame)
        end
    end
end})

Tabs.AutoBuy:AddInput("BuyAmount", {Title = "Amount", Icon = "hash", Default = "1", Numeric = true, Callback = function(Value) Amount = tonumber(Value) or 1 end})

local buyItems = {
    {"Rokakaka (2,500c)", "MerchantAU", "Option2", "apple"},
    {"Stand Arrow (3,500c)", "MerchantAU", "Option4", "arrow-right"},
    {"Charged Arrow (50,000c)", "Merchantlvl120", "Option2", "zap"},
    {"Dio Diary (1,500,000c)", "Merchantlvl120", "Option3", "book"},
    {"Requiem Arrow (1,500,000c)", "Merchantlvl120", "Option4", "arrow-up"}
}
for _, item in ipairs(buyItems) do
    Tabs.AutoBuy:AddButton({Title = item[1], Icon = item[4], Callback = function()
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

Tabs.DungeonFarm:AddDropdown("ChooseDungeon", {Title = "Dungeon", Icon = "list", Values = DunLvl, Default = 1})
Options.ChooseDungeon:OnChanged(function()
    ChDun = Options.ChooseDungeon.Value
    currentDistance = dungeonSettings[ChDun].baseDistance
    currentTarget = nil
    safePosition = nil
    lastHealth = 0
    lastDamageCheck = 0
end)

Tabs.DungeonFarm:AddToggle("AutoFarmDungeon", {Title = "Auto Farm", Icon = "play", Default = false})
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
                        local selectedSkills = Options.SelectedSkills and Options.SelectedSkills.Value or {}
                        if next(selectedSkills) then
                            useSelectedSkills(char, selectedSkills)
                        elseif isUsingAllSkills then
                            useAllSkills(char)
                        end
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

Tabs.DungeonFarm:AddSlider("DungeonYOffset", {Title = "Y Offset", Icon = "move-up", Default = 7, Min = -30, Max = 30, Rounding = 1})
Options.DungeonYOffset:OnChanged(function(Value) Disc = Value end)

Tabs.DungeonFarm:AddSlider("DungeonZOffset", {Title = "Z Offset", Icon = "move-right", Default = 0, Min = -30, Max = 30, Rounding = 1})
Options.DungeonZOffset:OnChanged(function(Value) Disc3 = Value end)

Tabs.DungeonFarm:AddButton({Title = "Refresh", Icon = "refresh-cw", Callback = function()
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

Tabs.ItemFarm:AddToggle("FarmItems", {Title = "Farm Items", Icon = "play", Default = false})
Options.FarmItems:OnChanged(function()
    isItemFarming = Options.FarmItems.Value
    _G.On = isItemFarming

    if isItemFarming and (isFarming or isLevelFarming or isBossFarming or isDungeonFarming) then
        isItemFarming = false
        _G.On = false
        Options.FarmItems:SetValue(false)
        return
    end

    if itemConnection then itemConnection:Disconnect() end

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

Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti-AFK", Icon = "clock", Default = false})
Options.AntiAFK:OnChanged(function()
    isAntiAFK = Options.AntiAFK.Value
    if isAntiAFK then antiAFK() end
end)

Tabs.Settings:AddToggle("UseAllSkills", {Title = "All Skills", Icon = "wand", Default = false})
Options.UseAllSkills:OnChanged(function()
    isUsingAllSkills = Options.UseAllSkills.Value
end)

Tabs.Settings:AddDropdown("SelectedSkills", {Title = "Skills", Icon = "list", Values = getPlayerSkills(), Multi = true, Default = {}})

Tabs.Settings:AddButton({Title = "Refresh Skills", Icon = "refresh-cw", Callback = function()
    local newSkills = getPlayerSkills()
    Options.SelectedSkills:SetValues(newSkills)
    local currentSelected = Options.SelectedSkills.Value
    local updatedSelected = {}
    for skill, enabled in pairs(currentSelected) do
        if enabled and table.find(newSkills, skill) then
            updatedSelected[skill] = true
        end
    end
    Options.SelectedSkills:SetValue(updatedSelected)
    Fluent:Notify({Title = "Info", Content = "Skills refreshed successfully!", Duration = 3})
end})

local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local availableKeys = {
    "E", "R", "T", "Y", "J", "H", "F", "Z", "X", "C", "V",
    "LeftClick", "RightClick"
}

_G.Asd = false
local selectedKeys = {}
local toggleKey = Enum.KeyCode.P

local function pressKey(key)
    if key == "E" then
        VirtualInputManager:SendKeyEvent(true, "E", false, game)
        task.wait(4)
        VirtualInputManager:SendKeyEvent(false, "E", false, game)
    elseif key == "LeftClick" then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    elseif key == "RightClick" then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
    else
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end
end

local function useSelectedKeys()
    task.spawn(function()
        while _G.Asd do
            local char = waitForCharacter()
            if not char then
                task.wait(1)
                continue
            end
            for key, enabled in pairs(selectedKeys) do
                if enabled then
                    pressKey(key)
                    if key == "E" then task.wait(0.5)
                    elseif key == "LeftClick" or key == "RightClick" then task.wait(0.0)
                    else task.wait(0.2) end
                end
            end
            task.wait(0.5)
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == toggleKey then
        _G.Asd = not _G.Asd
        if _G.Asd then
            if next(selectedKeys) == nil then
                Fluent:Notify({Title = "Error", Content = "Please select at least one key first!", Duration = 5})
                _G.Asd = false
                Options.UseKeySkills:SetValue(false)
                return
            end
            Fluent:Notify({Title = "Info", Content = "Key Skills activated with '" .. toggleKey.Name .. "'!", Duration = 3})
            useSelectedKeys()
            Options.UseKeySkills:SetValue(true)
        else
            Fluent:Notify({Title = "Info", Content = "Key Skills stopped with '" .. toggleKey.Name .. "'!", Duration = 3})
            Options.UseKeySkills:SetValue(false)
        end
    end
end)

Tabs.Settings:AddDropdown("SelectKeySkills", {Title = "Key Skills", Icon = "keyboard", Values = availableKeys, Multi = true, Default = {}})
Options.SelectKeySkills:OnChanged(function(Value)
    selectedKeys = {}
    for key, state in pairs(Value) do
        if state then selectedKeys[key] = true end
    end
end)

Tabs.Settings:AddToggle("UseKeySkills", {Title = "Use Keys", Icon = "play", Default = false})
Options.UseKeySkills:OnChanged(function()
    _G.Asd = Options.UseKeySkills.Value
    if _G.Asd then
        if next(selectedKeys) == nil then
            Fluent:Notify({Title = "Error", Content = "Please select at least one key first!", Duration = 5})
            _G.Asd = false
            Options.UseKeySkills:SetValue(false)
            return
        end
        Fluent:Notify({Title = "Info", Content = "Key Skills activated via GUI!", Duration = 3})
        useSelectedKeys()
    else
        Fluent:Notify({Title = "Info", Content = "Key Skills stopped via GUI!", Duration = 3})
    end
end)

-- Floating Button
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "FloatingButtonGui"
ScreenGui.ResetOnSpawn = false

local FloatingButton = Instance.new("ImageButton")
FloatingButton.Size = UDim2.new(0, 40, 0, 40)
FloatingButton.Position = UDim2.new(0.5, -25, 0.5, -25)
FloatingButton.BackgroundTransparency = 1
FloatingButton.Image = "rbxassetid://12514663645"
FloatingButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatingButton

local dragging, dragInput, dragStart, startPos

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatingButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

local isUIVisible = true
local TweenService = game:GetService("TweenService")

FloatingButton.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    Window:Minimize(not isUIVisible)
    TweenService:Create(FloatingButton, TweenInfo.new(0.3), {ImageTransparency = isUIVisible and 0 or 0.5}):Play()
end)

Window:SelectTab(1)
Fluent:Notify({Title = "EDU HUB", Content = "The script has been loaded.", Duration = 8})
SaveManager:LoadAutoloadConfig()
