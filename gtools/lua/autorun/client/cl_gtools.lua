--[[
Copyright (C) 2016-2019 DBotThePony


-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

]]

module('GTools', package.seeall)

surface.CreateFont('MultiTool.ScreenHeader', {
	font = 'Roboto',
	size = 48,
	weight = 800,
})

function MultiTool_AddSorterChoices(pnl)
	pnl:AddChoice('Unsorted', '1')
	pnl:AddChoice('Select the nearests to fire point first', '2')
	pnl:AddChoice('Select the far to fire point first', '3')
	pnl:AddChoice('Select x - X', '4')
	pnl:AddChoice('Select X - x', '5')
	pnl:AddChoice('Select y - Y', '6')
	pnl:AddChoice('Select Y - y', '7')

	pnl:AddChoice('Select x+y - X+Y', '8')
	pnl:AddChoice('Select X+Y - x+y', '9')
	pnl:AddChoice('Select x+Y - X+y', '10')
	pnl:AddChoice('Select X+y - x+Y', '11')
end

_G.MultiTool_AddSorterChoices = MultiTool_AddSorterChoices

function BuildPhysgunMenu(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	Panel:CheckBox('Draw physgun beams', 'physgun_drawbeams')
	Panel:CheckBox('Draw physgun halos', 'physgun_halo')
	Panel:NumSlider('Sensitivity', 'physgun_rotation_sensitivity', 0, 2, 4)
	Panel:NumSlider('Wheel speed', 'physgun_wheelspeed', 0, 5000, 0)

	local button = Panel:Button('Reset to default')

	function button:DoClick()
		RunConsoleCommand('physgun_drawbeams', '1')
		RunConsoleCommand('physgun_halo', '1')
		RunConsoleCommand('physgun_rotation_sensitivity', '0.05')
		RunConsoleCommand('physgun_wheelspeed', '10')
	end
end

PhysgunVars = {
	{'physgun_DampingFactor', 'Damping Factor', 0, 4, 2},
	{'physgun_maxAngular', 'Max Angular Velocity', 0, 32000, 0},
	{'physgun_maxAngularDamping', 'Max Angular Velocity Damping', 0, 32000, 0},
	{'physgun_maxrange', 'Max Range', 0, 8192, 0},
	{'physgun_maxSpeed', 'Max Speed', 0, 32000, 0},
	{'physgun_maxSpeedDamping', 'Max Speed Damping', 0, 32000, 0},
	{'physgun_timeToArrive', 'Time to arrive', 0, 4, 2},
	{'physgun_timeToArriveRagdoll', 'Time to arrive for ragdoll', 0, 4, 2},
}

PhysgunVarsDefault = {
	{'physgun_DampingFactor', '0.8'},
	{'physgun_limited', '0'},
	{'physgun_maxAngular', '5000'},
	{'physgun_maxAngularDamping', '10000'},
	{'physgun_maxrange', '4096'},
	{'physgun_maxSpeed', '5000'},
	{'physgun_maxSpeedDamping', '10000'},
	{'physgun_rotation_sensitivity', '0.05'},
	{'physgun_teleportDistance', '0'},
	{'physgun_timeToArrive', '0.05'},
	{'physgun_timeToArriveRagdoll', '0.01'},
}

Sliders = Sliders or {}

function BuildPhysgunMenuAdmin(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	local lab = Label('Only super admin can change this settings', Panel)
	lab:SetDark(true)
	Panel:AddItem(lab)

	local lab = Label('If you are an server owner and want to disable this menu\nyou need to set gtools_disable_physgun_config to 1 in server console.', Panel)
	lab:SetDark(true)
	lab:SetTooltip(lab:GetText())
	lab:SizeToContents()
	Panel:AddItem(lab)

	for k, data in ipairs(PhysgunVars) do
		local slider = Panel:NumSlider(data[2], '', data[3], data[4], data[5])
		slider:SetTooltip(data[2])

		Sliders[data[1]] = slider

		local ignore = true

		function slider:OnValueChanged(val)
			if ignore then return end

			timer.Create('_g_set_' .. data[1], 1, 1, function()
				RunConsoleCommand('_g_' .. data[1], tostring(val))
			end)

			timer.Create('_g_get_' .. data[1], 2, 1, function()
				if not IsValid(slider) then return end
				slider:SetValue(tonumber(GetGlobalString(data[1], 0) or 0) or 0)
			end)
		end

		timer.Simple(0.5, function()
			if IsValid(slider) then
				ignore = true
				slider:SetValue(tonumber(GetGlobalString(data[1], 0) or 0) or 0)
				ignore = false
			end
		end)
	end

	local button = Panel:Button('Reset to default')

	function button:DoClick()
		for i, data in ipairs(PhysgunVarsDefault) do
			if IsValid(Sliders[data[1]]) then
				Sliders[data[1]]:SetValue(tonumber(data[2]))
			end
		end
	end
end

function About(Panel)
	if not IsValid(Panel) then return end
	Panel:Clear()

	local lab = Label('GTools: By DBotThePony(Robot)', Panel)
	lab:SetDark(true)
	Panel:AddItem(lab)

	local button = Panel:Button('GTools workshop link')

	function button:DoClick()
		gui.OpenURL('http://steamcommunity.com/sharedfiles/filedetails/?id=796786540')
	end

	local button = Panel:Button('GTools repository')

	function button:DoClick()
		gui.OpenURL('https://gitlab.com/DBotThePony/DBotProjects')
	end

	local button = Panel:Button('Questions or ideas? Join Discord!')

	function button:DoClick()
		gui.OpenURL('https://discord.gg/HG9eS79')
	end
end

function PreRender()
	if not LocalPlayer():IsValid() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not wep:IsValid() then return end

	if wep:GetClass() ~= 'gmod_tool' then return end

	pcall(hook.Run, 'PreDrawAnythingToolgun', LocalPlayer(), wep, wep:GetMode())
end

function PostDrawTranslucentRenderables(a, b)
	if a or b then return end
	if not LocalPlayer():IsValid() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not wep:IsValid() then return end

	if wep:GetClass() ~= 'gmod_tool' then return end

	hook.Run('PostDrawWorldToolgun', LocalPlayer(), wep, wep:GetMode())
end

function PreDrawOpaqueRenderables(a, b)
	if a or b then return end
	if not LocalPlayer():IsValid() then return end
	local wep = LocalPlayer():GetActiveWeapon()
	if not wep:IsValid() then return end

	if wep:GetClass() ~= 'gmod_tool' then return end

	hook.Run('PreDrawWorldToolgun', LocalPlayer(), wep, wep:GetMode())
end

local Green = Color(0, 200, 0)
local Gray = Color(200, 200, 200)

function ChatPrint(...)
	chat.AddText(Green, '[GTools] ', Gray, ...)
end

function AutoSelectOptions(Panel, ToolClass)
	local Lab = Label('Auto-select settings')
	Lab:SetDark(true)
	Panel:AddItem(Lab)

	Panel:NumSlider('Auto Select Range', ToolClass .. '_select_range', 1, 1024, 0)
	Panel:CheckBox('Auto Select by Model', ToolClass .. '_select_model')
	Panel:CheckBox('Auto Select by Color', ToolClass .. '_select_color')
	Panel:CheckBox('Auto Select inverts selection', ToolClass .. '_select_invert')
	Panel:CheckBox('Auto Select only owned by you entities (Needs CPPI)', ToolClass .. '_select_owned')
	Panel:CheckBox('Select only constrained entities', ToolClass .. '_select_only_constrained')
	Panel:CheckBox('Print auto selection into console', ToolClass .. '_select_print')

	local Lab = Label('Firing at entity with color will invert that option\nEntities without color will be selected instead')
	Lab:SetDark(true)
	Lab:SizeToContents()
	Panel:AddItem(Lab)

	Panel:CheckBox('Auto Select by Material', ToolClass .. '_select_material')

	local Lab = Label('Note: It is strict lookup. Material mismatch - don\'t select')
	Lab:SetDark(true)
	Panel:AddItem(Lab)

	local combo = Panel:ComboBox('Select Sort Mode', ToolClass .. '_select_sort')

	MultiTool_AddSorterChoices(combo)
end

function GenericSelectPicker(Panel, ToolClass)
	local Lab = Label('Entity select color')
	Lab:SetDark(true)
	Lab:SizeToContents()
	Panel:AddItem(Lab)

	local mixer = vgui.Create('DColorMixer', Panel)
	Panel:AddItem(mixer)
	mixer:SetConVarR(ToolClass .. '_select_r')
	mixer:SetConVarG(ToolClass .. '_select_g')
	mixer:SetConVarB(ToolClass .. '_select_b')
	mixer:SetAlphaBar(false)

	return mixer
end

function GenericMultiselectReceive(tabToInsert, cvar)
	local read = ReadEntityList()

	for k, new in ipairs(read) do
		local hit = false

		for i, ent in ipairs(tabToInsert) do
			if ent == new then
				if cvar.select_invert:GetBool() then
					table.remove(tabToInsert, i)
				end

				hit = true
				break
			end
		end

		if not hit then
			table.insert(tabToInsert, new)
		end
	end

	ChatPrint('Auto Selected ' .. #read .. ' entities')

	if cvar.select_print:GetBool() then
		ChatPrint('Look into console for the list')

		for k, v in ipairs(read) do
			PrintEntity(v)
		end
	end
end

net.Receive('GTools.PrintMessage', function()
	ChatPrint(unpack(net.ReadTable()))
end)

net.Receive('GTools.ConsoleMessage', function()
	Message(unpack(net.ReadTable()))
end)

hook.Add('PopulateToolMenu', 'GTools.SpawnMenu', function()
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'GTool.About', 'About GTools', '', '', About)
	spawnmenu.AddToolMenuOption('Utilities', 'User', 'GTool.PhysgunSettings', 'Physgun Settings', '', '', BuildPhysgunMenu)
	spawnmenu.AddToolMenuOption('Utilities', 'Admin', 'GTool.PhysgunSettingsAdmin', 'Physgun Settings', '', '', BuildPhysgunMenuAdmin)
end)

hook.Add('PostDrawTranslucentRenderables', 'GTools.DrawHooks', PostDrawTranslucentRenderables)
hook.Add('PreDrawOpaqueRenderables', 'GTools.DrawHooks', PreDrawOpaqueRenderables)
hook.Add('PreRender', 'GTools.DrawHooks', PreRender)
