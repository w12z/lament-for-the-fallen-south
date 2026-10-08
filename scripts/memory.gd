extends Control

@onready var round_label: Label = $MarginContainer/Content/RoundLabel
@onready var memory_title: Label = $MarginContainer/Content/MemoryTitle
@onready var passage_label: Label = $MarginContainer/Content/Passage
@onready var attention_container: HBoxContainer = $MarginContainer/Content/AttentionContainer
@onready var selection_label: Label = $MarginContainer/Content/SelectionLabel
@onready var continue_button: Button = $MarginContainer/Content/ContinueButton


func _ready() -> void:
	round_label.text = "第 %d 轮 · 回忆" % GameState.round_number
	var memory: Dictionary = GameState.current_memory()
	if memory.has("cg"):
		$MemoryImage.texture = load(memory["cg"])
	else:
		$MemoryImage.visible = false
		$MissingImage.visible = true
	memory_title.text = memory["title"]
	passage_label.text = memory["text"]
	selection_label.text = GameState.memory_reason + "\n请选择你额外注意的意象"
	continue_button.disabled = true
	for attention in memory["attention"]:
		var button := Button.new()
		button.text = attention
		button.theme_type_variation = &"MaterialButton"
		button.add_theme_font_size_override("font_size", 18)
		button.toggle_mode = true
		button.pressed.connect(_select_attention.bind(attention, button))
		attention_container.add_child(button)
	continue_button.pressed.connect(_open_writing)
	$ViewButton.pressed.connect(_toggle_text)


func _toggle_text() -> void:
	$MarginContainer.visible = not $MarginContainer.visible
	$PaperVeil.visible = $MarginContainer.visible
	$ViewButton.text = "隐去文字 · 观景" if $MarginContainer.visible else "显示文字 · 落笔"


func _open_writing() -> void:
	get_tree().change_scene_to_file("res://scenes/writing.tscn")


func _select_attention(attention: String, button: Button) -> void:
	GameState.select_memory_attention(attention)
	selection_label.text = "已注意：%s" % attention
	continue_button.disabled = false
	for child in attention_container.get_children():
		child.set_pressed_no_signal(child == button)
