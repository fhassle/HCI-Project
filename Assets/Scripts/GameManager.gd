extends Node

# Signals ------------------------------------------
signal floor_changed(floor_number: int)
signal floor_cleared(floor_number: int)

# State --------------------------------------------
var current_floor: int = 0
var is_running: bool = false
var current_condition_type: int = 1

# Condition registry -------------------------------
var condition_scripts: Dictionary = {
	1: AmbushCondition,
}

# Auto-start on game launch ------------------------
func _ready():
	call_deferred("start_run")

# Run lifecycle ------------------------------------
func start_run():
	current_floor = 0
	is_running = true
	_roll_condition()
	go_to_next_floor()


func go_to_next_floor():
	current_floor += 1
	floor_changed.emit(current_floor)
	print("Entering floor ", current_floor)

func on_floor_cleared():
	floor_cleared.emit(current_floor)
	_roll_condition()
	print("Floor ", current_floor, " cleared")

# Condition selection ------------------------------
func _roll_condition():
	var types = condition_scripts.keys()
	current_condition_type = types[randi() % types.size()]

func get_condition_script() -> Script:
	return condition_scripts.get(current_condition_type, AmbushCondition)
