pcall(function()
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/couldntBeT/Main/refs/heads/main/Main.lua"))()
    ]])
end)

if getgenv().macro_script_running then return end
getgenv().macro_script_running = true



if getgenv().macro_script_running then
    return
end
getgenv().macro_script_running = true


local ReplicatedStorage = game:GetService("ReplicatedStorage")

function Startgame()
    local Network = ReplicatedStorage:WaitForChild("Network")

    Network:WaitForChild("ClientOpenedPartyRequest"):FireServer()
    Network:WaitForChild("ClientChangePartyTypeRequest"):FireServer("Party")
    Network:WaitForChild("ClientChangePartyMapRequest"):FireServer("Intermediate")
    Network:WaitForChild("ClientStartGameRequest"):FireServer()
end

function map()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")

    Remotes:WaitForChild("MapOverride"):FireServer("Scorched Passage")
    Remotes:WaitForChild("MapVoteCast"):FireServer("Scorched Passage")
    Remotes:WaitForChild("MapVoteReady"):FireServer()
end

function macro()
    loadstring(
        game:HttpGet("https://raw.githubusercontent.com/couldntBeT/Main/refs/heads/main/Main.lua")
    )()
end


local macroHasRun = false


task.spawn(function()
    while true do
        local maingame = workspace:FindFirstChild("mainlobby")
        local gameFolder = workspace:FindFirstChild("Game")
        local mapvoting = gameFolder and gameFolder:FindFirstChild("MapVoting")

        if maingame then
            print("in main lobby")
            macroHasRun = false
            Startgame()

        elseif mapvoting then
            print("in map voting")
            map()

        else
            print("in game")
            if not macroHasRun then
                macro()
                macroHasRun = true
            end
        end

        task.wait(2) 
    end
end)
