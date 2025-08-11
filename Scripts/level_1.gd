extends Node2D


var spawnCoodrinates: Array[int] = [55, 375, 695]
var spawnY: int = -100
@onready var console: LineEdit = get_node('ConsoleLine')
var zIndex: int = -100

func get_word_dict_from_node(node: Node) -> Dictionary:
	var label = node.get_node('Word')
	if label:
		return {label.text: node}
	else:
		return {}


func _on_spawn_cooldown_timeout() -> void:
	var enemyScene = preload("res://Scenes/enemy.tscn")
	var enemy = enemyScene.instantiate()
	enemy.z_index = zIndex
	zIndex -= 1

	var tracks = get_node('Tracks').get_children()
	var track = tracks.pick_random()
	track.add_child(enemy)


func _on_console_line_text_submitted(new_text: String) -> void:
	var enemyNodes: Array[Node] = get_tree().get_nodes_in_group('EnemyPathFollow')
	enemyNodes.sort_custom(func (a, b): return a.progress_ratio > b.progress_ratio)
	print(enemyNodes)
	if enemyNodes.size() > 0:
		var wordsDict = enemyNodes.map(get_word_dict_from_node)
		for dict in wordsDict:
			if dict.has(new_text):
				dict[new_text].death()
				break

	console.clear()
