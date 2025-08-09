extends Area2D

var speed: int

func _ready() -> void:
	rotation_degrees = 29.5
	speed = 500

func _process(delta: float) -> void:
	position += transform.x * speed * delta

func death() -> void:
	queue_free()
