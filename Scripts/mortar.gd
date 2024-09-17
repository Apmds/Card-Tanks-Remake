class_name Mortar extends AiTank

func move(steps : int = 1) -> void:
	super.move(0)

func _ready():
	bulletScene = preload("res://Scenes/mortar_ball.tscn")
	super._ready()
