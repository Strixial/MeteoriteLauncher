if not game:IsLoaded() then
	game.Loaded:Wait()
end

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

task.delay(2, function()
	workspace:WaitForChild("Camera")
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = workspace:WaitForChild("CameraPart").CFrame
end)

if game:GetService("GuiService"):IsTenFootInterface() then
	game:GetService("Players").LocalPlayer:Kick("Xbox interface not supported")
end

local LauncherUI = script:FindFirstAncestor("MeteoriteLauncher")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local MultifadeLib = require(LauncherUI.Multifade)

local DefaultTweenData = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local LoadingGroupChildren = LauncherUI.Loading:GetDescendants()
table.insert(LoadingGroupChildren, LauncherUI.Loading)
local LoadingGroup = MultifadeLib.CreateGroup(LoadingGroupChildren, DefaultTweenData)

LauncherUI.GlobalEvents.ToggleLoadingScreen.Event:Connect(function(Set)
	if Set then
		LauncherUI.Loading.Visible = true
		LoadingGroup:FadeIn()
	else
		LoadingGroup:FadeOut()
	end
end)

LoadingGroup:FadeOut()