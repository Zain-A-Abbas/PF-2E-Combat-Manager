extends HBoxContainer

@onready var enemy_name = $EnemyName
@onready var initiative_count = $InitCount

var enemy_data
# The enemy node that this initiative is tied to, for the sake of deleting initiative
var enemy_node: Node
var initiative: int = 0

# Adds the enemy name and rolls its initiative
func setup_initiative(enemy_sheet):
	initiative = randi_range(1, 20)
	
	enemy_data = enemy_sheet
	
	if enemy_data == null:
		enemy_name.text = "Blank"
		initiative_count.text = str(initiative)
		return
	
	enemy_name.text = enemy_data["name"]
	initiative += enemy_data["system"]["attributes"]["perception"]["value"]
	initiative_count.text = str(initiative)

func reroll_initiative():
	initiative = randi_range(1, 20)
	if enemy_data == null:
		initiative_count.text = str(initiative)
		return
	initiative += enemy_data["system"]["attributes"]["perception"]["value"]
	initiative_count.text = str(initiative)

func rename_enemy(new_name: String):
	enemy_name.text = new_name