extends RayCast3D

@onready var interact_prompt_label : Label = get_node("Label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var object = get_collider()
	
	if object and object is InteractableObject:
		object = object as InteractableObject
		if object.can_interact:
			interact_prompt_label.text = object.interact_prompt
			if Input.is_action_just_pressed("interact"):
				object._interact()
	else:
		interact_prompt_label.text = ""
