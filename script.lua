local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local targetPart = nil
local bodyVelocity = nil
local bodyPosition = nil
local connection = nil

-- 드래그 시작 함수
local function startDrag(part)
    targetPart = part
    targetPart.CanCollide = false -- 잡는 동안 벽 뚫기 방지 (선택 사항)
    
    -- 물리 객체 생성 (잡고 있는 효과)
    bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(1, 1, 1) * 1e6
    bodyPosition.D = 1000
    bodyPosition.P = 10000
    bodyPosition.Parent = targetPart
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 1e6
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = targetPart

    connection = RunService.RenderStepped:Connect(function()
        if targetPart and bodyPosition then
            -- 마우스 위치에서 15유닛 떨어진 곳으로 몬스터 이동
            local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
            bodyPosition.Position = ray.Origin + (ray.Direction * 15)
        end
    end)
end

-- 드래그 종료 (던지기)
local function stopDrag()
    if connection then connection:Disconnect() end
    
    if targetPart then
        if bodyPosition then bodyPosition:Destroy() end
        if bodyVelocity then
            -- 마우스 이동 속도를 계산해 던지는 힘 부여
            bodyVelocity.Velocity = mouse.UnitRay.Direction * 100
            game.Debris:AddItem(bodyVelocity, 0.2) -- 0.2초 뒤 힘 제거
        end
        targetPart.CanCollide = true
        targetPart = nil
    end
end

-- 클릭 이벤트
mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if target and target.Parent:FindFirstChild("Humanoid") then
        startDrag(target.Parent.PrimaryPart or target)
    end
end)

mouse.Button1Up:Connect(stopDrag)
