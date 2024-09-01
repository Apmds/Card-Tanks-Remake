class_name GameCamera extends Camera2D

@export var following : Node2D
var speed = 5
var position_internal = Vector2.ZERO
var zoom_internal = Vector2.ZERO

func distance_to_following_obj():
	return sqrt(pow(position.x - following.position.x, 2) + pow(position.y - following.position.y, 2))

func set_new_zoom(new_zoom : Vector2):
	zoom_internal = new_zoom

func _ready():
	position_internal = position
	zoom_internal = zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if following != null:
		position_internal.x = move_toward(position_internal.x, following.position.x, distance_to_following_obj() * speed * delta)
		position_internal.y = move_toward(position_internal.y, following.position.y, distance_to_following_obj() * speed * delta)
		position = position_internal.round()
	
	zoom.x = move_toward(zoom.x, zoom_internal.x, delta)
	zoom.y = move_toward(zoom.y, zoom_internal.y, delta)
