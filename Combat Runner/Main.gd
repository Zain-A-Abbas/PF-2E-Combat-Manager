extends Control

@onready var combat = $TabBar/Combat
@onready var enemy_database = $TabBar/EnemyDatabase


# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_database.add_enemy.connect(add_enemy_to_combat)

func add_enemy_to_combat(enemy_data):
	combat.add_enemy_from_sheet(enemy_data)
