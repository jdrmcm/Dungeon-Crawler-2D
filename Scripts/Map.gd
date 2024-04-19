extends Node

@onready var tile_map = $Tilemap

var pawns: Dictionary = {}

# Add pawn to dict of pawns, returns false if pawn is already in dict
func add_pawn_to_list(pawn: Object) -> bool:
	if pawns.has(pawn):
		return false
	else:
		var pawn_position = tile_map.local_to_map(pawn.global_position)
		pawns[pawn] = pawn_position
		return true

func _process(delta):
	update_pawn_positions()

# Updates positions of pawns
func update_pawn_positions():
	for pawn in pawns:
		var pawn_position = tile_map.local_to_map(pawn.global_position)
		pawns[pawn] = pawn_position

# Function to return pawn by location
# Query arg is a Vector2i of the queried location on the tilemap
func check_for_pawn_by_location(query: Vector2i) -> Object:
	return pawns.find_key(query)