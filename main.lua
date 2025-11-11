-- Prevent multiple loops running across place loads
if _G.originalScriptRunning then
    return -- already running, stop this new execution
end
_G.originalScriptRunning = true

local ReplicatedStorage = game:GetService('ReplicatedStorage')

function Startgame()
    local Network = ReplicatedStorage:WaitForChild('Network')

    Network:WaitForChild('ClientOpenedPartyRequest'):FireServer()
    Network:WaitForChild('ClientChangePartyTypeRequest'):FireServer('Party')
    Network:WaitForChild('ClientChangePartyMapRequest')
        :FireServer('Intermediate')
    Network:WaitForChild('ClientStartGameRequest'):FireServer()
end

function map()
    local Remotes = ReplicatedStorage:WaitForChild('Remotes')

    Remotes:WaitForChild('MapOverride'):FireServer('Scorched Passage')
    Remotes:WaitForChild('MapVoteCast'):FireServer('Scorched Passage')
    Remotes:WaitForChild('MapVoteReady'):FireServer()
end

function macro()
    loadstring(
        game:HttpGet(
            'https://raw.githubusercontent.com/couldntBeT/Main/refs/heads/main/Main.lua'
        )
    )()
end

local macroHasRun = false

local function mainLoop()
    while true do
        local maingame = workspace:FindFirstChild('mainlobby')
        local gameFolder = workspace:FindFirstChild('Game')
        local mapvoting = gameFolder and gameFolder:FindFirstChild('MapVoting')

        if maingame then
            print('in main lobby')
            macroHasRun = false
            Startgame()
        elseif mapvoting then
            print('in map voting')
            map()
        else
            print('in game')
            if not macroHasRun then
                macro()
                macroHasRun = true
            end
        end

        task.wait(1)
    end
end

local function runScript()
    if not _G.originalScriptRunning then
        _G.originalScriptRunning = true
        task.spawn(mainLoop)
    end
end

if game:IsLoaded() then
    task.spawn(mainLoop)
end

game.Loaded:Connect(function()
    if not _G.originalScriptRunning then
        task.spawn(mainLoop)
    end
end)
