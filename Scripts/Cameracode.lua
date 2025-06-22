-- Cameracode.lua --
Cameracode = {}

    -- the equivalent of a unity public variable but this time we have to do self.variable name in a specific class if we want to access it in other places
function Cameracode:Create()
    self.velocity = Vec()
    self.moveSpeed = 4.5
    self.negativeMoveSpeed = -2.5
    self.moveMultiplier = 2.5
    self.gravity = 0
    self.lookSpeed = 20
    self.rotation = Vec()
    self.maxPitch = 35
    self.resolution = Renderer.GetScreenResolution()
    self.debugCamera = false
    self.deadzone = 0.1
end

    -- set up some vars when launching the game
function Cameracode:Start()
    Log.Debug("GameStart!")
    System.SetWindowTitle("maez runner")
    if not (System.IsFullscreen) then
        System.SetFullscreen(fullscreen)
    end
    Input.ShowCursor(false) -- hides the cursor

    if (self.debugCamera) then
        self.gravity = 0
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

        -- if you hold space or left ctrl you go up or down but this is only if debug vars are set true
    if (Input.IsKeyDown(Key.Space) and self.debugCamera) then
        self.velocity.y = self.moveSpeed
    elseif (Input.IsKeyDown(Key.ControlL) and self.debugCamera) then
        self.velocity.y = -self.moveSpeed
    else
        self.velocity.y = 0
    end

        -- if you hold the left shift key down you run
    if (Input.IsKeyDown(Key.ShiftL)) then
        self.velocity.x = self.velocity.x * self.moveMultiplier
        self.velocity.y = self.velocity.y * self.moveMultiplier
        self.velocity.z = self.velocity.z * self.moveMultiplier
    end

        -- mouse deltas and the rotation math
    local deltaX, deltaY = Input.GetMouseDelta()
    self.rotation.x = -deltaY * self.lookSpeed
    self.rotation.y = -deltaX * self.lookSpeed
    
        -- checks if you have a controller then runs this code
    if (Engine.GetPlatform() == "3DS") then
            -- controller movement code for the left joystick
        local leftAxisX = Input.GetGamepadAxisValue(Gamepad.AxisLX)
        local leftAxisY = Input.GetGamepadAxisValue(Gamepad.AxisLY)

            -- apply controller deadzone
        leftAxisX = deadzone(leftAxisX, self.deadzone)
        leftAxisY = deadzone(leftAxisY, self.deadzone)

        self.velocity.x = leftAxisX * self.moveSpeed
        self.velocity.z = -leftAxisY * self.moveSpeed

            -- right joystick (if it exists) and rotation calculation
        local rightAxisX = Input.GetGamepadAxisValue(Gamepad.AxisRY)
        local rightAxisY = Input.GetGamepadAxisValue(Gamepad.AxisRX)

        self.rotation.x = rightAxisX * self.lookSpeed * self.moveMultiplier
        self.rotation.y = -rightAxisY * self.lookSpeed * self.moveMultiplier

            -- if you hold your left bumper you run
        if (Input.IsGamepadDown(Gamepad.R1)) then
            self.velocity.x = self.velocity.x * self.moveMultiplier
            self.velocity.z = self.velocity.z * self.moveMultiplier
        end

            -- basically running but with your mouse because the whole value given by the game engine is really bad :(
        if (Input.IsGamepadDown(Gamepad.R2)) then
            self.rotation.x = self.rotation.x * self.moveMultiplier
            self.rotation.y = self.rotation.y * self.moveMultiplier
        end
    end

        -- update world rotation
    local rot = self:GetWorldRotation()
    rot = rot + self.rotation * deltaTime
    rot.x = math.max(-self.maxPitch, math.min(self.maxPitch, rot.x)) -- clamp pitch
    self:SetWorldRotation(rot)

        -- get yaw in radians
    local yaw = math.rad(rot.y)

        -- rotate velocity vector according to yaw angle:
    local dir = Vec(
        self.velocity.z * math.sin(yaw) + self.velocity.x * math.cos(yaw),  -- world X (right)
        self.velocity.y,
        self.velocity.z * math.cos(yaw) - self.velocity.x * math.sin(yaw)   -- world Z (forward)
    )

        -- update world position
    local newPos = self:GetWorldPosition()
    newPos = newPos + dir * deltaTime
    self:SetWorldPosition(newPos)
    Input.SetCursorPosition(self.resolution.x / 2, self.resolution.y / 2)
end

function Cameracode:Stop()
    Input.ShowCursor(true)
end

function deadzone(value, threshold)
    if math.abs(value) < threshold then
        return 0
    else
        return value
    end
end
