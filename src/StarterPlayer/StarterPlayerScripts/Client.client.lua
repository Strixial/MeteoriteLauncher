-- Meteorite Launcher - Development build v0.0.0 (14/06/2023)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplStore = game:GetService("ReplicatedStorage")

-- Modules
local MultifadeLib = require(ReplStore.Multifade)

-- Consts
local Player = Players.LocalPlayer
local LauncherUI = Player.PlayerGui:WaitForChild("MeteoriteLauncher")
local DefaultTweenData = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local PageGroups = {}

-- Navbar handler
local PageGroups = {}

local PageSwitchCooldown = 0.3
local OnCooldown = false

local RebuildQueue = {}

task.spawn(function()
	while true do
		for i, v in RebuildQueue do
			print("Rebuilding "..v.Name)
			if PageGroups[v].Faded then
				PageGroups[v]:FadeIn()
			end
			task.delay(0.26, function()
				local Children = v:GetDescendants()
				table.insert(Children, v)
				PageGroups[v] = MultifadeLib.CreateGroup(Children, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
			end)
		end
		
		RebuildQueue = {}
		
		task.wait(0.1)
	end
end)

for i, v in LauncherUI.Navbar:GetChildren() do
	if v:IsA("ImageButton") then
		print(v)
		local Page = LauncherUI.Pages:FindFirstChild(v.Name.."Page")
		print(Page)
		local Children = Page:GetDescendants()
		table.insert(Children, Page)
		PageGroups[Page] = MultifadeLib.CreateGroup(Children, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
		
		Page.DescendantAdded:Connect(function()
			if not table.find(RebuildQueue, Page) then
				print("Flagged for rebuild:"..Page.Name)
				table.insert(RebuildQueue, Page)
			end
		end)
		
		v.Activated:Connect(function()
			if OnCooldown or Page.Visible then return end
			OnCooldown = true
			for i, v in LauncherUI.Pages:GetChildren() do
				if v.Visible then
					PageGroups[v]:FadeOut()
					local Tween = TweenService:Create(v.UIScale, DefaultTweenData, {Scale = 0.9})
					Tween.Completed:Connect(function()
						Tween:Destroy()
					end)
					Tween:Play()
					task.delay(0.5, function() v.Visible = false v.UIScale.Scale = 1 end)
				end
			end
			
			Page.Position = UDim2.new(0.5, -70, 0.5, -50)
			Page.Visible = true
			PageGroups[Page]:FadeIn()
			Page:TweenPosition(UDim2.new(0.5, -70, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.25)
			task.delay(PageSwitchCooldown, function() OnCooldown = false end)
		end)
	end
end

script.SwitchPage.Event:Connect(function(Page)
	if Page.Visible then return end
	if OnCooldown then repeat task.wait() until not OnCooldown end
	OnCooldown = true
	for i, v in LauncherUI.Pages:GetChildren() do
		if v.Visible then
			PageGroups[v]:FadeOut()
			local Tween = TweenService:Create(v.UIScale, DefaultTweenData, {Scale = 0.9})
			Tween.Completed:Connect(function()
				Tween:Destroy()
			end)
			Tween:Play()
			task.delay(0.5, function() v.Visible = false v.UIScale.Scale = 1 end)
		end
	end

	Page.Position = UDim2.new(0.5, -70, 0.5, -50)
	Page.Visible = true
	PageGroups[Page]:FadeIn()
	Page:TweenPosition(UDim2.new(0.5, -70, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.25)
	task.delay(PageSwitchCooldown, function() OnCooldown = false end)
end)

PageGroups[LauncherUI.Pages.HomePage]:FadeIn()

-- Initialise all pages
for i, v in script.Parent.PageModules:GetChildren() do
	require(v):Init(LauncherUI.Pages:FindFirstChild(v.Name))
end

