class_name AiTank extends Tank
## Base class for every tank with "AI".

## Timer for everything.
@onready var timer : Timer = $Timer
## Node with all the raycasts.
@onready var raycasts : Node2D = $Cannons/RayCasts

## Dictionary that assciates a raycasts id with the respective crossair.
@export var raycast_to_crossair : Dictionary

## All the modes the tank can be in.
enum modes {
	LOOK_AROUND,
	CHASE,
	ATTACK,
	DESTROYED,
}

## Time between moving (in seconds).
const movement_time : float = 2
## Time between looking around (in seconds).
const look_time : float = 3
## Time between attacks (in seconds).
const attack_time : float = 1

## Tanks current mode.
var mode : modes = modes.LOOK_AROUND
## Grid position of the tank this is chasing.
var chase_pos : Vector2i = Vector2i.ZERO
## Direction to rotate the body to chase the tank.
var chase_direction : directions = directions.RIGHT

## Setter for the [member mode].
func set_mode(new_mode : modes) -> void:
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

## Force updates all of the raycasts.
func update_raycasts() -> void:
	for raycast in raycasts.get_children():
		raycast.force_raycast_update()

## Returns the RayCast2D that is colliding or null if none are colliding.
func get_colliding_raycast() -> RayCast2D:
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return raycast
	return null

## Returns whether or not there is a raycast colliding.
func raycasts_colliding() -> bool:
	return get_colliding_raycast() != null

## Updates [member grid_pos] and [member chase_direction].
func update_chase_variables() -> void:
	chase_pos = get_colliding_raycast().get_collider().grid_position
	
	# Hacky way of getting the direction to turn the tank
	var chase_dir_degs = direction_to_degrees(cannons_direction)
	chase_dir_degs += direction_to_degrees(get_node(raycast_to_crossair[get_colliding_raycast().get_meta("id", 0)]).get_meta("shoot_direction"))
	match chase_dir_degs % 360:
		270:
			chase_direction = directions.UP
		90:
			chase_direction = directions.DOWN
		180:
			chase_direction = directions.LEFT
		0:
			chase_direction = directions.RIGHT

## What to do when the tank has the LOOK_AROUND mode.
func look_around_action() -> void:
	var rand : float = randf()
	if rand < 0.25:
		rotate_left()
	elif rand < 0.5:
		rotate_right()
	elif rand < 0.75:
		rotate_left(false, true)
	else:
		rotate_right(false, true)
	
	update_raycasts()
	if raycasts_colliding():
		update_chase_variables()
		set_mode(modes.ATTACK)

## What to do when the tank has the CHASE mode.
func chase_action() -> void:
	set_direction(chase_direction)
	move()
	
	update_raycasts()
	if raycasts_colliding():
		set_mode(modes.ATTACK)
	elif grid_position == chase_pos:
		set_mode(modes.LOOK_AROUND)

## What to do when the tanks has the ATTACK mode.
func attack_action() -> void:
	update_raycasts()
	if raycasts_colliding():
		update_chase_variables()
		shoot_all()
	else:
		set_mode(modes.CHASE)

func _ready():
	super._ready()
	randomize()
	set_mode(mode)

func _physics_process(_delta):
	if raycasts_colliding() and mode != modes.ATTACK and mode != modes.DESTROYED:
		update_chase_variables()
		set_mode(modes.ATTACK)

func _on_timer_timeout():
	match mode:
		modes.LOOK_AROUND:
			look_around_action()
		modes.CHASE:
			chase_action()
		modes.ATTACK:
			attack_action()
		modes.DESTROYED:
			timer.stop()

func _on_destroyed():
	set_mode(modes.DESTROYED)
