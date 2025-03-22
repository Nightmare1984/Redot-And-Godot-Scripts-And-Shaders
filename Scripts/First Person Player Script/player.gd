extends CharacterBody3D

#player vars

@onready var head = $head
@onready var standing_collision = $"standing collision"
@onready var crouching_collision = $"crouching collision"
@onready var ray_cast_3d = $RayCast3D
@onready var spot_light_3d: SpotLight3D = $head/SpotLight3D
@onready var camera_3d: Camera3D = $head/Camera3D

#Speed Vars

var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0
var lerp_speed = 10.0

#Mouse Vars

var direction = Vector3.ZERO
@export var mouse_sens = 0.4

#Movement Vars

@export var jump_velocity = 4.5
@export var crouching_depth = -0.5

#Fov Vars
@export var fov_default = 65.0
@export var fov_sprint = 85.0
var current_fov = fov_default

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))


func _physics_process(delta):
	if Input.is_action_just_pressed("flashlight"):
		spot_light_3d.visible = !spot_light_3d.visible
	#HandelMovementState
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,0.7 + crouching_depth,delta*lerp_speed)
		standing_collision.disabled = true
		crouching_collision.disabled = false
	elif !ray_cast_3d.is_colliding():
		standing_collision.disabled = false
		crouching_collision.disabled = true
		head.position.y = lerp(head.position.y,0.7,delta*lerp_speed)
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
			current_fov = fov_sprint
		else:
			current_speed = walking_speed
			current_fov = fov_default
	camera_3d.fov = lerp(camera_3d.fov, current_fov, delta * lerp_speed)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	move_and_slide()
