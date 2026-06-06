extends CharacterBody3D

signal died

# HP --------------------------------------
var hp = 200.0
const MAX_HP = 200.0
const EXECUTE_THRESHOLD = 0.3

# Detection -------------------------------
const DETECTION_RANGE = 20.0
const ATTACK_RANGE = 4.0
const THROW_RATE = 2.0
const MOVE_SPEED = 3.0
const PROJECTILE_DAMAGE = 5.0
const PROJECTILE_SPEED = 14.0
const SEPARATION_RADIUS = 1.5
const SEPARATION_FORCE = 4.0

# Knockback ----------------------------------------
var knockback_velocity = Vector3.ZERO
var knockback_friction = 8.0
var impulse = Vector3.ZERO

# Branded ------------------------------------------
var branded_timer = 0.0

# References ------------------------------
var player = null 
var throw_timer = 0.0
var speed_multiplier = 1.0

@onready var projectile_spawn = $ProjectileSpawn
@onready var nav_agent = $NavigationAgent3D
@onready var hp_label = $HPLabel
const PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	if branded_timer > 0:
		branded_timer -= delta
		if branded_timer <= 0:
			remove_from_group("branded")
	
	var distance = global_position.distance_to(player.global_position)
	
	if throw_timer > 0 and speed_multiplier > 0:
		throw_timer -= delta
	
	# Follow player when within detection range -----
	if distance <= DETECTION_RANGE and distance > ATTACK_RANGE:
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
	
	# Attack when within attack range -----
	if distance <= ATTACK_RANGE and throw_timer <= 0 and speed_multiplier > 0:
		_throw_dagger()
		throw_timer = THROW_RATE
	
	# Show status effects above HP -----------------
	if speed_multiplier == 0.0:
		hp_label.text = "Petrified"
	else:
		hp_label.text = str(round(hp))
		if is_in_group("branded"):
			hp_label.text += "\nBranded"
		if hp / MAX_HP <= EXECUTE_THRESHOLD:
			hp_label.text += "\nExecute"
	
	_separate_from_others()
	
	# One-shot impulse (set by abilities) ------------
	if impulse.length() > 0:
		velocity += impulse
		impulse = Vector3.ZERO
	
	# Knockback additive after AI movement -----------
	if knockback_velocity.length() > 0.1:
		velocity += knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_friction * delta)
	
	velocity += get_gravity() * delta * 3.0
	move_and_slide()


func _separate_from_others() -> void:
	var push = Vector3.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == self:
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < SEPARATION_RADIUS and dist > 0.01:
			var away = (global_position - enemy.global_position).normalized()
			push += away * (SEPARATION_RADIUS - dist) / SEPARATION_RADIUS
	if push != Vector3.ZERO:
		velocity += push * SEPARATION_FORCE


# Attack ----------------------------------
func _throw_dagger():
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.is_enemy_projectile = true
	projectile.damage = PROJECTILE_DAMAGE
	projectile.speed = PROJECTILE_SPEED
	get_tree().root.add_child(projectile)
	projectile.global_position = projectile_spawn.global_position
	var direction = (player.global_position - projectile_spawn.global_position).normalized()
	projectile.launch(direction)
	projectile.add_collision_exception_with(self)
	
# DMG Taken -------------------------------
func take_damage(amount: float):
	if is_in_group("branded"):
		amount *= 0.7
	hp -= amount
	hp = clamp(hp, 0, MAX_HP)
	hp_label.text = str(round(hp))
	print("Enemy HP: ", hp)
	if hp <= 0:
		died.emit()
		queue_free()
