class_name Power extends Area2D
## Base class for all powers.

@export_group("Debug vars")
## Debug var. Check to make the tank spawn in the [member start_position].
@export var use_start_position : bool
## Debug var. The position to start the tank in.
@export var start_position : Vector2i

@export_group("Power")
## The power this gives.
@export var power : Global.powers

const add_cannon_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/addCannon.png")
const armor_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/superArmor.png")
const double_points_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/doublePoints.png")
const zoom_out_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/zoomOut.png")

@onready var icon : Sprite2D = $Icon

## Powers current position in the grid.
var grid_position : Vector2i = Vector2i.ZERO


## Emitted when the player tank grabs the power up.
signal grabbed(powerType : Global.powers)

## Setter for the grid position.
func set_grid_position(new_position : Vector2i) -> void:
	grid_position = new_position
	position.x = grid_position.x * 32
	position.y = grid_position.y * 32

## Setter for the power.
func set_power(new_power) -> void:
	power = new_power
	
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

func _ready():
	set_power(power)
	
	if use_start_position:
		set_grid_position(start_position)

func _on_area_entered(area):
	grabbed.emit(power)
	queue_free()
