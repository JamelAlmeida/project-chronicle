extends EnemyBase


func _enemy_ready() -> void:
	move_speed = 60.0
	max_health = 30
	health = max_health
	attack_damage = 15
	attack_range = 26.0
	attack_cooldown = 1.0
	detection_range = 250.0
	knockback_force_on_hit = 80.0
	if loot_item_id.is_empty():
		loot_item_id = "slime_gel"
		loot_quantity = 1
