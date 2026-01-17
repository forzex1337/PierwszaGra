extends Node2D
class_name Building
## Building - pojedynczy budynek na mapie

signal clicked(building: Building)

const Building3DViewScene = preload("res://scenes/building_3d_view.tscn")
const RoadVisualScene = preload("res://scenes/road_visual.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var placeholder: ColorRect = $Placeholder
@onready var connection_indicator: ColorRect = $ConnectionIndicator

var building_data: BuildingData
var grid_position: Vector2i
var is_connected_to_road: bool = false
var building_3d_view: Building3DView = null
var road_visual: RoadVisual = null

func _ready() -> void:
	# Ukryj indicator na start
	if connection_indicator:
		connection_indicator.visible = false

func setup(data: BuildingData, grid_pos: Vector2i) -> void:
	building_data = data
	grid_position = grid_pos

	# Ustaw pozycję w świecie (środek komórki)
	# grid_to_world zwraca górny wierzchołek, dodajemy offset do centrum
	position = GridManager.grid_to_world(grid_pos) + Vector2(0, GridManager.CELL_HEIGHT / 2)

	# Ustaw wygląd
	_setup_visuals()

	# Sprawdź połączenie z drogą
	update_road_connection()

func _setup_visuals() -> void:
	if not building_data:
		return

	# Pobierz węzły bezpośrednio (setup może być przed _ready)
	var _sprite: Sprite2D = get_node_or_null("Sprite2D")
	var _placeholder: ColorRect = get_node_or_null("Placeholder")

	# Ukryj domyślne elementy
	if _sprite:
		_sprite.visible = false
	if _placeholder:
		_placeholder.visible = false

	# Priorytet: 1) Droga (specjalna wizualizacja), 2) Model 3D, 3) Sprite 2D, 4) Placeholder
	if building_data.building_type == "road":
		_setup_road_visual()
	elif building_data.model_path and not building_data.model_path.is_empty():
		_setup_3d_model()
	elif building_data.sprite and _sprite:
		_sprite.texture = building_data.sprite
		_sprite.visible = true
	else:
		# Użyj placeholder z kolorem
		if _placeholder:
			_placeholder.color = building_data.color
			# Rozmiar izometryczny (rombus-like)
			_placeholder.size = Vector2(GridManager.CELL_WIDTH * 0.8, GridManager.CELL_HEIGHT * 0.8)
			_placeholder.position = Vector2(-_placeholder.size.x / 2, -_placeholder.size.y / 2)
			_placeholder.visible = true

func _setup_road_visual() -> void:
	# Ukryj placeholder (pobierz bezpośrednio)
	var _placeholder: ColorRect = get_node_or_null("Placeholder")
	if _placeholder:
		_placeholder.visible = false

	# Stwórz wizualizację drogi
	if not road_visual:
		road_visual = RoadVisualScene.instantiate()
		road_visual.grid_position = grid_position
		add_child(road_visual)

	# Aktualizuj połączenia (po dodaniu do drzewa)
	road_visual.call_deferred("update_connections")

func _setup_3d_model() -> void:
	# Stwórz widok 3D jeśli nie istnieje
	if not building_3d_view:
		building_3d_view = Building3DViewScene.instantiate()
		add_child(building_3d_view)

	# Załaduj model
	building_3d_view.load_model(building_data.model_path, building_data.footprint)

	# Pozycjonuj viewport - wycentruj na pozycji budynku
	# Viewport 128x128, środek viewportu = środek renderowanego budynku
	# Przesuwamy tak żeby środek viewportu był na pozycji grida
	building_3d_view.position = Vector2(-64, -64)

func update_road_connection() -> void:
	# Drogi są zawsze "podłączone"
	if building_data.building_type == "road":
		is_connected_to_road = true
		# Aktualizuj wizualizację drogi (połączenia z sąsiadami)
		if road_visual:
			road_visual.update_connections()
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
