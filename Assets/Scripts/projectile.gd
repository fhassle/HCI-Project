extends RigidBody3D

signal hit_enemy(enemy: Node3D)

# Projectile Speed
var speed = 20.0
var damage = 25.0
var is_enemy_projectile: bool = false

@onready var dagger_visual = $MeshInstance3D
@onready var sphere_visual = $SphereVisual
@onready var dagger_collision = $DaggerCollision
@onready var sphere_collision = $SphereCollision

func _ready():
	dagger_visual.visible = not is_enemy_projectile
	sphere_visual.visible = is_enemy_projectile
	dagger_collision.disabled = is_enemy_projectile
	sphere_collision.disabled = not is_enemy_projectile

# Launch physics
func launch(direction: Vector3):
	gravity_scale = 0
	linear_velocity = direction * speed

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
	elif body.is_in_group("enemies"):
		body.take_damage(damage)
		hit_enemy.emit(body)
	queue_free()
