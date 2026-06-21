-- CONFIGURAÇÕES DO DOUTOR DA PESTE SINISTRO
local WALK_ID = "rbxassetid://616158929"   -- Zombie Walk
local RUN_ID  = "rbxassetid://1083194401"  -- Werewolf Run
local IDLE_ID = "rbxassetid://616163682"   -- Zombie Idle (Corpo curvado e braços abertos/estranhos)
local VELOCIDADE = 9                       -- Velocidade entre 8 e 10

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local function applyPlagueDoctorStyle()
    -- 1. Ajuste de Velocidade (Slower/Sinistro)
    local Humanoid = Character:WaitForChild("Humanoid")
    Humanoid.WalkSpeed = VELOCIDADE
    
    -- 2. Troca de Animações
    local animateScript = Character:WaitForChild("Animate")
    
    -- Substituir Andar (Walk)
    animateScript.walk.WalkAnim.AnimationId = WALK_ID
    
    -- Substituir Correr (Run)
    animateScript.run.RunAnim.AnimationId = RUN_ID
    
    -- Substituir Parado (Idle) - O Roblox usa duas animações de idle
    animateScript.idle.Animation1.AnimationId = IDLE_ID
    animateScript.idle.Animation2.AnimationId = IDLE_ID
    
    -- Resetar animações para aplicar as mudanças na hora
    for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    print("Estilo Doutor da Peste aplicado com sucesso!")
end

-- Executa ao carregar
applyPlagueDoctorStyle()

-- Garante que o estilo volte se você morrer e renascer
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    applyPlagueDoctorStyle()
end)
