extends Area2D

@export var stats: ExplosionSkill

var time: float = 0.0
var isActive: bool = false
var blastRadius: int = 120
var duration: int

@onready var blastShape: CollisionShape2D = $BlastShape


func _ready() -> void:
	blastShape.shape.radius = stats.radius
	duration = stats.duration


func _process(delta: float) -> void:
	var enemyAreas: Array[Area2D] = get_overlapping_areas()
	for area in enemyAreas:
		if area.is_in_group('EnemyArea'):
			var parent = area.get_parent()
			stats.effect(parent)
	if time < duration:
		time += 1
	else:
		queue_free()
