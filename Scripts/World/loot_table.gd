class_name LootTable
extends Resource

@export var entries: Array[LootTableEntry] = []


func roll_all() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for entry: LootTableEntry in entries:
		if entry == null or entry.item_id.is_empty() or entry.quantity <= 0:
			continue
		results.append({
			"item_id": entry.item_id,
			"quantity": entry.quantity,
		})
	return results
