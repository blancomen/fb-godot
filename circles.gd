extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var objects = []
var unit

func _ready():
	set_z(100)
	var root = get_owner()
	objects.append(root.get_node("tree"))
	unit = root.get_node("unit")
	set_process(true)
		
func _process(delta):
    update()

func _draw():
	for object in objects:
	    draw_circle(object.get_pos(),4, Color(1.0, 0.0, 0.0))
	draw_circle(unit.get_pos(),3, Color(1.0, 0.0, 0.0))
	