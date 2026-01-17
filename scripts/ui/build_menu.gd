extends Control
## BuildMenu - menu wyboru budynków do budowania

signal building_selected(building_data: BuildingData)
signal demolish_selected()
signal menu_closed()

@onready var buttons_container: VBoxContainer = $Panel/VBoxContainer/ButtonsContainer
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton
@onready var demolish_button: Button = $Panel/VBoxContainer/DemolishButton

# Ścieżki do zasobów budynków
var building_resources: Array[BuildingData] = []

func _ready() -> void:
	visible = false
	_load_building_resources()
	_create_buttons()

	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if demolish_button:
		demolish_button.pressed.connect(_on_demolish_pressed)

func _load_building_resources() -> void:
	# Wczytaj wszystkie zasoby budynków
	var paths := [
		"res://resources/buildings/road.tres",
		"res://resources/buildings/house.tres",
		"res://resources/buildings/apartment_small.tres",
		"res://resources/buildings/apartment.tres",
		"res://resources/buildings/shop.tres",
		"res://resources/buildings/factory.tres",
		"res://resources/buildings/office.tres"
	]

	for path in paths:
		if ResourceLoader.exists(path):
			var resource := load(path) as BuildingData
			if resource:
				building_resources.append(resource)

func _create_buttons() -> void:
	if not buttons_container:
		return

	# Wyczyść istniejące przyciski
	for child in buttons_container.get_children():
		child.queue_free()

	# Stwórz przyciski dla każdego budynku
	for building_data in building_resources:
		var button := Button.new()
		button.text = building_data.display_name + " ($" + str(building_data.cost) + ")"
		button.custom_minimum_size = Vector2(200, 50)

		# Dodaj tooltip
		button.tooltip_text = building_data.description

		# Połącz sygnał
		button.pressed.connect(_on_building_button_pressed.bind(building_data))

		buttons_container.add_child(button)

func _on_building_button_pressed(building_data: BuildingData) -> void:
	building_selected.emit(building_data)
	hide()

func _on_demolish_pressed() -> void:
	demolish_selected.emit()
	hide()

func _on_close_pressed() -> void:
	menu_closed.emit()
	hide()

func show_menu() -> void:
	# Aktualizuj stan przycisków (czy stać nas)
	_update_button_states()
	show()

func _update_button_states() -> void:
	var idx := 0
	for child in buttons_container.get_children():
		if child is Button and idx < building_resources.size():
			var data := building_resources[idx]
			child.disabled = not GameManager.can_afford(data.cost)
			idx += 1
