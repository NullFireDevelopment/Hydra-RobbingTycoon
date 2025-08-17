--// Load Material Library
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

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
local walkspeed = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed or 16
local Noclipping

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

--// Function to update toggle visually
local function UpdateToggle(State)
    noclipToggle.Callback(State)
    noclipToggle.Toggle.Text = State and "ON" or "OFF"
end

--// Keybind for Noclip (UserInputService)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.N then
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
        walkspeed = Value
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Value
        end
    end,
    Min = 16,
    Max = 200,
    Def = walkspeed
})

--// Reapply WalkSpeed and Noclip on respawn
Player.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.WalkSpeed = walkspeed end
    if NoclipEnabled then
        StartNoclip()
    end
end)

--// Gem Farm Toggle
local gemFarmToggle = MainTab.Toggle({
    Text = "Gem Farm",
    Callback = function(State)
        if State then
            if game.PlaceId ~= 6055743719 then
                TeleportService:Teleport(6055743719, Player)
            else
                local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(75, 14.979994773864746, 4275)
                end
            end
        end
    end,
    Enabled = false
})

--// Auto-execute after teleport
Player.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Finished then
        task.wait(1)
        if game.PlaceId == 6055743719 then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NullFireDevelopment/Hydra-RobbingTycoon/refs/heads/main/Hydra%3ARobbingTycoon.lua"))()
        end
    end
end)
