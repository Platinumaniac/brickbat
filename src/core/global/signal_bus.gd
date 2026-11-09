extends Node
## signals across nodes here
var score: int = 0
var level: int = 1

func _ready() -> void:
	score_changed.connect(func(point: int) -> void: score += point)

func tower_count() -> int:
	return 1 + mini(floori((level - 1) / 3.0), 2)

func scale_up(step: float, cap: float) -> float:
	return minf(1.0 + step * (level - 1), cap)

signal play_clicked

## sent when the stage is added to the StageRoot
signal stage_initiated(stage: Stage)

signal enemy_added(enemy: Enemy)
signal dummb_enemy_added(enemy: DumbEnemy)

## sent when a building has been built
signal building_finished(building: Building)

signal building_destroyed(building: Building)

signal building_path_requested(start: Vector2)

signal building_path_calculated(start: Vector2, path: NavigationSystem.BuildingPath)

signal quota_finished(won: bool)

signal score_changed(point: int)
