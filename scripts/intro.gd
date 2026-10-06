extends Control

@export var opening_texture: Texture2D = preload("res://assets/images/cg/dream_opening.png")
@export var siege_texture: Texture2D = preload("res://assets/images/cg/memory_siege.png")
@export var dongting_texture: Texture2D = preload("res://assets/images/cg/memory_dongting.png")
@export var zhangmanzhi_texture: Texture2D = preload("res://assets/images/cg/memory_zhangmanzhi.png")
@export var water_mountains_texture: Texture2D = preload("res://assets/images/cg/memory_water_mountains.png")
@export var black_water_ice_texture: Texture2D = preload("res://assets/images/cg/memory_black_water_ice.png")
@export var luji_wangcan_texture: Texture2D = preload("res://assets/images/cg/memory_luji_wangcan.png")
@export var study_texture: Texture2D = preload("res://assets/images/cg/study_intro.png")

@onready var cg_image: TextureRect = $CGImage
@onready var echo_image: TextureRect = $EchoImage
@onready var black_overlay: ColorRect = $BlackOverlay
@onready var wake_overlay: ColorRect = $WakeOverlay
@onready var continue_button: Button = $BottomMargin/ContinueButton

var active_tween: Tween
var leaving: bool = false


func _ready() -> void:
	continue_button.pressed.connect(_enter_study)
	_play_sequence()


func _play_sequence() -> void:
	cg_image.texture = opening_texture
	await get_tree().create_timer(1.5).timeout
	await _fade_black(0.0, 3.5)
	await get_tree().create_timer(3.0).timeout
	await _fade_black(1.0, 1.2)
	await _flash(siege_texture, 2.8, 0.8)
	await _flash(dongting_texture, 3.2, 1.0)
	await _flash(zhangmanzhi_texture, 2.2, 0.8)
	await _flash(water_mountains_texture, 2.4, 0.8)
	await _flash(black_water_ice_texture, 2.6, 0.9)
	await _flash(luji_wangcan_texture, 2.8, 1.0)
	await _flash(opening_texture, 1.5, 0.7)
	await _flash(siege_texture, 1.0, 0.55)
	await _flash(dongting_texture, 1.3, 0.65)
	await _flash(zhangmanzhi_texture, 0.9, 0.5)
	await _flash(water_mountains_texture, 1.0, 0.5)
	await _flash(black_water_ice_texture, 1.1, 0.55)
	await _flash(luji_wangcan_texture, 1.2, 0.6)
	await _fade_black(0.0, 0.4)
	echo_image.texture = siege_texture
	echo_image.modulate.a = 0.0
	active_tween = create_tween()
	active_tween.tween_property(echo_image, "modulate:a", 0.35, 1.0)
	active_tween.tween_interval(1.2)
	active_tween.tween_property(echo_image, "modulate:a", 0.0, 1.2)
	await active_tween.finished
	await _fade_black(1.0, 1.2)
	cg_image.texture = study_texture
	await _wake_up()
	_enter_study()


func _flash(texture: Texture2D, hold_duration: float, fade_duration: float) -> void:
	cg_image.texture = texture
	await _fade_black(0.0, fade_duration)
	await get_tree().create_timer(hold_duration).timeout
	await _fade_black(1.0, fade_duration)


func _fade_black(alpha: float, duration: float) -> void:
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(black_overlay, "modulate:a", alpha, duration)
	await active_tween.finished


func _wake_up() -> void:
	black_overlay.modulate.a = 1.0
	wake_overlay.modulate.a = 0.0
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	active_tween.set_parallel(true)
	active_tween.tween_property(black_overlay, "modulate:a", 0.0, 2.5)
	active_tween.tween_property(wake_overlay, "modulate:a", 1.0, 2.5)
	await active_tween.finished
	await get_tree().create_timer(1.2).timeout
	cg_image.texture = study_texture
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(wake_overlay, "modulate:a", 0.0, 3.0)
	await active_tween.finished


func _enter_study() -> void:
	if leaving:
		return
	leaving = true
	if active_tween:
		active_tween.kill()
	get_tree().change_scene_to_file("res://scenes/study.tscn")
