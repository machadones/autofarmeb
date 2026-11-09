-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Proteção estrita da GUI (Invisível no PlayerGui / Explorer)
local targetParent = nil
if gethui then
    targetParent = gethui()
elseif syn and syn.protect_gui then
    targetParent = CoreGui
    syn.protect_gui(targetParent)
else
    targetParent = CoreGui
end

if targetParent:FindFirstChild("ProtectedAutoFarmGui") then
    targetParent:FindFirstChild("ProtectedAutoFarmGui"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProtectedAutoFarmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- Ponto Inicial da Caixa
local BoxPickupPos = Vector3.new(2068.0417, 1.3496, -329.4766)

-- Destinos Finais Extraídos do Console
local Destinations = {
    [1] = Vector3.new(2945.3516, 1.3500, -344.0660),
    [2] = Vector3.new(2172.2461, 15.5915, -1128.2362),
    [3] = Vector3.new(1657.4124, 1.3496, -545.7861)
}

-- Rota única (apenas 1 ponto de entrega — agora usando a Rota 3)
local Routes = {
    [1] = {
        Waypoints = {
            Vector3.new(1735.0505, 1.2496, -471.7930),
            Vector3.new(1688.8496, 1.3496, -558.1766),
            Vector3.new(1657.4124, 1.3496, -545.7861)
        },
        Target = Destinations[3]
    }
}

local isFarming = false

-- Arrastar elementos da GUI
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- --- ESTRUTURA VISUAL DA GUI ---

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 55, 0, 55)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleBtn.Text = ""
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(0, 170, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleBtn

local ToggleEmoji = Instance.new("TextLabel")
ToggleEmoji.Size = UDim2.new(1, 0, 1, 0)
ToggleEmoji.BackgroundTransparency = 1
ToggleEmoji.Text = "😇"
ToggleEmoji.TextSize = 32
ToggleEmoji.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleEmoji.Parent = ToggleBtn

makeDraggable(ToggleBtn)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Exclusive"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

makeDraggable(MainFrame, TitleBar)

local HomeTab = Instance.new("Frame")
HomeTab.Name = "HomeTab"
HomeTab.Size = UDim2.new(1, 0, 1, -42)
HomeTab.Position = UDim2.new(0, 0, 0, 42)
HomeTab.BackgroundTransparency = 1
HomeTab.Visible = true
HomeTab.Parent = MainFrame

local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(0.88, 0, 0, 50)
FarmBtn.Position = UDim2.new(0.06, 0, 0.12, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
FarmBtn.Text = "Farm Auto: OFF"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.TextSize = 16
FarmBtn.Parent = HomeTab

local FarmCorner = Instance.new("UICorner")
FarmCorner.CornerRadius = UDim.new(0, 8)
FarmCorner.Parent = FarmBtn

local CreditsTabBtn = Instance.new("TextButton")
CreditsTabBtn.Size = UDim2.new(0.88, 0, 0, 45)
CreditsTabBtn.Position = UDim2.new(0.06, 0, 0.50, 0)
CreditsTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
CreditsTabBtn.Text = "Créditos"
CreditsTabBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
CreditsTabBtn.Font = Enum.Font.GothamBold
CreditsTabBtn.TextSize = 15
CreditsTabBtn.Parent = HomeTab

local CreditsCorner = Instance.new("UICorner")
CreditsCorner.CornerRadius = UDim.new(0, 8)
CreditsCorner.Parent = CreditsTabBtn

local CreditsTab = Instance.new("Frame")
CreditsTab.Name = "CreditsTab"
CreditsTab.Size = UDim2.new(1, 0, 1, -42)
CreditsTab.Position = UDim2.new(0, 0, 0, 42)
CreditsTab.BackgroundTransparency = 1
CreditsTab.Visible = false
CreditsTab.Parent = MainFrame

local LabelUnverified = Instance.new("TextLabel")
LabelUnverified.Size = UDim2.new(1, 0, 0, 30)
LabelUnverified.Position = UDim2.new(0, 0, 0.08, 0)
LabelUnverified.BackgroundTransparency = 1
LabelUnverified.Text = "Por: Unverified"
LabelUnverified.TextColor3 = Color3.fromRGB(255, 77, 77)
LabelUnverified.Font = Enum.Font.GothamBold
LabelUnverified.TextSize = 15
LabelUnverified.Parent = CreditsTab

local LabelCrazySkel = Instance.new("TextLabel")
LabelCrazySkel.Size = UDim2.new(1, 0, 0, 30)
LabelCrazySkel.Position = UDim2.new(0, 0, 0.28, 0)
LabelCrazySkel.BackgroundTransparency = 1
LabelCrazySkel.Text = "Gui por: CrazySkel"
LabelCrazySkel.TextColor3 = Color3.fromRGB(77, 255, 136)
LabelCrazySkel.Font = Enum.Font.GothamBold
LabelCrazySkel.TextSize = 15
LabelCrazySkel.Parent = CreditsTab

local BackBtn = Instance.new("TextButton")
BackBtn.Size = UDim2.new(0.88, 0, 0, 40)
BackBtn.Position = UDim2.new(0.06, 0, 0.58, 0)
BackBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
BackBtn.Text = "Voltar"
BackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BackBtn.Font = Enum.Font.GothamBold
BackBtn.TextSize = 15
BackBtn.Parent = CreditsTab

local BackCorner = Instance.new("UICorner")
BackCorner.CornerRadius = UDim.new(0, 8)
BackCorner.Parent = BackBtn

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CreditsTabBtn.MouseButton1Click:Connect(function()
    HomeTab.Visible = false
    CreditsTab.Visible = true
    TitleText.Text = "CRÉDITOS"
end)

BackBtn.MouseButton1Click:Connect(function()
    CreditsTab.Visible = false
    HomeTab.Visible = true
    TitleText.Text = "Exclusive"
end)

-- --- MOVIMENTAÇÃO E INTERAÇÃO ---

local function disableSmallCollisions()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local rootPos = char.HumanoidRootPart.Position
    for _, part in ipairs(workspace:GetPartBoundsInRadius(rootPos, 6)) do
        if part:IsA("BasePart") and not part:IsDescendantOf(char) and part.Name ~= "Terrain" then
            if part.Size.X <= 4 and part.Size.Y <= 4 and part.Size.Z <= 4 then
                part.CanCollide = false
            end
        end
    end
end

local function walkTo(targetPos, stopRadius, maxTime)
    stopRadius = stopRadius or 3.5
    maxTime = maxTime or 20
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local startTime = tick()
    while isFarming do
        if not character or not rootPart or not humanoid then break end

        local currentPos = rootPart.Position
        local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetPos.X, 0, targetPos.Z)).Magnitude

        if dist <= stopRadius or (tick() - startTime) > maxTime then
            break
        end

        disableSmallCollisions()
        humanoid:MoveTo(targetPos)
        task.wait(0.1)
    end
