extends RigidBody3D

signal hit_enemy(enemy: Node3D)

# Projectile Speed
var speed = 20.0
var damage = 25.0

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
