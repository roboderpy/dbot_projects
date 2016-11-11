
--[[
Copyright (C) 2016 DBot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]

AddCSLuaFile('cl_init.lua')

ENT.Type = 'anim'
ENT.PrintName = 'SCP-409 Fragment'
ENT.Author = 'DBot'
ENT.Base = 'dbot_scp409'

function ENT:Initialize()
	self:SetModel('models/props_combine/breenbust_chunk03.mdl')
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	
	self.Rem = CurTime() + 10
	
	self.phys = IsValid(self:GetPhysicsObject()) and self:GetPhysicsObject()
end

function ENT:Push()
	if not self.phys then return end
	self.phys:Wake()
	self.phys:SetVelocity(VectorRand() * math.random(500, 5000))
end

function ENT:Think()
	self.BaseClass.Think(self)
	if self.Rem < CurTime() then self:Remove() end
end

function ENT:Attack(ent)
	local point = self.BaseClass.Attack(self, ent)
	if not point then return end
	point.Crystal = self.Crystal
	
	return point
end
