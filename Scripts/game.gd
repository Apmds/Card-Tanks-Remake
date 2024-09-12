class_name Game extends Node2D
## The game world.

@export_group("Buttons")
## The button on the left.
@export var button_left : TextureButton
## The button on the center.
@export var button_center : TextureButton
## The button on the right.
@export var button_right : TextureButton

@export_group("Tanks")
## The player tank node in the scene.
@export var player : PlayerTank
## Number of tanks that spawn in the begining.
@export var start_spawn_tanks : int
## Max number of tiles of distance from the player to spawn a tank.
@export var spawn_radius : int
## Max number of tanks.
@export var max_tanks = 100
## Radius in tiles where tanks cannot spawn.
@export var not_spawn_radius : int = 6

@export_group("Powers")
## Number of pwoers that spawn in the begining.
@export var start_spawn_powers : int

## Array of tank scenes to spawn.
var spawnable_tanks : Array[PackedScene] = []

var powerScene : PackedScene = preload("res://Scenes/power.tscn")
var powerTimerScene : PackedScene = preload("res://Scenes/power_timer.tscn")

## Whether or not powers spawn or not
var spawn_powers : bool = false

## The current score.
var score : int = 0 :
	set(new_score):
		score = new_score
		score_label.text = "Score: " + str(score)
		if score > Global.high_scores[Global.current_game_mode]:
			Global.high_scores[Global.current_game_mode] = score

## Multiplier for gaining score.
var score_multiplier : float = 1


@onready var tanks : Node2D = $Tanks
@onready var powers : Node2D = $Powers
@onready var power_timers : HBoxContainer = $HUD/PowerTimers
@onready var score_label : Label = $HUD/Up/Score
@onready var camera : GameCamera = $Camera
@onready var pause_button : TextureButton = $HUD/Up/PauseButton

const move_button_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/Move.png")
const move_button_hover_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/MoveHover.png")
const move_button_pressed_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/MovePressed.png")

const turn_left_button_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/TurnLeft.png")
const turn_left_button_hover_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/TurnLeftHover.png")
const turn_left_button_pressed_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/TurnLeftPressed.png")

const turn_right_button_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/TurnRight.png")
const turn_right_button_hover_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/TurnRightHover.png")
const turn_right_button_pressed_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/TurnRightPressed.png")

const shoot_button_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/Shoot.png")
const shoot_button_hover_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/ShootHover.png")
const shoot_button_pressed_texture : CompressedTexture2D = preload("res://Assets/World/Hud/Cards/ShootPressed.png")

enum actions {
	MOVE, SHOOT, TURN_LEFT, TURN_RIGHT
}

## Randomizes the action of the requested button and updates its texture.
func randomize_button(button : TextureButton) -> void:
	var val = randf()
	if val < 0.25:
		button.set_meta("action", actions.MOVE)
		button.texture_normal = move_button_texture
		button.texture_hover = move_button_hover_texture
		button.texture_pressed = move_button_pressed_texture
		button.texture_disabled = move_button_pressed_texture
	elif val < 0.5:
		button.set_meta("action", actions.TURN_LEFT)
		button.texture_normal = turn_left_button_texture
		button.texture_hover = turn_left_button_hover_texture
		button.texture_pressed = turn_left_button_pressed_texture
		button.texture_disabled = turn_left_button_pressed_texture
	elif val < 0.75:
		button.set_meta("action", actions.TURN_RIGHT)
		button.texture_normal = turn_right_button_texture
		button.texture_hover = turn_right_button_hover_texture
		button.texture_pressed = turn_right_button_pressed_texture
		button.texture_disabled = turn_right_button_pressed_texture
	else:
		button.set_meta("action", actions.SHOOT)
		button.texture_normal = shoot_button_texture
		button.texture_hover = shoot_button_hover_texture
		button.texture_pressed = shoot_button_pressed_texture
		button.texture_disabled = shoot_button_pressed_texture

## Executes the action from the given button.
func execute_button_action(button : TextureButton) -> void:
	if player != null:
		match button.get_meta("action", 0):
			actions.MOVE:
				player.move()
			actions.TURN_LEFT:
				player.rotate_left()
			actions.TURN_RIGHT:
				player.rotate_right()
			actions.SHOOT:
				player.shoot_all()

## Returns a grid position that isn't occupied by anything and is within the proper spawn radius.
func get_valid_grid_position() -> Vector2i:
	var grid_pos : Vector2i
	var position_valid = false
	while !position_valid:
		grid_pos = Vector2i(
			randi_range(not_spawn_radius, spawn_radius) * pow(-1, randi_range(0, 1)),
			randi_range(not_spawn_radius, spawn_radius) * pow(-1, randi_range(0, 1))
		)
		
		#var tank_x = randi_range(not_spawn_radius, spawn_radius) * pow(-1, randi_range(0, 1))
		#var tank_y = randi_range(not_spawn_radius, spawn_radius) * pow(-1, randi_range(0, 1))
		if randf() < 0.5:
			grid_pos.x = randi_range(-spawn_radius, spawn_radius)
		else:
			grid_pos.y = randi_range(-spawn_radius, spawn_radius)

		# Spawn around the player if it exists
		if player != null:
			grid_pos.x += player.grid_position.x
			grid_pos.y += player.grid_position.y

		#tank_instance.set_grid_position(Vector2i(tank_x, tank_y))
	
		# Check if tank is overlapping with another
		position_valid = true
		for t : Tank in tanks.get_children():
			if t.grid_position == grid_pos:
				position_valid = false
				break
		for p : Power in powers.get_children():
			if p.grid_position == grid_pos:
				position_valid = false
				break
	
	return grid_pos

