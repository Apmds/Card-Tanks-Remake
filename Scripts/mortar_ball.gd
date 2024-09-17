class_name MortarBall extends Bullet

@onready var sprite : Sprite2D = $Sprite

func _ready():
	max_distance = tile_range * 32
	speed = 10
	super._ready()

func _physics_process(delta):
	sprite.scale.x = 1 + sin(distance_travelled/32.0)*1.5
	sprite.scale.y = sprite.scale.x
	super._physics_process(delta)
