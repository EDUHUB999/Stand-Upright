-- Global Toggle
getgenv().BeginFarm = false
_G.ScriptLoaded = false -- ตัวแปรป้องกันการรันสคริปต์ซ้ำ

if _G.ScriptLoaded then return end
_G.ScriptLoaded = true

local ScreenGui = Instance.new("ScreenGui")
local Frame_1 = Instance.new("Frame")
local ImageButton_1 = Instance.new("ImageButton")

-- Properties:
ScreenGui.Parent = game.CoreGui

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

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- GUI Setup
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/EVILDARKSIDEUPV1/ui/main/README.md"))()
local Window = Library.CreateLib("EDU HUB : Stand Upright : Rebooted", "BloodTheme")

local STXModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local STXClient = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

-- Default Values
local Disc = 7 -- Default Y offset
local Disc3 = 0 -- Default Z offset
local Amount = 1 -- Default buy amount
local PositionChoice = "Middle" -- ตัวเลือกตำแหน่งเริ่มต้น

-- Utility Functions
local function safeCFrameTeleport(part, targetCFrame)
    if not part or not targetCFrame then return end
    part.CFrame = targetCFrame
    part.Velocity = Vector3.new(0, 0, 0)
end

local function fireServerSafe(event, ...)
    if not event then return end
    event:FireServer(...)
end

local function waitForCharacter()
    local maxWaitTime = 5
    local startTime = tick()
    repeat
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return LocalPlayer.Character
        end
        task.wait(0.2)
    until tick() - startTime >= maxWaitTime
    return nil
end

local function waitForCharacterWithRetry(maxRetries, retryDelay)
    local retries = 0
    while retries < maxRetries do
        local char = waitForCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            return char
        end
        retries += 1
        task.wait(retryDelay)
    end
    warn("Failed to find character after " .. maxRetries .. " retries.")
    return nil
end

local function Notify(title, desc)
    STXClient:Notify({Title = title, Description = desc .. " ✅"}, {OutlineColor = Color3.fromRGB(128, 17, 255), Time = 3, Type = "default"})
end

-- Anti-AFK Function
local function antiAFK()
    task.spawn(function()
        while _G.AntiAFK do
            local char = waitForCharacter()
            if char and char:FindFirstChild("HumanoidRootPart") then
                VirtualInputManager:SendKeyEvent(true, "W", false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, "W", false, game)
                task.wait(300)
            else
                task.wait(5)
            end
        end
    end)
end

