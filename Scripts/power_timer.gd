class_name PowerTimer extends TextureProgressBar

@onready var timer : Timer = $Timer

const add_cannon_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/addCannon.png")
const armor_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/superArmor.png")
const double_points_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/doublePoints.png")
const zoom_out_texture : CompressedTexture2D = preload("res://Assets/Powers/Icons/zoomOut.png")

@export var power : Global.powers

signal ended(powerType : Global.powers)

## Setter for the power.
func set_power(new_power) -> void:
	power = new_power
	
	timer.stop()
	match power:
		Global.powers.ADD_CANNON:
			modulate = Color("2ddc48")
			texture_over = add_cannon_texture
			timer.wait_time = 20
		Global.powers.ARMOR:
			modulate = Color("dc2d2d")
			texture_over = armor_texture
			timer.wait_time = 20
		Global.powers.DOUBLE_POINTS:
			modulate = Color("d3dc2d")
			texture_over = double_points_texture
			timer.wait_time = 15
		Global.powers.ZOOM_OUT:
			modulate = Color("2db7dc")
			texture_over = zoom_out_texture
			timer.wait_time = 15
	timer.start()

## Restarts the timer.
func restart() -> void:
	timer.start()

## Stops the timer.
func stop() -> void:
	timer.stop()

## Stops the timer while also deleting it and ending it with the [signal ended] signal.
func stop_ended() -> void:
	timer.stop()
	ended.emit(power)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_power(power)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = (timer.time_left / timer.wait_time) * max_value

func _on_timer_timeout():
	stop_ended()
