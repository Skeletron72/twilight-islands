extends Node2D
class_name WorkshopInterior

@onready var blueprint_table_area: Area2D = $BlueprintTable
@onready var level_2_decor: Node2D = get_node_or_null("Level2Decor")
@onready var level_3_decor: Node2D = get_node_or_null("Level3Decor")

func _ready() -> void:
	y_sort_enabled = true
	_update_expansion_visuals()

func _update_expansion_visuals() -> void:
	var hsm = get_node_or_null("/root/HomeStateManager")
	var lvl = hsm.workshop_level if hsm else 1
	if level_2_decor:
		level_2_decor.visible = (lvl >= 2)
	if level_3_decor:
		level_3_decor.visible = (lvl >= 3)

func interact_blueprint_table(_player: Node2D) -> void:
	# Opens boat upgrades directly from inside the workshop
	var boat = get_tree().get_first_node_in_group("boat")
	var boat_ui = get_tree().current_scene.get_node_or_null("UILayer/BoatUI")
	if boat_ui:
		boat_ui.open(boat)
	else:
		var ui_layer = get_tree().get_first_node_in_group("ui_layer")
		if ui_layer and ui_layer.has_node("BoatUI"):
			ui_layer.get_node("BoatUI").open(boat)
		else:
			var exp_mgr = get_node_or_null("/root/ExpeditionManager")
			if exp_mgr and exp_mgr.has_method("post_thought"):
				exp_mgr.post_thought("Чертежи кораблей: здесь можно планировать модернизацию судна.", Color(0.9, 0.85, 0.5))
