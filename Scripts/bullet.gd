class_name Bullet extends Area2D

# Number of tiles of range
var tile_range = 3
var speed = 300
var tank_owner = null

var distance_travelled = 0
var max_distance = tile_range * 32 - 16
var speed_vector = Vector2.ZERO

## Emitted when the bullet has been destroyed in any way.
signal destroyed

## What to do when the bullet has reached the end of its range.
func end_range() -> void:
	destroyed.emit()
	queue_free()

## Executed when a bullet enters this one.
func bullet_entered(bullet : Bullet) -> void:
	bullet.queue_free()
	destroyed.emit()
	end_range()

## Executed when a tank enters this one.
func tank_entered(tank : Tank) -> void:
	tank.explode()
	destroyed.emit()
	end_range()

func _ready():
	speed_vector.x = cos(rotation) * speed
	speed_vector.y = sin(rotation) * speed

func _physics_process(delta):
	global_position += speed_vector * delta
	distance_travelled += speed * delta
	
	if distance_travelled >= max_distance:
		end_range() 


func _on_area_entered(area):
	if area is Bullet and tank_owner != area.tank_owner:
		bullet_entered(area)
		
	if area is Tank and tank_owner != area:
		tank_entered(area)
	

