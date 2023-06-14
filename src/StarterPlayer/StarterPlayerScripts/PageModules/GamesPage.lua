local GamesPage = {}

function GamesPage:Init(UI)
    local LauncherUI = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("MeteoriteLauncher")
    local ReplStore = game:GetService("ReplicatedStorage")

    local LoadingGames = false

    local function LoadMoreGames(Page)
        LoadingGames = true
        print("Getting games page data...")
        local PopularGames = ReplStore.GetGames:InvokeServer("Popular", Page)
        local MostVisitedGames = ReplStore.GetGames:InvokeServer("MostVisited", Page)
        local RecommendedGames = ReplStore.GetGames:InvokeServer("Recommended", Page)

        assert(PopularGames, "Getting popular games failed or returned nil.")
        assert(MostVisitedGames, "Getting most visited games failed or returned nil.")
        assert(RecommendedGames, "Getting recommended games failed or returned nil.")

        print("Fetched games, continuing...")

        print(PopularGames)

        for i, v in pairs(PopularGames) do
            local GameFrame = script.Game:Clone()
            
            GameFrame.GameName.Text = v.nameofgame
            GameFrame.PlayerCount.Text = v.numberofplayers .. " Players"
            
            GameFrame.Parent = UI.Popular.ScrollFrame
        end

        for i, v in pairs(MostVisitedGames) do
            local GameFrame = script.Game:Clone()

            GameFrame.GameName.Text = v.nameofgame
            GameFrame.PlayerCount.Text = v.numberofplayers .. " Players"

            GameFrame.Parent = UI.MostVisited.ScrollFrame
        end

        for i, v in pairs(RecommendedGames) do
            local GameFrame = script.Game:Clone()

            GameFrame.GameName.Text = v.nameofgame
            GameFrame.PlayerCount.Text = v.numberofplayers .. " Players"

            GameFrame.Parent = UI.Recommended.ScrollFrame
        end
        if UI.Visible then
            LauncherUI.GlobalEvents.ToggleLoadingScreen:Fire(false)
        end
        LoadingGames = false
    end

    UI.Changed:Connect(function(Property)
        if Property == "Visible" then
            if UI.Visible then
                if LoadingGames then
                    LauncherUI.GlobalEvents.ToggleLoadingScreen:Fire(true)
                end
            else
                if LoadingGames then
                    LauncherUI.GlobalEvents.ToggleLoadingScreen:Fire(false)
                end
            end
        end
    end)

    for i = 0, 2 do
        LoadMoreGames(i)
    end
end

return GamesPage