end

local function interactBox()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character.HumanoidRootPart

    if humanoid then humanoid:MoveTo(rootPart.Position) end

    local startTime = tick()
    while (tick() - startTime) < 3.5 and isFarming do
        local rootPos = rootPart.Position
        if humanoid then humanoid:MoveTo(rootPos) end

        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local parentPart = prompt.Parent
                if parentPart and parentPart:IsA("BasePart") then
                    if (parentPart.Position - rootPos).Magnitude <= (prompt.MaxActivationDistance + 6) then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                        prompt:InputHoldBegin()
                        task.wait(prompt.HoldDuration or 0.2)
                        prompt:InputHoldEnd()
                    end
                end
            end
        end
        task.wait(0.15)
    end
    task.wait(0.4)
end

-- Função de entrega com micro-movimentos laterais (passos para o lado) para confirmar e disparar o evento
local function deliverAtCircle(targetPos)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character.HumanoidRootPart

    walkTo(targetPos, 1.5, 15)
    if not isFarming then return end

    local rightOffset = targetPos + (rootPart.CFrame.RightVector * 3)
    walkTo(rightOffset, 1.0, 3)
    if not isFarming then return end

    local leftOffset = targetPos - (rootPart.CFrame.RightVector * 3)
    walkTo(leftOffset, 1.0, 3)
    if not isFarming then return end

    walkTo(targetPos, 1.0, 5)

    local startTime = tick()
    while (tick() - startTime) < 3.0 and isFarming do
        humanoid:MoveTo(targetPos)

        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local parentPart = prompt.Parent
                if parentPart and parentPart:IsA("BasePart") then
                    if (parentPart.Position - rootPart.Position).Magnitude <= 12 then
                        if fireproximityprompt then fireproximityprompt(prompt) end
                        prompt:InputHoldBegin()
                        task.wait(0.1)
                        prompt:InputHoldEnd()
                    end
                end
            end
        end

        if humanoid then humanoid.Jump = true end
        task.wait(0.2)
    end
