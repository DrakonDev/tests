local Players = game:GetService("Players")

local redzlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fznkb2zo/.TheCleaner/refs/heads/main/lib/libraly.lua"))()

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

local webhookSelected = nil
local selectedPlayer = nil

local function getPlayerByPartialName(text)
    if not text or text == "" then return nil end

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

