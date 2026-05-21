extends CharacterBody3D

# HP --------------------------------------
var hp = 100.0
const MAX_HP = 100.0

# Detection -------------------------------
const DETECTION_RANGE = 10.0
const ATTACK_RANGE = 4.0
const THROW_RATE = 2.0
const MOVE_SPEED = 3.0

# References ------------------------------
var player = null 
var throw_timer = 0.0

@onready var projectile_spawn = $ProjectileSpawn
@onready var nav_agent = $NavigationAgent3D
const PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if throw_timer > 0:
		throw_timer -= delta
	
	# Follow player when within detection range -----
	if distance <= DETECTION_RANGE and distance > ATTACK_RANGE:
		nav_agent.target_position = player.global_position
		var next_pos = nav_agent.get_next_path_position()
		var move_dir = (next_pos - global_position).normalized()
		velocity = move_dir * MOVE_SPEED
	else:
		velocity = Vector3.ZERO
	
	# Attack when within attack range -----
	if distance <= ATTACK_RANGE and throw_timer <= 0:
		_throw_dagger()
		throw_timer = THROW_RATE
	
	move_and_slide()

# Attack ----------------------------------
func _throw_dagger():
	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = projectile_spawn.global_position
	var direction = (player.global_position - projectile_spawn.global_position).normalized()
	projectile.launch(direction)
	projectile.add_collision_exception_with(self)
	
# DMG Taken -------------------------------
func take_damage(amount: float):
	hp -= amount
	hp = clamp(hp, 0, MAX_HP)
	print("Enemy HP: ", hp)
	if hp <= 0:
		queue_free()
