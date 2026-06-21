local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ===== CONFIG =====
local WALK_ID = "rbxassetid://616158929"
local RUN_ID  = "rbxassetid://616163921"
local CRAWL_ID = "rbxassetid://15234485039"
local VELOCIDADE = 9

local Character = player.Character or player.CharacterAdded:Wait()

-- ===== UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PesteNegraUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 190)
frame.Position = UDim2.new(0, 15, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundTransparency = 1
title.Text = "🩺 Doutor da Peste"
title.TextColor3 = Color3.fromRGB(210, 210, 210)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 30)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = frame

local function criarBotao(texto, ordem, corOn)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
    btn.Text = texto
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = ordem
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    return btn
end

local btnAnim = criarBotao("Ativar Animação Macabra", 1)
local btnWalk = criarBotao("Ativar Andar Zumbi", 2)
local btnCrawl = criarBotao("Rastejar (Crawl)", 3)

-- ===== ESTADOS =====
local animMacabraAtiva = false
local andarZumbiAtivo = false
local rastejandoAtivo = false
local conexaoMacabra = nil

-- ===== POSE MACABRA (cabeça baixa + tremor) =====
local function pararAnimMacabra()
    if conexaoMacabra then
        conexaoMacabra:Disconnect()
        conexaoMacabra = nil
    end
end

local function aplicarAnimMacabra(char)
    local upperTorso = char:FindFirstChild("UpperTorso")
    if not upperTorso then return end
    local neck = upperTorso:FindFirstChild("Neck")
    local waist = upperTorso:FindFirstChild("Waist")
    if not neck or not waist then return end

    local originalNeckC0 = neck.C0
    local originalWaistC0 = waist.C0
    local proximoTique = tick() + math.random(2, 5)

    pararAnimMacabra()
    conexaoMacabra = RunService.RenderStepped:Connect(function()
        if not char.Parent then
            pararAnimMacabra()
            return
        end
        local t = tick()
        local tremorX = math.sin(t * 9) * 1.5
        local tremorY = math.sin(t * 13 + 2) * 1.5

        neck.C0 = originalNeckC0 * CFrame.Angles(math.rad(30 + tremorX), math.rad(tremorY), math.rad(math.sin(t * 4) * 3))
        waist.C0 = originalWaistC0 * CFrame.Angles(math.rad(12 + math.sin(t * 1.5) * 2), math.rad(math.sin(t * 0.8) * 4), 0)

        if t >= proximoTique then
            proximoTique = t + math.random(2, 5)
            task.spawn(function()
                local inicio = tick()
                while tick() - inicio < 0.15 do
                    neck.C0 = neck.C0 * CFrame.Angles(math.rad(math.random(-15,15)), math.rad(math.random(-15,15)), 0)
                    task.wait()
                end
            end)
        end
    end)
end

-- ===== TROCA DE ANIMAÇÃO DE ANDAR/CORRER =====
local function aplicarAndarZumbi(char)
    local animateScript = char:WaitForChild("Animate", 5)
    if not animateScript then return end
    local humanoid = char:WaitForChild("Humanoid")

    animateScript:WaitForChild("walk"):WaitForChild("WalkAnim").AnimationId = WALK_ID
    animateScript:WaitForChild("run"):WaitForChild("RunAnim").AnimationId = RUN_ID
    humanoid.WalkSpeed = VELOCIDADE

    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    humanoid.WalkSpeed = 0
    task.wait(0.1)
    humanoid.WalkSpeed = VELOCIDADE
end

-- ===== CRAWL =====
local crawlTrack = nil
local function ativarCrawl(char)
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:WaitForChild("Animator")
    local anim = Instance.new("Animation")
    anim.AnimationId = CRAWL_ID
    crawlTrack = animator:LoadAnimation(anim)
    crawlTrack.Looped = true
    crawlTrack:Play()
end

local function pararCrawl()
    if crawlTrack then
        crawlTrack:Stop()
        crawlTrack = nil
    end
end

-- ===== BOTÕES =====
btnAnim.MouseButton1Click:Connect(function()
    animMacabraAtiva = not animMacabraAtiva
    if animMacabraAtiva then
        btnAnim.Text = "Desativar Animação Macabra"
        btnAnim.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        aplicarAnimMacabra(Character)
    else
        btnAnim.Text = "Ativar Animação Macabra"
        btnAnim.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        pararAnimMacabra()
    end
end)

btnWalk.MouseButton1Click:Connect(function()
    andarZumbiAtivo = not andarZumbiAtivo
    if andarZumbiAtivo then
        btnWalk.Text = "Desativar Andar Zumbi"
        btnWalk.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        aplicarAndarZumbi(Character)
    else
        btnWalk.Text = "Ativar Andar Zumbi"
        btnWalk.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        Character:WaitForChild("Humanoid").WalkSpeed = 16
    end
end)

btnCrawl.MouseButton1Click:Connect(function()
    rastejandoAtivo = not rastejandoAtivo
    if rastejandoAtivo then
        btnCrawl.Text = "Parar de Rastejar"
        btnCrawl.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        ativarCrawl(Character)
    else
        btnCrawl.Text = "Rastejar (Crawl)"
        btnCrawl.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
        pararCrawl()
    end
end)

-- ===== RECARREGAR AO RESPAWN =====
player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    task.wait(0.5)
    if animMacabraAtiva then aplicarAnimMacabra(newChar) end
    if andarZumbiAtivo then aplicarAndarZumbi(newChar) end
end)