-- Auto Farm NPC Function (ใช้ Y และ Z เท่านั้น)
local function autoFarmNPC(npcName, questNPC, customPos, conditionFunc)
    local charConnection = nil
    local safePosition = Vector3.new(0, 50, 0) -- ตำแหน่งปลอดภัยเริ่มต้น

    task.spawn(function()
        while (_G.AutoFarm or _G.AutoFarmSpecific) and not _G.AutoFarmBoss do -- ตรวจสอบว่าไม่ทำงานพร้อมกับ Boss Farm
            local char = waitForCharacter()
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                if charConnection then
                    charConnection:Disconnect()
                    charConnection = nil
                end
                task.wait(0.5)
                continue
            end
            local hrp = char.HumanoidRootPart
            local foundTarget = false

            for _, npc in pairs(Workspace.Living:GetChildren()) do
                if npc.Name == npcName and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and (not conditionFunc or conditionFunc()) then
                    foundTarget = true
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                    if not npcHRP then break end

                    fireServerSafe(Workspace.Map.NPCs[questNPC].Done)
                    fireServerSafe(Workspace.Map.NPCs[questNPC].QuestDone)

                    local bodyPosition = hrp:FindFirstChild("AntiGravity") or Instance.new("BodyPosition")
                    bodyPosition.Name = "AntiGravity"
                    bodyPosition.MaxForce = Vector3.new(1000, 1000, 1000)
                    bodyPosition.D = 500
                    bodyPosition.P = 1000
                    bodyPosition.Position = hrp.Position
                    bodyPosition.Parent = hrp

                    local stand = char:FindFirstChild("Stand")
                    local standHRP = stand and stand:FindFirstChild("HumanoidRootPart")

                    charConnection = RunService.Heartbeat:Connect(function()
                        if not (_G.AutoFarm or _G.AutoFarmSpecific) or _G.AutoFarmBoss then
                            if charConnection then
                                charConnection:Disconnect()
                                charConnection = nil
                            end
                            if hrp:FindFirstChild("AntiGravity") then
                                hrp.AntiGravity:Destroy()
                            end
                            return
                        end

                        local targetPosition, targetOrientation
                        if PositionChoice == "Top" then
                            targetPosition = npcHRP.Position + Vector3.new(0, 7 + Disc, Disc3)
                            targetOrientation = CFrame.lookAt(targetPosition, npcHRP.Position)
                        elseif PositionChoice == "Middle" then
                            targetPosition = npcHRP.Position + Vector3.new(0, Disc, Disc3)
                            targetOrientation = CFrame.lookAt(targetPosition, npcHRP.Position)
                        elseif PositionChoice == "Bottom" then
                            targetPosition = npcHRP.Position + Vector3.new(0, -5 + Disc, Disc3)
                            targetOrientation = CFrame.lookAt(targetPosition, npcHRP.Position)
                        end

                        local currentPosition = hrp.Position
                        local distance = (currentPosition - targetPosition).Magnitude
                        if distance > 0.5 then
                            bodyPosition.Position = currentPosition:Lerp(targetPosition, 0.2)
                        else
                            bodyPosition.Position = currentPosition
                        end

                        if (hrp.CFrame.lookVector - targetOrientation.lookVector).Magnitude > 0.1 then
                            local currentOrientation = hrp.CFrame
                            local newOrientation = currentOrientation:Lerp(targetOrientation, 0.2)
                            safeCFrameTeleport(hrp, newOrientation)
                        end

                        if standHRP then
                            local standOffset = targetOrientation * CFrame.new(0, 0, -4)
                            safeCFrameTeleport(standHRP, standOffset)
                        end
                    end)

                    repeat
                        if not char or not char:FindFirstChild("HumanoidRootPart") then break end

                        if char:FindFirstChild("Aura") and not char.Aura.Value then
                            fireServerSafe(char.StandEvents.Summon)
                        end
                        if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                            fireServerSafe(char.StandEvents.M1)
                        end
                        task.wait(0.1)
                    until npc.Humanoid.Health <= 0 or (not _G.AutoFarm and not _G.AutoFarmSpecific)

                    if charConnection then
                        charConnection:Disconnect()
                        charConnection = nil
                    end

                    if hrp:FindFirstChild("AntiGravity") then
                        hrp.AntiGravity:Destroy()
                    end

                    if not (_G.AutoFarm or _G.AutoFarmSpecific) then
                        local safeCFrame = CFrame.new(safePosition) * CFrame.Angles(0, math.rad(0), 0)
                        safeCFrameTeleport(hrp, safeCFrame)
                        if standHRP then
                            safeCFrameTeleport(standHRP, safeCFrame + Vector3.new(0, 0, -2))
                        end
                    end

                    if _G.AutoFarm or _G.AutoFarmSpecific then
                        local resetPosition = hrp.CFrame + Vector3.new(0, 10, 400)
                        safeCFrameTeleport(hrp, resetPosition)
                        if standHRP then
                            safeCFrameTeleport(standHRP, resetPosition + Vector3.new(0, 0, -2))
                        end
                        task.wait(0.5)
                    end
                    break
                end
            end

            if not foundTarget and (_G.AutoFarm or _G.AutoFarmSpecific) then
                local resetPosition = hrp.CFrame + Vector3.new(0, 10, 400)
                safeCFrameTeleport(hrp, resetPosition)
                if standHRP then
                    safeCFrameTeleport(standHRP, resetPosition + Vector3.new(0, 0, -2))
                end
                task.wait(1)
            end
            task.wait(0.6)
        end

        if charConnection then
            charConnection:Disconnect()
            charConnection = nil
        end
        local char = waitForCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("AntiGravity") then
            char.HumanoidRootPart.AntiGravity:Destroy()
        end
    end)
end

