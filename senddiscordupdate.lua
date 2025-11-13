local Players = game:GetService('Players')
local mainGuis = Players.LocalPlayer.PlayerGui.Interface.GameOverScreen

function getrewards()
    local mainGui = Players.LocalPlayer.PlayerGui.Interface.GameOverScreen.Main

    -- Names we want to capture
    local wanted = {
        Map = true,
        Mode = true,
        Time = true,
        Crystals = true,
        Gold = true,
        Tokens = true,
        XP = true,
    }

    -- Storage for results
    local results = {}

    -- Determine status
    local status
    if mainGui.DefeatText.Visible and not mainGui.VictoryText.Visible then
        status = 'Defeated'
    else
        status = 'Victorious'
    end

    results.Status = status

    -- Extract wanted values
    for _, child in ipairs(mainGui:GetDescendants()) do
        if wanted[child.Name] then
            if child:IsA('TextLabel') then
                results[child.Name] = child.Text
            elseif child:IsA('Frame') then
                local txt = child:FindFirstChildWhichIsA('TextLabel', true)
                if txt then
                    results[child.Name] = txt.Text
                end
            end
        end
    end

    return results
end

local HttpService = game:GetService('HttpService')
local WEBHOOK_URL =
    'https://discordapp.com/api/webhooks/1438351456150487143/ae8QE0aY5iS1RHlYx60FoCkeFTZ3CFoUrf-rrLEpnwY3oarhSyQikuxYhL2NIfUCYimK'

local function sendEmbed(data)
    local http = syn and syn.request
        or http_request
        or request
        or (http and http.request)
        or (fluxus and fluxus.request)

    if not http then
        warn('Your executor does not support HTTP requests.')
        return
    end

    http({
        Url = WEBHOOK_URL,
        Method = 'POST',
        Headers = { ['Content-Type'] = 'application/json' },
        Body = HttpService:JSONEncode(data),
    })
end

function sendGameOverEmbed(results)
    local color = results.Status == 'Victorious' and 0x2ECC71 or 0xE74C3C -- green or red

    local timestamp = os.date('%Y-%m-%d %H:%M:%S')

    local embed = {
        title = 'Game Over – ' .. results.Status,
        color = color,

        fields = {
            { name = 'Map', value = results.Map or 'N/A', inline = true },
            { name = 'Mode', value = results.Mode or 'N/A', inline = true },
            { name = 'Time', value = results.Time or 'N/A', inline = true },

            {
                name = 'Crystals',
                value = results.Crystals or 'N/A',
                inline = true,
            },
            { name = 'Gold', value = results.Gold or 'N/A', inline = true },
            { name = 'Tokens', value = results.Tokens or 'N/A', inline = true },
            { name = 'XP', value = results.XP or 'N/A', inline = true },
        },

        footer = {
            text = 'Logged at ' .. timestamp,
        },
    }

    sendEmbed({ embeds = { embed } })
end

task.spawn(function()
    -- wait for UI safely
    local player = game:GetService('Players').LocalPlayer
    local gui = player:WaitForChild('PlayerGui')
    local interface = gui:WaitForChild('Interface')
    local gameOver = interface:WaitForChild('GameOverScreen')

    -- loop inside the loaded script
    while true do
        task.wait(1)
        print('checking...')

        if gameOver.Visible == true then
            local rewards = getrewards()
            sendGameOverEmbed(rewards)
            task.wait(2)
            game:GetService('ReplicatedStorage').Remotes.RequestTeleportToLobby
                :FireServer()
            break
        end
    end
end)
