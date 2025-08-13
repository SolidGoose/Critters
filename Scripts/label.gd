extends Label


func _process(delta: float) -> void:
	var enemyNodes: Array[Node] = get_tree().get_nodes_in_group('EnemyPathFollow')
	text = str(enemyNodes.size())
