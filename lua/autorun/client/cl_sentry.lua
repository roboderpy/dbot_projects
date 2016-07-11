
local Line = Color(200, 0, 0)

language.Add('dbot_sentry', 'DBot Sentry')
language.Add('dbot_srocket', 'DBot Rocket')
language.Add('dbot_sentry_r', 'DBot Rocket Sentry')

local function PostDrawOpaqueRenderables(a, b)
	if a or b then return end
	--if true then return end
	
	local lpos = LocalPlayer():GetPos()
	
	draw.NoTexture()
	
	for k, ent in ipairs(ents.FindByClass('dbot_srocket')) do
		local target = ent:GetCurTarget()
		if not IsValid(target) then continue end
		
		local pos = DSentry_GetEntityHitpoint(target) + Vector(0, 0, 30)
		local ang = (lpos - pos):Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		
		local add = Vector(0, 12, 0)
		add:Rotate(ang)
		
		cam.Start3D2D(pos + add, ang, 0.2)
		
		surface.SetDrawColor(200, 0, 0)
		
		surface.DrawLine(0, 0, 0, 100)
		surface.DrawLine(50, 50, 0, 0)
		surface.DrawLine(50, 50, 0, 100)
		
		surface.DrawPoly{
			{y = 0, x = 0},
			{y = 100, x = 0},
			{y = 50, x = 50},
		}
		
		cam.End3D2D()
	end
	
	for k, ent in ipairs(ents.FindByClass('dbot_sentry_r')) do
		if not ent.GetIsLocking then continue end
		if not ent:GetIsLocking() then continue end
		local target = ent:GetLockTarget()
		if not IsValid(target) then continue end
		local time = ent:GetLockTime()
		if time == 0 then continue end
		
		local pos = DSentry_GetEntityHitpoint(target) + Vector(0, 0, 30)
		local ang = (lpos - pos):Angle()
		ang:RotateAroundAxis(ang:Right(), -90)
		
		local mult = (5 - time * 4)
		
		local add = Vector(15 * 2 - 15 * mult, 12 * mult, 0)
		add:Rotate(ang)
		
		cam.Start3D2D(pos + add, ang, 0.2)
		
		surface.SetDrawColor(0, 255, 0)
		
		surface.DrawLine(0, 0, 0, 100 * mult)
		surface.DrawLine(50 * mult, 50 * mult, 0, 0)
		surface.DrawLine(50 * mult, 50 * mult, 0, 100 * mult)
		
		cam.End3D2D()
	end
	
	for k, self in ipairs(GetDSentries()) do
		local p = self:GetPos()
		local f = self:GetAngles():Forward()
		
		local tr = util.TraceLine{
			start = p,
			endpos = p + f * 16000,
			filter = {self, self:GetNWEntity('tower'), self:GetNWEntity('stick'), self:GetNWEntity('base'), self:GetNWEntity('antennas')}
		}
		
		render.DrawLine(p, tr.HitPos, Line, true)
	end
end

hook.Add('PostDrawOpaqueRenderables', 'DSentry', PostDrawOpaqueRenderables)
