
-- Copyright (C) 2019 DBotThePony

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

import DLib, color_white, hook, MCDeaths, type from _G
import i18n from DLib

hook.Add 'EntityTakeDamage', 'MCDeaths.EntityTakeDamage', (dmg) =>
	return if not @IsPlayer() and not @IsNPC() and type(@) ~= 'NextBot'
	@__mc_tracker = MCDeaths.CombatTracker(@) if not @__mc_tracker
	@__mc_tracker\Track(dmg)
	return

hook.Add 'PlayerSpawn', 'MCDeaths.PlayerSpawn', =>
	@__mc_tracker = MCDeaths.CombatTracker(@) if not @__mc_tracker
	@__mc_tracker\ForceClear()
	return


hook.Add 'PlayerDeath', 'MCDeaths.PlayerDeath', (inflictor, attacker) =>
	@__mc_tracker = MCDeaths.CombatTracker(@) if not @__mc_tracker
	strategy = @__mc_tracker\GetStrategy()
	return if not strategy
	text = {strategy\GetText()}
	return if text[1] == false
	rebuild = i18n.rebuildTable(text, color_white, true)

	MsgC(color_white, unpack(rebuild, 1, #rebuild))
	MsgC('\n')

	return

hook.Add 'OnNPCKilled', 'MCDeaths.PlayerDeath', (attacker, inflictor) =>
	return if not @__mc_tracker
	strategy = @__mc_tracker\GetStrategy()
	return if not strategy
	text = {strategy\GetText()}
	return if text[1] == false
	rebuild = i18n.rebuildTable(text, color_white, true)

	MsgC(color_white, unpack(rebuild, 1, #rebuild))
	MsgC('\n')

	return

ent.__mc_tracker = nil for ent in *ents.GetAll()
