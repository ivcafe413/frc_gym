extends RigidBody2D

var torque = 2_000_000
var drive_torque = 2000

var rotation_direction = 0
var drive_direction = Vector2.ZERO

var self_reset = false
var initial_transform = self.transform

# Called when the node enters the scene tree for the first time.
func _ready():
	var environment = get_parent()
	if not environment is Window:
		environment.env_reset.connect(_on_env_reset)
	
func _on_env_reset():
	self_reset = true
	
func _integrate_forces(state):
	if self_reset:
		self_reset = false

		state.linear_velocity *= 0
		state.angular_velocity *= 0
		state.transform = initial_transform
	else:
		#if Input.is_action_pressed("swerve_left"):
			#rotation_direction = -1.0
		#if Input.is_action_pressed("swerve_right"):
			#rotation_direction = 1.0
			
		apply_torque(rotation_direction * torque)
		
		#if Input.is_action_pressed("drive_up"):
			#drive_direction.y = -1
		#if Input.is_action_pressed("drive_down"):
			#drive_direction.y = 1
		#if Input.is_action_pressed("drive_left"):
			#drive_direction.x = -1
		#if Input.is_action_pressed("drive_right"):
			#drive_direction.x = 1
			
		if drive_direction.length() > 0:
			drive_direction = drive_direction.normalized()
			apply_central_impulse(drive_direction * drive_torque)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
