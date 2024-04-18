extends Node2D

@export var movespeed: float = 1

@onready var tile_map = $"../World/Tilemap"
@onready var world = $"../World"
@onready var sprite = $Sprite
@onready var selectable_c = $SelectableComponent
@onready var move_marker = $MoveMarker

var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	world.add_pawn_to_list(self)

func _process(delta):
	move_marker.visible = selectable_c.selected and is_moving

func try_move_to_position(target: Vector2):
	var id_path
	var astar_grid: AStarGrid2D = tile_map.astar_grid
	
	if is_moving:
		id_path = astar_grid.get_id_path(
			tile_map.local_to_map(target),
			tile_map.local_to_map(get_global_mouse_position())
		)
	else:
		id_path = astar_grid.get_id_path(
			tile_map.local_to_map(global_position),
			tile_map.local_to_map(get_global_mouse_position())
		).slice(1)
	
	if id_path.is_empty() == false:
		move_marker.top_level = true
		move_marker.visible = true
		move_marker.global_position = tile_map.map_to_local(id_path.back())
		
		current_id_path = id_path
		

# CHANGE EVERYTHING TO WORK IN 'STEPS'

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
		return
	
	if is_moving == false:
		target_position = tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	global_position = global_position.move_toward(
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
