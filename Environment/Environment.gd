extends Node

func apply_action(action: Array) -> void:
	$Robot.drive_direction = Vector2(action[0], action[1])
	$Robot.rotation_direction = action[2]
	
func get_observation() -> Array:
	return [$Robot.position.x, $Robot.position.y, $Robot.rotation, $Robot.angular_velocity,
		$Robot.linear_velocity.x, $Robot.linear_velocity.y, 0, 0]
	
func get_reward() -> float:
	return 0.0
	
func reset() -> void:
	$Robot.position = Vector2(256, 256)
	$Robot.linear_velocity *= 0
	$Robot.angular_velocity *= 0
	
func is_done() -> bool:
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass