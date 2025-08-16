extends PathFollow2D

@export var stats: EnemyStats

var speed: float
var runaway_speed: float = 0.5
var isRunningAway: bool = false
var spritePosition: Vector2

@onready var sprite: AnimatedSprite2D = $HitboxArea/Sprite
# @onready var word: Label = $Word


func _ready() -> void:
	randomize()

	speed = stats.speed + randf_range(-0.025, 0.025)
	sprite.sprite_frames = stats.spriteFrames
	sprite.play("walk")
	sprite.scale = stats.scale
	sprite.offset = stats.spriteOffset


func run_away() -> void:
	isRunningAway = true
	speed = 0.8 + randf_range(-0.1, 0.1)
	sprite.flip_h = true
	sprite.rotation = 1.35
	sprite.speed_scale = 3


func _process(delta: float) -> void:
	if isRunningAway:
		progress_ratio -= speed * delta
	else:
		progress_ratio += speed * delta
	if progress_ratio == 1.0:
		run_away()
	
	if progress_ratio <= 0.0 and isRunningAway:
		Global.health -= 1
		queue_free()


func death() -> void:
	print("Enemy died")
	queue_free()