-- Boss Farm Function
local function autoFarmBoss(bossName)
    local charConnection = nil
    task.spawn(function()
        while _G.AutoFarmBoss and not (_G.AutoFarm or _G.AutoFarmSpecific) do -- ตรวจสอบว่าไม่ทำงานพร้อมกับ NPC Farm
            local char = waitForCharacterWithRetry(10, 0.5)
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                if charConnection then
                    charConnection:Disconnect()
                    charConnection = nil
                end
                task.wait(0.5)
                continue
            end
            local hrp = char.HumanoidRootPart
            local stand = char:FindFirstChild("Stand")
            local standHRP = stand and stand:FindFirstChild("HumanoidRootPart")
            local boss = Workspace.Living:FindFirstChild(bossName)

            if char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0 then
                Notify("EDU HUB", "Player died! Waiting to respawn and restart farming...")
                if charConnection then
                    charConnection:Disconnect()
                    charConnection = nil
                end
                if hrp:FindFirstChild("AntiGravity") then
                    hrp.AntiGravity:Destroy()
                end
                char:WaitForChild("Humanoid").Died:Wait()
                task.wait(1)
                continue
            end

            if not boss or not boss:FindFirstChild("Humanoid") or boss.Humanoid.Health <= 0 then
                Notify("EDU HUB", "Boss '" .. bossName .. "' not spawned yet! Waiting...")
                if charConnection then
                    charConnection:Disconnect()
                    charConnection = nil
                end
                if hrp:FindFirstChild("AntiGravity") then
                    hrp.AntiGravity:Destroy()
                end
                task.wait(5)
                continue
            end

            local bossHRP = boss:FindFirstChild("HumanoidRootPart")
            if not bossHRP then
                local ragdollConstraints = boss:FindFirstChild("RagdollConstraints")
                if ragdollConstraints and ragdollConstraints:IsA("BasePart") then
                    bossHRP = ragdollConstraints
                else
                    continue
                end
            end

            local bodyPosition = hrp:FindFirstChild("AntiGravity") or Instance.new("BodyPosition")
            bodyPosition.Name = "AntiGravity"
            bodyPosition.MaxForce = Vector3.new(10000, 10000, 10000)
            bodyPosition.D = 500
            bodyPosition.P = 2000
            bodyPosition.Position = hrp.Position
            bodyPosition.Parent = hrp

            if not charConnection then
                charConnection = RunService.Heartbeat:Connect(function()
                    if not _G.AutoFarmBoss or not char or not hrp or not boss or not bossHRP or boss.Humanoid.Health <= 0 then
                        if charConnection then
                            charConnection:Disconnect()
                            charConnection = nil
                        end
                        if hrp:FindFirstChild("AntiGravity") then
                            hrp.AntiGravity:Destroy()
                        end
                        return
                    end

                    local targetPosition = bossHRP.Position + Vector3.new(0, Disc, Disc3)
                    local targetOrientation = CFrame.lookAt(targetPosition, bossHRP.Position)

                    local currentPosition = hrp.Position
                    local distance = (currentPosition - targetPosition).Magnitude
                    if distance > 1 then
                        bodyPosition.Position = currentPosition:Lerp(targetPosition, 0.3)
                    else
                        bodyPosition.Position = targetPosition
                    end

                    if (hrp.CFrame.lookVector - targetOrientation.lookVector).Magnitude > 0.1 then
                        local currentOrientation = hrp.CFrame
                        local newOrientation = currentOrientation:Lerp(targetOrientation, 0.2)
                        safeCFrameTeleport(hrp, newOrientation)
                    end

                    if standHRP then
                        local standOffset = targetOrientation * CFrame.new(0, 0, -4)
                        safeCFrameTeleport(standHRP, standOffset)
                    end
                end)
            end

            if char:FindFirstChild("Aura") and not char.Aura.Value then
                fireServerSafe(char.StandEvents.Summon)
            end
            if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                fireServerSafe(char.StandEvents.M1)
            end

            task.wait(0.1)
            if boss.Humanoid.Health <= 0 then
                if charConnection then
                    charConnection:Disconnect()
                    charConnection = nil
                end
                if hrp:FindFirstChild("AntiGravity") then
                    hrp.AntiGravity:Destroy()
                end

                Notify("EDU HUB", "Boss '" .. bossName .. "' defeated! Collecting drops...")
                task.wait(2)
                for _, v in pairs(Workspace.Vfx:GetDescendants()) do
                    if v.Name == "Handle" and _G.AutoFarmBoss then
                        safeCFrameTeleport(hrp, v.CFrame)
                        task.wait(0.2)
                    elseif v.Name == "ProximityPrompt" and _G.AutoFarmBoss then
                        fireproximityprompt(v, 20)
                        task.wait(0.2)
                    end
                end

                if _G.AutoFarmBoss then
                    local resetPosition = CFrame.new(hrp.Position + Vector3.new(0, 10, 400))
                    safeCFrameTeleport(hrp, resetPosition)
                    if standHRP then
                        safeCFrameTeleport(standHRP, resetPosition * CFrame.new(0, 0, -2))
                    end
                    task.wait(1)
                end
            end
            task.wait(0.3)
        end

        if charConnection then
            charConnection:Disconnect()
            charConnection = nil
        end
        local char = waitForCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("AntiGravity") then
            char.HumanoidRootPart.AntiGravity:Destroy()
        end
    end)
