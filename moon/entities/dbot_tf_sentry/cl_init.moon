
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

MUZZLE_BONE_ID_1 = 4
MUZZLE_BONE_ID_2_L = 7
MUZZLE_BONE_ID_2_R = 8
MUZZLE_BONE_ID_3_L = 5
MUZZLE_BONE_ID_3_R = 12
MUZZLE_ANIM_TIME = 0.3

ENT.Initialize = =>
    @BaseClass.Initialize(@)
    @SetAimPitch(0)
    @SetAimYaw(0)
    @lastPitch = 0
    @lastYaw = 0
    @fireAnim = 0
    @isEmpty = false

ENT.Draw = =>
    deltaFireAnim = @fireAnim - CurTime()
    pitchAdd = 0

    switch @GetLevel()
        when 1
            if deltaFireAnim > 0
                deltaFireAnimNormal = math.abs(0.3 - deltaFireAnim / MUZZLE_ANIM_TIME)
                pitchAdd += deltaFireAnimNormal * 5 if not @isEmpty
                @ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector(0, 0, -deltaFireAnimNormal * 4))
            else
                @ManipulateBonePosition(MUZZLE_BONE_ID_1, Vector())
        when 2
            if deltaFireAnim > 0
                deltaFireAnimNormal = math.abs(deltaFireAnim / MUZZLE_ANIM_TIME)
                ang = Angle(0, -180 + deltaFireAnimNormal * 360, 0)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_2_L, ang)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_2_R, ang)
            else
                ang = Angle(0, 0, 0)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_2_L, ang)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_2_R, ang)
        when 3
            if deltaFireAnim > 0
                deltaFireAnimNormal = math.abs(deltaFireAnim / MUZZLE_ANIM_TIME)
                ang = Angle(0, -180 + deltaFireAnimNormal * 360, 0)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_3_L, ang)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_3_R, ang)
            else
                ang = Angle(0, 0, 0)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_3_L, ang)
                @ManipulateBoneAngles(MUZZLE_BONE_ID_3_R, ang)
    
    diffPitch = math.AngleDifference(@lastPitch, @GetAimPitch())
    diffYaw = math.AngleDifference(@lastYaw, @GetAimYaw())
    @lastPitch = Lerp(FrameTime() * 10, @lastPitch, @lastPitch - diffPitch)
    @lastYaw = Lerp(FrameTime() * 10, @lastYaw, @lastYaw - diffYaw)
    -- Random is a GetAttachment fix
    @SetPoseParameter('aim_pitch', @lastPitch + pitchAdd + math.random(1, 2) / 100)
    @SetPoseParameter('aim_yaw', @lastYaw + math.random(1, 2) / 100)
    @InvalidateBoneCache()
    @BaseClass.Draw(@)

net.Receive 'DTF2.SentryWing', ->
    sentry = net.ReadEntity()
    return if not IsValid
    target = net.ReadEntity()
    if target ~= LocalPlayer()
        sentry\EmitSound('weapons/sentry_spot.wav', SNDLVL_85dB)
    else
        sentry\EmitSound('weapons/sentry_spot_client.wav', SNDLVL_105dB)

net.Receive 'DTF2.SentryFire', ->
    sentry = net.ReadEntity()
    return if not IsValid
    isEmpty = not net.ReadBool()
    sentry.isEmpty = isEmpty
    sentry.fireAnim = CurTime() + MUZZLE_ANIM_TIME
    
    if not isEmpty
        switch sentry\GetLevel()
            when 1
                with sentry\GetAttachment(sentry\LookupAttachment('muzzle'))
                    ParticleEffect('muzzle_sentry', .Pos, .Ang, @)
            when 2
                sentry.nextMuzzle = not sentry.nextMuzzle
                with sentry\GetAttachment(sentry\LookupAttachment(sentry.nextMuzzle and 'muzzle_l' or 'muzzle_r'))
                    ParticleEffect('muzzle_sentry2', .Pos, .Ang, @)
            when 3
                sentry.nextMuzzle = not sentry.nextMuzzle
                with sentry\GetAttachment(sentry\LookupAttachment(sentry.nextMuzzle and 'muzzle_l' or 'muzzle_r'))
                    ParticleEffect('muzzle_sentry2', .Pos, .Ang, @)