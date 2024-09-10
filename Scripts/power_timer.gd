class_name PowerTimer extends TextureProgressBar

@export var power : Global.powers

signal ended(powerType : Global.powers)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	value = ($Timer.time_left / $Timer.wait_time) * max_value


func _on_timer_timeout():
	ended.emit(power)
	queue_free()
