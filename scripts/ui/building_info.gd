extends Control
## BuildingInfo - panel z informacjami o wybranym budynku

signal demolish_requested(building: Building)

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/VBoxContainer/NameLabel
@onready var info_label: Label = $Panel/VBoxContainer/InfoLabel
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton
@onready var demolish_button: Button = $Panel/VBoxContainer/DemolishButton

var selected_building: Building = null

func _ready() -> void:
	visible = false

	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if demolish_button:
		demolish_button.pressed.connect(_on_demolish_pressed)

func show_building(building: Building) -> void:
	if not building or not building.building_data:
		return

	selected_building = building

	if name_label:
		name_label.text = building.building_data.display_name

	if info_label:
		info_label.text = building.get_info_text()

	show()

func _on_close_pressed() -> void:
	selected_building = null
	hide()

func _on_demolish_pressed() -> void:
	if selected_building:
		demolish_requested.emit(selected_building)
		hide()
	selected_building = null
