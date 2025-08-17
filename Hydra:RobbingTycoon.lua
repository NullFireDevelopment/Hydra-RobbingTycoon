--// Load Material Library
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

--// Hydra Hub GUI
local Window = Material.Load({
    Title = "Hydra Hub",
    Style = 3,
    SizeX = 500,
    SizeY = 350,
    Theme = "Light",
    ColorOverrides = {MainFrame = Color3.fromRGB(235,235,235)}
})

local MainTab = Window.New({Title = "Main"})

--// Variables
local NoclipEnabled = false
local walkspeed = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16
local Noclipping
local GemFarmEnabled = false
local gemPos = Vector3.new(75, 14.979994773864746, 4275)
local gemPlaceId = 6055743719
local returnPos = Vector3.new(0.218, 8.8, 11.155)

--// Noclip Functions
local function StartNoclip()
    NoclipEnabled = true
    Noclipping = RunService.Stepped:Connect(function()
        if NoclipEnabled and Player.Character then
            for _, child in pairs(Player.Character:GetDescendants()) do
                if child:IsA("BasePart") then
                    child.CanCollide = false
                end
            end
        end
    end)
end

local function StopNoclip()
    NoclipEnabled = false
    if Noclipping then Noclipping:Disconnect() Noclipping=nil end
    if Player.Character then
        for _, child in pairs(Player.Character:GetDescendants()) do
            if child:IsA("BasePart") then
                child.CanCollide = true
            end
        end
    end
end

--// Noclip Toggle
local noclipToggle = MainTab.Toggle({
    Text = "Noclip [N]",
    Callback = function(State)
        if State then
            StartNoclip()
        else
            StopNoclip()
        end
    end,
    Enabled = false
})

local function UpdateToggle(State)
    noclipToggle.Callback(State)
    noclipToggle.Toggle.Text = State and "ON" or "OFF"
end

Mouse.KeyDown:Connect(function(KEY)
    KEY = KEY:lower()
    if KEY == "n" then
        if NoclipEnabled then
            StopNoclip()
            UpdateToggle(false)
        else
            StartNoclip()
            UpdateToggle(true)
        end
    end
end)

--// WalkSpeed Slider
MainTab.Slider({
    Text = "WalkSpeed",
    Callback = function(Value)
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Value
        end
    end,
    Min = 16,
    Max = 200,
    Def = walkspeed
})

--// Fly function (300 speed)
local function FlyTo(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        while (hrp.Position - pos).Magnitude > 2 and GemFarmEnabled do
            local direction = (pos - hrp.Position).Unit
            hrp.CFrame = hrp.CFrame + direction * 300 * task.wait()
        end
    end
end

--// AutoConvert function
local function AutoConvert()
    local popup = PlayerGui:FindFirstChild("AreYouSure")
    if popup and popup:FindFirstChild("Frame") and popup.Frame:FindFirstChild("Convert") then
        local button = popup.Frame.Convert
        local absPos = button.AbsolutePosition + button.AbsoluteSize/2
        VirtualInputManager:SendMouseMove(absPos.X, absPos.Y)
        VirtualInputManager:SendMouseButtonEvent(absPos.X, absPos.Y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(absPos.X, absPos.Y, 0, false, game, 0)
    end
end

--// Gem Farm Loop
local function StartGemFarm()
    task.spawn(function()
        while GemFarmEnabled do
            -- Teleport to Gem Farm place if not there
            if game.PlaceId ~= gemPlaceId then
                TeleportService:Teleport(gemPlaceId, Player)
                break -- stop script, will auto-continue after teleport
            end

            -- Fly to gem coordinates
            FlyTo(gemPos)
            task.wait(0.05)

            -- Auto click Convert button
            AutoConvert()

            -- Wait for game auto-teleport back
            repeat task.wait(0.5) until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

            -- Detect return position and auto-fly again
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                while (hrp.Position - returnPos).Magnitude < 2 and GemFarmEnabled do
                    task.wait(0.1)
                    FlyTo(gemPos)
                    AutoConvert()
                    repeat task.wait(0.5) until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                end
            end
        end
    end)
end

--// Gem Farm Toggle
local gemFarmToggle = MainTab.Toggle({
    Text = "Gem Farm",
    Callback = function(State)
        GemFarmEnabled = State
        if State then
            StartGemFarm()
        end
    end,
    Enabled = false
})

--// AutoClicker Button
MainTab.Button({
    Text = "AutoClicker",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/stavurself/FastClicker/refs/heads/main/main.lua"))()
    end
})

--// Auto-execute after teleport (optional)
Player.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started or State == Enum.TeleportState.Finished then
        task.wait(1)
        if game.PlaceId == gemPlaceId then
            -- reload Hydra Hub automatically (replace with your script URL if needed)
            -- loadstring(game:HttpGet("PASTE_YOUR_SCRIPT_URL_HERE"))()
        end
    end
end)
