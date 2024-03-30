extends Node

signal env_reset

func apply_action(action: Array) -> void:
	$Robot.drive_direction = Vector2(action[0], action[1])
	$Robot.rotation_direction = action[2]
	
func human_input() -> void:
	$Robot.rotation_direction = 0.0
	$Robot.drive_direction = Vector2.ZERO
	
	if Input.is_action_pressed("swerve_left"):
		$Robot.rotation_direction = -1.0
	if Input.is_action_pressed("swerve_right"):
		$Robot.rotation_direction = 1.0
	
	if Input.is_action_pressed("drive_up"):
		$Robot.drive_direction.y = -1
	if Input.is_action_pressed("drive_down"):
		$Robot.drive_direction.y = 1
	if Input.is_action_pressed("drive_left"):
		$Robot.drive_direction.x = -1
	if Input.is_action_pressed("drive_right"):
		$Robot.drive_direction.x = 1
	
func get_observation() -> Array:
	return [$Robot.position.x, $Robot.position.y, $Robot.rotation, $Robot.angular_velocity,
		$Robot.linear_velocity.x, $Robot.linear_velocity.y, 0, 0]
	
func get_reward() -> float:
	return 0.0
	
func reset() -> void:
	print(" ----- ----- ----- RESETTING GODOT ENVIRONMENT ----- ----- -----")
	env_reset.emit() 
	
func is_done() -> bool:
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
