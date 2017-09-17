
extends KinematicBody2D

const speed = 200
var clickpoint = Vector2(0,0)

func _ready():
	set_fixed_process(true)
	get_node("../Area2D").connect("body_enter",self,"_on_Area2D_body_enter")
	get_node("../Area2D").connect("body_exit",self,"_on_Area2D_body_exit")
	set_process_input(true)
	clickpoint = self.get_pos()

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_LEFT and event.pressed:
			clickpoint = self.get_global_mouse_pos()
			print(clickpoint)
			
func _fixed_process(delta):
	var direction = (clickpoint - self.get_pos()).normalized()

	if (self.get_pos().distance_to(clickpoint) > 2):
		move( direction * speed * delta)
		if is_colliding():
			print("Collision with ",get_collider())
			var n = get_collision_normal()
			direction = n.slide( direction )
			move(direction*speed*delta)

func _on_Area2D_body_enter( body ):
	print("Entered Area2D with body ", body)
func _on_Area2D_body_exit( body ):
	print("Exited Area2D with body ", body)