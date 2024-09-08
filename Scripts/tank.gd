class_name Tank extends Area2D
## The base class for all tanks.

@export_group("Debug vars")

## Debug var. Check to make the tank spawn in the [member start_position].
@export var use_start_position : bool

## Debug var. The position to start the tank in.
@export var start_position : Vector2i


const bulletScene : PackedScene = preload("res://Scenes/bullet.tscn")
const shootParticlesScene : PackedScene = preload("res://Scenes/shoot_particles.tscn")


## Node that contains all the crossairs.
@onready var crossairs : Node2D = $Cannons/Crossairs
## Sprite of the explosion
@onready var explosion : AnimatedSprite2D = $Explosion

## Body node of the tank.
@onready var body : Node2D = $Body
## Node with all the cannons and anyhting that goes with them.
@onready var cannons : Node2D = $Cannons

## The directions that the tank can have.
enum directions {UP, DOWN, LEFT, RIGHT}

## Tanks body current direction.
var body_direction : directions = directions.RIGHT

## Tanks cannons current direction.
var cannons_direction : directions = directions.RIGHT

## Tanks current position in the grid.
var grid_position : Vector2i = Vector2i.ZERO

## Emitted when the tank moves.
signal moved
## Emitted when the tank is destroyed.
signal destroyed

## Returns the rotation in degrees associated to dir.
func direction_to_degrees(dir : directions) -> int:
	match dir:
		directions.UP:
			return 270
		directions.DOWN:
			return 90
		directions.LEFT:
			return 180
		directions.RIGHT:
			return 0
		_:
			return 0

## Setter for the grid position. Does not emit the [signal moved] signal.
func set_grid_position(new_position : Vector2i) -> void:
	grid_position = new_position
	position.x = grid_position.x * 32
	position.y = grid_position.y * 32

## Setter for both of the tanks directions.
func set_direction(new_direction):
	set_body_direction(new_direction)
	set_cannons_direction(new_direction)

## Setter for the body direction.
func set_body_direction(new_direction : directions) -> void:
	match new_direction:
		directions.UP:
			body.rotation_degrees = -90
		directions.DOWN:
			body.rotation_degrees = 90
		directions.LEFT:
			body.rotation_degrees = 180
		directions.RIGHT:
			body.rotation_degrees = 0
	
	body_direction = new_direction

## Setter for the cannons direction.
func set_cannons_direction(new_direction : directions) -> void:
	match new_direction:
		directions.UP:
			cannons.rotation_degrees = -90
		directions.DOWN:
			cannons.rotation_degrees = 90
		directions.LEFT:
			cannons.rotation_degrees = 180
		directions.RIGHT:
			cannons.rotation_degrees = 0
	
	cannons_direction = new_direction


## Rotates the tank to the left.
func rotate_left(rot_body : bool = true, rot_cannons : bool = true) -> void:
	if rot_body:
		match body_direction:
			directions.UP:
				set_body_direction(directions.LEFT)
			directions.DOWN:
				set_body_direction(directions.RIGHT)
			directions.LEFT:
				set_body_direction(directions.DOWN)
			directions.RIGHT:
				set_body_direction(directions.UP)
	if rot_cannons:
		match cannons_direction:
			directions.UP:
				set_cannons_direction(directions.LEFT)
			directions.DOWN:
				set_cannons_direction(directions.RIGHT)
			directions.LEFT:
				set_cannons_direction(directions.DOWN)
			directions.RIGHT:
				set_cannons_direction(directions.UP)
	
	

## Rotates the tank to the right.
func rotate_right(rot_body : bool = true, rot_cannons : bool = true) -> void:
	if rot_body:
		match body_direction:
			directions.UP:
				set_body_direction(directions.RIGHT)
			directions.DOWN:
				set_body_direction(directions.LEFT)
			directions.LEFT:
				set_body_direction(directions.UP)
			directions.RIGHT:
				set_body_direction(directions.DOWN)
	
	if rot_cannons:
		match cannons_direction:
			directions.UP:
				set_cannons_direction(directions.RIGHT)
			directions.DOWN:
				set_cannons_direction(directions.LEFT)
			directions.LEFT:
				set_cannons_direction(directions.UP)
			directions.RIGHT:
				set_cannons_direction(directions.DOWN)

## Moves the tank a specified number of steps in the direction they facing.
func move(steps : int = 1) -> void:
	var new_position = grid_position
	for i in range(steps):
		match body_direction:
			directions.UP:
				new_position.y -= 1
			directions.DOWN:
				new_position.y += 1
			directions.LEFT:
				new_position.x -= 1
			directions.RIGHT:
				new_position.x += 1
	set_grid_position(new_position)
	moved.emit()

## Shoots all the crossairs the tank has.
func shoot_all() -> void:
	for crossair in crossairs.get_children():
		shoot(crossair)

## Shoots a specific crossair of the tank.
func shoot(crossair : Marker2D) -> void:
	if crossair == null:
		return
	var bullet_instance = bulletScene.instantiate()
	bullet_instance.tank_owner = self
	bullet_instance.global_position = crossair.global_position
	
	# Make shooting particles that delete themselves after
	var shoot_particles = shootParticlesScene.instantiate()
	shoot_particles.finished.connect(func(): shoot_particles.queue_free())
	shoot_particles.emitting = true
	crossair.add_child(shoot_particles)
	
	match cannons_direction:
		directions.UP:
			bullet_instance.rotation_degrees = -90
		directions.DOWN:
			bullet_instance.rotation_degrees = 90
		directions.LEFT:
			bullet_instance.rotation_degrees = 180
		directions.RIGHT:
			bullet_instance.rotation_degrees = 0
	
	match crossair.get_meta("shoot_direction", directions.RIGHT):
		directions.UP:
			bullet_instance.rotation_degrees += -90
		directions.DOWN:
			bullet_instance.rotation_degrees += 90
		directions.LEFT:
			bullet_instance.rotation_degrees += 180
		directions.RIGHT:
			bullet_instance.rotation_degrees += 0
	
	$ShootSound.play()
	if owner == null:
		add_child(bullet_instance)
	else:
		owner.add_child(bullet_instance)

## Explodes the tank.
func explode() -> void:
	# Remove comments and comment next line to make crashing into an exploding tank kill the player
	#set_deferred("monitoring", false)
	#set_deferred("monitorable", false)
	$Collision.set_deferred("disabled", true)
	
	explosion.visible = true
	explosion.play("default")
	$ExplosionSound.play()
	destroyed.emit()
	await explosion.animation_finished
	queue_free()

func _ready():
	if use_start_position:
		set_grid_position(start_position)
	
	for crossair in crossairs.get_children():
		if crossair.get_meta("shoot_direction", -1) == -1:
			crossair.set_meta("shoot_direction", directions.RIGHT)
	
	set_direction(body_direction)


func _on_area_entered(area):
	if area is Tank:
		explode()