end

-- Farm Tab
local FarmTab = Window:NewTab("Farm")
local FarmSection = FarmTab:NewSection("Farm Level to Auto Quests")

FarmSection:NewSlider("Set Y Value", "Adjust Y offset (-30 to 30)", -30, 30, function(value)
    Disc = value
end, {Default = 2, Step = 1})

FarmSection:NewSlider("Set Z Value", "Adjust Z offset (-30 to 30)", -30, 30, function(value)
    Disc3 = value
end, {Default = 7, Step = 1})

local SkillSection = FarmTab:NewSection("Auto Use Skill")
SkillSection:NewToggle("Use All Skills", "Auto-use all applicable skills", function(state)
    _G.AutoSkill = state
    task.spawn(function()
        while _G.AutoSkill do
            local char = waitForCharacter()
            if char and char:FindFirstChild("Aura") and not char.Aura.Value then
                fireServerSafe(char.StandEvents.Summon)
            end
            for _, event in pairs(char and char.StandEvents:GetChildren() or {}) do
                if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                    fireServerSafe(event, true)
                end
            end
            task.wait(0.1)
        end
    end)
end)

local SkillChoiceSection = FarmTab:NewSection("Use Skill Choice")
local SkillList = {"E", "R", "T", "Y", "F", "H", "J", "Z", "X", "W"}
SkillChoiceSection:NewDropdown("Skill Choice", "Select a skill to spam", SkillList, function(sk) Chsk = sk end)
SkillChoiceSection:NewToggle("Start Using Skill", "Toggle selected skill", function(state)
    _G.Asd = state
    task.spawn(function()
        while _G.Asd and Chsk do
            VirtualInputManager:SendKeyEvent(true, Chsk, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Chsk, false, game)
        end
    end)
end)

local FarmLevelSection = FarmTab:NewSection("Farm Level All")
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

local isFarming = false
FarmLevelSection:NewToggle("Auto Farm Level All", "Farm based on level", function(state)
    _G.AutoFarm = state
    if _G.AutoFarmBoss then
        Notify("EDU HUB", "Please disable Boss Farm before starting NPC Farm!")
        _G.AutoFarm = false
        return
    end
    if isFarming then return end
    isFarming = true
    task.spawn(function()
        while _G.AutoFarm do
            local char = waitForCharacter()
            if not char or not LocalPlayer.Data or not LocalPlayer.Data.Level then
                task.wait(0.5)
                continue
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
                autoFarmNPC(matchedSetting[1], matchedSetting[2], {Disc, Disc3}, function()
                    return _G.AutoFarm
                end)
            else
                task.wait(1)
            end
            task.wait(0.6)
        end
        isFarming = false
    end)
end)

