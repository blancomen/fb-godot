extends Node2D

var objects = []
onready var unit = get_node("unit")
onready var inventory = get_node("ui_root/canvas_layer/inventory_control/inventory")

var item_axe

func _ready():
	set_fixed_process(true)
	set_process(true)
	
	get_node("background").set_z(-4096)
	var childrens = get_node("Y-Zdepth").get_children()
	for child in childrens:
		objects.append(child)
	
	var item_axe = preload("res://items/axe.tscn")
	var item_sword = preload("res://items/sword.tscn")
	var item_black_rec = preload("res://items/black_rec.tscn")
	
	inventory.add_item(item_axe.instance())
	inventory.add_item(item_axe.instance())
	inventory.add_item(item_sword.instance())
	inventory.add_item(item_axe.instance())
	inventory.add_item(item_axe.instance())
	inventory.add_item(item_sword.instance())
	
	get_tree().get_root().connect("size_changed", self, "update_ui")
	update_ui()

func update_ui():
	var viewport_rect = get_viewport_rect().size
	
	var left_control = get_node("ui_root/canvas_layer/left_control")
	left_control.set_pos(Vector2(0, viewport_rect.height - left_control.get_size().height))
	
	var buttons_control = get_node("ui_root/canvas_layer/buttons_control")
	buttons_control.set_pos(viewport_rect - buttons_control.get_size())
	
	var inventory_control = get_node("ui_root/canvas_layer/inventory_control")
	inventory_control.set_pos(Vector2(viewport_rect.width - inventory_control.get_size().width * get_node("ui_root/canvas_layer/inventory_control").get_scale().x, 0))
	
	# todo move
	# todo buttons

	
func _process(delta):
	unit.mouse_on_hud = inventory.mouse_on
	
func _fixed_process(delta):
	for object in objects:
		if (unit.get_pos().y < object.get_pos().y && object.get_z() != unit.get_z() + 1):
			object.set_z(unit.get_z() + 5)
			
		if (unit.get_pos().y > object.get_pos().y && object.get_z() != unit.get_z() - 1):
			object.set_z(unit.get_z() - 5)
			
	
		