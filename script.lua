local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local targetPart = nil
local bp = nil -- 위치 고정용
local connection = nil

local function stopDrag()
    if connection then connection:Disconnect(); connection = nil end
    if bp then bp:Destroy(); bp = nil end
    if targetPart then
        -- 던지기: 마우스 방향으로 강한 힘 전달
        targetPart.AssemblyLinearVelocity = mouse.UnitRay.Direction * 200 + Vector3.new(0, 50, 0)
        targetPart = nil
    end
end

mouse.Button1Down:Connect(function()
    local hit = mouse.Target
    if hit and hit.Parent:FindFirstChild("Humanoid") then
        local char = hit.Parent
        -- 잡힌 대상이 나 자신이 아닐 때만 작동
        if char.Name ~= player.Name then
            targetPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            
            if targetPart then
                -- 플레이어의 네트워크 소유권 문제를 우회하기 위해 강한 물리력 사용
                bp = Instance.new("BodyPosition")
                bp.MaxForce = Vector3.new(1, 1, 1) * math.huge
                bp.P = 20000
                bp.D = 1000
                bp.Parent = targetPart
                
                connection = RunService.RenderStepped:Connect(function()
                    if bp then
                        -- 카메라 앞 15유닛 지점으로 끌고 다님
                        local dragPos = camera.CFrame.Position + (mouse.UnitRay.Direction * 15)
                        bp.Position = dragPos
                    end
                end)
            end
        end
    end
end)

mouse.Button1Up:Connect(stopDrag)