local SelectFarmSection = FarmTab:NewSection("Auto Farm Specific Level")
local MonList = {
    "Bad Gi [Lvl. 1+]", "Scary Monster [Lvl. 10+]", "Giorno Giovanna [Lvl. 20+]", "Rker Dummy [Lvl. 30+]",
    "Yoshikage Kira [Lvl. 40+]", "Dio Over Heaven [Lvl. 50+]", "Angelo [Lvl. 75+]", "Alien [Lvl. 100+]",
    "Jotaro Part 4 [Lvl. 125+]", "Kakyoin [Lvl. 150+]", "Sewer Vampire [Lvl. 200+]", "Pillerman [Lvl. 275+]"
}
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

SelectFarmSection:NewDropdown("Select Farm Level", "Choose an NPC to farm", MonList, function(npc)
    Monkill = npc
end)
SelectFarmSection:NewToggle("Start Farm Level", "Start farming selected NPC", function(state)
    _G.AutoFarmSpecific = state
    if _G.AutoFarmBoss then
        Notify("EDU HUB", "Please disable Boss Farm before starting Specific NPC Farm!")
        _G.AutoFarmSpecific = false
        return
    end
    if not Monkill or not MonSettings[Monkill] then
        _G.AutoFarmSpecific = false
        return
    end
    task.spawn(function()
        while _G.AutoFarmSpecific do
            local char = waitForCharacter()
            autoFarmNPC(MonSettings[Monkill][1], MonSettings[Monkill][2], {Disc, Disc3}, function()
                return _G.AutoFarmSpecific
            end)
            task.wait(0.6)
        end
    end)
end)

local DungeonSection = FarmTab:NewSection("Auto Farm Dungeon")
local DunLvl = {
    "Dungeon [Lvl.15+]", "Dungeon [Lvl.40+]", "Dungeon [Lvl.80+]", "Dungeon [Lvl.100+]", "Dungeon [Lvl.200+]"
}
local dungeonSettings = {
    ["Dungeon [Lvl.15+]"] = {"i_stabman [Lvl. 15+]", "Bad Gi Boss"},
    ["Dungeon [Lvl.40+]"] = {"i_stabman [Lvl. 40+]", "Dio [Dungeon]"},
    ["Dungeon [Lvl.80+]"] = {"i_stabman [Lvl. 80+]", "Homeless Lord"},
    ["Dungeon [Lvl.100+]"] = {"i_stabman [Lvl. 100+]", "Diavolo [Dungeon]"},
    ["Dungeon [Lvl.200+]"] = {"i_stabman [Lvl. 200+]", "Jotaro P6 [Dungeon]"}
}

DungeonSection:NewDropdown("Choose Dungeon", "Select a dungeon", DunLvl, function(AuDun)
    STXClient:Notify({
        Title = "Press Start Farm Dungeon✅",
        Description = "Saving the Dungeon please wait......✅"
    }, {
        OutlineColor = Color3.fromRGB(128, 17, 255),
        Time = 2,
        Type = "default"
    })
    task.wait(0.2)
    ChDun = AuDun
end)

