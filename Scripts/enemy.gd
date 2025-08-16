extends PathFollow2D

@export var stats: EnemyStats

var speed: float
var runaway_speed: float = 0.5
var isRunningAway: bool = false
var spritePosition: Vector2

@onready var sprite: AnimatedSprite2D = $HitboxArea/Sprite
@onready var confusionTimer: Timer = $ConfusionDuration
@onready var word: Label = $Word
@onready var hitboxShape: CollisionShape2D = $HitboxArea/HitboxShape


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
	hitboxShape.disabled = true
	set_process(false)
	word.queue_free()
	sprite.play("dead")
	var deathAnimtionTween = create_tween()
	deathAnimtionTween\
		.tween_property(sprite, "position", Vector2(0, -50), 0.2)\
		.set_trans(Tween.TRANS_SINE)
	deathAnimtionTween\
		.tween_property(sprite, "position", Vector2(0, 50), 0.2)\
		.set_trans(Tween.TRANS_SINE)
	deathAnimtionTween\
		.tween_property(sprite, "modulate", Color(1,1,1,0), 1)\
		.set_trans(Tween.TRANS_EXPO)
	await deathAnimtionTween.finished
	queue_free()


func sleep() -> void:
	confusionTimer.wait_time = Global.sleepingDuration
	confusionTimer.start()
	if sprite.animation != "sleep":
		sprite.play("sleep")
	set_process(false)


func _on_confusion_duration_timeout() -> void:
	sprite.play("walk")
	set_process(true)
