extends Control

@onready var round_label: Label = $MarginContainer/Content/RoundLabel
@onready var memory_title: Label = $MarginContainer/Content/MemoryTitle
@onready var passage_label: Label = $MarginContainer/Content/Passage
@onready var attention_container: VBoxContainer = $MarginContainer/Content/AttentionContainer
@onready var selection_label: Label = $MarginContainer/Content/SelectionLabel
@onready var continue_button: Button = $MarginContainer/Content/ContinueButton


func _ready() -> void:
	round_label.text = "第 %d 轮 · 回忆" % GameState.round_number
	var memory: Dictionary = GameState.current_memory()
	if memory.has("cg"):
		$MemoryImage.texture = load(memory["cg"])
	memory_title.text = memory["title"]
	passage_label.text = memory["text"]
	selection_label.text = GameState.memory_reason + "\n请选择你额外注意的意象"
	continue_button.disabled = true
	for attention in memory["attention"]:
		var button := Button.new()
		button.text = attention
		button.toggle_mode = true
		button.pressed.connect(_select_attention.bind(attention, button))
		attention_container.add_child(button)
	continue_button.pressed.connect(_open_writing)


func _open_writing() -> void:
	get_tree().change_scene_to_file("res://scenes/writing.tscn")


func _select_attention(attention: String, button: Button) -> void:
	GameState.select_memory_attention(attention)
	selection_label.text = "已注意：%s" % attention
	continue_button.disabled = false
	for child in attention_container.get_children():
		child.set_pressed_no_signal(child == button)
