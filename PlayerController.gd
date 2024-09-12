class_name PlayerController
extends CharacterBody3D

@export_group("Movement")
@export var sprint_modifier : float = 2
@export var max_speed : float = 2.5
@export var max_acceleration : float = 8
@export var max_deceleration : float = 20
@export var air_acceleration_modifier : float = 0.05

@export_group("Camera")
@export var look_sensitivity : float = 0.005

var is_running : bool = false
var camera_look_input : Vector2

var speed = max_speed
var acceleration = max_acceleration
const JUMP_VELOCITY = 4.5

@onready var camera : Camera3D = get_node("Camera3D")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Handle Inputs ---------------------------------------------------------- #
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
			
	# Camera Look
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-camera_look_input.x * look_sensitivity)
		camera.rotate_x(-camera_look_input.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
		camera_look_input = Vector2.ZERO
	
	# Mouse Capture Toggle
	if Input.is_action_just_pressed("menu"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Sprint modifier
	if Input.is_action_pressed("sprint"):
		is_running = true
	else:
		is_running = false
	
	# ------------------------------------------------------------------------ #	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		acceleration = max_acceleration * air_acceleration_modifier
	else:
		acceleration = max_acceleration

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_running:
		speed = max_speed * sprint_modifier
		direction *= clamp(-direction.dot(transform.basis.z), 0.0, 1.0)
	else:
		speed = max_speed
		
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	else:
		acceleration = max_deceleration
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0, acceleration * delta)

	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_look_input = event.relative
