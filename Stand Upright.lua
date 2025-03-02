-- Global Toggle
getgenv().BeginFarm = false

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

-- Default Values
local Disc = 2 -- Default Y offset
local Disc3 = 7 -- Default Z offset
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
    task.spawn(function()
        while _G.AutoFarm or _G.AutoFarmSpecific do
            local char = waitForCharacter()
            if not char or not char:FindFirstChild("HumanoidRootPart") then 
                task.wait(0.5)
                continue 
            end
            local hrp = char.HumanoidRootPart
            local foundTarget = false

            -- ลูปหามอนสเตอร์ใหม่
            for _, npc in pairs(Workspace.Living:GetChildren()) do
                if npc.Name == npcName and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and (not conditionFunc or conditionFunc()) then
                    foundTarget = true
                    local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                    if not npcHRP then break end

                    fireServerSafe(Workspace.Map.NPCs[questNPC].Done)
                    fireServerSafe(Workspace.Map.NPCs[questNPC].QuestDone)

                    -- ใช้ BodyPosition กับ Damping เพื่อลดการสั่น
                    local bodyPosition = hrp:FindFirstChild("AntiGravity") or Instance.new("BodyPosition")
                    bodyPosition.Name = "AntiGravity"
                    bodyPosition.MaxForce = Vector3.new(3000, 3000, 3000) -- ลด MaxForce เพื่อลดการสั่น
                    bodyPosition.D = 150 -- เพิ่ม Damping เพื่อนิ่งขึ้น
                    bodyPosition.Position = hrp.Position
                    bodyPosition.Parent = hrp

                    -- หา Stand ของผู้เล่น (ถ้ามี)
                    local stand = char:FindFirstChild("Stand")
                    local standHRP = stand and stand:FindFirstChild("HumanoidRootPart")

                    -- ตัวแปรเก็บตำแหน่งและทิศทางล่าสุด
                    local lastPosition, lastOrientation = hrp.Position, hrp.CFrame

                    -- ใช้ RenderStepped เพื่ออัปเดตทิศทางและตำแหน่งอย่างลื่นไหล
                    charConnection = RunService.RenderStepped:Connect(function()
                        local targetPosition, targetOrientation
                        if PositionChoice == "Top" then
                            -- เหนือหัวมอน (ใช้ค่าเสถียร +7)
                            targetPosition = npcHRP.Position + Vector3.new(0, 7 + Disc, Disc3)
                            targetOrientation = CFrame.lookAt(targetPosition, npcHRP.Position) -- หันหน้าลงไปหามอน
                        elseif PositionChoice == "Middle" then
                            -- ตรงกลางมอน (ระดับ HumanoidRootPart)
                            targetPosition = npcHRP.Position + Vector3.new(0, Disc, Disc3)
                            targetOrientation = CFrame.lookAt(targetPosition, npcHRP.Position) -- หันหน้าไปหามอน
                        elseif PositionChoice == "Bottom" then
                            -- ใต้ตีนมอน (ใช้ค่าเสถียร -5)
                            targetPosition = npcHRP.Position + Vector3.new(0, -5 + Disc, Disc3)
                            targetOrientation = CFrame.lookAt(targetPosition, npcHRP.Position) -- หันหน้าขขึ้นไปหามอน
                        end

                        -- อัปเดตตำแหน่งผู้เล่นอย่างนิ่มนวล
                        local distance = (hrp.Position - targetPosition).Magnitude
                        if distance > 0.5 then
                            bodyPosition.Position = targetPosition
                        else
                            bodyPosition.Position = hrp.Position -- หยุดเคลื่อนเมื่อใกล้พอ
                        end

                        -- อัปเดตทิศทางผู้เล่นและ Stand อย่างลื่นไหล
                        if (hrp.CFrame.lookVector - targetOrientation.lookVector).Magnitude > 0.1 then
                            safeCFrameTeleport(hrp, targetOrientation)
                            -- หัน Stand ตามทิศทางของผู้เล่น
                            if standHRP then
                                safeCFrameTeleport(standHRP, targetOrientation)
                            end
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
                        task.wait(0.1) -- ลดเป็น 0.1 เพื่อตรวจสอบสถานะมอนบ่อยขึ้น
                    until npc.Humanoid.Health <= 0 or (not _G.AutoFarm and not _G.AutoFarmSpecific)

                    if charConnection then
                        charConnection:Disconnect() -- หยุดการอัปเดต RenderStepped
                    end

                    if hrp:FindFirstChild("AntiGravity") then
                        hrp.AntiGravity:Destroy() -- ทำลาย BodyPosition ทันที
                    end

                    -- วาร์ปตัวผู้เล่นกลับสู่พื้นหลังหยุดฟาร์ม
                    if not (_G.AutoFarm or _G.AutoFarmSpecific) then
                        local groundPosition = hrp.Position - Vector3.new(0, hrp.Position.Y - 5, 0) -- วาร์ปลงพื้น (ลด Y ลง 5 หน่วย)
                        safeCFrameTeleport(hrp, CFrame.new(groundPosition))
                        if standHRP then
                            safeCFrameTeleport(standHRP, CFrame.new(groundPosition)) -- วาร์ป Stand ลงพื้นด้วย
                        end
                    end

                    -- วาร์ปไปมอนตัวใหม่ทันทีหลังฆ่ามอนเสร็จ
                    if _G.AutoFarm or _G.AutoFarmSpecific then
                        safeCFrameTeleport(hrp, hrp.CFrame + Vector3.new(0, 10, 1000)) -- วาร์ปขึ้นสูงชั่วครู่
                        task.wait(0.5) -- รอให้เซิร์ฟเวอร์อัปเดต
                    end
                    break
                end
            end

            -- ถ้าไม่พบมอนตัวใหม่ รอและลองใหม่
            if not foundTarget and (_G.AutoFarm or _G.AutoFarmSpecific) then
                task.wait(1) -- รอ 1 วินาทีเพื่อให้มอนตัวใหม่ spawn
                safeCFrameTeleport(hrp, hrp.CFrame + Vector3.new(0, 10, 1000)) -- วาร์ปขึ้นสูงเพื่อหามอนตัวใหม่
            end
            task.wait(0.6) -- รักษาความถี่ 0.6 นอกลูป
        end
    end)
end

-- Farm Tab
local FarmTab = Window:NewTab("Farm")
local FarmSection = FarmTab:NewSection("Farm Level to Auto Quests")

-- เพิ่มตัวเลือกตำแหน่ง (ใช้ Y และ Z ด้วย TextBox)
FarmSection:NewDropdown("Farm Position", "Choose farming position", {"Top", "Middle", "Bottom"}, function(choice)
    PositionChoice = choice
end)

FarmSection:NewTextBox("Set Y Value", "Enter Y offset (-30 to 30)", function(value)
    local num = tonumber(value)
    if num and num >= -30 and num <= 30 then
        Disc = num
    else
        Disc = 2 -- ค่าเริ่มต้นถ้าป้อนไม่ถูกต้อง
    end
end)

FarmSection:NewTextBox("Set Z Value", "Enter Z offset (-30 to 30)", function(value)
    local num = tonumber(value)
    if num and num >= -30 and num <= 30 then
        Disc3 = num
    else
        Disc3 = 7 -- ค่าเริ่มต้นถ้าป้อนไม่ถูกต้อง
    end
end)

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
local farmSettings = {
    {levelRange = {1, 10}, npcName = "Bad Gi", questNPC = "Giorno"},
    {levelRange = {10, 20}, npcName = "Scary Monster", questNPC = "Scared Noob"},
    {levelRange = {21, 30}, npcName = "Giorno Giovanna", questNPC = "Koichi"},
    {levelRange = {31, 40}, npcName = "Rker Dummy", questNPC = "aLLmemester"},
    {levelRange = {41, 50}, npcName = "Yoshikage Kira", questNPC = "Okayasu"},
    {levelRange = {51, 60}, npcName = "Dio Over Heaven", questNPC = "Joseph Joestar"},
    {levelRange = {61, 100}, npcName = "Angelo", questNPC = "Josuke"},
    {levelRange = {101, 125}, npcName = "Alien", questNPC = "Rohan"},
    {levelRange = {126, 150}, npcName = "Jotaro Part 4", questNPC = "DIO"},
    {levelRange = {151, 200}, npcName = "Kakyoin", questNPC = "Giorno"},
    {levelRange = {201, 275}, npcName = "Sewer Vampire", questNPC = "Giorno"},
    {levelRange = {276, math.huge}, npcName = "Pillerman", questNPC = "Young Joseph"}
}

local isFarming = false
FarmLevelSection:NewToggle("Auto Farm Level All", "Farm based on level", function(state)
    _G.AutoFarm = state
    if isFarming then return end
    isFarming = true
    task.spawn(function()
        while _G.AutoFarm do
            local char = waitForCharacter()
            local level = LocalPlayer.Data.Level.Value or 1
            for _, setting in ipairs(farmSettings) do
                if level >= setting.levelRange[1] and level <= setting.levelRange[2] then
                    autoFarmNPC(setting.npcName, setting.questNPC, {Disc2, Disc, Disc3})
                    break
                end
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
    ["Kakyoin [Lvl. 150+]"] = {"Kakyoin", "Giorno"},
    ["Sewer Vampire [Lvl. 200+]"] = {"Sewer Vampire", "Giorno"},
    ["Pillerman [Lvl. 275+]"] = {"Pillerman", "Young Joseph"}
}

SelectFarmSection:NewDropdown("Select Farm Level", "Choose an NPC to farm", MonList, function(npc)
    Monkill = npc
end)
SelectFarmSection:NewToggle("Start Farm Level", "Start farming selected NPC", function(state)
    _G.AutoFarmSpecific = state
    if not Monkill or not MonSettings[Monkill] then
        _G.AutoFarmSpecific = false
        return
    end
    task.spawn(function()
        while _G.AutoFarmSpecific do
            local char = waitForCharacter()
            autoFarmNPC(MonSettings[Monkill][1], MonSettings[Monkill][2], {Disc2, Disc, Disc3})
            task.wait(0.6)
        end
    end)
end)

local DungeonSection = FarmTab:NewSection("Auto Farm Dungeon")
local DunLvl = {"Dungeon [Lvl.15+]", "Dungeon [Lvl.40+]", "Dungeon [Lvl.80+]", "Dungeon [Lvl.100+]", "Dungeon [Lvl.200+]"}

DungeonSection:NewDropdown("Choose Dungeon", "Select a dungeon", DunLvl, function(dun)
    ChDun = dun
end)

local dungeonSettings = {
    ["Dungeon [Lvl.15+]"] = {"i_stabman [Lvl. 15+]", "Bad Gi Boss"},
    ["Dungeon [Lvl.40+]"] = {"i_stabman [Lvl. 40+]", "Dio [Dungeon]"},
    ["Dungeon [Lvl.80+]"] = {"i_stabman [Lvl. 80+]", "Homeless Lord"},
    ["Dungeon [Lvl.100+]"] = {"i_stabman [Lvl. 100+]", "Diavolo [Dungeon]"},
    ["Dungeon [Lvl.200+]"] = {"i_stabman [Lvl. 200+]", "Jotaro P6 [Dungeon]"}
}

DungeonSection:NewToggle("Start Farm Dungeon", "Toggle dungeon farming", function(state)
    _G.AutoFarmDungeon = state
    if not ChDun or not dungeonSettings[ChDun] then return end
    task.spawn(function()
        while _G.AutoFarmDungeon do
            local char = waitForCharacter()
            if not char then continue end
            local hrp = char.HumanoidRootPart
            for _, npc in pairs(Workspace.Map.NPCs:GetDescendants()) do
                if npc.Name:find("i_stabman") and npc:FindFirstChild("Head") and npc.Head.Main.Text.Text == dungeonSettings[ChDun][1] then
                    fireServerSafe(npc:FindFirstChild("Done"))
                end
            end
            for _, boss in pairs(Workspace.Living:GetChildren()) do
                if boss.Name == "Boss" and boss.Humanoid.Health > 0 and boss.Head.Display.Frame.t.Text == dungeonSettings[ChDun][2] then
                    repeat
                        local targetCFrame = boss.HumanoidRootPart.CFrame * CFrame.new(Disc2, Disc, Disc3)
                        if (hrp.Position - targetCFrame.Position).Magnitude > 1 then
                            safeCFrameTeleport(hrp, targetCFrame)
                        end
                        if not char.Aura.Value then
                            fireServerSafe(char.StandEvents.Summon)
                        end
                        if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                            fireServerSafe(char.StandEvents.M1)
                        end
                        task.wait(0.1)
                    until boss.Humanoid.Health <= 0 or not _G.AutoFarmDungeon
                    if _G.AutoFarmDungeon then
                        safeCFrameTeleport(hrp, hrp.CFrame + Vector3.new(0, 10, 1000))
                    end
                    break
                end
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

local STXModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
local STXClient = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()

local ItemSection = StandTab:NewSection("Use Item Farm Stand")
local ArrowToUse = "Stand Arrow"
ItemSection:NewButton("Use Stand Arrows", "Set to Stand Arrow", function()
    ArrowToUse = "Stand Arrow"
    STXClient:Notify({Title="EDU HUB", Description="Farm set to Use Stand Arrow ✅"}, {OutlineColor=Color3.fromRGB(128,17,255), Time=3, Type="default"})
    task.wait(1.5)
end)
ItemSection:NewButton("Use Charged Arrows", "Set to Charged Arrow", function()
    ArrowToUse = "Charged Arrow"
    STXClient:Notify({Title="EDU HUB", Description="Farm set to Use Charged Arrow ✅"}, {OutlineColor=Color3.fromRGB(128,17,255), Time=3, Type="default"})
    task.wait(1.5)
end)
ItemSection:NewButton("Use Kars Mask", "Set to Kars Mask", function()
    ArrowToUse = "Kars Mask"
    STXClient:Notify({Title="EDU HUB", Description="Farm set to Use Kars Mask ✅"}, {OutlineColor=Color3.fromRGB(128,17,255), Time=3, Type="default"})
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

local function Notify(title, desc)
    STXClient:Notify({Title = title, Description = desc .. " ✅"}, {OutlineColor = Color3.fromRGB(128, 17, 255), Time = 3, Type = "default"})
end

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
            BeginFarm = false
            return 
        end
        char.Humanoid:EquipTool(arrow)
        task.wait(0.2)
        if char:FindFirstChild(ArrowToUse) then
            char[ArrowToUse]:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            Notify("EDU HUB", "Using " .. ArrowToUse)
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value ~= "None" or not BeginFarm
        end
    elseif CheckInfo() then
        local stored = false
        for i = 1, 2 do
            if LocalPlayer.Data["Slot" .. i .. "Stand"].Value == "None" then
                Notify("EDU HUB", "Storing " .. stand .. " to Slot " .. i)
                fireServerSafe(ReplicatedStorage.Events.SwitchStand, "Slot" .. i)
                repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not BeginFarm
                Notify("EDU HUB", "Stored " .. stand .. " Successfully")
                stored = true
                break
            end
        end
        if not stored then
            Notify("EDU HUB", "Storage Full: No empty slots available!")
            BeginFarm = false
        end
    else
        local rokakaka = LocalPlayer.Backpack:FindFirstChild("Rokakaka")
        if not rokakaka then 
            Notify("EDU HUB", "Error: No Rokakaka in Backpack!")
            BeginFarm = false
            return 
        end
        char.Humanoid:EquipTool(rokakaka)
        task.wait(0.2)
        if char:FindFirstChild("Rokakaka") then
            char.Rokakaka:Activate()
            fireServerSafe(ReplicatedStorage.Events.UseItem)
            Notify("EDU HUB", "Using Rokakaka to reset Stand")
            repeat task.wait(0.5) until LocalPlayer.Data.Stand.Value == "None" or not BeginFarm
        end
    end
end

StartFarmSection:NewToggle("Start Stand Farm", "Toggle Stand Farm", function()
    BeginFarm = not BeginFarm
    if BeginFarm then
        if not CheckStand and not CheckAttri then
            Notify("EDU HUB", "Please enable Stand Check or Attribute Check!")
            BeginFarm = false
            return
        end
        if #Whitelisted == 0 and CheckStand then
            Notify("EDU HUB", "No Stands selected in Whitelist!")
            BeginFarm = false
            return
        end
        if #WhitelistedAttributes == 0 and CheckAttri then
            Notify("EDU HUB", "No Attributes selected in Whitelist!")
            BeginFarm = false
            return
        end
        Notify("EDU HUB", "Stand Farm Started")
        task.spawn(function()
            while BeginFarm do
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

-- Combat Enhancements Tab
local CombatTab = Window:NewTab("Combat Enhancements")
local CombatSection = CombatTab:NewSection("Enhance Your Combat")

CombatSection:NewToggle("Fast Attack", "Reduce attack and skill cooldowns", function(state)
    _G.FastAttack = state
    task.spawn(function()
        while _G.FastAttack do
            local char = waitForCharacter()
            if char then
                if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                    fireServerSafe(char.StandEvents.M1)
                end
                for _, event in pairs(char.StandEvents:GetChildren()) do
                    if not table.find({"Block", "Quote", "Pose", "Summon", "Heal", "Jump", "TogglePilot"}, event.Name) then
                        fireServerSafe(event, true)
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

local KillAuraRange = 10
CombatSection:NewToggle("Kill Aura", "Auto-kill enemies in range", function(state)
    _G.KillAura = state
    task.spawn(function()
        while _G.KillAura do
            local char = waitForCharacter()
            if not char or not char:FindFirstChild("HumanoidRootPart") then 
                task.wait(0.5)
                continue 
            end
            local hrp = char.HumanoidRootPart

            for _, npc in pairs(Workspace.Living:GetChildren()) do
                if npc ~= char and npc.ClassName == "Model" and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 and npc:FindFirstChild("HumanoidRootPart") then
                    local distance = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
                    if distance <= KillAuraRange then
                        if char:FindFirstChild("Aura") and not char.Aura.Value then
                            fireServerSafe(char.StandEvents.Summon)
                        end
                        if not LocalPlayer.PlayerGui.CDgui.fortnite:FindFirstChild("Punch") then
                            fireServerSafe(char.StandEvents.M1)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

CombatSection:NewSlider("Kill Aura Range", "Set range for Kill Aura", 5, 50, function(range)
    KillAuraRange = range
end, {Default = 10, Step = 1})

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