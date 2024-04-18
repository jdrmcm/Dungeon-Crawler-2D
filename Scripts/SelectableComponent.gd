extends Node2D

@export var controllable: bool = false

@onready var selection_box = $SelectionBox

var selected: bool

func select(s: bool):
	selected = s
	selection_box.visible = s
