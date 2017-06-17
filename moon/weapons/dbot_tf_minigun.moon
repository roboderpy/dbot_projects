
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

AddCSLuaFile()

BaseClass = baseclass.Get('dbot_tf_ranged')

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Heavy'
SWEP.PrintName = 'Minigun'
SWEP.ViewModel = 'models/weapons/c_models/c_heavy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_minigun/c_minigun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 3

SWEP.MuzzleAttachment = 'muzzle'

SWEP.CooldownTime = 0.13
SWEP.BulletDamage = 15
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.015

SWEP.FireSoundsScript = 'Weapon_Minigun.Single'
SWEP.FireCritSoundsScript = 'Weapon_Minigun.Fire'
SWEP.EmptySoundsScript = 'Weapon_Minigun.FireCrit'

SWEP.DrawAnimation = 'pstl_draw'
SWEP.IdleAnimation = 'pstl_idle'
SWEP.AttackAnimation = 'pstl_fire'
SWEP.AttackAnimationCrit = 'pstl_fire'
SWEP.SingleReloadAnimation = true
SWEP.ReloadStart = 'pstl_reload'
SWEP.ReloadDeployTime = 1.12

SWEP.Primary = {
    'Ammo': 'SMG1'
    'ClipSize': -1
    'DefaultClip': 200
    'Automatic': true
}
