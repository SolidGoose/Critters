extends Node2D


const SPAWN_COOLDOWN: float = 3.0
var spawnCoodrinates: Array[int] = [55, 375, 695]
var spawnY: int = -100
var zIndex: int = -100
var time: float = 0.0
@onready var console: LineEdit = $ConsoleLine
@onready var spawnCooldown: Timer = $SpawnCooldown
@onready var explosionSkill: TextureButton = $ExplosionSkill

var enemyScene = preload("res://Scenes/enemy.tscn")
var blastScene = preload("res://Scenes/blast_area.tscn")


func _ready() -> void:
	randomize()


func _process(delta: float) -> void:
	time += 0.016
	var s = 1.5
	spawnCooldown.wait_time = s*cos(0.2*time + PI) + 2.2


func get_word_dict_from_node(node: Node) -> Dictionary:
	var label = node.get_node('Word')
	if label:
		return {label.text: node}
	else:
		return {}


func _on_spawn_cooldown_timeout() -> void:
	var enemy = enemyScene.instantiate()
	enemy.z_index = zIndex
	zIndex -= 1

	var tracks = get_node('Tracks').get_children()
	var track = tracks.pick_random()
	track.add_child(enemy)


func create_blast_area(spawnPosition: Vector2) -> void:
	var blast = blastScene.instantiate()
	blast.global_position = spawnPosition
	add_child(blast)


func _on_console_line_text_submitted(new_text: String) -> void:
	var enemyNodes: Array[Node] = get_tree().get_nodes_in_group('EnemyPathFollow')
	enemyNodes.sort_custom(func (a, b): return a.progress_ratio > b.progress_ratio)

	if enemyNodes.size() > 0:
		var wordsDict = enemyNodes.map(get_word_dict_from_node)
		for dict in wordsDict:
			if dict.has(new_text):
				if not explosionSkill.button_pressed:
					create_blast_area(dict[new_text].global_position)
				explosionSkill.button_pressed = true
				dict[new_text].death()
				break

	console.clear()
