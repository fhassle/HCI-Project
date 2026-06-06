class_name BaseCondition
extends Node

# References ---------------------------------------
var player: CharacterBody3D = null

# Interface ----------------------------------------
func start_condition() -> void:
	pass

func process_condition(_delta: float) -> void:
	pass

func is_complete() -> bool:
	return false

func get_progress() -> float:
	return 0.0
