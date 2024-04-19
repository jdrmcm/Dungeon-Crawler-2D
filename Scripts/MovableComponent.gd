extends Node2D

@export var movespeed: float = 1

@onready var tile_map = $"/root/World/Map/Tilemap"
@onready var map = $"/root/World/Map"
@onready var selectable_c = $"../SelectableComponent"
@onready var move_marker = $MoveMarker
@onready var pawn = $".."

var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool

# Try to move the pawn to a target position
func try_move_to_position(target: Vector2):
	var id_path
	var target_tile = tile_map.local_to_map(target)

	if map.check_for_pawn_by_location(target_tile) != null:
		return

	# If the pawn is moving, get the path from the next point to the mouse position
	# Otherwise, get the path from the pawn's current position to the mouse position
	if is_moving:
		id_path = get_id_path(current_id_path.front(), target)
	else:
		id_path = get_id_path(global_position, target).slice(1)

	# If the path is not empty, make the move marker visible and set its position to the last point in the path
	if id_path.is_empty() == false:
		move_marker.top_level = true
		move_marker.visible = true
		move_marker.global_position = tile_map.map_to_local(id_path.back())

		current_id_path = id_path

# Gets id path from pos arg to target arg
func get_id_path(pos: Vector2, target: Vector2):
	var astar_grid: AStarGrid2D = tile_map.astar_grid

	return astar_grid.get_id_path(
			tile_map.local_to_map(pos),
			tile_map.local_to_map(target)
		)

# Gets movespeed based off modifiers like floor multiplier
func get_movespeed() -> float:
	var mod
	var current_movespeed = movespeed

	# Calculates movespeed modifiers for floor
	var tile_data = tile_map.get_cell_tile_data(
			0, 
			tile_map.local_to_map(global_position)
		)
	
	if tile_data != null:
		mod = tile_data.get_custom_data("movespeed")
	
	current_movespeed *= mod
	
	# Calculates movespeed modifiers for objects
	tile_data = tile_map.get_cell_tile_data(
			1, 
			tile_map.local_to_map(global_position)
		)
	
	if tile_data != null:
		mod = tile_data.get_custom_data("movespeed")
	
	current_movespeed *= mod
	
	return current_movespeed

func movement_step():
	if current_id_path.is_empty(): # If no path, then close out
		move_marker.visible = false
		return
	
	if selectable_c.controllable:
		move_marker.visible = true

	if is_moving == false:
		target_position = tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	pawn.global_position = pawn.global_position.move_toward(
			target_position, 
			get_movespeed()
		)
	
	# If at target position
	if global_position == target_position:
		current_id_path.pop_front()

		# If more points in path, continue to next point
		if current_id_path.is_empty() == false:
			target_position = tile_map.map_to_local(current_id_path.front())
		else: # Else stop moving
			is_moving = false
			move_marker.visible = false

func _physics_process(delta):
	movement_step()

