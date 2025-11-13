-- Prevent multiple loops running across place loads
if getgenv().originalScriptRunning then
    return  -- already running, stop this new execution
end
getgenv().originalScriptRunning = true  -- ✔ MUST be true, not false

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Starts game
function Startgame()
    local Network = ReplicatedStorage:WaitForChild("Network")

    Network:WaitForChild("ClientOpenedPartyRequest"):FireServer()
    Network:WaitForChild("ClientChangePartyTypeRequest"):FireServer("Party")
    Network:WaitForChild("ClientChangePartyMapRequest"):FireServer("Intermediate")
    Network:WaitForChild("ClientStartGameRequest"):FireServer()
end

-- Map voting logic
function map()
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")

    Remotes:WaitForChild("MapOverride"):FireServer("Scorched Passage")
    Remotes:WaitForChild("MapVoteCast"):FireServer("Scorched Passage")
    Remotes:WaitForChild("MapVoteReady"):FireServer()
end

-- Macro loader
function macro()
    loadstring(
        game:HttpGet("https://raw.githubusercontent.com/couldntBeT/Main/refs/heads/main/Main.lua")
    )()
end

local macroHasRun = false

-- Main farm loop
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

-- Run main loop AFTER game loads
if game:IsLoaded() then
    task.spawn(mainLoop)
else
    game.Loaded:Once(function()
        task.spawn(mainLoop)
    end)
end

-- Queue teleport reload
local queueteleport = (syn and syn.queue_on_teleport)
    or queue_on_teleport
    or (fluxus and fluxus.queue_on_teleport)

if queueteleport then
    queueteleport([[
        getgenv().originalScriptRunning = nil
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Yhamire-ac/Auto-farm/refs/heads/main/main.lua'))()
    ]])
end
