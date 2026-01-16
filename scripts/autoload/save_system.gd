extends Node
## SaveSystem - zapis i odczyt stanu gry

signal game_saved()
signal game_loaded()
signal save_failed(reason: String)
signal load_failed(reason: String)

const SAVE_PATH := "user://savegame.json"
const AUTO_SAVE_INTERVAL := 60.0  # sekundy

var auto_save_timer: float = 0.0
var auto_save_enabled: bool = true

func _ready() -> void:
	print("SaveSystem: Initialized, save path: ", SAVE_PATH)

func _process(delta: float) -> void:
	if not auto_save_enabled:
		return

	auto_save_timer += delta
	if auto_save_timer >= AUTO_SAVE_INTERVAL:
		auto_save_timer = 0.0
		save_game()
		print("SaveSystem: Auto-saved")

func save_game() -> bool:
	var save_data := {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"game_manager": GameManager.get_save_data(),
		"grid_manager": GridManager.get_save_data()
	}

	var json_string := JSON.stringify(save_data, "\t")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		var error := FileAccess.get_open_error()
		save_failed.emit("Nie można otworzyć pliku: " + str(error))
		return false

	file.store_string(json_string)
	file.close()

	game_saved.emit()
	print("SaveSystem: Game saved successfully")
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		load_failed.emit("Brak pliku zapisu")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		var error := FileAccess.get_open_error()
		load_failed.emit("Nie można otworzyć pliku: " + str(error))
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		load_failed.emit("Błąd parsowania JSON: " + json.get_error_message())
		return false

	var save_data: Dictionary = json.data

	# Sprawdź wersję
	var version: int = save_data.get("version", 0)
	if version < 1:
		load_failed.emit("Nieobsługiwana wersja zapisu")
		return false

	# Wyczyść aktualny stan
	_clear_current_game()

	# Wczytaj dane
	if save_data.has("game_manager"):
		GameManager.load_save_data(save_data["game_manager"])

	if save_data.has("grid_manager"):
		_load_buildings(save_data["grid_manager"])

	game_loaded.emit()
	print("SaveSystem: Game loaded successfully")
	return true

func _clear_current_game() -> void:
	# Usuń wszystkie budynki
	for building in GridManager.get_all_buildings():
		if building:
			building.queue_free()
	GridManager.clear_all()
	GameManager.reset_game()

func _load_buildings(grid_data: Dictionary) -> void:
	var buildings_data: Array = grid_data.get("buildings", [])

	for building_data in buildings_data:
		var building_id: String = building_data.get("id", "")
		var grid_x: int = building_data.get("grid_x", 0)
		var grid_y: int = building_data.get("grid_y", 0)
		var grid_pos := Vector2i(grid_x, grid_y)

		# Znajdź dane budynku
		var resource_path := "res://resources/buildings/" + building_id + ".tres"
		if not ResourceLoader.exists(resource_path):
			print("SaveSystem: Building resource not found: ", resource_path)
			continue

		var building_resource := load(resource_path)
		if not building_resource:
			continue

		# Użyj BuildSystem do postawienia budynku
		# Tymczasowo wyłącz sprawdzanie kosztów
		var original_money := GameManager.money
		GameManager.money = 999999

		BuildSystem.enter_build_mode(building_resource)
		BuildSystem.place_building(grid_pos)
		BuildSystem.exit_build_mode()

		GameManager.money = original_money

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("SaveSystem: Save file deleted")
