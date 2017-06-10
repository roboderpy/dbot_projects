AddCSLuaFile()
local BaseClass = baseclass.Get('dbot_tf_ranged')
SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Engineer'
SWEP.PrintName = 'Shotgun'
SWEP.ViewModel = 'models/weapons/c_models/c_engineer_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_shotgun/c_shotgun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false
SWEP.SingleCrit = true
SWEP.MuzzleAttachment = 'muzzle'
SWEP.MuzzleEffect = 'muzzle_shotgun'
SWEP.BulletDamage = 9
SWEP.BulletsAmount = 6
SWEP.ReloadBullets = 1
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.05
SWEP.DefaultViewPunch = Angle(-3, 0, 0)
SWEP.FireSoundsScript = 'Weapon_Shotgun.Single'
SWEP.FireCritSoundsScript = 'Weapon_Shotgun.SingleCrit'
SWEP.EmptySounds = 'Weapon_Shotgun.Empty'
SWEP.Primary = {
  ['Ammo'] = 'Buckshot',
  ['ClipSize'] = 6,
  ['DefaultClip'] = 6,
  ['Automatic'] = true
}