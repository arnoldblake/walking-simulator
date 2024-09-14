extends State

@export var flee_distance: float = 6

func enter() -> void:
	super.enter()
	controller.is_running = true
	flee()
	
func exit() -> void:
	super.exit()
	controller.is_running = false

func flee() -> void:
	var position = (controller.position - controller.player.position).normalized()
	var move_position = controller.position + (position * flee_distance)
	controller.move_to_position(move_position)

func navigation_complete() -> void:
	state_machine.change_state("Wander")
