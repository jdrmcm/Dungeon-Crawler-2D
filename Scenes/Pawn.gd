extends Node2D

@onready var map = $"/root/World/Map"

func _ready():
	map.add_pawn_to_list(self)
