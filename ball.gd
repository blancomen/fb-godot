extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
    # ...calculate desired velocity, e.g. due to keypresses
    # ...then move the character
