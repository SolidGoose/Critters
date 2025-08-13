extends Area2D


var time: float = 0.0
var isActive: bool = false


func _process(delta: float) -> void:
	print('blast area ready')
	var enemyAreas: Array[Area2D] = get_overlapping_areas()
	print('enemyAreas: ', enemyAreas)
	for area in enemyAreas:
		print('area: ', area)
		if area.is_in_group('EnemyArea'):
			print('area is in group EnemyArea')
			area.get_parent().queue_free()
	if time < 3:
		time += 1
	else:
		print('blast area time expired')
		queue_free()

			