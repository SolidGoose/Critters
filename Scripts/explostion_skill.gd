class_name ExplosionSkill
extends SkillStats


func effect(area: Node) -> void:
	return area.queue_free()
