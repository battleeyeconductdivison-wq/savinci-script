-- MacLib Loader
local MacLib = loadstring(
    game:HttpGet(
        'https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt'
    )
)()

-- Setup Window
local Window = MacLib:Window({
    Title = 'Vinci',
    Subtitle = 'Arcade Basketball',
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    Keybind = Enum.KeyCode.P, -- OPEN WITH "P"
    AcrylicBlur = true,
    ShowUserInfo = true,
})

-- UI Global Settings
Window:GlobalSetting({
    Name = 'UI Blur',
    Default = Window:GetAcrylicBlurState(),
    Callback = function(bool)
        Window:SetAcrylicBlurState(bool)
    end,
})
Window:GlobalSetting({
    Name = 'Notifications',
    Default = Window:GetNotificationsState(),
    Callback = function(bool)
        Window:SetNotificationsState(bool)
    end,
})
Window:GlobalSetting({
    Name = 'Show User Info',
    Default = Window:GetUserInfoState(),
    Callback = function(bool)
        Window:SetUserInfoState(bool)
    end,
})

-- Tabs & Section
local MainTab = Window
    :TabGroup()
    :Tab({ Name = 'Main', Image = 'rbxassetid://18821914323' })
local SettingsTab = Window:TabGroup():Tab({
    Name = 'Settings',
    Image = 'rbxassetid://10734950309',
})
local Section = MainTab:Section({ Side = 'Left' })

-- Game services and references
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild('Humanoid')
local Inventory = LocalPlayer:WaitForChild('Profile'):WaitForChild('Inventory')
local ClothingAssets = ReplicatedStorage:WaitForChild('ClothingAssets')
local LogosFolder = LocalPlayer.Profile.Logos
local Stamina = LocalPlayer:WaitForChild('Values'):WaitForChild('Stamina')
local ShootRemote = ReplicatedStorage
    :WaitForChild('Events')
    :WaitForChild('Shoot')

-- Toggles
local Toggles = {
    AutoGreen = false,
    WalkSpeed = false,
    InfStamina = false,
    RageGreen = false,
}
local WalkSpeed = 16

-- UI Elements
Section:Toggle({
    Name = 'Auto Green',
    Default = false,
    Callback = function(val)
        Toggles.AutoGreen = val
    end,
})

Section:Toggle({
    Name = 'Rage Auto Green (Press T)',
    Default = false,
    Callback = function(val)
        Toggles.RageGreen = val
    end,
})

Section:Toggle({
    Name = 'Walk Speed',
    Default = false,
    Callback = function(val)
        Toggles.WalkSpeed = val
    end,
})
Section:Slider({
    Name = 'Speed',
    Default = 16,
    Minimum = 0,
    Maximum = 40,
    Callback = function(val)
        WalkSpeed = val
    end,
})

Section:Toggle({
    Name = 'Infinite Stamina',
    Default = false,
    Callback = function(val)
        Toggles.InfStamina = val
    end,
})

Section:Button({
    Name = 'Unlock All Clothes',
    Callback = function()
        for _, item in Inventory:GetChildren() do
            item:Destroy()
        end
        for _, asset in ClothingAssets:GetChildren() do
            asset:Clone().Parent = Inventory
        end
        Window:Notify({
            Title = 'Inventory',
            Description = 'Unlocked all clothing!',
        })
    end,
})

-- Logo Selection
local logoNames = {}
for _, logo in LogosFolder:GetChildren() do
    table.insert(logoNames, logo.Name)
end
Section:Dropdown({
    Name = 'Logo Picker',
    Options = logoNames,
    Default = 1,
    Callback = function(selected)
        for _, logo in LogosFolder:GetChildren() do
            logo.Value = (logo.Name == selected)
        end
    end,
})

-- Rage Green Key (T)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if
        not gameProcessed
        and input.KeyCode == Enum.KeyCode.T
        and Toggles.RageGreen
    then
        ShootRemote:FireServer(nil, -1, nil)
    end
end)

-- Hook for Auto Green
local oldNamecall
oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
    local args = { ... }
    if
        not checkcaller()
        and self == ShootRemote
        and getnamecallmethod():lower() == 'fireserver'
    then
        if Toggles.AutoGreen then
            args[2] = -0.98
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- Runtime behavior
RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeed and Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
    end
    if Toggles.InfStamina and Stamina and Stamina.Value < 1 then
        Stamina.Value = 1
    end

    local ping = math.floor(
        game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
    )
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    Window:SetWatermark(('Inertia | %s FPS | %s ms'):format(fps, ping))
end)

-- Config + Unload
MacLib:SetFolder('InertiaMacLib')
SettingsTab:InsertConfigSection('Left')
Window.onUnloaded(function()
    print('UI closed and script unloaded.')
end)

MainTab:Select()
MacLib:LoadAutoLoadConfig()
