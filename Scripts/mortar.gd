class_name Mortar extends AiTank

var num_bullets : int = 0

func move(steps : int = 1) -> void:
	super.move(0)

func attack_action() -> void:
	update_raycasts()
	if raycasts_colliding() and num_bullets == 0:
		shoot(get_node(raycast_to_crossair[get_colliding_raycast().get_meta("id", 0)]))
		num_bullets += 1

func _ready():
	bulletScene = preload("res://Scenes/mortar_ball.tscn")
	super._ready()

func _on_bullet_destroyed():
	num_bullets -= 1
	if num_bullets < 0:
		num_bullets = 0
