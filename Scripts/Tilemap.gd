extends TileMap

@onready var world = $".."

var astar_grid: AStarGrid2D
var tile_data = {}

const NUM_LAYERS: int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_used_cells(0):
		tile_data[i] = Tile.new()
	recalculate_astar()

# Calculates astar grid walkable points
func recalculate_astar():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.set_offset(Vector2(8, 8))
	astar_grid.update()
	
	for x in get_used_rect().size.x:
		for y in get_used_rect().size.y:
			var tile_position = Vector2i(
				x + get_used_rect().position.x,
				y + get_used_rect().position.y
			)
			
			calculate_walkable(tile_position)

# Calculates if a specific tile is walkable
func calculate_walkable(tile_position: Vector2i):
	var tile_data = get_cell_tile_data(0, tile_position)
	
	if tile_data == null or tile_data.get_custom_data("traversable") == false:
		astar_grid.set_point_solid(tile_position, true)
	
	tile_data = get_cell_tile_data(1, tile_position)
	
	if tile_data != null and tile_data.get_custom_data("traversable") == false:
		astar_grid.set_point_solid(tile_position, true)

# Called by pawn whenever they move instead of updating grid every frame
func pawn_moved(destination: Vector2i, pawn):
	tile_data[destination].obstructed = true
	tile_data[world.pawns[pawn]].obstructed = false

func set_obstructed(pos: Vector2i, obstructed: bool):
	tile_data[pos].obstructed = obstructed
	print("obstructed ", position, " = ", obstructed)
