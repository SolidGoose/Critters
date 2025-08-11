extends PathFollow2D


var speed: float = 0.1


func _process(delta: float) -> void:
	progress_ratio += speed * delta
	if progress_ratio == 1.0:
		queue_free()
		print("Game Over")
