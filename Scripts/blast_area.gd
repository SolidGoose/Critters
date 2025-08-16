extends Area2D

@export var stats: SkillStats

var time: float = 0.0
var isActive: bool = false
var blastRadius: int = 120
var duration: float

@onready var blastShape: CollisionShape2D = $BlastShape


func _ready() -> void:
	blastShape.shape.radius = stats.radius
	duration = stats.duration


func activate_effect(node: Node) -> void:
	match stats.name:
		"explosion":
			if node.has_method("death"):
				node.death()
		"sleeping":
			if node.has_method("sleep"):
				node.sleep()
		_:
			print("Unknown skill effect")


func _process(delta: float) -> void:
	var enemyAreas: Array[Area2D] = get_overlapping_areas()
	for area in enemyAreas:
		var hitboxShape = area.get_node_or_null('HitboxShape')
		if area.is_in_group('EnemyArea') and hitboxShape and not hitboxShape.disabled:
			var parent = area.get_parent()
			activate_effect(parent)
	if time < duration:
		time += 1
	else:
		queue_free()
