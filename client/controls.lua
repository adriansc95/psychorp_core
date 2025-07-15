-- DESHABILITAR EL STEALTH MODE
CreateThread(function()
    while true do
        Wait(0)
        DisableControlAction(0, 36, true)
    end
end)

-- AGACHARSE, BOTÓN CTRL
local crouched = false

function toggleCrouch()
    local ped = PlayerPedId()
    RequestAnimSet("move_ped_crouched")
    while not HasAnimSetLoaded("move_ped_crouched") do
        Wait(100)
    end

    if not crouched then
        SetPedMovementClipset(ped, "move_ped_crouched", 0.25)
        crouched = true
        print("Agachado")
    else
        ResetPedMovementClipset(ped, 0.25)
        crouched = false
        print("De pie")
    end
end

RegisterCommand('crouch', function()
    toggleCrouch()
end)

RegisterKeyMapping('crouch', '~g~[Animations]~s~ Crouch', 'keyboard', 'LCONTROL')

-- FUNCIÓN PARA LEVANTAR LAS MANOS, BOTÓN X
local handsUp = false

function toggleHandsUp()
    local ped = PlayerPedId()
    RequestAnimDict("random@mugging3")
    while not HasAnimDictLoaded("random@mugging3") do
        Wait(100)
    end

    if not handsUp then
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
        TaskPlayAnim(ped, "random@mugging3", "handsup_standing_base", 8.0, -8, -1, 49, 0, 0, 0, 0)
        handsUp = true
        print("Manos arriba")
    else
        ClearPedSecondaryTask(ped)
        handsUp = false
        print("Manos abajo")
    end
end

RegisterCommand('handsup', function()
    toggleHandsUp()
end)

RegisterKeyMapping('handsup', '~g~[Animations]~s~ Hands Up', 'keyboard', 'X')

-- SEÑALAR, CON EL BOTÓN B
local mp_pointing = false

function startPointing()
    local ped = PlayerPedId()
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

function stopPointing()
    local ped = PlayerPedId()
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, 1) then
        SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
    end
    SetPedConfigFlag(ped, 36, 0)
    ClearPedSecondaryTask(ped)
end

RegisterCommand('point', function()
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        if mp_pointing then
            stopPointing()
            mp_pointing = false
        else
            startPointing()
            mp_pointing = true
        end
        while mp_pointing do
            local ped = PlayerPedId()
            local camPitch = GetGameplayCamRelativePitch()
            if camPitch < -70.0 then
                camPitch = -70.0
            elseif camPitch > 42.0 then
                camPitch = 42.0
            end
            camPitch = (camPitch + 70.0) / 112.0

            local camHeading = GetGameplayCamRelativeHeading()
            local cosCamHeading = Cos(camHeading)
            local sinCamHeading = Sin(camHeading)
            if camHeading < -180.0 then
                camHeading = -180.0
            elseif camHeading > 180.0 then
                camHeading = 180.0
            end
            camHeading = (camHeading + 180.0) / 360.0

            local blocked = 0
            local nn = 0

            local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
            local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
            nn,blocked,coords,coords = GetRaycastResult(ray)

            Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
            Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
            Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
            Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
            Wait(1)
        end
    end
end)
RegisterKeyMapping('point', '~g~[Animations]~s~ Point-Finger', 'keyboard', 'B')

-- CRUZAR DE BRAZOS, BOTÓN Z
local armsCrossed = false

function toggleArmsCrossed()
    local ped = PlayerPedId()
    RequestAnimDict("anim@amb@business@bgen@bgen_no_work@")
    while not HasAnimDictLoaded("anim@amb@business@bgen@bgen_no_work@") do
        Wait(100)
    end

    if not armsCrossed then
        TaskPlayAnim(ped, "anim@amb@business@bgen@bgen_no_work@", "stand_phone_phoneputdown_idle_nowork", 8.0, -8.0, -1, 49, 0, false, false, false)
        armsCrossed = true
        print("Brazos cruzados")
    else
        ClearPedSecondaryTask(ped)
        armsCrossed = false
        print("Brazos desencruzados")
    end
end

RegisterCommand('crossarms', function()
    toggleArmsCrossed()
end)

RegisterKeyMapping('crossarms', '~g~[Animations]~s~ Cross Arms', 'keyboard', 'Z')