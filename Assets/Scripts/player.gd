extends CharacterBody3D

# Camera ----------------------------------
var sensitivity = 0.003
@onready var camera = $Camera3D
@onready var stamina_label = $HUD/StaminaLabel

# Weapon Holder ---------------------------
@onready var weapon_holder = $Camera3D/RWeaponHolder
const PROJECTILE_SCENE = preload("res://Scenes/projectile.tscn")

@onready var fist_holder = $Camera3D/LWeaponHolder

# Ranged Attack Stats ---------------------
var shoot_timer = 0.0
const SHOOT_RATE = 0.5

# Melee Attack Stats ----------------------
var melee_cooldown = 0.0
const MELEE_COOLDOWN_TIME = 0.6
const MELEE_FORESWING = 0.2
const MELEE_RANGE = 2.5
const MELEE_ANGLE = 90.0
var melee_timer = 0.0
var is_attacking = false

# Melee test animation --------------------
const FIST_REST_POS = Vector3(0, 0, 0)
const FIST_WINDUP_POS = Vector3(0, 0.1, 0.2)
const FIST_LUNGE_POS = Vector3(0, -0.05, -0.2)

# Dash to sprint --------------------------
var is_dashing = false
var is_sprinting = false
var dash_hold_time = 0.0
var dash_cooldown = 0.0
var dash_direction = Vector3.ZERO
var sprint_boost_active = false

const DASH_SPEED = 14.0
const SPRINT_SPEED = 7.8
const DASH_DURATION = 0.3
const DASH_HOLD_THRESHOLD = 0.3
const DASH_COOLDOWN_TIME = 0.1

# HP --------------------------------------
var hp = 100.0
const MAX_HP = 100.0
@onready var hp_label = $HUD/HPLabel

# Stamina ---------------------------------
var stamina = 100.0
const MAX_STAMINA = 100.0

const DASH_STAMINA_COST = 35.5
const SPRINT_STAMINA_DRAIN = 15.5
const WALK_STAMINA_RECOVERY = 8.0
const IDLE_STAMINA_RECOVERY = 30.0

var exhausted_timer = 0.0
const EXHAUSTED_DELAY = 1.5
const EXHAUSTED_RECOVERY = 8.0
const EXHAUSTED_THRESHOLD = 60.0
const EXHAUSTED_SPEED = 3.5
var is_exhausted = false

# Walk and Jump height/speed --------------
var jump_count = 0

const SPEED = 5.0
const JUMP_VELOCITY = 9.5
const DJUMP_VELOCITY = 6.8

# Mouse-lock, sensitivity control and terminate game --------
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	if Input.is_action_just_pressed("terminate"):
		get_tree().quit()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

# MOVEMENT --------------------------------
# Gravity ---------------------------------
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta * 3.0

# Jump ------------------------------------
	if is_on_floor():
		jump_count = 0
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_count = 1
		elif jump_count < 2:
			velocity.y = DJUMP_VELOCITY
			jump_count = 2

# Dash and Sprint calculations ------------
	if dash_cooldown > 0:
		dash_cooldown -= delta
	
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0 and not is_exhausted and stamina >= 40:
		is_dashing = true
		is_sprinting = false
		sprint_boost_active = false
		dash_hold_time = 0.0
		stamina -= DASH_STAMINA_COST
		var input_dir_dash := Input.get_vector("left", "right", "up", "down")
		var raw_dir = (transform.basis * Vector3(input_dir_dash.x, 0, input_dir_dash.y)).normalized()
		if raw_dir != Vector3.ZERO:
			dash_direction = raw_dir
		else:
			dash_direction = -global_transform.basis.z
		velocity.x = 0
		velocity.z = 0

	if is_dashing and not is_sprinting:
		dash_hold_time += delta
		if dash_hold_time >= DASH_HOLD_THRESHOLD:
			is_sprinting = true
			is_dashing = false
			dash_direction = -camera.global_transform.basis.z
	
	if is_sprinting and not Input.is_action_pressed("dash"):
		is_dashing = false
		is_sprinting = false
		sprint_boost_active = false
		dash_cooldown = DASH_COOLDOWN_TIME
		dash_direction = Vector3.ZERO

