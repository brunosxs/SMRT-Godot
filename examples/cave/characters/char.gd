extends KinematicBody2D

var walk_speed = 500
var direction = Vector2(0,0)
func _ready():
	set_fixed_process(true)
	Globals.set("player", self) # We make the player accessible more easily through Globals.
	

func _fixed_process(delta):
	# Simple movement for our char
	if Input.is_action_pressed("player_up"):
		direction.y = -1
	elif Input.is_action_pressed("player_down"):
		direction.y = 1
	elif Input.is_action_pressed("player_left"):
		direction.x = -1
	elif Input.is_action_pressed("player_right"):
		direction.x = 1
	else:
		direction = Vector2(0,0)
	
	move(direction*walk_speed*delta)