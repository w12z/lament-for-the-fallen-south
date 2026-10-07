extends Control

var draft: Array[Dictionary] = []
var undo_stack: Array = []
var selected_index: int = -1
var material_list: VBoxContainer
var draft_list: VBoxContainer
var notes: Label
var undo_button: Button
var remove_button: Button
var up_button: Button
var down_button: Button
var blank_button: Button

@onready var round_label: Label = $MarginContainer/Content/RoundLabel
@onready var description: Label = $MarginContainer/Content/Description
@onready var finish_button: Button = $MarginContainer/Content/FinishButton


func _ready() -> void:
	draft = GameState.manuscript.duplicate(true)
	round_label.text = "第 %d / %d 轮 · 落笔" % [GameState.round_number, GameState.TOTAL_ROUNDS]
	description.text = "回忆：%s · 注意：%s\n点击材料追加；选中残句后换序或删除。允许重复与留白，最多 %d 行。" % [GameState.selected_memory_title, GameState.selected_attention, GameState.MAX_SLOTS]
	var content: VBoxContainer = $MarginContainer/Content
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 24)
	content.add_child(columns)
	content.move_child(columns, 2)
	material_list = _make_column(columns, "案头材料 · 点击落笔")
	draft_list = _make_column(columns, "本卷 · 前轮文字仍可删改")
	for material in GameState.materials:
		var button := Button.new()
		button.text = "%s\n%s" % [material["text"], material["note"]]
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_append_fragment.bind(material))
		material_list.add_child(button)
	var note_scroll := ScrollContainer.new()
	note_scroll.custom_minimum_size.y = 100
	note_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(note_scroll)
	content.move_child(note_scroll, 3)
	notes = Label.new()
	notes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notes.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notes.add_theme_font_size_override("font_size", 18)
	note_scroll.add_child(notes)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(actions)
	content.move_child(actions, 4)
	blank_button = _make_button(actions, "留白", _add_blank)
	up_button = _make_button(actions, "上移", _move.bind(-1))
	down_button = _make_button(actions, "下移", _move.bind(1))
	remove_button = _make_button(actions, "删去", _remove)
	undo_button = _make_button(actions, "撤回", _undo)
	finish_button.pressed.connect(_finish_round)
	_refresh()


func _make_column(parent: Control, title: String) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(column)
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", 22)
	column.add_child(label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	return list


func _make_button(parent: Control, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _append_fragment(fragment: Dictionary) -> void:
	if draft.size() >= GameState.MAX_SLOTS:
		return
	undo_stack.append(draft.duplicate(true))
	draft.append(fragment.duplicate(true))
	selected_index = draft.size() - 1
	_refresh()


func _add_blank() -> void:
	_append_fragment({"blank": true, "text": "〔留白〕", "round": GameState.round_number})


func _select(index: int) -> void:
	selected_index = index
	_refresh()


func _remove() -> void:
	if selected_index < 0:
		return
	undo_stack.append(draft.duplicate(true))
	draft.remove_at(selected_index)
	selected_index = mini(selected_index, draft.size() - 1)
	_refresh()


func _move(direction: int) -> void:
	var destination: int = selected_index + direction
	if selected_index < 0 or destination < 0 or destination >= draft.size():
		return
	undo_stack.append(draft.duplicate(true))
	var fragment: Dictionary = draft[selected_index]
	draft.remove_at(selected_index)
	draft.insert(destination, fragment)
	selected_index = destination
	_refresh()


func _undo() -> void:
	if undo_stack.is_empty():
		return
	draft.assign(undo_stack.pop_back())
	selected_index = -1
	_refresh()


func _refresh() -> void:
	for child in draft_list.get_children():
		draft_list.remove_child(child)
		child.queue_free()
	for fragment_index in range(draft.size()):
		var button := Button.new()
		button.text = "%02d  %s" % [fragment_index + 1, draft[fragment_index]["text"]]
		button.toggle_mode = true
		button.button_pressed = fragment_index == selected_index
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_select.bind(fragment_index))
		draft_list.add_child(button)
	notes.text = "纸边批注 · %d / %d 行\n%s" % [draft.size(), GameState.MAX_SLOTS, GameState.relationship_notes(draft)]
	finish_button.disabled = draft.is_empty()
	undo_button.disabled = undo_stack.is_empty()
	remove_button.disabled = selected_index < 0
	up_button.disabled = selected_index <= 0
	down_button.disabled = selected_index < 0 or selected_index >= draft.size() - 1
	blank_button.disabled = draft.size() >= GameState.MAX_SLOTS
	for child in material_list.get_children():
		child.disabled = draft.size() >= GameState.MAX_SLOTS


func _finish_round() -> void:
	GameState.finish_round(draft)
	get_tree().change_scene_to_file("res://scenes/study.tscn")