DungeonSection:NewToggle("Start Farm Dungeon", "Toggle dungeon farming", function(state)
    _G.AutoFarmDungeon = state
    if _G.AutoFarmBoss or _G.AutoFarm or _G.AutoFarmSpecific then
        Notify("EDU HUB", "Please disable other farming modes before starting Dungeon Farm!")
        _G.AutoFarmDungeon = false
        return
    end
    if not ChDun or not dungeonSettings[ChDun] then
        _G.AutoFarmDungeon = false
        warn("No dungeon selected or invalid dungeon settings!")
        return
    end

    task.spawn(function()
        while _G.AutoFarmDungeon do
            local char = waitForCharacter()
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                task.wait(0.5)
                continue
            end
            local hrp = char:WaitForChild("HumanoidRootPart")
            local stand = char:FindFirstChild("Stand")
            local standHRP = stand and stand:WaitForChild("HumanoidRootPart")
            local foundBoss = false

            pcall(function()
                for _, npc in pairs(Workspace.Map.NPCs:GetDescendants()) do
                    if npc.Name:find("i_stabman") and npc:FindFirstChild("Head") and npc.Head:FindFirstChild("Main") and npc.Head.Main:FindFirstChild("Text") then
                        if npc.Head.Main.Text.Text == dungeonSettings[ChDun][1] then
                            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                            if npcHRP and (hrp.Position - npcHRP.Position).Magnitude > 5 then
                                safeCFrameTeleport(hrp, npcHRP.CFrame + Vector3.new(0, 3, 5))
                                if standHRP then
                                    safeCFrameTeleport(standHRP, hrp.CFrame + Vector3.new(0, 0, -2))
                                end
                            end
                            fireServerSafe(npc:FindFirstChild("Done"))
                            task.wait(0.5)
                        end
                    end
                end
            end)

            pcall(function()
                for _, boss in pairs(Workspace.Living:GetChildren()) do
                    if boss.Name == "Boss" and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("Head") and boss.Head:FindFirstChild("Display") and boss.Head.Display:FindFirstChild("Frame") and boss.Head.Display.Frame:FindFirstChild("t") then
                        if boss.Head.Display.Frame.t.Text == dungeonSettings[ChDun][2] then
                            foundBoss = true
                            local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                            if not bossHRP then break end

                            repeat
                                task.wait(0.1)
                                pcall(function()
                                    if char:FindFirstChild("Aura") and not char.Aura.Value then
                                        fireServerSafe(char.StandEvents.Summon)
                                    end
                                    if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                                        fireServerSafe(char.StandEvents.M1)
                                    end
                                    hrp.Velocity = Vector3.new(0, 0, 0)
                                    if _G.AutoFarmDungeon then
                                        safeCFrameTeleport(hrp, bossHRP.CFrame * CFrame.new(0, Disc, Disc3))
                                        if standHRP then
                                            safeCFrameTeleport(standHRP, bossHRP.CFrame * CFrame.new(0, Disc, Disc3 - 4))
                                        end
                                    else
                                        safeCFrameTeleport(hrp, CFrame.new(0, 50, 0))
                                        if standHRP then
                                            safeCFrameTeleport(standHRP, CFrame.new(0, 50, -2))
                                        end
                                    end
                                end)
                            until boss.Humanoid.Health <= 0 or not _G.AutoFarmDungeon

                            if _G.AutoFarmDungeon then
                                safeCFrameTeleport(hrp, hrp.CFrame + Vector3.new(0, 10, 1000))
                                if standHRP then
                                    safeCFrameTeleport(standHRP, hrp.CFrame + Vector3.new(0, 0, -2))
                                end
                                task.wait(0.5)
                            end
                            break
                        end
                    end
                end
            end)

            if not foundBoss then
                safeCFrameTeleport(hrp, hrp.CFrame + Vector3.new(0, 10, 1000))
                if standHRP then
                    safeCFrameTeleport(standHRP, hrp.CFrame + Vector3.new(0, 0, -2))
                end
                task.wait(1)
            end
            task.wait(0.6)
        end
    end)
end)

-- Auto Buy Item Tab
local BuyTab = Window:NewTab("Auto Buy Item")
local BuySection = BuyTab:NewSection("Stand near NPC and set amount before buying")
BuySection:NewButton("Teleport to Shop", "Warp to shop location", function()
    local char = waitForCharacter()
    if char then
        safeCFrameTeleport(char.HumanoidRootPart, CFrame.new(11927.1, -3.28935, -4488.59))
        if char:FindFirstChild("Stand") then
            safeCFrameTeleport(char.Stand.HumanoidRootPart, char.HumanoidRootPart.CFrame)
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
            fireServerSafe(ReplicatedStorage.Events.BuyItem, item[2], item[3])
            task.wait(0.2)
        end
    end)
end

-- Stand Farm Tab
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
    Notify("EDU HUB", "Farm set to Use Stand Arrow")
    task.wait(1.5)
