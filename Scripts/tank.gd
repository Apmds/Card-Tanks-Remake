class_name Tank extends Area2D

@export_group("Debug vars")
@export var use_start_position : bool
@export var start_position : Vector2i

const bulletScene : PackedScene = preload("res://Scenes/bullet.tscn")
const shootParticlesScene : PackedScene = preload("res://Scenes/shoot_particles.tscn")

@onready var crossairs = $Rotatable/Crossairs
@onready var rotating_stuff = $Rotatable

enum directions {UP, DOWN, LEFT, RIGHT}

var direction : directions = directions.RIGHT
var grid_position = Vector2i.ZERO

signal moved
signal destroyed

func set_grid_position(new_position : Vector2i) -> void:
	grid_position = new_position
	position.x = grid_position.x * 32
	position.y = grid_position.y * 32

func set_direction(new_direction : directions) -> void:
	match new_direction:
		directions.UP:
			rotating_stuff.rotation_degrees = -90
		directions.DOWN:
			rotating_stuff.rotation_degrees = 90
		directions.LEFT:
			rotating_stuff.rotation_degrees = 180
		directions.RIGHT:
			rotating_stuff.rotation_degrees = 0
	
	direction = new_direction

func rotate_left() -> void:
	match direction:
		directions.UP:
			set_direction(directions.LEFT)
		directions.DOWN:
			set_direction(directions.RIGHT)
		directions.LEFT:
			set_direction(directions.DOWN)
		directions.RIGHT:
			set_direction(directions.UP)

func rotate_right() -> void:
	match direction:
		directions.UP:
			set_direction(directions.RIGHT)
		directions.DOWN:
			set_direction(directions.LEFT)
		directions.LEFT:
			set_direction(directions.UP)
		directions.RIGHT:
			set_direction(directions.DOWN)

func move(steps : int = 1) -> void:
	var new_position = grid_position
	for i in range(steps):
		match direction:
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

func shoot_all() -> void:
	for crossair in crossairs.get_children():
		shoot(crossair)

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
	
	match direction:
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

func explode() -> void:
	monitoring = false
	set_deferred("monitorable", false)
	
	$Rotatable/Explosion.visible = true
	$Rotatable/Explosion.play("default")
	$ExplosionSound.play()
	destroyed.emit()
	await $Rotatable/Explosion.animation_finished
	queue_free()

func _ready():
	if use_start_position:
		set_grid_position(start_position)
	
	for crossair in crossairs.get_children():
		if crossair.get_meta("shoot_direction", -1) == -1:
			crossair.set_meta("shoot_direction", directions.RIGHT)
	
	set_direction(direction)


func _on_area_entered(area):
	if area is Tank:
		explode()
