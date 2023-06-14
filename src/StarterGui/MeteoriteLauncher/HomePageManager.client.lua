if not game:IsLoaded() then
	game.Loaded:Wait()
end

local LauncherUI = script:FindFirstAncestor("MeteoriteLauncher")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplStore = game:GetService("ReplicatedStorage")

local MultifadeLib = require(LauncherUI.Multifade)

local UI = LauncherUI.Pages.HomePage

UI:GetPropertyChangedSignal("Visible"):Connect(function()
	local Visible = UI.Visible
	
	local FriendsList = ReplStore.GetFriends:InvokeServer()
end)