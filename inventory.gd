extends Node2D

export var items = {}
export var mouse_on = false
export(NodePath) var unit_path

var unit

var max_items = 15
var rows = 3
var columns = 5
var count_items = 0

var hud_offset = Vector2(14, 14)
var item_size = Vector2(32,32)
var border_size = 2

var last_viewport_size = Vector2()

func _ready():
	set_fixed_process(true)
	for i in range(0, max_items):
		items[i] = null
		
	unit = get_node(unit_path)

func get_item(i):
	return items[i]

func add_item(item):
	var free_cell = get_free_cell()
	if free_cell != null:
		items[free_cell] = item
		item.set_pos(get_cell_position(free_cell))
		get_node("items").add_child(item)
		item.set_z(1000)
		
func get_free_cell():
	for i in range(0, max_items):
		if items[i] == null:
			return i
	return null

func get_cell_position(cell):
	return i_to_xy(cell) * item_size + hud_offset + i_to_xy(cell)*border_size

func i_to_xy(i):
	return Vector2(i % columns, (i / columns)%(rows))

func xy_to_i(pos):
	return pos.y * columns + pos.x

func _on_area_mouse_enter():
	mouse_on = true

func _on_area_mouse_exit():
	mouse_on = false
