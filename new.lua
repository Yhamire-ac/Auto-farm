-- Prevent multiple loops running across place loads
if getgenv().originalScriptRunning then
    return 
end
getgenv().originalScriptRunning = true

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

local function mainLoop()
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

        task.wait(1)
    end
end

local function runScript()
    if not getgenv().originalScriptRunning then
        getgenv().originalScriptRunning = true
        task.spawn(mainLoop)
    end
end

if game:IsLoaded() then
    task.spawn(mainLoop)
end

local queueteleport =
    (syn and syn.queue_on_teleport)
    or queue_on_teleport
    or (fluxus and fluxus.queue_on_teleport)

if queueteleport then
    queueteleport([[
        getgenv().originalScriptRunning = nil
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Yhamire-ac/Auto-farm/refs/heads/main/new.lua'))()
    ]])
end

game.Loaded:Connect(function()
    if not getgenv().originalScriptRunning then
        task.spawn(mainLoop)
    end
end)

local Players = game:GetService('Players')
local mainGui = Players.LocalPlayer.PlayerGui.Interface.GameOverScreen

while true do
    task.wait(1)
    print("checking...")
    if mainGui.Visible == true  then
        sent = true
        loadstring(
            game:HttpGet("https://raw.githubusercontent.com/Yhamire-ac/Auto-farm/refs/heads/main/senddiscordupdate.lua")
        )()
    end
end
