extends PathFollow2D

@export var stats: EnemyStats

var speed: float

@onready var sprite: Sprite2D = $HitboxArea/Sprite


func _ready() -> void:
	randomize()

	speed = stats.speed + randf_range(-0.025, 0.025)
	sprite.texture = stats.texture

func _process(delta: float) -> void:
	progress_ratio += speed * delta
	if progress_ratio == 1.0:
		queue_free()


func death() -> void:
	queue_free()
