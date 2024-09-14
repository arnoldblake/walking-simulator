class_name AIController
extends CharacterBody3D

@export var walk_speed: float = 1.0
@export var run_speed: float = 2.0
var is_running: bool = false
var is_stopped: bool = false
var look_at_player: bool = false

var target_y_rotation: float

@onready var agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var state_machine: StateMachine = get_node("StateMachine")

var player_distance: float

func _process(_delta: float) -> void:
	if player:
		player_distance = position.distance_to(player.position)
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var target_position = agent.get_next_path_position()
	var direction = position.direction_to(target_position)
	
	if direction == Vector3.ZERO and state_machine.current_state != null:
		state_machine.current_state.navigation_complete()
	
	if agent.is_navigation_finished() or is_stopped:
		direction = Vector3.ZERO
	
	var current_speed = walk_speed
	if is_running:
		current_speed = run_speed
		
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	move_and_slide()
	
	if look_at_player:
		var player_direction = player.position - position
		target_y_rotation = atan2(player_direction.x, player_direction.z)
	elif velocity.length() > 0:
		target_y_rotation = atan2(velocity.x, velocity.z)
		
	rotation.y = lerp_angle(rotation.y, target_y_rotation, 0.1)
	
func move_to_position(to_position: Vector3, adjust_position: bool = true) -> void:
	if not agent:
		agent = get_node("NavigationAgent3D")
	is_stopped = false
	if adjust_position:
		var map = get_world_3d().navigation_map
		var adjusted_position = NavigationServer3D.map_get_closest_point(map, to_position)
		agent.set_target_position(adjusted_position)
	else:
		agent.set_target_position(to_position)
