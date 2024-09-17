class_name Bullet extends Area2D

# Number of tiles of range
var tile_range = 3
var speed = 300
var tank_owner = null

var distance_travelled = 0
var max_distance = tile_range * 32 - 16
var speed_vector = Vector2.ZERO

func _ready():
	speed_vector.x = cos(rotation) * speed
	speed_vector.y = sin(rotation) * speed

func _physics_process(delta):
	global_position += speed_vector * delta
	distance_travelled += speed * delta
	
	if distance_travelled >= max_distance:
		queue_free() 


func _on_area_entered(area):
	if area is Bullet and tank_owner != area.tank_owner:
		area.queue_free()
		queue_free()
		
	if area is Tank and tank_owner != area:
		area.explode()
		queue_free()
	