end)
ItemSection:NewButton("Use Charged Arrows", "Set to Charged Arrow", function()
    ArrowToUse = "Charged Arrow"
    Notify("EDU HUB", "Farm set to Use Charged Arrow")
    task.wait(1.5)
end)
ItemSection:NewButton("Use Kars Mask", "Set to Kars Mask", function()
    ArrowToUse = "Kars Mask"
    Notify("EDU HUB", "Farm set to Use Kars Mask")
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
    local PlayerStand = LocalPlayer.PlayerGui.PlayerGUI.ingame.Stats.StandName:FindFirstChild("Name_") and LocalPlayer.PlayerGui.PlayerGUI.ingame.Stats.StandName.Name_.TextLabel.Text or "None"
    local PlayerAttri = LocalPlayer.Data.Attri.Value
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
            Notify("EDU HUB", "Error: No " .. ArrowToUse .. " in Backpack!")
            getgenv().BeginFarm = false
            return
        end
        char.Humanoid:EquipTool(arrow)
        task.wait(0.2)
        if char:FindFirstChild(ArrowToUse) then
            char[ArrowToUse]:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            Notify("EDU HUB", "Using " .. ArrowToUse)
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value ~= "None" or not getgenv().BeginFarm
        end
    elseif CheckInfo() then
        local stored = false
        for i = 1, 2 do
            if LocalPlayer.Data["Slot" .. i .. "Stand"].Value == "None" then
                Notify("EDU HUB", "Storing " .. stand .. " to Slot " .. i)
                fireServerSafe(ReplicatedStorage.Events.SwitchStand, "Slot" .. i)
                repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not getgenv().BeginFarm
                Notify("EDU HUB", "Stored " .. stand .. " Successfully")
                stored = true
                break
            end
        end
        if not stored then
            Notify("EDU HUB", "Storage Full: No empty slots available!")
            getgenv().BeginFarm = false
        end
    else
        local rokakaka = LocalPlayer.Backpack:FindFirstChild("Rokakaka")
        if not rokakaka then
            Notify("EDU HUB", "Error: No Rokakaka in Backpack!")
            getgenv().BeginFarm = false
            return
        end
        char.Humanoid:EquipTool(rokakaka)
        task.wait(0.2)
        if char:FindFirstChild("Rokakaka") then
            char.Rokakaka:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            Notify("EDU HUB", "Using Rokakaka to reset Stand")
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not getgenv().BeginFarm
        end
    end
end

StartFarmSection:NewToggle("Start Stand Farm", "Toggle Stand Farm", function()
    getgenv().BeginFarm = not getgenv().BeginFarm
    if getgenv().BeginFarm then
        if not CheckStand and not CheckAttri then
            Notify("EDU HUB", "Please enable Stand Check or Attribute Check!")
            getgenv().BeginFarm = false
            return
        end
        if #Whitelisted == 0 and CheckStand then
            Notify("EDU HUB", "No Stands selected in Whitelist!")
            getgenv().BeginFarm = false
            return
        end
        if #WhitelistedAttributes == 0 and CheckAttri then
            Notify("EDU HUB", "No Attributes selected in Whitelist!")
            getgenv().BeginFarm = false
            return
        end
        Notify("EDU HUB", "Stand Farm Started")
        task.spawn(function()
            while getgenv().BeginFarm do
                CycleStand()
                task.wait(0.5)
            end
            Notify("EDU HUB", "Stand Farm Stopped")
        end)
    end
end)

-- Item Farm Tab
local ItemTab = Window:NewTab("Item Farm")
local ItemSection = ItemTab:NewSection("Auto Farm Items")
ItemSection:NewToggle("Farm Items", "Collect nearby items", function(state)
    _G.On = state
    task.spawn(function()
        while _G.On do
            for _, v in pairs(Workspace.Vfx:GetDescendants()) do
                if v.Name == "Handle" then
                    safeCFrameTeleport(LocalPlayer.Character.HumanoidRootPart, v.CFrame)
                elseif v.Name == "ProximityPrompt" then
                    fireproximityprompt(v, 20)
                end
            end
            task.wait(0.2)
        end
    end)
end)

-- Performance Tab
local PerformanceTab = Window:NewTab("Performance")
local PerformanceSection = PerformanceTab:NewSection("Optimize FPS")
PerformanceSection:NewToggle("Low Graphics Mode", "Reduce graphics load to boost FPS", function(state)
    _G.LowGraphics = state
    if _G.LowGraphics then
        pcall(function()
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").FogEnd = 100000
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Part") or v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    v.CastShadow = false
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
            Notify("EDU HUB", "Low Graphics Mode Enabled - FPS Boosted")
        end)
    else
        pcall(function()
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").FogEnd = 1000
            Notify("EDU HUB", "Low Graphics Mode Disabled")
        end)
    end
end)

-- Settings Tab
local KeybindTab = Window:NewTab("Settings")
local KeybindSection = KeybindTab:NewSection("Keybind")
KeybindSection:NewKeybind("Toggle UI", "Show/hide GUI", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)

local AntiAFKSection = KeybindTab:NewSection("Anti-AFK")
AntiAFKSection:NewToggle("Enable Anti-AFK", "Prevent AFK kick by simulating movement", function(state)
    _G.AntiAFK = state
    if _G.AntiAFK then
        Notify("EDU HUB", "Anti-AFK Enabled")
        antiAFK()
    else
        Notify("EDU HUB", "Anti-AFK Disabled")
    end
end)

-- Boss Farm Tab
local BossTab = Window:NewTab("Boss Farm")
local BossSection = BossTab:NewSection("Auto Farm Bosses")
BossSection:NewSlider("Set Y Value", "Adjust Y offset (-30 to 30)", -30, 30, function(value)
    Disc = value
end, {Default = 7, Step = 1})

BossSection:NewSlider("Set Z Value", "Adjust Z offset (-30 to 30)", -30, 30, function(value)
    Disc3 = value
end, {Default = 0, Step = 1})

BossSection:NewButton("Fix Alternate Jotaro Part 4", "", function()
    local char = waitForCharacter()
    if char then
        safeCFrameTeleport(char.HumanoidRootPart, CFrame.new(11927.1, -3.28935, -4488.59))
        if char:FindFirstChild("Stand") then
            safeCFrameTeleport(char.Stand.HumanoidRootPart, char.HumanoidRootPart.CFrame)
        end
    end
end)

local SkillSection = BossTab:NewSection("Auto Use Skills")
_G.AutoSkillBossAll = false
SkillSection:NewToggle("Auto Use All Skills", "Toggle auto-use all applicable skills while farming boss", function(state)
    _G.AutoSkillBossAll = state
    if _G.AutoSkillBossAll then
        Notify("EDU HUB", "Auto Use All Skills for Boss Farming Started")
        task.spawn(function()
            while _G.AutoSkillBossAll and _G.AutoFarmBoss do
                local char = waitForCharacterWithRetry(10, 0.5)
                if char and char:FindFirstChild("StandEvents") then
                    if char:FindFirstChild("Aura") and not char.Aura.Value then
                        fireServerSafe(char.StandEvents.Summon)
                    end
                    for _, event in pairs(char.StandEvents:GetChildren()) do
                        if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                            fireServerSafe(event, true)
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.2)
            end
            Notify("EDU HUB", "Auto Use All Skills for Boss Farming Stopped")
        end)
    else
        Notify("EDU HUB", "Auto Use All Skills for Boss Farming Disabled")
    end
end)

