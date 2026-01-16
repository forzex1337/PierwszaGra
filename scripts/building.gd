extends Node2D
class_name Building
## Building - pojedynczy budynek na mapie

signal clicked(building: Building)

@onready var sprite: Sprite2D = $Sprite2D
@onready var placeholder: ColorRect = $Placeholder
@onready var connection_indicator: ColorRect = $ConnectionIndicator

var building_data: BuildingData
var grid_position: Vector2i
var is_connected_to_road: bool = false

func _ready() -> void:
	# Ukryj indicator na start
	if connection_indicator:
		connection_indicator.visible = false

func setup(data: BuildingData, grid_pos: Vector2i) -> void:
	building_data = data
	grid_position = grid_pos

	# Ustaw pozycję w świecie
	position = GridManager.grid_to_world(grid_pos)

	# Ustaw wygląd
	_setup_visuals()

	# Sprawdź połączenie z drogą
	update_road_connection()

func _setup_visuals() -> void:
	if not building_data:
		return

	# Rozmiar placeholder na podstawie footprint
	var footprint := building_data.footprint
	var width := footprint.x * GridManager.CELL_WIDTH
	var height := footprint.y * GridManager.CELL_HEIGHT

	# Jeśli jest sprite, użyj go
	if building_data.sprite and sprite:
		sprite.texture = building_data.sprite
		sprite.visible = true
		if placeholder:
			placeholder.visible = false
	else:
		# Użyj placeholder z kolorem
		if placeholder:
			placeholder.color = building_data.color
			# Rozmiar izometryczny (rombus-like)
			placeholder.size = Vector2(GridManager.CELL_WIDTH * 0.8, GridManager.CELL_HEIGHT * 0.8)
			placeholder.position = Vector2(-placeholder.size.x / 2, -placeholder.size.y / 2)
			placeholder.visible = true
		if sprite:
			sprite.visible = false

func update_road_connection() -> void:
	# Drogi są zawsze "podłączone"
	if building_data.building_type == "road":
		is_connected_to_road = true
		_update_connection_visual()
		return

	# Sprawdź czy budynek sąsiaduje z drogą
	is_connected_to_road = false
	for x in range(building_data.footprint.x):
		for y in range(building_data.footprint.y):
			var check_pos := Vector2i(grid_position.x + x, grid_position.y + y)
			if GridManager.is_adjacent_to_road(check_pos):
				is_connected_to_road = true
				break
		if is_connected_to_road:
			break

	_update_connection_visual()

func _update_connection_visual() -> void:
	if connection_indicator:
		# Czerwona kropka jeśli niepodłączony
		connection_indicator.visible = not is_connected_to_road and building_data.building_type != "road"

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			clicked.emit(self)

func get_save_data() -> Dictionary:
	return {
		"id": building_data.id if building_data else "",
		"grid_x": grid_position.x,
		"grid_y": grid_position.y
	}

func get_info_text() -> String:
	if not building_data:
		return "Nieznany budynek"

	var text := building_data.display_name + "\n"
	text += building_data.description + "\n\n"

	if building_data.population_capacity > 0:
		text += "Mieszkańcy: " + str(building_data.population_capacity) + "\n"
	if building_data.jobs_capacity > 0:
		text += "Miejsca pracy: " + str(building_data.jobs_capacity) + "\n"
	if building_data.happiness_bonus != 0:
		var sign_str := "+" if building_data.happiness_bonus > 0 else ""
		text += "Zadowolenie: " + sign_str + str(building_data.happiness_bonus) + "\n"
	if building_data.upkeep > 0:
		text += "Utrzymanie: " + str(building_data.upkeep) + "/tick\n"

	text += "\nStatus: " + ("Podłączony" if is_connected_to_road else "BRAK DROGI!")

	return text
