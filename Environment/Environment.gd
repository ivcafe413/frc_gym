extends Node

var robot

signal env_reset

func apply_action(action: Array) -> void:
	robot.drive_direction = Vector2(action[0], action[1])
	robot.rotation_direction = action[2]
	
func get_observation() -> Array:
	return [robot.position.x, robot.position.y, robot.rotation, robot.angular_velocity,
		robot.linear_velocity.x, robot.linear_velocity.y, 0, 0]
	
func get_reward() -> float:
	return 0.0
	
func reset() -> void:
	print(" ----- ----- ----- RESETTING GODOT ENVIRONMENT ----- ----- -----")
	env_reset.emit() 
	
func is_done() -> bool:
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	robot = get_parent().find_child("Robot")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
