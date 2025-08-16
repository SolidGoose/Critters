extends TextureButton

@onready var cooldown = $Cooldown
@onready var key = $Key
@onready var time = $Time
@onready var timer = $Timer


func _ready() -> void:
	cooldown.max_value = timer.wait_time
	set_process(false)


func _process(delta: float) -> void:
	time.text = "%3.1f" % timer.time_left
	cooldown.value = timer.time_left


func _on_timer_timeout() -> void:
	disabled = false
	time.text = ""
	cooldown.value = 0.0
	set_process(false)
	button_pressed = false


func _on_toggled(toggled_on:bool) -> void:
	if toggled_on:
		timer.start()
		disabled = true
		set_process(true)
