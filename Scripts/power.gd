class_name Power extends Area2D
## Base class for all powers.

@onready var icon : Sprite2D = $Icon

const add_cannon_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/addCannon.png")
const armor_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/superArmor.png")
const double_points_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/doublePoints.png")
const zoom_out_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/zoomOut.png")

## Powers current position in the grid.
var grid_position : Vector2i = Vector2i.ZERO

## The power this gives.
@export var power : Global.powers

## Emitted when the player tank grabs the power up.
signal grabbed(powerType : Global.powers)

## Setter for the grid position.
func set_grid_position(new_position : Vector2i) -> void:
	grid_position = new_position
	position.x = grid_position.x * 32
	position.y = grid_position.y * 32

func _ready():
	match power:
		Global.powers.ADD_CANNON:
			modulate = Color("2ddc48")
			icon.texture = add_cannon_texture
		Global.powers.ARMOR:
			modulate = Color("dc2d2d")
			icon.texture = armor_texture
		Global.powers.DOUBLE_POINTS:
			modulate = Color("d3dc2d")
			icon.texture = double_points_texture
		Global.powers.ZOOM_OUT:
			modulate = Color("2db7dc")
			icon.texture = zoom_out_texture

func _on_area_entered(area):
	grabbed.emit(power)
	queue_free()
