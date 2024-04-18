extends Node2D

var selected: Array

func _input(event):
	# Handles selecting things
	if event.is_action_pressed("select"):
		if selected.is_empty() == false:
			for item in selected:
				item.collider.get_parent().selected = false
		
		selected = check_if_something_at_position(get_global_mouse_position())
		
		if selected.is_empty() == false:
			for item in selected:
				item.collider.get_parent().selected = true
	
	if event.is_action_pressed("move"):
		for item in selected:
			item.collider.get_parent().try_move_to_position(get_global_mouse_position())

# Checks if there is a selectable thing at target position
func check_if_something_at_position(target: Vector2) -> Array:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = target
	query.collide_with_areas = true
	query.collision_mask = 2 # Layer 2 is for selectable things (wont remember that later lol)
	var result: Array = space_state.intersect_point(query, 32)
	return result
