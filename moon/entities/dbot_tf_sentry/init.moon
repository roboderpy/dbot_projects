
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

include 'shared.lua'
AddCSLuaFile 'shared.lua'

util.AddNetworkString('DTF2.SentryWing')

VALID_TARGETS = {}

isEnemy = (ent = NULL) ->
    return false if not ent\IsValid()
    return IsEnemyEntityName(ent\GetClass())

timer.Create 'DTF2.FetchTargets', 0.5, 0, ->
    VALID_TARGETS = for ent in *ents.GetAll()
        continue if not ent\IsNPC()
        continue if not isEnemy(ent)
        {ent, ent\GetPos(), ent\OBBMins(), ent\OBBMaxs(), ent\OBBCenter()}

ENT.MAX_DISTANCE = 512 ^ 2
ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @targetAngle = Angle(0, 0, 0)
    @currentAngle = Angle(0, 0, 0)
    @moveSpeed = 2
    @idleAnim = true
    @idleAngle = Angle(0, 0, 0)
    @idleDirection = false
    @idleYaw = 0
    @center = @OBBCenter()
    @currentTarget = NULL
    @idleWaitOnAngle = 0
    @lastSentryThink = CurTime()
    @nextTargetUpdate = 0

ENT.GetTargetsVisible = =>
    output = {}
    pos = @GetPos()

    for ply in *player.GetAll()
        ppos = ply\GetPos()
        dist = pos\DistToSqr(ppos)
        if ply ~= @GetPlayer() and dist < @MAX_DISTANCE
            table.insert(output, {ply, ppos, dist, ply\OBBCenter()})
    
    for {target, tpos, mins, maxs, center} in *VALID_TARGETS
        dist = pos\DistToSqr(tpos)
        if target\IsValid() and dist < @MAX_DISTANCE
            table.insert(output, {target, tpos, dist, center})
    
    table.sort output, (a, b) -> a[3] < b[3]
    newOutput = {}

    for {target, tpos, dist, center} in *output
        trData = {
            filter: @
            start: @center + pos
            endpos: center + tpos
        }

        tr = util.TraceLine(trData)
        if tr.Hit and tr.Entity == target
            table.insert(newOutput, target)

    return newOutput

ENT.GetFirstVisible = =>
    output = {}
    pos = @GetPos()

    for ply in *player.GetAll()
        ppos = ply\GetPos()
        dist = pos\DistToSqr(ppos)
        if ply ~= @GetPlayer() and dist < @MAX_DISTANCE
            table.insert(output, {ply, ppos, dist, ply\OBBCenter()})
    
    for {target, tpos, mins, maxs, center} in *VALID_TARGETS
        dist = pos\DistToSqr(tpos)
        if target\IsValid() and dist < @MAX_DISTANCE
            table.insert(output, {target, tpos, dist, center})
    
    table.sort output, (a, b) -> a[3] < b[3]

    for {target, tpos, dist, center} in *output
        trData = {
            filter: @
            start: @center + pos
            endpos: center + tpos
        }

        tr = util.TraceLine(trData)
        if tr.Hit and tr.Entity == target
            return target

    return NULL

ENT.PlayScanSound = =>
    switch @GetLevel()
        when 1
            @EmitSound('weapons/sentry_scan.wav')
        when 2
            @EmitSound('weapons/sentry_scan2.wav')
        when 3
            @EmitSound('weapons/sentry_scan3.wav')

ENT.Think = =>
    cTime = CurTime()
    delta = cTime - @lastSentryThink
    @lastSentryThink = cTime
    @BaseClass.Think(@)
    if not @IsAvaliable()
        @currentTarget = NULL
        return
    
    if @nextTargetUpdate < cTime
        @nextTargetUpdate = cTime + 0.1
        newTarget = @GetFirstVisible()
        if newTarget ~= @currentTarget
            @currentTarget = newTarget
            if IsValid(newTarget)
                net.Start('DTF2.SentryWing', true)
                net.WriteEntity(@)
                net.WriteEntity(newTarget)
                net.Broadcast()
    
    if IsValid(@currentTarget)
        @currentTargetPosition = @currentTarget\GetPos() + @currentTarget\OBBCenter()
        @idleWaitOnAngle = cTime + 2
        @targetAngle = (@currentTargetPosition - @GetPos() - @obbcenter)\Angle()
        @idleAngle = @targetAngle
        @idleAnim = false
        @idleDirection = false
        @idleYaw = 0
    else
        @idleAnim = true
        if @idleWaitOnAngle < cTime
            @idleAngle = @GetAngles()
        
        @idleYaw += delta * @SENTRY_SCAN_YAW_MULT if @idleDirection
        @idleYaw -= delta * @SENTRY_SCAN_YAW_MULT if not @idleDirection
        if @idleYaw > @SENTRY_SCAN_YAW_CONST or @idleYaw < -@SENTRY_SCAN_YAW_CONST
            @idleDirection = not @idleDirection
            @PlayScanSound()
        {:p, :y, :r} = @idleAngle
        @targetAngle = Angle(p, y + @idleYaw, r)
    
    diffPitch = math.Clamp(math.AngleDifference(@currentAngle.p, @targetAngle.p), -2, 2)
    diffYaw = math.Clamp(math.AngleDifference(@currentAngle.y, @targetAngle.y), -2, 2)
    newPitch = @currentAngle.p - diffPitch * delta * @SENTRY_ANGLE_CHANGE_MULT
    newYaw = @currentAngle.y - diffYaw * delta * @SENTRY_ANGLE_CHANGE_MULT
    @currentAngle = Angle(newPitch, newYaw, 0)
    {p: cp, y: cy, r: cr} = @GetAngles()
    posePitch = math.floor(math.NormalizeAngle(cp - newPitch))
    poseYaw = math.floor(math.NormalizeAngle(cy - newYaw))
    
    @SetAimPitch(posePitch)
    @SetAimYaw(poseYaw)

    if IsValid(@currentTarget)
        lookingAtTarget = math.floor(diffPitch) == 0 and math.floor(diffYaw) == 0
        print lookingAtTarget, diffPitch, diffYaw
        print math.floor(newPitch), math.floor(@targetAngle.p), math.floor(newYaw), math.floor(@targetAngle.y)
    @NextThink(cTime)
    return true
