extends Control

@onready var round_label: Label = $MarginContainer/Content/RoundLabel
@onready var start_button: Button = $MarginContainer/Content/StartButton
@onready var restart_button: Button = $MarginContainer/Content/RestartButton


func _ready() -> void:
	start_button.pressed.connect(_open_memory)
	restart_button.pressed.connect(_restart)
	_update_round()


func _open_memory() -> void:
	get_tree().change_scene_to_file("res://scenes/memory.tscn")


func _restart() -> void:
	GameState.restart()
	get_tree().change_scene_to_file("res://scenes/start.tscn")


func _update_round() -> void:
	round_label.text = "第 %d 轮创作" % GameState.round_number
