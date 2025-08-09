extends Node2D


var spawnCoodrinates: Array[Vector2] = [
	Vector2(120, 470),
	Vector2(290, 298),
	Vector2(460, 126),
]

func _draw() -> void:
	draw_line(Vector2(0, 540), Vector2(960, 1080), Color.BLACK, 10)
	draw_line(Vector2(0, 270), Vector2(1440, 1080), Color.BLACK, 10)
	draw_line(Vector2(0, 0), Vector2(1920, 1080), Color.BLACK, 10)
	draw_line(Vector2(480, 0), Vector2(1920, 810), Color.BLACK, 10)

func _ready() -> void:
	var enemyScene = preload("res://Scenes/enemy.tscn")
	var instance = enemyScene.instantiate()
	instance.global_position.x = 135
	instance.global_position.y = 210
	add_child(instance)

func _on_spawn_cooldown_timeout() -> void:
	var enemyScene = preload("res://Scenes/enemy.tscn")
	var instance = enemyScene.instantiate()
	var coordinates = spawnCoodrinates.pick_random()
	print(coordinates)
	instance.global_position = coordinates
	add_child(instance)