local bossList = {
    "Jotaro Over Heaven", "Alternate Jotaro Part 4", "JohnnyJoestar", "Giorno Giovanna Requiem"
}
local selectedBoss = nil
BossSection:NewDropdown("Select Boss", "Choose a boss to farm", bossList, function(boss)
    selectedBoss = boss
end)

BossSection:NewToggle("Start Boss Farm", "Toggle boss farming", function(state)
    _G.AutoFarmBoss = state
    if _G.AutoFarm or _G.AutoFarmSpecific or _G.AutoFarmDungeon then
        Notify("EDU HUB", "Please disable other farming modes before starting Boss Farm!")
        _G.AutoFarmBoss = false
        return
    end
    if not selectedBoss then
        Notify("EDU HUB", "Please select a boss first!")
        _G.AutoFarmBoss = false
        return
    end
    if _G.AutoFarmBoss then
        Notify("EDU HUB", "Started farming '" .. selectedBoss .. "'")
        autoFarmBoss(selectedBoss)
    else
        Notify("EDU HUB", "Stopped farming '" .. selectedBoss .. "'")
        if charConnection then
            charConnection:Disconnect()
            charConnection = nil
        end
        local char = waitForCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart:FindFirstChild("AntiGravity") then
            char.HumanoidRootPart.AntiGravity:Destroy()
        end
    end
end)
