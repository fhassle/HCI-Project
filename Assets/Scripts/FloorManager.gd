extends Node

# State --------------------------------------------
var current_condition: BaseCondition = null
var is_active: bool = false

# Init ---------------------------------------------
func _ready():
	GameManager.floor_cleared.connect(_on_floor_cleared)
	call_deferred("_auto_start")

func _auto_start() -> void:
	var script = GameManager.get_condition_script()
	var condition: BaseCondition = script.new()
	start_condition(condition)

# Start --------------------------------------------
func start_condition(condition: BaseCondition) -> void:
	if current_condition:
		current_condition.queue_free()
	current_condition = condition
	add_child(current_condition)
	current_condition.start_condition()
	is_active = true
	print("Condition started: ", condition.get_class())

# Process loop -------------------------------------
func _process(delta: float) -> void:
	if not is_active or not current_condition:
		return
	current_condition.process_condition(delta)
	if current_condition.is_complete():
		is_active = false
		GameManager.on_floor_cleared()

# Floor clear hook ---------------------------------
func _on_floor_cleared(_floor_number: int) -> void:
	pass
