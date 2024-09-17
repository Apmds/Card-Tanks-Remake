extends Control

var i = 0

var modesImages = {
	Global.gameModes.CLASSIC: preload("res://Assets/Main menu/ClassicModeBanner.png"),
	Global.gameModes.TANK_MAYHEM: preload("res://Assets/Main menu/TankMayhemModeBanner.png"),
	Global.gameModes.POWER_MANIA: preload("res://Assets/Main menu/PowerManiaModeBanner.png"),
	Global.gameModes.CHAOS_MODE: preload("res://Assets/Main menu/ClassicModeBanner.png"),
}

var checkIcon = preload("res://Assets/Ui/check_icon.png")
var uncheckIcon = preload("res://Assets/Ui/uncheck_icon.png")

@onready var modeImage : TextureRect = $MainMenu/VBoxContainer/Background/VBoxContainer/PanelContainer/ModeImage
@onready var modeNameLabel : Label = $MainMenu/VBoxContainer/Background/VBoxContainer/PanelContainer/ModeName
@onready var highScoreLabel : Label = $MainMenu/VBoxContainer/Background/VBoxContainer/HBoxContainer/HighScore
@onready var modeLeftButton : Button = $MainMenu/VBoxContainer/Background/VBoxContainer/HBoxContainer/ModeLeft
@onready var modeRightButton : Button = $MainMenu/VBoxContainer/Background/VBoxContainer/HBoxContainer/ModeRight
@onready var title : Label = $MainMenu/VBoxContainer/Background/VBoxContainer/Title

@onready var settingsMenu : Control = $Settings
@onready var soundButton : Button = $Settings/CenterContainer/Panel/MarginContainer/VBoxContainer/Sound/SoundButton
@onready var musicButton : Button = $Settings/CenterContainer/Panel/MarginContainer/VBoxContainer/Music/MusicButton

func update_game_mode() -> void:
	modeNameLabel.text = Global.gameModes.keys()[Global.current_game_mode].replace("_", " ")
	modeImage.texture = modesImages[Global.current_game_mode]
	highScoreLabel.text = "High score: " + str(Global.high_scores[Global.current_game_mode])
	
	modeLeftButton.disabled = Global.current_game_mode == Global.gameModes.values()[0]
	modeRightButton.disabled = Global.current_game_mode == Global.gameModes.values()[-1]
	
	#-------------------------
	# Remove later after other gamemodes are made!
	if Global.current_game_mode == Global.gameModes.POWER_MANIA:
		modeRightButton.disabled = true
	#-------------------------


# Called when the node enters the scene tree for the first time.
func _ready():
	update_game_mode()
	
	soundButton.set_pressed_no_signal(Global.sound_effects_on == 1)
	soundButton.icon = checkIcon if Global.sound_effects_on == 1 else uncheckIcon
	
	musicButton.set_pressed_no_signal(Global.music_on == 1)
	musicButton.icon = checkIcon if Global.music_on == 1 else uncheckIcon


func _process(delta):
	i += delta * 200
	title.position.y = 100 + sin(deg_to_rad(i))*20
	#await get_tree().physics_frame

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_mode_left_pressed() -> void:
	if Global.current_game_mode != Global.gameModes.values()[0]:
		Global.current_game_mode -= 1
		update_game_mode()
		Global.save_game_data()

func _on_mode_right_pressed() -> void:
	if Global.current_game_mode != Global.gameModes.values()[-1]:
		Global.current_game_mode += 1
		update_game_mode()
		Global.save_game_data()


#-------------------
# Settings buttons
#-------------------

func _on_settings_pressed() -> void:
	get_tree().create_tween().tween_property(settingsMenu, "position", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN_OUT)

func _on_settings_back_button_pressed() -> void:
	get_tree().create_tween().tween_property(settingsMenu, "position", Vector2(0, -1200), 0.5).set_ease(Tween.EASE_IN_OUT)

func _on_sound_button_toggled(toggled_on) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SoundEffects"), !toggled_on)
	
	Global.sound_effects_on = toggled_on
	Global.save_game_data()
	
	soundButton.icon = checkIcon if Global.sound_effects_on == 1 else uncheckIcon


func _on_music_button_toggled(toggled_on) -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), !toggled_on)
	
	Global.music_on = toggled_on
	Global.save_game_data()
	
	musicButton.icon = checkIcon if Global.music_on == 1 else uncheckIcon



