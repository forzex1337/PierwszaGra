extends Control
## MessagePopup - wyświetla komunikaty (błędy, informacje)

@onready var label: Label = $Panel/Label
@onready var timer: Timer = $Timer

var message_queue: Array[String] = []

func _ready() -> void:
	visible = false
	if timer:
		timer.timeout.connect(_on_timer_timeout)

	# Połącz sygnały błędów budowania
	BuildSystem.build_failed.connect(_on_build_failed)

func show_message(text: String, duration: float = 2.0) -> void:
	message_queue.append(text)
	if not visible:
		_show_next_message(duration)

func _show_next_message(duration: float = 2.0) -> void:
	if message_queue.is_empty():
		hide()
		return

	var text: String = message_queue.pop_front()
	if label:
		label.text = text
	show()

	if timer:
		timer.wait_time = duration
		timer.start()

func _on_timer_timeout() -> void:
	if message_queue.is_empty():
		hide()
	else:
		_show_next_message()

func _on_build_failed(reason: String) -> void:
	show_message(reason, 2.0)
