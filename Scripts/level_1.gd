extends Node2D

const SPAWN_COOLDOWN: float = 3.0
var spawnCoodrinates: Array[int] = [55, 375, 695]
var spawnY: int = -100
var zIndex: int = -100
var time: float = 0.0
@onready var console: LineEdit = $ConsoleLine
@onready var spawnCooldown: Timer = $SpawnCooldown
@onready var explosionSkill: TextureButton = $GUI/ExplosionSkill
@onready var healthLabel: Label = $GUI/HealthLabel
@onready var pointsLabel: Label = $GUI/PointsLabel
@onready var explosionSfx: AudioStreamPlayer2D = $SFX/Explosion

var enemyScene = preload("res://Scenes/enemy.tscn")
var blastScene = preload("res://Scenes/blast_area.tscn")
var enemyStats = [
	preload("res://Resources/Enemies/enemy_squirrel.tres"),
	preload("res://Resources/Enemies/enemy_mouse.tres"),
	preload("res://Resources/Enemies/enemy_rat.tres"),
]
var explosionSkillStats = preload("res://Resources/Skills/explosion_skill.tres")


func _ready() -> void:
	randomize()


func _process(delta: float) -> void:
	time += 0.016
	var s: float = 1.5
	spawnCooldown.wait_time = s*cos(0.2*time + PI) + 2.2

	healthLabel.text = str(Global.health)
	pointsLabel.text = str("EXP: ", Global.points)
	if Global.health <= 0:
		console.text = "You lost! Press F5 to restart."
		console.editable = false
		spawnCooldown.stop()
		set_process(false)
		return


func get_word_dict_from_node(node: Node) -> Dictionary:
	var label = node.get_node('Word')
	if label:
		return {label.text: node}
	else:
		return {}


func pick_random_enemy() -> EnemyStats:
	var squirrelSpawnChance: int = 50
	var mouseSpawnChance: int = 15
	# var ratSpawnChance: int = 20
	var chance = randi_range(0, 100)
	if chance < 100 - squirrelSpawnChance:
		return enemyStats[0]  # Squirrel
	elif chance < 100 - mouseSpawnChance:
		return enemyStats[1]  # Mouse
	else:
		return enemyStats[2]  # Rat


func _on_spawn_cooldown_timeout() -> void:
	var enemy = enemyScene.instantiate()
	enemy.stats = pick_random_enemy()

	var tracks = get_node('Tracks').get_children()
	var track = tracks.pick_random()

	# print(track.name + " spawned enemy: " + enemy.stats.name)
	var trackNumber = int(track.name.substr(5, 1))
	enemy.z_index = trackNumber * 20

	track.add_child(enemy)


func create_blast_area(spawnPosition: Vector2) -> void:
	var blast = blastScene.instantiate()
	blast.stats = explosionSkillStats
	blast.global_position = spawnPosition
	add_child(blast)

# A bunch of functions for matching string patterns
func isPattern(text:String, pattern: String) -> String:
	var regex = RegEx.new()
	regex.compile(pattern)
	var result = regex.search(text)
	if result:
		if result.get_string().length() == text.length():
			return result.get_string()
		else:
			return ""
	else:
		return ""
	
func isBracketOrSignPattern(text: String) -> String:
	var pattern = r"\[(\w+)\](\?|\!)?"
	return isPattern(text, pattern)
	
func isWordOrSignPattern(text: String) -> String:
	var pattern = r"(\w+)(\?|\!)?"
	return isPattern(text, pattern)
	
func isLastCharSign(text: String) -> String:
	var c = text[text.length()-1]
	if c == "!" or c == "?": # add more signs here if necessary
		return c
	else:
		return ""
	
func getBracketCmd(text:String) -> String:
	var regex = RegEx.new()
	var pattern =  r"\[(\w+)\]"
	regex.compile(pattern)
	var matches = regex.search_all(text)
	if matches.size() > 0:
		return matches[0].get_string(1)
	else:
		return ""

func isSentencePattern(text: String) -> String:
	var pattern = r"^\w+( \w+)*"
	return isPattern(text, pattern)

func _on_console_line_text_submitted(new_text: String) -> void:
	var enemyNodes: Array[Node] = get_tree().get_nodes_in_group('EnemyPathFollow')
	enemyNodes.sort_custom(func (a, b): return a.progress_ratio > b.progress_ratio)
	
	# Text processing logic. In the end the command is stored in cmd, and sign in sign.
	# Sentence is stored if found in sentence_str
	var bracketsign_str = isBracketOrSignPattern(new_text)
	var wordsign_str = isWordOrSignPattern(new_text)
	var sentence_str = isSentencePattern(new_text)
	var cmd = ""
	var sign = ""
	
	if bracketsign_str != "":
		cmd = getBracketCmd(bracketsign_str)
		sign = isLastCharSign(bracketsign_str)
		
	if wordsign_str != "":
		sign = isLastCharSign(wordsign_str)
		if sign == "":
			cmd = wordsign_str
		else:
			cmd = wordsign_str.substr(0, wordsign_str.length()-1)
		
	print("cmd: " + cmd + ", sign: " + sign)		

	if enemyNodes.size() > 0:
		var wordsDict = enemyNodes.map(get_word_dict_from_node)
		for dict in wordsDict:
			if dict.has(cmd):
				if not explosionSkill.button_pressed and sign == "!":
					create_blast_area(dict[cmd].global_position)
					explosionSkill.button_pressed = true
					explosionSfx.play()
				dict[cmd].death()
				Global.points += cmd.length()
				break

	console.clear()
