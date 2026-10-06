extends Control

@onready var round_label: Label = $MarginContainer/Content/RoundLabel
@onready var description: Label = $MarginContainer/Content/Description
@onready var finish_button: Button = $MarginContainer/Content/FinishButton


func _ready() -> void:
	round_label.text = "第 %d 轮 · 创作" % GameState.round_number
	description.text = "本轮回忆：%s\n你注意到了：%s\n\n这里将接入意象与词句拼贴。" % [GameState.selected_memory_title, GameState.selected_attention]
	finish_button.pressed.connect(_finish_round)


func _finish_round() -> void:
	GameState.finish_round()
	get_tree().change_scene_to_file("res://scenes/study.tscn")
