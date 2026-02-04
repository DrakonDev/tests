-- =========================
-- SERVIÇOS
-- =========================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- =========================
-- UI (REDZ LIB)
-- =========================

local redzlib = loadstring(
    game:HttpGet("https://raw.githubusercontent.com/Fznkb2zo/.TheCleaner/refs/heads/main/lib/libraly.lua")
)()

local Window = redzlib:MakeWindow({
    Title = "redz Hub : Blox Fruits",
    SubTitle = "by redz9999",
    SaveFolder = "testando | redz lib v5.lua"
})

Window:AddMinimizeButton({	
    Button = { Image = "rbxassetid://94800455817009", BackgroundTransparency = 0 },
    Corner = { CornerRadius = UDim.new(0, 5) },
})

local Tab1 = Window:MakeTab({"Player", "users"})

-- =========================
-- VARIÁVEIS GLOBAIS
-- =========================

local webhookSelected = nil
local selectedPlayer = nil

-- =========================
-- FUNÇÕES AUXILIARES
-- =========================

local function getPlayerByPartialName(text)
    if not text or text == "" then
        return nil
    end

    text = string.lower(text)

    for _, player in ipairs(Players:GetPlayers()) do
        local name = string.lower(player.Name)
        local displayName = string.lower(player.DisplayName)

        if string.find(name, text) or string.find(displayName, text) then
            return player
        end
    end

    return nil
end

local function getCreationDateFromAccountAge(days)
    local now = os.time()
    local creationTime = now - (days * 24 * 60 * 60)
    return os.date("%d/%m/%Y", creationTime)
end

local function getExecutorRequest()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or (fluxus and fluxus.request)
end

local function getCharacterInfo(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    local positionText = "N/A"

    if root then
        local pos = root.Position
        positionText = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
    end

    return {
        humanoid = humanoid,
        root = root,
        positionText = positionText
    }
end

-- =========================
-- COMPONENTES DA INTERFACE
-- =========================

Tab1:AddTextBox({ 
    Name = "Nome do Jogador",  
    PlaceholderText = "Ex: Specter", 
    Callback = function(Value)
        local playerFound = getPlayerByPartialName(Value)

        if playerFound then
            selectedPlayer = playerFound
            print("Selecionado:", playerFound.Name, "| Display:", playerFound.DisplayName)
        else
            selectedPlayer = nil
            print("Jogador não encontrado:", Value)
        end
    end
})

Tab1:AddTextBox({ 
    Name = "Webhook:",  
    PlaceholderText = "Input", 
    Callback = function(Value)
        webhookSelected = Value
    end
})

Tab1:AddButton({
    Name = "Search Player",
    Callback = function()
        if not selectedPlayer then
            warn("Nenhum jogador selecionado!")
            return
        end

        if not webhookSelected or webhookSelected == "" then
            warn("Nenhum webhook inserido!")
            return
        end

        local request = getExecutorRequest()
        if not request then
            warn("Executor não suporta requests HTTP")
            return
        end

        local player = selectedPlayer
        local userId = player.UserId
        local timeNow = os.date("%d/%m/%Y %H:%M:%S")
        local creationDate = getCreationDateFromAccountAge(player.AccountAge)

        local charInfo = getCharacterInfo(player)

        local embed = {
            title = "Player Search Result",
            color = 0x00A2FF,
            thumbnail = {
                url = string.format(
                    "https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=420&height=420&format=png",
                    userId
                )
            },
            fields = {
                {
                    name = "Player",
                    value = string.format("%s (@%s)", player.DisplayName, player.Name),
                    inline = false
                },
                {
                    name = "User ID",
                    value = tostring(userId),
                    inline = true
                },
                {
                    name = "Data de criação",
                    value = creationDate,
                    inline = true
                },
                {
                    name = "Account Age",
                    value = tostring(player.AccountAge) .. " dias",
                    inline = true
                },
                {
                    name = "Membership",
                    value = tostring(player.MembershipType),
                    inline = true
                },
                {
                    name = "Place ID",
                    value = tostring(game.PlaceId),
                    inline = true
                },
                {
                    name = "Job ID",
                    value = game.JobId,
                    inline = false
                },
                {
                    name = "Players no servidor",
                    value = tostring(#Players:GetPlayers()),
                    inline = true
                },
                {
                    name = "Time",
                    value = player.Team and player.Team.Name or "Sem time",
                    inline = true
                },
                {
                    name = "Vida",
                    value = charInfo.humanoid and tostring(math.floor(charInfo.humanoid.Health)) or "N/A",
                    inline = true
                },
                {
                    name = "WalkSpeed",
                    value = charInfo.humanoid and tostring(charInfo.humanoid.WalkSpeed) or "N/A",
                    inline = true
                },
                {
                    name = "JumpPower",
                    value = charInfo.humanoid and tostring(charInfo.humanoid.JumpPower) or "N/A",
                    inline = true
                },
                {
                    name = "Posição no mapa",
                    value = charInfo.positionText,
                    inline = false
                },
                {
                    name = "Hora da pesquisa",
                    value = timeNow,
                    inline = false
                },
                {
                    name = "Perfil",
                    value = string.format(
                        "[Clique aqui](https://www.roblox.com/users/%d/profile)",
                        userId
                    ),
                    inline = false
                }
            }
        }

        request({
            Url = webhookSelected,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                embeds = { embed }
            })
        })

        print("Webhook enviado para:", webhookSelected)
    end
})
