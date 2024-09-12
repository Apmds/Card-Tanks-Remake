class_name PlayerTank extends Tank
## The tank used by the player.

const single_cannon_texture : CompressedTexture2D = preload("res://Assets/Tanks/Player/cannon_idle.png")
const double_cannon_texture : CompressedTexture2D = preload("res://Assets/Tanks/Player/cannon_double.png")
const triple_cannon_texture : CompressedTexture2D = preload("res://Assets/Tanks/Player/cannon_triple.png")
const quadruple_cannon_texture : CompressedTexture2D = preload("res://Assets/Tanks/Player/cannon_quadruple.png")

@onready var cannons_sprite = $Cannons/CannonsSprite

var crossair_left : Marker2D = Marker2D.new()
var crossair_up : Marker2D = Marker2D.new()
var crossair_down : Marker2D = Marker2D.new()
var stage : int = 0 :
	set(new_stage):
		stage = new_stage
		
		remove_cannon_left()
		remove_cannon_up()
		remove_cannon_down()
		match stage:
			0:
				cannons_sprite.texture = single_cannon_texture
			1:
				cannons_sprite.texture = double_cannon_texture
				add_cannon_left()
			2:
				cannons_sprite.texture = triple_cannon_texture
				add_cannon_left()
				add_cannon_up()
			3:
				cannons_sprite.texture = quadruple_cannon_texture
				add_cannon_left()
				add_cannon_up()
				add_cannon_down()

func add_cannon_left() -> void:
	if not crossair_left in crossairs.get_children():
		crossairs.add_child(crossair_left)

func add_cannon_up() -> void:
	if not crossair_up in crossairs.get_children():
		crossairs.add_child(crossair_up)

func add_cannon_down() -> void:
	if not crossair_down in crossairs.get_children():
		crossairs.add_child(crossair_down)

func remove_cannon_left() -> void:
	if crossair_left in crossairs.get_children():
		crossairs.remove_child(crossair_left)

func remove_cannon_up() -> void:
	if crossair_up in crossairs.get_children():
		crossairs.remove_child(crossair_up)

func remove_cannon_down() -> void:
	if crossair_down in crossairs.get_children():
		crossairs.remove_child(crossair_down)

func _ready():
	crossair_left.set_meta("shoot_direction", directions.LEFT)
	crossair_left.position.x = -20
	
	crossair_up.set_meta("shoot_direction", directions.UP)
	crossair_up.position.y = -20
	
	crossair_down.set_meta("shoot_direction", directions.DOWN)
	crossair_down.position.y = 20

#func _physics_process(delta):
#	if Input.is_action_just_pressed("button_left"):
#		rotate_left()
#	if Input.is_action_just_pressed("button_center"):
#		move()
#	if Input.is_action_just_pressed("button_right"):
#		rotate_right()
			
