
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

import DMaps, vgui, ScrW, ScrH, color_white, TOP, LEFT, RIGHT, BOTTOM, surface, table from _G
import WaypointsDataContainer, ClientsideWaypoint from DMaps

WaypointsDataContainer\CreateTables!

DMaps.LoadWaypoints = ->
	status = ClientsideWaypoint\LoadWaypoints(false)
	if status == false
		chat.AddText('[DMaps] ERROR LOADING CLIENTSIDE WAYPOINTS:')
		chat.AddText(sql.LastError!)
	elseif status == nil
		chat.AddText('[DMaps] No waypoints found for this server/map')
DMaps.OpenWaypointEditMenu = (pointid = 0, container = ClientsideWaypoint.DataContainer, onCancel = (->), onFinish = (->)) ->
	data = container\GetWaypoint(pointid)
	if not data return
	frame = vgui.Create('DFrame')
	self = frame
	
	w, h = 300, 500
	@SetSize(w, h)
	@SetTitle("Waypoint №#{pointid} edit menu")
	@Center()
	@MakePopup()
	
	@OnClose = ->
		onCancel() if not @confirmed
	
	fieldsData = {
		{"Waypoint name", data.name}
		{"Position X", data.posx}
		{"Position Y", data.posy}
		{"Position Z", data.posz}
	}
	
	labels = {}
	fields = {}
	
	for field in *fieldsData
		str = vgui.Create('EditablePanel', @)
		with str
			\Dock(TOP)
			\SetSize(0, 20)
			.Paint = (w, h) =>
				surface.SetDrawColor(100, 100, 100)
				surface.DrawRect(0, 0, w, h)
		
		label = vgui.Create('DLabel', str)
		with label
			\Dock(LEFT)
			\DockMargin(5, 0, 5, 0)
			\SetText(field[1])
			\SetColor(color_white)
			\SizeToContents()
		table.insert(labels, label)
		
		fieldPanel = vgui.Create('DTextEntry', str)
		with fieldPanel
			\Dock(FILL)
			\DockMargin(5, 0, 5, 0)
			\SetText(tostring(field[2]))
		table.insert(fields, fieldPanel)
	
	isVisible = vgui.Create('DCheckBoxLabel', @)
	with isVisible
		\SetText('Enabled (draw in world and no alpha on map)')
		\SetTooltip('Enabled (draw in world and no alpha on map)')
		\SetValue(data.visible)
		\Dock(TOP)
	
	decline = vgui.Create('DButton', @)
	with decline
		\SetText('Decline')
		\Dock(BOTTOM)
		\SetSize(0, 20)
		.DoClick = -> @Close()
	
	local picker
	confirm = vgui.Create('DButton', @)
	with confirm
		\SetText('Save')
		\Dock(BOTTOM)
		\SetSize(0, 20)
		.DoClick = ->
			color = picker\GetColor()
			newData = {
				name: fields[1]\GetText()
				posx: tonumber(fields[2]\GetText()) or 0
				posy: tonumber(fields[3]\GetText()) or 0
				posz: tonumber(fields[4]\GetText()) or 0
				red: color.r
				green: color.g
				blue: color.b
				visible: tobool(isVisible\GetChecked())
			}
			container\SetSaveData(pointid, newData)
			@confirmed = true
			onFinish()
			@Close()
	
	picker = vgui.Create('DColorMixer', @)
	with picker
		\Dock(FILL)
		\SetAlphaBar(false)
	with data
		picker\SetColor(Color(.red, .green, .blue))
	DMaps.WaypointEditContainer = frame
	return frame
DMaps.OpenWaypointsMenu = ->
	frame = vgui.Create('DFrame')
	self = frame
	
	w, h = ScrW! - 200, ScrH! - 200
	@SetSize(w, h)
	@SetTitle('DMap Clientside waypoints menu')
	@Center()
	@MakePopup()
	
	@top = vgui.Create('EditablePanel', @)
	@top\Dock(TOP)
	@top\SetSize(0, 20)
	@top.Paint = (w, h) =>
		with surface
			.SetDrawColor(130, 130, 130)
			.DrawRect(0, 0, w, h)
	
	labelsTable = {}
	labels = {"Server IP: #{game.GetIPAddress()}", "Current map: #{game.GetMap()}", "Total waypoints: #{ClientsideWaypoint.DataContainer\GetCount!}"}
	for name in *labels
		label = vgui.Create('DLabel', @top)
		with label
			\SetText(name)
			\Dock(LEFT)
			\DockMargin(3, 0, 3, 0)
			\SizeToContents()
			\SetColor(color_white)
		table.insert(labelsTable, label)
	
	labelsTable[3].Think = => @SetText("Total waypoints: #{ClientsideWaypoint.DataContainer\GetCount!}")
	
	@topButtons = vgui.Create('EditablePanel', @)
	@topButtons\Dock(TOP)
	@topButtons\SetSize(0, 20)
	
	@create = vgui.Create('DButton', @topButtons)
	with @create
		\Dock(LEFT)
		\SetText('Create waypoint')
		\SizeToContents()
		.DoClick = ->
			data, id = ClientsideWaypoint.DataContainer\CreateWaypoint()
			DMaps.OpenWaypointEditMenu(id, ClientsideWaypoint.DataContainer,
				-> ClientsideWaypoint.DataContainer\DeleteWaypoint(id),
				-> DMaps.WaypointListContainer.buildList()
			) if id
	
	@buildList = ->
		@scroll\Remove() if IsValid(@scroll)
		@scroll = vgui.Create('DScrollPanel', @)
		@scroll\Dock(FILL)
		if @points
			v\Remove() for i, v in pairs @points
		@points = {}
		for i, point in pairs ClientsideWaypoint.DataContainer\GetData()
			str = vgui.Create('DMapsWaypointRow', @scroll)
			str\Dock(TOP)
			str\SetData(i, ClientsideWaypoint.DataContainer)
			str\SetOnUpdate(-> DMaps.WaypointListContainer.buildList())
			table.insert(@points, str)
				
	DMaps.WaypointListContainer = frame
	DMaps.WaypointListContainer.buildList()
	return frame
timer.Simple(0, DMaps.LoadWaypoints)