extends Node2D

export var items = {}
export var mouse_on = false
export(NodePath) var unit_path

var unit

var is_open = true

var max_items = 15
var rows = 3
var columns = 5

var hud_offset = Vector2(13, 14)
var item_size = Vector2(34,34)

var last_viewport_size = Vector2()

func _ready():
	set_fixed_process(true)
	for i in range(0, max_items):
		items[i] = null
		
	unit = get_node(unit_path)

func get_item(i):
	if i < 0 or i > max_items:
		return null
	return items[i]
	
func set_item(i, item):
	items[i] = item
	item.set_pos(get_cell_position(i))
	item.inventory = self
	item.inventory_index = i
	
func reset_item(i):
	items[i] = null

func add_item(item):
	var free_cell = get_free_cell()
	if free_cell != null:
		set_item(free_cell, item)
		get_node("items").add_child(item)
		item.set_z(1000)
		
func get_free_cell():
	for i in range(0, max_items):
		if items[i] == null:
			return i
	return null

func get_cell_position(cell):
	return i_to_xy(cell) * item_size + hud_offset

func move_item(from, to):
	var item_from = get_item(from)
	var item_to = get_item(to)
	if item_to:
		set_item(from, item_to)
		set_item(to, item_from)
	else:
		if from != to:
			reset_item(from)
		set_item(to, item_from)
		
func i_to_xy(i):
	return Vector2(i % columns, (i / columns)%(rows))

func xy_to_i(pos):
	return pos.y * columns + pos.x

func _on_area_mouse_enter():
	mouse_on = true

func _on_area_mouse_exit():
	mouse_on = false
