extends Camera2D

@export var speed_mult = 1.5
@export var accel_speed_mult = 3

func _ready():
	pass # Replace with function body.

func _process(delta):
	# WASD camera movement
	var current_speed_mult
	
	if Input.is_action_pressed("accel"):
		current_speed_mult = accel_speed_mult
	else:
		current_speed_mult = speed_mult
	
	if Input.is_action_pressed("up"):
		position.y -= (10 * current_speed_mult) / zoom.x
	if Input.is_action_pressed("down"):
		position.y += (10 * current_speed_mult) / zoom.x
	if Input.is_action_pressed("left"):
		position.x -= (10 * current_speed_mult) / zoom.x
	if Input.is_action_pressed("right"):
		position.x += (10 * current_speed_mult) / zoom.x

func _input(event):
	# Handles zooming in and out
	if Input.is_action_just_released("zoom_in"):
		zoom_in(ZOOM_INCREMENT)
	if Input.is_action_just_released("zoom_out"):
		zoom_out(ZOOM_INCREMENT)
	
	# Trackpad zooming
	if event is InputEventPanGesture:
		if event.delta.y < 0:
			zoom_in(ZOOM_INCREMENT / 5)
		elif event.delta.y > 0:
			zoom_out(ZOOM_INCREMENT / 5)
	
	# Handles MMB drag camera movement
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("drag_camera"):
			position -= event.relative / zoom

var target_zoom = 4
const MIN_ZOOM = 3
const MAX_ZOOM = 10
const ZOOM_INCREMENT = 0.25

func zoom_in(increment: float):
	target_zoom = clampf(target_zoom + increment, MIN_ZOOM, MAX_ZOOM)
	set_physics_process(true)

func zoom_out(increment: float):
	target_zoom = clampf(target_zoom - increment, MIN_ZOOM, MAX_ZOOM)
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
