extends RefCounted
class_name NumberFilterData
var text : String
var lower_bound : int
var upper_bound : int

func _init(t, l=0, u=9999):
	text = t
	lower_bound = l
	upper_bound = u

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
