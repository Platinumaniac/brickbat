extends Node
## signals across nodes here

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
