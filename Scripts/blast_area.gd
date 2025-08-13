extends Area2D


var time: float = 0.0
var isActive: bool = false


func _process(delta: float) -> void:
	var enemyAreas: Array[Area2D] = get_overlapping_areas()
	for area in enemyAreas:
		if area.is_in_group('EnemyArea'):
			area.get_parent().queue_free()
	if time < 3:
		time += 1
	else:
		queue_free()

			