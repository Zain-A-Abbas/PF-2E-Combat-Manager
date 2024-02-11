extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	$"../../DiceButtons/GridContainer/d2Button".connect("dice_rolled", roll_dice)
	$"../../DiceButtons/GridContainer/d4Button".connect("dice_rolled", roll_dice)
	$"../../DiceButtons/GridContainer/d6Button".connect("dice_rolled", roll_dice)
	$"../../DiceButtons/GridContainer/d8Button".connect("dice_rolled", roll_dice)
	$"../../DiceButtons/GridContainer/d10Button".connect("dice_rolled", roll_dice)
	$"../../DiceButtons/GridContainer/d12Button".connect("dice_rolled", roll_dice)
	$"../../DiceButtons/GridContainer/d20Button".connect("dice_rolled", roll_dice)
	$"../../DiceButtons/GridContainer/d100Button".connect("dice_rolled", roll_dice)
	EventBus.d20_rolled.connect(d20_with_mod)


func roll_dice(dice_faces: int):
	if text != "":
		text += "\n"
	var dice_result: int = randi_range(1, dice_faces)
	text += "d" + str(dice_faces) + " = " + str(dice_result)

func d20_with_mod(mod: int, enemy_name: String):
	if text != "":
		text += "\n"
	var dice_result: int = randi_range(1, 20)
	var dice_total: int = dice_result + mod
	text += enemy_name + " d20" + " (" + str(dice_result) +  ") + " + str(mod) + " = " + str(dice_total)


func _on_clear_dice_pressed():
	text = ""
