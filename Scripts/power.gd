class_name Power extends Area2D
## Base class for all powers.


## The power this gives.
@export var power : Global.powers

## Emitted when the player tank grabs the power up
signal grabbed(powerType : Global.powers)

func _ready():
	pass

func _on_area_entered(area):
	grabbed.emit(power)
	queue_free()
