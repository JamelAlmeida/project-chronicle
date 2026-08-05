class_name StatBlock
extends Resource

@export var max_health: float = 0.0
@export var move_speed: float = 0.0
@export var attack_damage: float = 0.0
@export var attack_speed: float = 0.0
@export var armor: float = 0.0
@export var crit_chance: float = 0.0
@export var lifesteal: float = 0.0


func get_stat(stat_name: String) -> float:
	match stat_name:
		"max_health":
			return max_health
		"move_speed":
			return move_speed
		"attack_damage":
			return attack_damage
		"attack_speed":
			return attack_speed
		"armor":
			return armor
		"crit_chance":
			return crit_chance
		"lifesteal":
			return lifesteal
		_:
			return 0.0
