repeat
    task.wait()
until game:IsLoaded()

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild('HumanoidRootPart')
local Humanoid = Char:WaitForChild('Humanoid')
local Inventory = LP:WaitForChild('Profile'):WaitForChild('Inventory')
local ClothingAssets = ReplicatedStorage:WaitForChild('ClothingAssets')
local LogosFolder = LP.Profile:WaitForChild('Logos')
local Stamina = LP:WaitForChild('Values'):WaitForChild('Stamina')
local CourtNoti = ReplicatedStorage
    :WaitForChild('Events')
    :WaitForChild('CourtNoti')

-- Notification sequence
firesignal(CourtNoti.OnClientEvent, 'WELCOME TO VINCI SCRIPT ')
task.wait(2)
firesignal(CourtNoti.OnClientEvent, 'SCRIPT MADE BY SAVINCI')

task.spawn(function()
    local url = 'https://discord.gg/b6SQ6KBmWs'
    setclipboard(url)
    game.StarterGui:SetCore('SendNotification', {
        Title = 'Discord',
        Text = 'Link copied to clipboard!',
        Duration = 5,
    })
end)

task.wait(2)
firesignal(CourtNoti.OnClientEvent, 'DISCORD.GG/b6SQ6KBmWs')
task.wait(2)

-- UI Library
local Library = loadstring(
    game:HttpGet(
        'https://raw.githubusercontent.com/Rain-Design/Libraries/main/Shaman/Library.lua'
    )
)()
local Flags = Library.Flags

local Window = Library:Window({ Text = 'Vinci | Arcade Basketball' })

-- Tabs
local PlayerTab = Window:Tab({ Text = 'Player' })
local ShootTab = Window:Tab({ Text = 'Shooting' })
local MiscTab = Window:Tab({ Text = 'Misc' })

-- Sections
local PlayerOptions = PlayerTab:Section({ Text = 'Player Options' })
local PlayerMods = PlayerTab:Section({
    Text = 'Player Modifications',
    Side = 'Right',
})
local ShootLegit = ShootTab:Section({ Text = 'Shooting | Legit' })
local MiscLeft = MiscTab:Section({ Text = 'Inventory' })
local MiscRight = MiscTab:Section({ Text = 'Logos', Side = 'Right' })

-- Toggles and Variables
local Toggles = {
    AutoGreen = false,
    WalkSpeed = false,
    SpinBot = false,
    InfStamina = false,
}

local SpeedValue = 16
local SpinSpeed = 10

-- Player Tab Toggles
PlayerOptions:Toggle({
    Text = 'Infinite Stamina',
    Default = false,
    Flag = 'InfStaminaToggle',
    Callback = function(v)
        Toggles.InfStamina = v
    end,
})

PlayerMods:Toggle({
    Text = 'Walk Speed',
    Default = false,
    Flag = 'WalkSpeedToggle',
    Callback = function(v)
        Toggles.WalkSpeed = v
    end,
})

PlayerMods:Slider({
    Text = 'Speed',
    Default = 16,
    Minimum = 0,
    Maximum = 80,
    Flag = 'SpeedSlider',
    Callback = function(v)
        SpeedValue = v
    end,
})

PlayerMods:Toggle({
    Text = 'SpinBot',
    Default = false,
    Flag = 'SpinBotToggle',
    Callback = function(v)
        Toggles.SpinBot = v
    end,
})

PlayerMods:Slider({
    Text = 'Spin Speed',
    Default = 10,
    Minimum = 1,
    Maximum = 50,
    Flag = 'SpinSpeedSlider',
    Callback = function(v)
        SpinSpeed = v
    end,
})

-- Shooting Tab
ShootLegit:Toggle({
    Text = 'Auto Green',
    Default = false,
    Flag = 'AutoGreenToggle',
    Callback = function(v)
        Toggles.AutoGreen = v
    end,
})

-- Misc Tab: Clothes
MiscLeft:Button({
    Text = 'Unlock All Clothes',
    Callback = function()
        for _, v in Inventory:GetChildren() do
            v:Destroy()
        end
        for _, v in ClothingAssets:GetChildren() do
            v:Clone().Parent = Inventory
        end
        Window:Notify({
            Title = 'Inventory',
            Description = 'Unlocked all clothing!',
        })
    end,
})

-- Misc Tab: Logo Picker
local logos = {}
for _, logo in LogosFolder:GetChildren() do
    table.insert(logos, logo.Name)
end

MiscRight:Dropdown({
    Text = 'Logo Picker',
    List = logos,
    Flag = 'LogoPickerDropdown',
    Callback = function(selected)
        for _, logo in LogosFolder:GetChildren() do
            logo.Value = (logo.Name == selected)
        end
    end,
})

-- Detect shoot remote
local ShootRemote
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA('RemoteEvent') and v.Name:lower():find('shoot') then
        ShootRemote = v
        break
    end
end

-- Hook AutoGreen
local oldNamecall
oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    if
        not checkcaller()
        and self == ShootRemote
        and method:lower() == 'fireserver'
    then
        if Toggles.AutoGreen then
            args[2] = -0.98
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)

-- Main loop
RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeed then
        if Humanoid.WalkSpeed ~= SpeedValue then
            Humanoid.WalkSpeed = SpeedValue
        end
    else
        if Humanoid.WalkSpeed ~= 16 then
            Humanoid.WalkSpeed = 16
        end
    end

    if Toggles.SpinBot then
        HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
    end

    if Toggles.InfStamina then
        Stamina.Value = 1
    end

    local ping = math.floor(
        game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
    )
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    Window:SetWatermark(('Vinci | %d FPS | %d ms'):format(fps, ping))
end)

Window:SelectTab(PlayerTab)
