-- Cameracode.lua
Cameracode = {}

-- the equivalent of a unity public variable but this time we have to do self.variable name in a specific class if we want to access it in other places
function Cameracode:Create()
    self.velocity = Vec()
    self.moveSpeed = 4.5
    self.negativeMoveSpeed = -2.5
    self.gravity = 0
    self.lookSpeed = 20
    self.rotation = Vec()
end

-- set up some vars when launching the game
function Cameracode:Start()
    System.SetWindowTitle("maez runner")
    if not (System.IsFullscreen) then
        System.SetFullscreen(fullscreen)
    end
end

-- game ticks once per frame
function Cameracode:Tick(deltaTime)
    self.velocity.y = self.velocity.y + self.gravity * deltaTime

    if (Input.IsKeyDown(Key.W)) then
        self.velocity.z = -self.moveSpeed
    elseif (Input.IsKeyDown(Key.S)) then
        self.velocity.z = -self.negativeMoveSpeed
    else
        self.velocity.z = 0
    end

    if (Input.IsKeyDown(Key.A)) then
        self.velocity.x = -self.moveSpeed

    elseif (Input.IsKeyDown(Key.D)) then
        self.velocity.x = self.moveSpeed
    else
        self.velocity.x = 0
    end

    -- mouse deltas and the rotation math
    local deltaX, deltaY = Input.GetMouseDelta()
    self.rotation.x = -deltaY * self.lookSpeed
    self.rotation.y = -deltaX * self.lookSpeed

    if (Engine.GetPlatform() == "3DS") then
        -- 3ds movement code for the left joystick
        local leftAxisX = Input.GetGamepadAxisValue(Gamepad.AxisLX)
        local leftAxisY = Input.GetGamepadAxisValue(Gamepad.AxisLY)
        -- centering the 3ds joystick
        local leftCenterX = (leftAxisX - 0.5) * 2
        local leftCenterY = (leftaxisY - 0.5) * 2
        self.velocity.x = leftCenterX
        self.velocity.y = leftCenterY
        -- 3ds right joystick (if it exists) and rotation calculation
        local rightAxisX = Input.GetGamepadAxisValue(Gamepad.AxisRX)
        local rightAxisY = Input.GetGamepadAxisValue(Gamepad.AxisRY)
        -- centering the 3ds joystick
        local rightCenterX = (rightAxisX - 0.5) * 2
        local rightCenterY = (rightAxisY - 0.5) * 2
        self.rotation.x = rightCenterX * self.lookSpeed
        self.rotation.y = rightCenterY * self.lookSpeed
    end

    -- update world rotation
    local rot = self:GetWorldRotation()
    rot = rot + self.rotation * deltaTime
    rot.x = math.max(-90, math.min(90, rot.x)) -- Optional: clamp pitch
    self:SetWorldRotation(rot)

    -- Calculate yaw in radians
    local yaw = math.rad(rot.y)

    -- Rotate velocity vector according to yaw angle:
    local dir = Vec(
        self.velocity.z * math.sin(yaw) + self.velocity.x * math.cos(yaw),  -- world X (right)
        self.velocity.y,
        self.velocity.z * math.cos(yaw) - self.velocity.x * math.sin(yaw)   -- world Z (forward)
    )

    -- update world position
    local newPos = self:GetWorldPosition()
    newPos = newPos + dir * deltaTime
    self:SetWorldPosition(newPos)
end