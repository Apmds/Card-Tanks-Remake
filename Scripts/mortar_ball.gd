class_name MortarBall extends Bullet

@onready var sprite : Sprite2D = $Sprite
@onready var collision : CollisionShape2D = $Collision

func end_range() -> void:
	collision.disabled = false
	visible = false
	await get_tree().physics_frame
	super.end_range()

func bullet_entered(bullet : Bullet) -> void:
	pass

func _ready():
	max_distance = tile_range * 32
	speed = 10
	
	collision.disabled = true
	super._ready()

func _physics_process(delta):
	sprite.scale.x = 1 + sin(distance_travelled/32.0)*1.5
	sprite.scale.y = sprite.scale.x
	super._physics_process(delta)
