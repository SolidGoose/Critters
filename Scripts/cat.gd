extends Node2D

@onready var leftEye: Sprite2D = $Sclera/LeftIris
@onready var rightEye: Sprite2D = $Sclera/RightIris


func _process(delta: float) -> void:
	var enemyNodes: Array[Node] = get_tree().get_nodes_in_group('EnemyPathFollow')

	enemyNodes.sort_custom(func (a, b):
		var progressA
		var progressB
		var offsetA = 1 - a.progress_ratio
		var offsetB = 1 - b.progress_ratio
		if a.isRunningAway:
			progressA = a.progress_ratio + offsetA
		else:
			progressA = a.progress_ratio
		if b.isRunningAway:
			progressB = b.progress_ratio + offsetB
		else:
			progressB = b.progress_ratio

		return float(a.isRunningAway) + progressA >\
			   float(b.isRunningAway) + progressB)

	var enemy = enemyNodes[0] if enemyNodes.size() > 0 else null

	if enemy:
		var direction: Vector2 = (enemy.position - position).normalized()
		print("Direction: ", direction)
		print("Direction.angle(): ", direction.angle())

		leftEye.rotation = direction.angle()
		rightEye.rotation = direction.angle()