end

-- --- LOOP DE FARM (sempre no mesmo destino) ---

task.spawn(function()
    while true do
        if isFarming then
            -- 1. Pega a caixa no ponto inicial
            walkTo(BoxPickupPos, 2.5, 25)
            if not isFarming then continue end
            interactBox()

            -- 2. Usa sempre a única rota disponível
            local currentRoute = Routes[1]
            local waypointsList = currentRoute.Waypoints
            local waypointsCount = #waypointsList

            -- 3. PERCURSO DE IDA (com curva W+A 9s após sair da caixa por 3s)
            local departureTime = tick()
            local curveDone = false
            local firstWp = waypointsList[1]

            -- Caminha até o 1º waypoint monitorando o tempo para inserir a curva
            while isFarming do
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local rootPart = char.HumanoidRootPart

                local currentPos = rootPart.Position
                local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(firstWp.X, 0, firstWp.Z)).Magnitude

                if dist <= 3.5 then break end

                -- Curva W+A (diagonal frente-esquerda) exatamente aos 9s, por 3s
                if not curveDone and (tick() - departureTime) >= 9 then
                    curveDone = true

                    -- Calcula direção diagonal UMA VEZ, baseada no rumo atual até o waypoint
                    local toWp = firstWp - currentPos
                    local flatToWp = Vector3.new(toWp.X, 0, toWp.Z)
                    if flatToWp.Magnitude > 0.1 then
                        flatToWp = flatToWp.Unit
                        local facingCF = CFrame.lookAt(Vector3.zero, flatToWp)
                        local leftVec = -facingCF.RightVector
                        local diagDir = (flatToWp + leftVec).Unit  -- W+A = 45° frente-esquerda

                        local curveEnd = tick() + 3
                        while tick() < curveEnd and isFarming do
                            local c = LocalPlayer.Character
                            if not c then break end
                            local h = c:FindFirstChildOfClass("Humanoid")
                            local r = c:FindFirstChild("HumanoidRootPart")
                            if not h or not r then break end
                            h:MoveTo(r.Position + diagDir * 20)
                            task.wait(0.05)
                        end
                    end
                end

                disableSmallCollisions()
                humanoid:MoveTo(firstWp)
                task.wait(0.1)
            end

            -- Percorre os waypoints restantes normalmente
            for i = 2, waypointsCount do
                walkTo(waypointsList[i], 3.5, 20)
                if not isFarming then break end
                task.wait(0.1)
            end

            -- 4. Realiza a entrega no destino
            if isFarming then
                deliverAtCircle(currentRoute.Target)
            end

            task.wait(0.3)

            -- 5. PERCURSO DE VOLTA
            for i = waypointsCount, 1, -1 do
                walkTo(waypointsList[i], 3.5, 20)
                if not isFarming then break end
                task.wait(0.1)
            end

            walkTo(BoxPickupPos, 2.0, 20)
            task.wait(0.4)
        else
            task.wait(0.5)
        end
    end
end)

-- Botão Liga/Desliga
FarmBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    if isFarming then
        FarmBtn.Text = "Farm Auto: ON"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    else
        FarmBtn.Text = "Farm Auto: OFF"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    end
end)
