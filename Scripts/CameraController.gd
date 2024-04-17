extends Camera2D

@export var speed_mult = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	# Handles zooming in and out
	if Input.is_action_just_released("zoom_in"):
		zoom_in()
	if Input.is_action_just_released("zoom_out"):
		zoom_out()

var target_zoom = 4
const MIN_ZOOM = 0.8
const MAX_ZOOM = 10
const ZOOM_INCREMENT = 0.25

func zoom_in():
	target_zoom = clampf(target_zoom + ZOOM_INCREMENT, MIN_ZOOM, MAX_ZOOM)
	set_physics_process(true)

func zoom_out():
	target_zoom = clampf(target_zoom - ZOOM_INCREMENT, MIN_ZOOM, MAX_ZOOM)
	set_physics_process(true)

const ZOOM_RATE = 16.0

# Just lerps for zoom animation
func _physics_process(delta):
	set_zoom( lerp(
		get_zoom(),
		target_zoom * Vector2.ONE,
		ZOOM_RATE * delta
	))
	set_physics_process(
		not is_equal_approx(zoom.x, target_zoom)
	)

func _unhandled_input(event: InputEvent) -> void:
	# Handles MMB drag camera movement
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("drag_camera"):
			position -= event.relative / zoom
