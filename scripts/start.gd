extends Control

@onready var begin_button: Button = $MarginContainer/Content/BeginButton


func _ready() -> void:
	begin_button.pressed.connect(_begin)


func _begin() -> void:
	GameState.restart()
	get_tree().change_scene_to_file("res://scenes/intro.tscn")
