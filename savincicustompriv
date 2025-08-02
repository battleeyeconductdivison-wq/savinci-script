local MacLib = loadstring(
    game:HttpGet(
        'https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt'
    )
)()

local Window = MacLib:Window({
    Title = 'Vinci',
    Subtitle = 'Arcade Basketball',
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    Keybind = Enum.KeyCode.P,
    AcrylicBlur = true,
    ShowUserInfo = true,
})

-- Global UI Settings
Window:GlobalSetting({
    Name = 'UI Blur',
    Default = Window:GetAcrylicBlurState(),
    Callback = function(b)
        Window:SetAcrylicBlurState(b)
    end,
})
Window:GlobalSetting({
    Name = 'Notifications',
    Default = Window:GetNotificationsState(),
    Callback = function(b)
        Window:SetNotificationsState(b)
    end,
})
Window:GlobalSetting({
    Name = 'Show User Info',
    Default = Window:GetUserInfoState(),
    Callback = function(b)
        Window:SetUserInfoState(b)
    end,
})

-- Tabs
local PlayerTab = Window
    :TabGroup()
    :Tab({ Name = 'Player', Image = 'rbxassetid://4483345998' })
local ShootTab = Window
    :TabGroup()
    :Tab({ Name = 'Shooting', Image = 'rbxassetid://7734053499' })
local MiscTab = Window
    :TabGroup()
    :Tab({ Name = 'Misc', Image = 'rbxassetid://10734950309' })

local PlayerSection = PlayerTab:Section({ Side = 'Left' })
local ShootSection = ShootTab:Section({ Side = 'Left' })
local MiscSection = MiscTab:Section({ Side = 'Left' })

-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')

-- Player references
local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild('HumanoidRootPart')
local Humanoid = Char:WaitForChild('Humanoid')
local Inventory = LP:WaitForChild('Profile'):WaitForChild('Inventory')
local ClothingAssets = ReplicatedStorage:WaitForChild('ClothingAssets')
local LogosFolder = LP.Profile:WaitForChild('Logos')
local Stamina = LP:WaitForChild('Values'):WaitForChild('Stamina')

local ShootRemote
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA('RemoteEvent') and v.Name:lower():find('shoot') then
        ShootRemote = v
        break
    end
end

-- Toggles and Values
local Toggles = {
    AutoGreen = false,
    RageGreen = false,
    WalkSpeed = false,
    SpinBot = false,
    InfStamina = false,
}
local SpeedValue = 16
local SpinSpeed = 10
local RageBind = Enum.KeyCode.T

-- Player Tab
PlayerSection:Toggle({
    Name = 'Walk Speed',
    Default = false,
    Callback = function(v)
        Toggles.WalkSpeed = v
    end,
})
PlayerSection:Slider({
    Name = 'Speed',
    Default = 16,
    Minimum = 0,
    Maximum = 80,
    Callback = function(v)
        SpeedValue = v
    end,
})
PlayerSection:Toggle({
    Name = 'Spinbot',
    Default = false,
    Callback = function(v)
        Toggles.SpinBot = v
    end,
})
PlayerSection:Slider({
    Name = 'Spin Speed',
    Default = 10,
    Minimum = 1,
    Maximum = 50,
    Callback = function(v)
        SpinSpeed = v
    end,
})
PlayerSection:Toggle({
    Name = 'Infinite Stamina',
    Default = false,
    Callback = function(v)
        Toggles.InfStamina = v
    end,
})

-- Shooting Tab
ShootSection:Toggle({
    Name = 'Auto Green',
    Default = false,
    Callback = function(v)
        Toggles.AutoGreen = v
    end,
})

ShootSection:Toggle({
    Name = 'Rage Auto Green',
    Default = false,
    Callback = function(v)
        Toggles.RageGreen = v
    end,
})

ShootSection:Keybind({
    Name = 'Rage Green Key',
    Callback = function(binded)
        RageBind = binded
        Window:Notify({
            Title = 'Keybind',
            Description = 'Rebound to ' .. tostring(binded.Name),
            Lifetime = 3,
        })
    end,
    onBinded = function(bind)
        RageBind = bind
        Window:Notify({
            Title = 'Keybind',
            Description = 'Successfully bound to ' .. tostring(bind.Name),
            Lifetime = 3,
        })
    end,
}, 'RageGreenBind')

-- Misc Tab
MiscSection:Button({
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

local logoNames = {}
for _, logo in LogosFolder:GetChildren() do
    table.insert(logoNames, logo.Name)
end
MiscSection:Dropdown({
    Name = 'Logo Picker',
    Options = logoNames,
    Default = 1,
    Callback = function(selected)
        for _, logo in LogosFolder:GetChildren() do
            logo.Value = (logo.Name == selected)
        end
    end,
})

-- Hook shoot for AutoGreen
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

-- Rage Key Trigger
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == RageBind and Toggles.RageGreen then
        ShootRemote:FireServer(nil, -1, nil)
    end
end)

-- Runtime
RunService.RenderStepped:Connect(function()
    if Toggles.WalkSpeed and Humanoid then
        Humanoid.WalkSpeed = SpeedValue
    end
    if Toggles.InfStamina and Stamina and Stamina.Value < 1 then
        Stamina.Value = 1
    end
    if Toggles.SpinBot and HRP then
        HRP.CFrame = HRP.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
    end

    local ping = math.floor(
        game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue()
    )
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    Window:SetWatermark(('Inertia | %s FPS | %s ms'):format(fps, ping))
end)

-- Config
MacLib:SetFolder('InertiaMacLib')
SettingsTab:InsertConfigSection('Left')
Window.onUnloaded(function()
    print('UI closed and script unloaded.')
end)
PlayerTab:Select()
MacLib:LoadAutoLoadConfig()
