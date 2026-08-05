extends Node

signal enemy_defeated(enemy_id: String, xp_reward: int, world_position: Vector2)
signal damage_dealt(amount: int, target: Node, source_id: String)
signal damage_taken(amount: int, remaining_health: int)
signal damage_avoided(reason: StringName)
signal dodge_used
signal item_equipped(item_id: String, slot_key: String)
signal technique_used(technique_id: String, targets_hit: int)
signal location_discovered(location_id: String)
signal quest_completed(quest_id: String)
signal expedition_survived
