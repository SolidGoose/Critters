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
@onready var levelLabel: Label = $GUI/IntensityLabel
@onready var explosionSfx: AudioStreamPlayer2D = $SFX/Explosion
@onready var sleepSfx: AudioStreamPlayer2D = $SFX/Sleep
@onready var consoleExplosionSfx: AudioStreamPlayer2D = $SFX/ConsoleExplosion
@onready var consoleSleepSfx: AudioStreamPlayer2D = $SFX/ConsoleSleep
@onready var consoleChainSfx: AudioStreamPlayer2D = $SFX/ConsoleChain
@onready var correctWordSfx: AudioStreamPlayer2D = $SFX/CorrectWord
@onready var wrongWordSfx: AudioStreamPlayer2D = $SFX/WrongWord
@onready var squeakSfx: AudioStreamPlayer2D = $SFX/Squeak
@onready var track1: AudioStreamPlayer2D = $SFX/Track1
@onready var track2: AudioStreamPlayer2D = $SFX/Track2
@onready var track3: AudioStreamPlayer2D = $SFX/Track3


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
var s: float = 2
var k: float = 5


func _ready() -> void:
	randomize()

	explosionSkillButton = explosionSkillPanel.get_node('SkillButton')
	sleepingSkillButton = sleepingSkillPanel.get_node('SkillButton')
	chainSkillButton = chainSkillPanel.get_node('SkillButton')

	track1.play()


func _process(delta: float) -> void:
	time += 0.016
	if time > 50:
		k = 4.5
		levelLabel.text = "Level: 1"
	if time > 100:
		k = 4.0
		levelLabel.text = "Level: 2"
	if time > 150:
		k = 3.5
		levelLabel.text = "Level: 3"
	if time > 200:
		k = 3.0
		levelLabel.text = "Level: 4"
	if time > 250:
		k = 2.5
		levelLabel.text = "Level: 5"
	if time > 300:
		k = 2.0
		levelLabel.text = "Level: 6"
	if time > 350:
		k = 1.5
		levelLabel.text = "Level: 7"
	if time > 400:
		k = 1.0
		levelLabel.text = "Level: 8"
	if time > 450:
		s = 1.0
		levelLabel.text = "Level: 9"
	if time > 500:
		s = 0.5
		levelLabel.text = "Level: 10"

	spawnCooldown.wait_time = s*cos(0.2*time + PI) + k + s

	healthLabel.text = str(Global.health)
	if Global.health <= 0:
		console.text = "Game Over!"
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
				sleepSfx.play()
			squeakSfx.play()
		else:
			wrongWordSfx.play()

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
		correctWordSfx.pitch_scale = cmds.size()

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
				correctWordSfx.play()
			if mark == '!':
				if (not explosionSkillButton.button_pressed):
					console_text_color = Color.CORAL
					consoleExplosionSfx.play()
				else:
					console_text_color = Color.LIGHT_GREEN
			if mark == '?':
				if (not sleepingSkillButton.button_pressed):
					console_text_color = Color.VIOLET
					consoleSleepSfx.play()
				else:
					console_text_color = Color.LIGHT_GREEN
			if cmds.size() > 1 and (not chainSkillButton.button_pressed):
				console.add_theme_color_override('font_outline_color', Color.SADDLE_BROWN)
				console.add_theme_constant_override("outline_size", 40)
				if mark == '':
					consoleChainSfx.play()
					correctWordSfx.play()
	
	console.add_theme_color_override("font_color", console_text_color)


func _on_track_1_finished() -> void:
	track3.play()


func _on_track_2_finished() -> void:
	track1.play()


func _on_track_3_finished() -> void:
	track2.play()
