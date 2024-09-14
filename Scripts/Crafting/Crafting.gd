extends Node

@onready var window: Panel = get_node("CraftingWindow")
@onready var ui_parent: VBoxContainer = get_node("CraftingWindow/MarginContainer/RecipeContainer")

@export var crafting_recipe_ui_scene: PackedScene
@export var recipes: Array[CraftingRecipe]

var recipe_uis: Array[CraftingRecipeUI]
var inventory: Inventory

func _ready() -> void:
	if window.visible:
		toggle_window(!window.visible)
		
	inventory = get_parent().get_node("Inventory")
	
	for recipe in recipes:
		var recipe_node = crafting_recipe_ui_scene.instantiate()
		ui_parent.add_child(recipe_node)
		recipe_node.recipe = recipe
		recipe_node.crafting = self
		recipe_uis.append(recipe_node)
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("craft"):
			toggle_window(!window.visible)

func craft(recipe: CraftingRecipe) -> void:
	for req in recipe.requirements:
		for i in range(req.quantity):
			inventory.remove_item(req.item)
	inventory.add_item(recipe.item)
	update_recipe_ui()
	
func toggle_window(open:bool) -> void:
	window.visible = open
	if open:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		update_recipe_ui()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
func update_recipe_ui() -> void:
		for recipe in recipe_uis:
			recipe.update_recipe(inventory)
