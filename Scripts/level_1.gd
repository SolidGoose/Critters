extends Node2D

const SPAWN_COOLDOWN: float = 3.0
var spawnCoodrinates: Array[int] = [55, 375, 695]
var spawnY: int = -100
var zIndex: int = -100
var time: float = 0.0
var explosionSkillButton: TextureButton
var sleepingSkillButton: TextureButton

# Onready nodes
@onready var console: LineEdit = $Console/ConsoleLine
@onready var spawnCooldown: Timer = $SpawnCooldown
@onready var explosionSkillPanel: Panel = $GUI/ExplosionSkill
@onready var sleepingSkillPanel: Panel = $GUI/SleepingSkill
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
	enemyNodes.sort_custom(func (a, b): return a.progress_ratio > b.progress_ratio)

	var parsedCommand: Dictionary = Utils.parse_console_command(new_text)
	var cmd: String = parsedCommand['cmd']
	var mark: String = parsedCommand['mark']

	if enemyNodes.size() > 0:
		for enemy in enemyNodes:
			var word: Label = enemy.get_node_or_null('Word')
			if word.text == cmd:
				if not explosionSkillButton.button_pressed and mark == "!":
					create_blast_area(enemy.global_position, mark)
					explosionSkillButton.button_pressed = true
					explosionSfx.play()
				elif not sleepingSkillButton.button_pressed and mark == "?":
					create_blast_area(enemy.global_position, mark)
					sleepingSkillButton.button_pressed = true
					explosionSfx.play()
					enemy.death()
				else:
					enemy.death()
				Global.points += cmd.length()
				break

	console.clear()