## Spawns a random tank from the array of spawnable tanks if any exist.
func spawn_tank() -> void:
	# Don't spawn if tank limit has been reached or there is no more space for a new tank
	if tanks.get_child_count() >= max_tanks or tanks.get_child_count() + powers.get_child_count() >= pow(2*spawn_radius+1, 2) - pow(2*(not_spawn_radius-1)+1, 2):
		return

	var tank : PackedScene = spawnable_tanks.pick_random()
	if tank == null:
		return
	
	var tank_instance : Tank = tank.instantiate()
	
	tank_instance.set_grid_position(get_valid_grid_position())
	
	tanks.add_child(tank_instance)
	tank_instance.owner = self
	tank_instance.destroyed.connect(_on_tank_destroyed)

## Spawns one power into the world.
func spawn_power() -> void:
	# Don't spawn if there is no more space.
	if tanks.get_child_count() + powers.get_child_count() >= pow(2*spawn_radius+1, 2) - pow(2*(not_spawn_radius-1)+1, 2):
		return
	
	var power_instance : Power = powerScene.instantiate()
	
	power_instance.set_grid_position(get_valid_grid_position())
	
	power_instance.power = Global.powers.values().pick_random()
	powers.add_child(power_instance)
	power_instance.grabbed.connect(_on_power_grabbed)

func _ready():
	score = 0
	
	# Set spawnable tanks
	match Global.current_game_mode:
		Global.gameModes.CLASSIC:
			spawnable_tanks.append(load("res://Scenes/ai_tank.tscn"))
		Global.gameModes.TANK_MAYHEM:
			spawnable_tanks.append(load("res://Scenes/ai_tank.tscn"))
			spawnable_tanks.append(load("res://Scenes/ai_tank_double_line.tscn"))
			spawnable_tanks.append(load("res://Scenes/ai_tank_double_l.tscn"))
		Global.gameModes.POWER_MANIA:
			spawnable_tanks.append(load("res://Scenes/ai_tank.tscn"))
			spawn_powers = true
	
	if button_left != null:
		button_left.connect("pressed", _on_button_left_pressed)
		randomize_button(button_left)
	if button_center != null:
		button_center.connect("pressed", _on_button_center_pressed)
		randomize_button(button_center)
	if button_right != null:
		button_right.connect("pressed", _on_button_right_pressed)
		randomize_button(button_right)
	if player != null:
		player.moved.connect(_on_player_moved)
		player.destroyed.connect(_on_player_destroyed)
	
	for i in range(start_spawn_tanks):
		spawn_tank()
	
	if spawn_powers:
		for i in range(start_spawn_powers):
			spawn_power()
	
	$SpawnTimer.start()


func _on_button_left_pressed():
	execute_button_action(button_left)
	randomize_button(button_left)

func _on_button_center_pressed():
	execute_button_action(button_center)
	randomize_button(button_center)

func _on_button_right_pressed():
	execute_button_action(button_right)
	randomize_button(button_right)


func _on_player_moved():
	# Delete tanks that are too far away from the player
	for tank in tanks.get_children():
		if abs(tank.grid_position.x - player.grid_position.x) > spawn_radius*1.1 or abs(tank.grid_position.y - player.grid_position.y) > spawn_radius*1.1:
			tank.queue_free()
	
	# Delete powers that are too far away from the player
	for power in powers.get_children():
		if abs(power.grid_position.x - player.grid_position.x) > spawn_radius*1.1 or abs(power.grid_position.y - player.grid_position.y) > spawn_radius*1.1:
			power.queue_free()

func _on_player_destroyed():
	button_left.disabled = true
	button_center.disabled = true
	button_right.disabled = true
	pause_button.disabled = true
	
	for power_timer : PowerTimer in power_timers.get_children():
		power_timer.stop()
	
	camera.set_new_zoom(Vector2.ONE * 3)
	Global.save_game_data()
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_tank_destroyed():
	score += 100 * score_multiplier

func _on_power_grabbed(power):
	for power_timer : PowerTimer in power_timers.get_children():
		if power_timer.power == power:
			power_timer.restart()
			
			if power_timer.power != Global.powers.ADD_CANNON:
				return
	
	var power_timer_instance : PowerTimer = powerTimerScene.instantiate()
	
	match power:
		Global.powers.ADD_CANNON:
			player.stage = clamp(player.stage + 1, 0, 3)
		Global.powers.ARMOR:
			pass
		Global.powers.DOUBLE_POINTS:
			score_multiplier *= 2
		Global.powers.ZOOM_OUT:
			camera.set_new_zoom(Vector2(1, 1))
	
	power_timers.add_child(power_timer_instance)
	power_timer_instance.set_power(power)
	power_timer_instance.ended.connect(_on_power_timer_ended)

func _on_power_timer_ended(power):
	match power:
		Global.powers.ADD_CANNON:
			player.stage = 0
		Global.powers.ARMOR:
			pass
		Global.powers.DOUBLE_POINTS:
			score_multiplier /= 2
		Global.powers.ZOOM_OUT:
			camera.set_new_zoom(Vector2(2, 2))

func _on_pause_button_pressed():
	get_tree().paused = true
	$PauseScreen.visible = true

func _on_unpause_button_pressed():
	get_tree().paused = false
	$PauseScreen.visible = false

func _on_main_menu_button_pressed():
	Global.save_game_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_spawn_timer_timeout():
	spawn_tank()
	
	if spawn_powers and randf() < 0.25:
		spawn_power()


func _notification(what):
	# Save the game on game closing or when the game is on second plane on android
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		Global.save_game_data()
	
	# Pause/Unpause game when going back on android
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if $PauseScreen.visible:
			_on_unpause_button_pressed()
		else:
			_on_pause_button_pressed()
