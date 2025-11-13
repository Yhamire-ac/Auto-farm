-- Prevent multiple loops running across place loads
if getgenv().originalScriptRunning then
    return  -- already running, stop this new execution
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

local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

if queueteleport then
    queueteleport([[
        getgenv().originalScriptRunning = nil
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Yhamire-ac/Auto-farm/refs/heads/main/main.lua'))()
    ]])
end

game.Loaded:Connect(function()
    if not getgenv().originalScriptRunning then
        task.spawn(mainLoop)
    end
end)

local Players = game:GetService("Players")
local mainGuis = Players.LocalPlayer.PlayerGui.Interface.GameOverScreen.Main

function getrewards()
    local wanted = {
        Map = true,
        Mode = true,
        Time = true,
        Crystals = true,
        Gold = true,
        Tokens = true,
        XP = true,
    }

    local results = {}

    if mainGui.DefeatText.Visible and not mainGui.VictoryText.Visible then
        results.Status = "Defeated"
    else
        results.Status = "Victorious"
    end

    for _, child in ipairs(mainGui:GetDescendants()) do
        if wanted[child.Name] then
            if child:IsA("TextLabel") then
                results[child.Name] = child.Text
            elseif child:IsA("Frame") then
                local txt = child:FindFirstChildWhichIsA("TextLabel", true)
                if txt then
                    results[child.Name] = txt.Text
                end
            end
        end
    end

    return results
end

-------------------------------------------------------
-- DISCORD EMBED SENDER
-------------------------------------------------------

local HttpService = game:GetService("HttpService")
local WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"

local function sendEmbed(data)
    local http = syn and syn.request
        or http_request
        or request
        or (http and http.request)
        or (fluxus and fluxus.request)

    if not http then
        warn("Executor does not support HTTP.")
        return
    end

    http({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    })
end

function sendGameOverEmbed(results)
    local color = results.Status == "Victorious" and 0x2ECC71 or 0xE74C3C
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")

    local embed = {
        title = "Game Over – " .. results.Status,
        color = color,

        fields = {
            { name = "Map", value = results.Map or "N/A", inline = true },
            { name = "Mode", value = results.Mode or "N/A", inline = true },
            { name = "Time", value = results.Time or "N/A", inline = true },
            { name = "Crystals", value = results.Crystals or "N/A", inline = true },
            { name = "Gold", value = results.Gold or "N/A", inline = true },
            { name = "Tokens", value = results.Tokens or "N/A", inline = true },
            { name = "XP", value = results.XP or "N/A", inline = true }
        },

        footer = { text = "Logged at " .. timestamp }
    }

    sendEmbed({ embeds = { embed } })
end

-------------------------------------------------------
-- MAIN GAMEOVER LOOP (FIXED)
-------------------------------------------------------

local sent = false

while true do
    task.wait(1)

    if mainGui.Visible and not sent then
        sent = true

        local rewards = getrewards()
        sendGameOverEmbed(rewards)

        game:GetService("ReplicatedStorage")
            .Remotes.RequestTeleportToLobby:FireServer()
    end

    if not mainGui.Visible then
        sent = false
    end
end
