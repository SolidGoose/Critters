extends Node2D

const SPAWN_COOLDOWN: float = 3.0
var spawnCoodrinates: Array[int] = [55, 375, 695]
var spawnY: int = -100
var zIndex: int = -100
var time: float = 0.0
var explosionSkillButton: TextureButton
var sleepingSkillButton: TextureButton
var chainSkillButton: TextureButton

# Onready nodes
@onready var console: LineEdit = $Console/ConsoleLine
@onready var spawnCooldown: Timer = $SpawnCooldown
@onready var explosionSkillPanel: Panel = $GUI/ExplosionSkill
@onready var sleepingSkillPanel: Panel = $GUI/SleepingSkill
@onready var chainSkillPanel: Panel = $GUI/ChainSkill
@onready var healthLabel: Label = $GUI/HealthLabel
@onready var pointsLabel: Label = $GUI/PointsLabel
@onready var explosionSfx: AudioStreamPlayer2D = $SFX/Explosion

# Preloads
var enemyScene = preload("res://Scenes/enemy.tscn")
var blastScene = preload("res://Scenes/blast_area.tscn")
var enemyStats = [
	preload("res://Resources/Enemies/enemy_squirrel.tres"),
	preload("res://Resources/Enemies/enemy_mouse.tres"),
	preload("res://Resources/Enemies/enemy_rat.tres"),
]
var explosionSkillStats = preload("res://Resources/Skills/explosion_skill.tres")
var sleepingSkillStats = preload("res://Resources/Skills/sleeping_skill.tres")


func _ready() -> void:
	randomize()

	explosionSkillButton = explosionSkillPanel.get_node('SkillButton')
	sleepingSkillButton = sleepingSkillPanel.get_node('SkillButton')
	chainSkillButton = chainSkillPanel.get_node('SkillButton')


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

	var trackNumber = int(track.name.substr(5, 1))
	enemy.z_index = trackNumber * 20

	track.add_child(enemy)


func create_blast_area(spawnPosition: Vector2, mark: String) -> void:
	var blast = blastScene.instantiate()
	match mark:
		"!":
			blast.stats = explosionSkillStats
		"?":
			blast.stats = sleepingSkillStats
	blast.global_position = spawnPosition
	add_child(blast)

func _on_console_line_text_submitted(new_text: String) -> void:
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

	var parsedCommand: Dictionary = Utils.parse_console_command(new_text)
	var cmds: Array[String] = parsedCommand['cmds']
	if cmds.size() > 1 and chainSkillButton.button_pressed:
		cmds = []
	var mark: String = parsedCommand['mark']
	var enemiesKilled: int = 0

	if enemyNodes.size() > 0 and cmds.size() > 0:
		for cmd in cmds:
			for i in enemyNodes.size():
				var enemy = enemyNodes[i]
				var word: Label = enemy.get_node_or_null('Word')
				if word != null and word.text == cmd:
					if not explosionSkillButton.button_pressed and mark == "!":
						create_blast_area(enemy.global_position, mark)
					elif not sleepingSkillButton.button_pressed and mark == "?":
						create_blast_area(enemy.global_position, mark)
						enemy.death()
					else:
						enemy.death()
					enemiesKilled += 1
					Global.points += cmd.length()
					enemyNodes.remove_at(i)
					break
		if enemiesKilled > 0:
			if cmds.size() > 1:
				chainSkillButton.button_pressed = true
			if not explosionSkillButton.button_pressed and mark == "!":
				explosionSkillButton.button_pressed = true
				explosionSfx.play()
			if not sleepingSkillButton.button_pressed and mark == "?":
				sleepingSkillButton.button_pressed = true
				explosionSfx.play()

	console.clear()


func _on_console_line_text_changed(new_text: String) -> void:
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
	
	var parsedCommand: Dictionary = Utils.parse_console_command(new_text)	
	var cmds = parsedCommand['cmds']
	var mark = parsedCommand['mark']
	
	var console_text_color: Color = Color.WHITE
	console.remove_theme_color_override("font_outline_color")
	console.add_theme_constant_override("outline_size", 0)
	
	if cmds == []:
		console_text_color = Color.WHITE	
	else:		
		# Build list of enemy words
		var enemy_words: Array[String] = []
		for enemy in enemyNodes:
			var word: Label = enemy.get_node_or_null('Word')
			if word != null:
				enemy_words.append(word.text)

		var word_error = false
		for cmd in cmds:
			if not cmd in enemy_words:
				word_error = true

		if not word_error:
			if mark == '':
				console_text_color = Color.LIGHT_GREEN
			if mark == '!' and (not explosionSkillButton.button_pressed):
				console_text_color = Color.RED
			if mark == '?' and (not sleepingSkillButton.button_pressed):
				console_text_color = Color.VIOLET
			if cmds.size() > 1 and (not chainSkillButton.button_pressed):
				console.add_theme_color_override('font_outline_color', Color.GOLDENROD)
				console.add_theme_constant_override("outline_size", 20)
	
	console.add_theme_color_override("font_color", console_text_color)
	
