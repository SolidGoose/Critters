extends Area2D


func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group("Enemy") and area.has_method("death"):
		print("GAME OVER")
		area.death()
		
