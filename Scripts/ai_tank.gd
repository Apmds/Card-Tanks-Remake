class_name AiTank extends Tank

@onready var timer : Timer = $Timer
@onready var raycasts = $Cannons/RayCasts

enum modes {
	LOOK_AROUND,
	CHASE,
	ATTACK,
	DESTROYED,
}

var movement_time : float = 2
var look_time : float = 3
var attack_time : float = 1

var mode : modes = modes.LOOK_AROUND
var chase_pos : Vector2i = Vector2i.ZERO


func set_mode(new_mode : modes):
	mode = new_mode
	timer.stop()
	match new_mode:
		modes.LOOK_AROUND:
			timer.wait_time = look_time
		modes.CHASE:
			timer.wait_time = movement_time
		modes.ATTACK:
			timer.wait_time = attack_time
		modes.DESTROYED:
			return
	
	timer.start()

func update_raycasts() -> void:
	for raycast in raycasts.get_children():
		raycast.force_raycast_update()

func get_colliding_raycast() -> RayCast2D:
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return raycast
	return null

func raycasts_colliding() -> bool:
	return get_colliding_raycast() != null

func _ready():
	super._ready()
	randomize()
	set_mode(mode)

func _physics_process(_delta):
	if raycasts_colliding() and mode != modes.ATTACK and mode != modes.DESTROYED:
		chase_pos = get_colliding_raycast().get_collider().grid_position
		set_mode(modes.ATTACK)

func _on_timer_timeout():
	match mode:
		modes.LOOK_AROUND:
			if randf() < 0.5:
				rotate_left()
			else:
				rotate_right()
			
			update_raycasts()
			if raycasts_colliding():
				chase_pos = get_colliding_raycast().get_collider().grid_position
				set_mode(modes.ATTACK)
		modes.CHASE:
			move()
			
			update_raycasts()
			if raycasts_colliding():
				set_mode(modes.ATTACK)
			elif grid_position == chase_pos:
				set_mode(modes.LOOK_AROUND)
		modes.ATTACK:
			update_raycasts()
			if raycasts_colliding():
				chase_pos = get_colliding_raycast().get_collider().grid_position
				shoot_all()
			else:
				set_mode(modes.CHASE)
		modes.DESTROYED:
			timer.stop()

func _on_destroyed():
	set_mode(modes.DESTROYED)
