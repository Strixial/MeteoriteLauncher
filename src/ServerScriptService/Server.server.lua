local HTTPService = game:GetService("HttpService")
local ReplStore = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerCookies = {}

local GamesAPIRoutes = {
	Popular = "Popular",
	MostVisited = "Visits",
	Recommended = "OurRecommendations"
}

local function GetGames(Route, Page)
	local Request = HTTPService:RequestAsync({
		Url = "https://mete0r.xyz/games/scroll",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HTTPService:JSONEncode({
			["cursor"] = Page,
			["type"] = Route
		})
	})
	
	return HTTPService:JSONDecode(Request.Body)
end

local function Login(Username, Password, Code)
	local Body
	if Code then
		Body = {
			["username"] = Username,
			["password"] = Password,
			["_2fa"] = tonumber(Code)
		}
	else
		Body = {
			["username"] = Username,
			["password"] = Password
		}
	end
	
	local Request = HTTPService:RequestAsync({
		Url = "https://mete0r.xyz/login",
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HTTPService:JSONEncode(Body)
	})
	
	return Request
end

local GetGamesAPI = Instance.new("RemoteFunction")
GetGamesAPI.Parent = ReplStore
GetGamesAPI.Name = "GetGames"
GetGamesAPI.OnServerInvoke = function(Player, Route, Page)
	local Result
	local Success, Err = pcall(function()
		Result = GetGames(GamesAPIRoutes[Route], Page)
	end)
	
	if Success then
		return Result
	else
		warn("Got an error from Meteorite when getting games: "..Err)
		return false
	end
end

local ErrorCodes = {
	["Usernames needs to be sent and it needs to be a string"] = "InvalidLoginDetails",
	["Password needs to be at least 5 characters"] = "InvalidLoginDetails",
	["Invalid username/password"] = "InvalidLoginDetails",
	["2FA Enabled on account but 2fa not sent"] = "2FARequired",
	["Invalid 2FA Code"] = "Invalid2FACode"
}

local LoginAPI = Instance.new("RemoteFunction")
LoginAPI.Parent = ReplStore
LoginAPI.Name = "GetGames"
LoginAPI.OnServerInvoke = function(Player, Username, Password, Code)
	local Result
	local Success, Err = pcall(function()
		Result = Login(Username, Password, Code)
	end)

	if Success then
		print(Result)
		if Result.Body then
			local Body = HTTPService:JSONDecode(Result.Body)
			if Body.status == "error" then
				print("Got an error: "..Body.error)
				if ErrorCodes[Body.error] then
					return ErrorCodes[Body.error]
				else
					return "UnknownError"
				end
			elseif Body.status == "ok" then
				print("Logged in successfully!")
				PlayerCookies[Player] = Body.cookie
				print(PlayerCookies[Player])
				return "Success"
			end
		end
	else
		warn("Got an error from Meteorite when logging in: "..Err)
		return "UnknownError"
	end
end

Players.PlayerRemoving:Connect(function(Player)
	PlayerCookies[Player] = nil
end)

game.ReplicatedStorage.GetLoginState.OnServerInvoke = function(Player)
	return PlayerCookies[Player] ~= nil
end
local GetFriendsAPI = Instance.new("RemoteFunction")
GetFriendsAPI.Parent = ReplStore
GetFriendsAPI.Name = "GetGames"
GetFriendsAPI.OnServerInvoke = function(Player)
	local Success, Result = pcall(function()
		return HTTPService:RequestAsync({
			Url = "https://mete0r.xyz/api/auth/requestfriends",
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = `{PlayerCookies[Player]}`
			},
		})
	end)
	
	if Success then
		print(Result)
	else
		warn("Error received when attempting to get friends:", Result)
		return false
	end
end