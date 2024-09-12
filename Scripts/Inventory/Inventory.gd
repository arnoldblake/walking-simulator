class_name Inventory
extends Node

@onready var window : Panel = get_node("InventoryWindow")
@onready var info_text : Label = get_node("InventoryWindow/InfoText")

var slots : Array[InventorySlot]

@export var starter_items : Array[Item]

func _ready() -> void:
	toggle_window(!window.visible)
	for child in get_node("InventoryWindow/InventoryContainer").get_children():
		child = child as InventorySlot
		slots.append(child)
		child.set_item(null)
		child.inventory = self
	
	for item in starter_items:
		add_item(item)
		
	GlobalSignals.on_give_player_item.connect(on_give_player_item)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_window(!window.visible)
	
func toggle_window(open:bool) -> void:
	window.visible = open
	if open:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func on_give_player_item(item: Item, amount: int) -> void:
	for i in range(amount):
		add_item(item)

func add_item(item: Item) -> void:
	var slot = get_slot_to_add(item)
	
	if slot == null:
		return
	if slot.item == null:
		slot.set_item(item)
	elif slot.item == item:
		slot.add_item()
	
func remove_item(item: Item) -> void:
	var slot = get_slot_to_remove(item)
	if slot == null or slot.item == item:
		return
	slot.remove_item()
	
func get_slot_to_add(item: Item) -> InventorySlot:
	for slot in slots:
		if slot.item == item and slot.quantity < item.max_stack_size:
			return slot
	for slot in slots:
		if slot.item == null:
			return slot
	return null
	
func get_slot_to_remove(item: Item) -> InventorySlot:
	for slot in slots:
		if slot.item == item:
			return slot
	return null
	
func get_number_of_item(item: Item) -> int:
	var total = 0
	
	for slot in slots:
		if slot.item == item:
			total += slot.quantity
	
	return total
