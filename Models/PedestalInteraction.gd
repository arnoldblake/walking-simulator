extends InteractableObject
 
@onready var light_bulb = get_node("LightBulb")

func _interact() -> void:
	light_bulb.visible = true
	can_interact = false
