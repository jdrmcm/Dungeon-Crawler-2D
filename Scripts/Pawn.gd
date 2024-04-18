extends Node2D

@export var movespeed: float = 1

@onready var tile_map = $"../World/Tilemap"
@onready var world = $"../World"
@onready var sprite = $Sprite
@onready var selection_box = $SelectionBox
@onready var move_marker = $MoveMarker

var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool

var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	world.add_pawn_to_list(self)

func _process(delta):
	selection_box.visible = selected
	move_marker.visible = selected and is_moving

func try_move_to_position(target: Vector2):
	var id_path
	var astar_grid: AStarGrid2D = tile_map.astar_grid
	var tile_data = tile_map.get_cell_tile_data(0, tile_map.local_to_map(target))
	
	if tile_map.tile_data[tile_map.local_to_map(target)].obstructed:
		return
	
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

func _physics_process(delta):
	if current_id_path.is_empty():
		return
	
	if is_moving == false:
		target_position = tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	global_position = global_position.move_toward(target_position, movespeed)
	
	if global_position == target_position:
		current_id_path.pop_front()
		
		if current_id_path.is_empty() == false:
			target_position = tile_map.map_to_local(current_id_path.front())
		else:
			is_moving = false
			move_marker.visible = false
