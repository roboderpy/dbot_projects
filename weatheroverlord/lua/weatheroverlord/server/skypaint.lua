
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local DLib = DLib
local WOverlord = WOverlord
local hook = hook
local CurTime = CurTime
local math = math
local tostring = tostring
local Vector = Vector
local Color = Color
local FrameTime = FrameTime
local Lerp = Lerp
local type = type
local LerpVector = LerpVector
local env_skypaint

local stars = 'skybox/starfield'
local clouds = 'skybox/clouds'

local topDefault = Vector(0.2, 0.5, 1.0)
local bottomDefault = Vector(0.8, 1.0, 1.0)

local function initializeEntity()
	local paint = ents.FindByClass('env_skypaint')

	if #paint > 1 then
		error('wtf? There is ' .. #paint .. ' env_skypaint in total')
	elseif #paint == 0 then
		return
	end

	env_skypaint = paint[1]

	-- set static values
	env_skypaint:SetStarScale(1.28)
	env_skypaint:SetStarLayers(1)
	env_skypaint:SetStarSpeed(0.01)
	env_skypaint:SetHDRScale(0.66)

	env_skypaint:SetDrawStars(true)
	env_skypaint:SetStarTexture(stars)

	env_skypaint:SetTopColor(topDefault)
	env_skypaint:SetBottomColor(bottomDefault)
	env_skypaint:SetFadeBias(1)

	env_skypaint:SetDuskColor(Vector(1.0, 0.2, 0.0))
	env_skypaint:SetDuskScale(1)
	env_skypaint:SetDuskIntensity(1)

	env_skypaint:SetSunNormal(Vector(0.4, 0.0, 0.01))
	env_skypaint:SetSunColor(Vector(0.2, 0.1, 0.0))
	env_skypaint:SetSunSize(1.5)

	-- env_skypaint:SetStarFade(0.78)
end

if AreEntitiesAvaliable() then
	initializeEntity()
end

local meta = DLib.FindMetaTable('WODate')
local emptyVector = Vector(0, 0, 0)
local proxiedValues = {}

local function proxiedCall(callFunc, callString, callValue, lerpFunction, lerpMult)
	local typeIn = type(callValue)
	if typeIn ~= 'string' then
		lerpMult = lerpMult or 6

		if not lerpFunction then
			if typeIn == 'number' then
				lerpFunction = Lerp
			elseif typeIn == 'Vector' then
				lerpFunction = LerpVector
			end
		end

		proxiedValues[callString] = proxiedValues[callString] or callValue
		local newValue = WOverlord.CallWeatherModifier(callString, callValue)
		local lerp = lerpFunction(FrameTime() * lerpMult, proxiedValues[callString], newValue)
		proxiedValues[callString] = lerp
		env_skypaint[callFunc](env_skypaint, lerp)
		return lerp
	else
		local newValue = WOverlord.CallWeatherModifier(callString, callValue)
		env_skypaint[callFunc](env_skypaint, newValue)
		return newValue
	end
end

local function WOverlord_NewSecond()
	if not env_skypaint then return end

	local self = WOverlord.GetCurrentDateAccurate()
	local progression = self:GetDayProgression()
	local progressionLight = self:GetLightProgression()
	local fullNight = progressionLight == 0 or progressionLight == 1
	local semiNight = progression == 0 or progression == 1 and not fullNight
	local noNight = progression ~= 0 and progression ~= 1
	local nightProgression = self:GetNightMultiplier()
	local almostNightStart = progression > 0.9
	local isSunrise = self:IsBeforeMidday()

	local wind = self:GetWindDirection()
	local windSpeed = wind:Length()

	if nightProgression ~= 0 then
		proxiedCall('SetStarSpeed', 'StarSpeed', 0.01)
		proxiedCall('SetStarFade', 'StarFade', 0.78 * nightProgression)
		proxiedCall('SetStarTexture', 'StarTexture', stars)
		proxiedCall('SetStarScale', 'StarScale', 1.28)
	else
		proxiedCall('SetStarSpeed', 'StarSpeed', windSpeed / 400)
		proxiedCall('SetStarFade', 'StarFade', 0.4)
		proxiedCall('SetStarTexture', 'StarTexture', clouds)
		proxiedCall('SetStarScale', 'StarScale', 1.6)
	end

	if not isSunrise then
		if noNight then
			proxiedCall('SetSunSize', 'SunSize', 1.5 * self:GetDayLengthMultiplier())

			if not almostNightStart then
				env_skypaint:SetDuskIntensity(0)
				env_skypaint:SetDuskScale(0)
				env_skypaint:SetFadeBias(1)
			else
				local dusken = (progression - 0.9) * 10
				proxiedCall('SetDuskIntensity', 'DuskIntensity', dusken * 2)
				proxiedCall('SetDuskScale', 'DuskScale', dusken)
				proxiedCall('SetFadeBias', 'FadeBias', 1 - dusken * 0.5)
			end

			if env_skypaint:GetTopColor() ~= topDefault then
				env_skypaint:SetTopColor(topDefault)
			end

			if env_skypaint:GetBottomColor() ~= bottomDefault then
				env_skypaint:SetBottomColor(bottomDefault)
			end
		elseif semiNight then
			proxiedCall('SetDuskScale', 'DuskScale', 1 - nightProgression * 0.5)
			proxiedCall('SetFadeBias', 'FadeBias', 1 - math.Clamp(nightProgression * 3, 0.5, 1))
			proxiedCall('SetSunSize', 'SunSize', math.max(1.5 * self:GetDayLengthMultiplier() * (1 - nightProgression * 1.5), 0))

			if nightProgression > 0.5 then
				proxiedCall('SetDuskIntensity', 'DuskIntensity', 4 * (1 - nightProgression))

				local multSkyColor = 1 - (nightProgression - 0.5) * 2

				local topColor = Color(51, 127, 255) * (multSkyColor ^ 2)
				local bottomColor = Color(204, 255, 255) * multSkyColor * 1.1

				proxiedCall('SetTopColor', 'TopColor', topColor:ToVector())
				proxiedCall('SetBottomColor', 'BottomColor', bottomColor:ToVector())
			end
		elseif fullNight then
			env_skypaint:SetFadeBias(0)
			env_skypaint:SetDuskIntensity(0)
			env_skypaint:SetDuskScale(0)
			env_skypaint:SetSunSize(0)

			env_skypaint:SetTopColor(emptyVector)
			env_skypaint:SetBottomColor(emptyVector)
		end
	else
		local dusken = progression * 10

		if nightProgression > 0.5 then
			proxiedCall('SetDuskIntensity', 'DuskIntensity', (1 - nightProgression) * 2)
			proxiedCall('SetDuskScale', 'DuskScale', 1 - nightProgression)
		elseif nightProgression < 0.5 and nightProgression > 0 then
			env_skypaint:SetDuskIntensity(1.5)
			env_skypaint:SetDuskScale(1)
		elseif nightProgression == 0 and dusken < 1 then
			proxiedCall('SetDuskScale', 'DuskScale', 1 - dusken)
			proxiedCall('SetDuskIntensity', 'DuskIntensity', 1.5 * (1 - dusken))
		else
			env_skypaint:SetDuskScale(0)
			env_skypaint:SetDuskIntensity(0)
		end

		if nightProgression == 1 then
			env_skypaint:SetSunSize(0)
		elseif nightProgression > 0 then
			proxiedCall('SetSunSize', 'SunSize', 1.5 * self:GetDayLengthMultiplier() * (0.5 - nightProgression * 0.5))
		elseif dusken < 1 then
			proxiedCall('SetSunSize', 'SunSize', 1.5 * self:GetDayLengthMultiplier() * (0.5 + dusken * 0.5))
		else
			proxiedCall('SetSunSize', 'SunSize', 1.5 * self:GetDayLengthMultiplier())
		end

		local multSkyColor

		if nightProgression > 0 then
			multSkyColor = (1 - nightProgression) * 0.5
		elseif dusken < 1 then
			multSkyColor = 0.5 + dusken * 0.5
		end

		if multSkyColor then
			local topColor = Color(51, 127, 255) * (multSkyColor ^ 2)
			local bottomColor = Color(204, 255, 255) * multSkyColor * 1.1

			proxiedCall('SetTopColor', 'TopColor', topColor:ToVector())
			proxiedCall('SetBottomColor', 'BottomColor', bottomColor:ToVector())
		else
			if env_skypaint:GetTopColor() ~= topDefault then
				env_skypaint:SetTopColor(topDefault)
			end

			if env_skypaint:GetBottomColor() ~= bottomDefault then
				env_skypaint:SetBottomColor(bottomDefault)
			end
		end
	end
end

hook.Add('InitPostEntity', 'WeatherOverlord_InitializeSkypaint', initializeEntity)
hook.Add('PostCleanupMap', 'WeatherOverlord_InitializeSkypaint', initializeEntity)
hook.Remove('WOverlord_NewSecond', 'WeatherOverlord_Skypaint', WOverlord_NewSecond)
hook.Add('Think', 'WeatherOverlord_Skypaint', WOverlord_NewSecond)