# Basic movement --------------------------
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Stamina system ----------------------
	if is_exhausted:
		if exhausted_timer > 0:
			exhausted_timer -= delta
		else:
			stamina += EXHAUSTED_RECOVERY * delta
			if stamina >= EXHAUSTED_THRESHOLD:
				is_exhausted = false
				print("Exhausted state ended — stamina: ", stamina)
	elif is_sprinting:
		stamina -= SPRINT_STAMINA_DRAIN * delta
		if stamina <= 0:
			stamina = 0
			is_exhausted = true
			exhausted_timer = EXHAUSTED_DELAY
			is_sprinting = false
			sprint_boost_active = false
			dash_direction = Vector3.ZERO
			print("Entered exhausted state")
	elif direction != Vector3.ZERO:
		stamina += WALK_STAMINA_RECOVERY * delta
	else:
		stamina += IDLE_STAMINA_RECOVERY * delta
	stamina = clamp(stamina, 0, MAX_STAMINA)
	stamina_label.text = "Stamina: " + str(round(stamina)) + "/100"

	# Healt HUD ---------------------------
	hp_label.text = "HP: " + str(round(hp)) + "/100"

	# Movement selection ------------------
	if is_dashing and dash_hold_time < DASH_HOLD_THRESHOLD:
		if not is_on_floor():
			if dash_hold_time < delta * 2:
				velocity.x = dash_direction.x * DASH_SPEED
				velocity.z = dash_direction.z * DASH_SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, DASH_SPEED * 1.5 * delta)
				velocity.z = move_toward(velocity.z, 0, DASH_SPEED * 1.5 * delta)
		else:
			velocity.x = dash_direction.x * DASH_SPEED
			velocity.z = dash_direction.z * DASH_SPEED
	elif is_sprinting:
		if not sprint_boost_active:
			if dash_hold_time >= DASH_HOLD_THRESHOLD:
				sprint_boost_active = true
		if sprint_boost_active:
			var sprint_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if sprint_dir != Vector3.ZERO:
				dash_direction = sprint_dir
			else:
				dash_direction = -camera.global_transform.basis.z
			velocity.x = dash_direction.x * SPRINT_SPEED
			velocity.z = dash_direction.z * SPRINT_SPEED
	elif direction:
		var current_speed = EXHAUSTED_SPEED if is_exhausted else SPEED
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		var current_speed = EXHAUSTED_SPEED if is_exhausted else SPEED
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

# Ranged Input ----------------------------
	if shoot_timer > 0:
		shoot_timer -= delta
	if Input.is_action_pressed("rangedATK") and shoot_timer <= 0:
		_shoot()
		shoot_timer = SHOOT_RATE

	# Melee cooldown ----------------------
	if melee_cooldown > 0:
		melee_cooldown -= delta
	if melee_timer > 0:
		melee_timer -= delta
		if melee_timer <= 0 and is_attacking:
			_melee_attack()
			is_attacking = false
			melee_cooldown = MELEE_COOLDOWN_TIME
			_fist_lunge()
	if Input.is_action_just_pressed("meleeATK") and melee_cooldown <= 0 and not is_attacking:
		is_attacking = true
		melee_timer = MELEE_FORESWING
		_fist_windup()

	move_and_slide()

# Ranged attak ----------------------------
func _shoot():
	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().root.add_child(projectile)
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_center = viewport_size / 2
	var ray_origin = camera.project_ray_origin(screen_center)
	var ray_dir = camera.project_ray_normal(screen_center)
	projectile.global_transform.basis = camera.global_transform.basis
	projectile.global_position = ray_origin + ray_dir * 0.3
	projectile.launch(ray_dir)

# Melee Attack ----------------------------
func _melee_attack():
	var space_state = get_world_3d().direct_space_state
	var bodies = []
	for body in get_tree().get_nodes_in_group("enemies"):
		var to_enemy = body.global_position - global_position
		var distance = to_enemy.length()
		if distance > MELEE_RANGE:
			continue
		var angle = rad_to_deg(to_enemy.normalized().angle_to(-global_transform.basis.z))
		if angle > MELEE_ANGLE / 2:
			continue
		var ray_query = PhysicsRayQueryParameters3D.create(
			global_position,
			body.global_position,
			2
		)
		var result = space_state.intersect_ray(ray_query)
		if result and result.collider != body:
			continue
		bodies.append(body)
		body.take_damage(20.0)
		print("Hit: ", body.name)
		
func _fist_windup():
	var tween = create_tween()
	tween.tween_property(fist_holder, "position", FIST_WINDUP_POS, MELEE_FORESWING)

func _fist_lunge():
	var tween = create_tween()
	tween.tween_property(fist_holder, "position", FIST_LUNGE_POS, 0.1)
	tween.tween_property(fist_holder, "position", FIST_REST_POS, 0.5)

# DMG Taken ---------------------------
func take_damage(amount: float):
	hp -= amount
	hp = clamp(hp, 0, MAX_HP)
	print("Player HP: ", hp)
	if hp <= 0:
		print("Player died!")
