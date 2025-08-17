extends Panel

@onready var button: TextureButton = $SkillButton
@onready var cooldown: TextureProgressBar = $SkillButton/Cooldown
@onready var key: Label = $KeyPanel/Key
# @onready var timePanel: Panel = $TimePanel
# @onready var time: Label = $TimePanel/Time
@onready var time: Label = $Time
@onready var timer: Timer = $Timer

@export var stats: SkillButtonStats


func _ready() -> void:
	timer.wait_time = stats.cooldown
	key.text = stats.key
	button.texture_normal = stats.texture
	time.visible = false

	cooldown.max_value = timer.wait_time
	set_process(false)


func _process(delta: float) -> void:
	time.text = "%3.1f" % timer.time_left
	cooldown.value = timer.time_left

	
func _on_skill_button_toggled(toggled_on:bool) -> void:
	if toggled_on:
		time.visible = true
		timer.start()
		button.disabled = true
		set_process(true)
	else:
		time.visible = false


func _on_timer_timeout() -> void:
	button.disabled = false
	time.text = ""
	cooldown.value = 0.0
	set_process(false)
	button.button_pressed = false
