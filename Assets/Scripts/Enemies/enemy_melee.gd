extends "res://Assets/Scripts/enemy.gd"

# Melee Stats -------------------------------------
const MELEE_DAMAGE = 15.0
const MELEE_KNOCKBACK = 12.0
const MELEE_RANGE = 3.0
const ATTACK_COOLDOWN = 2.0

var attack_timer = 0.0


func _physics_process(delta: float) -> void:
	if player == null:
		return

	if branded_timer > 0:
		branded_timer -= delta
		if branded_timer <= 0:
			remove_from_group("branded")

	var distance = global_position.distance_to(player.global_position)

	if attack_timer > 0 and speed_multiplier > 0:
		attack_timer -= delta

	# Chase player ----------------------------------
	if distance <= DETECTION_RANGE and distance > MELEE_RANGE:
		nav_agent.target_position = player.global_position
		var next_pos = nav_agent.get_next_path_position()
		var move_dir = (next_pos - global_position).normalized()
		var move_speed = MOVE_SPEED * speed_multiplier
		if is_in_group("branded"):
			move_speed *= 0.85
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# Melee attack ----------------------------------
	if distance <= MELEE_RANGE and attack_timer <= 0 and speed_multiplier > 0:
		_melee_attack()
		attack_timer = ATTACK_COOLDOWN

	# Status label ----------------------------------
	if speed_multiplier == 0.0:
		hp_label.text = "Petrified"
	else:
		hp_label.text = str(round(hp))
		if is_in_group("branded"):
			hp_label.text += "\nBranded"
		if hp / MAX_HP <= EXECUTE_THRESHOLD:
			hp_label.text += "\nExecute"

	_separate_from_others()

	if impulse.length() > 0:
		velocity += impulse
		impulse = Vector3.ZERO

	if knockback_velocity.length() > 0.1:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_friction * delta)

	velocity += get_gravity() * delta * 3.0
	move_and_slide()


func _melee_attack() -> void:
	player.take_damage(MELEE_DAMAGE)
	var push_dir = (player.global_position - global_position).normalized()
	push_dir.y = 0.0
	player.velocity += push_dir * MELEE_KNOCKBACK
