extends Node
class_name Game

@onready var _entity_root: Node2D = %EntityRoot
@onready var _stage_root: Node2D = %StageRoot
@onready var _title_screen: Control = %TitleScreen

## for loading the player
var _player_uid: String = "uid://sn3d6mmhnfno"

var _stage_uid: String = "uid://o8nun1q5hls4"

var _player: Player
var _current_stage: Stage

func _ready() -> void:
	if !Debug.bypass_title:
		SignalBus.play_clicked.connect(_start_game)
	else:
		_start_game()

func _init_player() -> void:
	var player_scene = ResourceLoader.load(_player_uid, "PackedScene") as PackedScene
	if player_scene == null:
		push_error("could not load player")
		return

	var player_instance = player_scene.instantiate()
	if player_instance == null:
		push_error("could not instantiate player")
		return

	var typed_player_instance = player_instance as Player
	if typed_player_instance == null:
		push_error("player instance is not of the Player type")
		return

	_player = player_instance
	_entity_root.add_child(_player)


func _start_game() -> void:
	_title_screen.hide()
	SignalBus.quota_finished.connect(_on_quota_finished)
	SignalBus.enemy_added.connect(_on_enemy_added)
	SignalBus.dummb_enemy_added.connect(_on_dumb_enemy_added)
	_init_player()
	_load_stage(_stage_uid)

func _load_stage(stage_uid: String) -> void:
	if _current_stage != null:
		_current_stage.queue_free()
		_current_stage = null
		await get_tree().process_frame

	var stage_scene = ResourceLoader.load(stage_uid, "PackedScene") as PackedScene
	if stage_scene == null:
		push_error("could not load stage")
		return

	var stage_instance = stage_scene.instantiate()
	if stage_instance == null:
		push_error("could not instantiate stage")
		return

	_current_stage = stage_instance as Stage
	if _current_stage == null:
		push_error("stage instance is not of the Stage type")
		return

	_stage_root.add_child(_current_stage)
	_player.global_position = _current_stage.get_player_spawn()
	SignalBus.stage_initiated.emit(_current_stage)

func _on_quota_finished(won: bool) -> void:
	if won:
		pass

func _on_enemy_added(enemy: Enemy) -> void:
	_entity_root.add_child(enemy)


func _on_dumb_enemy_added(enemy: DumbEnemy) -> void:
	_entity_root.add_child(enemy)
