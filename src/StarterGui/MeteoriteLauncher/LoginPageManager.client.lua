local LauncherUI = script:FindFirstAncestor("MeteoriteLauncher")
local UI = script.Parent
local ReplStore = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local BannerNotifs = require(ReplStore.BannerNotificationModule)

local StatusCodeNotifs = {
	["Invalid2FACode"] = {
		Title = "Invalid 2FA code!",
		Message = "Please check it's correct.",
		Icon = "rbxassetid://11419713314"
	},
	["InvalidLoginDetails"] = {
		Title = "Incorrect login details!",
		Message = "Please check your details are correct.",
		Icon = "rbxassetid://11419713314"
	},
	["2FARequired"] = {
		Title = "2FA code required!",
		Message = "Please check your authenticator app.",
		Icon = "rbxassetid://11422155687"
	},
	["Success"] = {
		Title = "Logged in!",
		Message = "",
		Icon = "rbxassetid://11419719540"
	}
}

for i, v in UI.VerifyScreen.Digits:GetChildren() do
	if v:IsA("TextBox") then
		v:GetPropertyChangedSignal("Text"):Connect(function()
			local Text = v.Text
			local idx = tonumber(v.Name)
			if #Text == 1 then
				-- Text box is filled
				if idx < 6 then
					print(idx+1)
					UI.VerifyScreen.Digits:FindFirstChild(tostring(idx+1)):CaptureFocus()
				else
					UI.VerifyScreen.Digits["6"]:ReleaseFocus()
				end
			else
				if idx > 1 then
					print(idx-1)
					UI.VerifyScreen.Digits:FindFirstChild(tostring(idx-1)):CaptureFocus()
				end
			end
		end)
	end
end

UI.LoginScreen.Login.Activated:Connect(function()
	LauncherUI.GlobalEvents.ToggleLoadingScreen:Fire(true)
	local LoginStatus = ReplStore.Login:InvokeServer(script.Parent.LoginScreen.Username.Text, script.Parent.LoginScreen.Password.Text)
	LauncherUI.GlobalEvents.ToggleLoadingScreen:Fire(false)
	print(LoginStatus)
	
	task.spawn(function()
		BannerNotifs:Notify(StatusCodeNotifs[LoginStatus].Title, StatusCodeNotifs[LoginStatus].Message, StatusCodeNotifs[LoginStatus].Icon, 2)
	end)
	
	if LoginStatus == "2FARequired" then
		script.Parent.LoginScreen.Visible = false
		script.Parent.VerifyScreen.Visible = true
	end
end)

UI.VerifyScreen.Verify.Activated:Connect(function()
	-- Get code from digits
	local Code = ""
	for i = 1, 6 do
		local TextBox = UI.VerifyScreen.Digits:FindFirstChild(tostring(i))
		Code = Code .. TextBox.Text
	end
	LauncherUI.GlobalEvents.ToggleLoadingScreen:Fire(true)
	local LoginStatus = ReplStore.Login:InvokeServer(script.Parent.LoginScreen.Username.Text, script.Parent.LoginScreen.Password.Text, Code)
	LauncherUI.GlobalEvents.ToggleLoadingScreen:Fire(false)
	print(LoginStatus)
	task.spawn(function()
		BannerNotifs:Notify(StatusCodeNotifs[LoginStatus].Title, StatusCodeNotifs[LoginStatus].Message, StatusCodeNotifs[LoginStatus].Icon, 2)
	end)
end)

UI.LoginScreen.Password:GetPropertyChangedSignal("Text"):Connect(function()
	local Text = UI.LoginScreen.Password.Text
	UI.LoginScreen.PasswordFrame.TextLabel.Visible = (#Text == 0)
	
	for i, v in UI.LoginScreen.PasswordFrame.Dots:GetChildren() do
		if v.Name == "Dot" then
			v:Destroy()
		end
	end
	
	for i = 1, #Text do
		UI.LoginScreen.PasswordFrame.Dots.UIListLayout.Dot:Clone().Parent = UI.LoginScreen.PasswordFrame.Dots
	end
end)