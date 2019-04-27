
-- Copyright (C) 2019 DBot

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

import NBT from DLib
import luatype from _G

class DTransitions.DoorSerializer extends DTransitions.PropSerializer
	@SAVENAME = 'doors'

	CanSerialize: (ent) =>
		switch ent\GetClass()
			when 'prop_door_rotating'
				return true
			else
				return false

	GetPriority: => 300

	Serialize: (ent) =>
		tag = super(ent)
		return if not tag

		if kv = @SerializeKeyValues(ent)
			tag\SetTag('keyvalues', kv)

		if sv = @SerializeSavetable(ent)
			tag\SetTag('savetable', sv)

		return tag

	DeserializePost: (ent, tag) =>
		super(ent, tag)

		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'), true)

	DeserializePre: (tag) =>
		local ent

		if tag\HasTag('map_id')
			ent = ents.GetMapCreatedEntity(tag\GetTagValue('map_id'))
			return if not IsValid(ent)
			ent\Remove()
			ent = ents.Create(tag\GetTagValue('classname'))
		else
			ent = ents.Create(tag\GetTagValue('classname'))

		return if not IsValid(ent)

		@DeserializePreSpawn(ent, tag)
		@DeserializeKeyValues(ent, tag\GetTag('keyvalues'))

		if savetable = tag\GetTag('savetable')
			@DeserializeSavetable(ent, savetable)
			if savetable\HasTag('m_angRotationClosed')
				ent\SetAngles(savetable\GetAngle('m_angRotationClosed'))

		ent\Spawn()
		ent\Activate()

		@DeserializePostSpawn(ent, tag)

		return ent