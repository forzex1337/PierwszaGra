extends Node
## BuildSystem - system budowania
## Zarządza trybem budowy, walidacją i stawianiem budynków

signal build_mode_changed(is_active: bool, building_data: Resource)
signal building_placed(grid_pos: Vector2i, building_data: Resource)
signal building_removed(grid_pos: Vector2i)
signal build_failed(reason: String)

# Aktualny stan budowania
var is_build_mode: bool = false
var current_building_data: Resource = null
var is_demolish_mode: bool = false

# Preload building scene
var building_scene: PackedScene = preload("res://scenes/building.tscn")

# Referencja do kontenera budynków (ustawiana przez Game scene)
var buildings_container: Node2D = null

func _ready() -> void:
	print("BuildSystem: Initialized")

# Włącz tryb budowania
func enter_build_mode(building_data: Resource) -> void:
	is_build_mode = true
	is_demolish_mode = false
	current_building_data = building_data
	build_mode_changed.emit(true, building_data)
	print("BuildSystem: Entered build mode for ", building_data.id)

# Włącz tryb wyburzania
func enter_demolish_mode() -> void:
	is_build_mode = false
	is_demolish_mode = true
	current_building_data = null
	build_mode_changed.emit(false, null)
	print("BuildSystem: Entered demolish mode")

# Wyjdź z trybu budowania/wyburzania
func exit_build_mode() -> void:
	is_build_mode = false
	is_demolish_mode = false
	current_building_data = null
	build_mode_changed.emit(false, null)
	print("BuildSystem: Exited build mode")

# Sprawdź czy można zbudować w danym miejscu
func can_build_at(grid_pos: Vector2i) -> bool:
	if not current_building_data:
		return false

	var footprint: Vector2i = current_building_data.footprint

	# Sprawdź granice mapy
	if not GridManager.is_in_bounds(grid_pos):
		return false

	# Sprawdź czy wszystkie pola są wolne
	if not GridManager.are_cells_free(grid_pos, footprint):
		return false

	# Sprawdź czy stać nas
	if not GameManager.can_afford(current_building_data.cost):
		return false

	# Drogi nie wymagają połączenia z innymi drogami
	if current_building_data.building_type == "road":
		return true

	# Inne budynki muszą sąsiadować z drogą
	# Sprawdź czy którykolwiek róg budynku sąsiaduje z drogą
	for x in range(footprint.x):
		for y in range(footprint.y):
			var check_pos := Vector2i(grid_pos.x + x, grid_pos.y + y)
			if GridManager.is_adjacent_to_road(check_pos):
				return true

	return false

# Pobierz powód dlaczego nie można budować
func get_build_failure_reason(grid_pos: Vector2i) -> String:
	if not current_building_data:
		return "Nie wybrano budynku"

	if not GridManager.is_in_bounds(grid_pos):
		return "Poza granicami mapy"

	var footprint: Vector2i = current_building_data.footprint
	if not GridManager.are_cells_free(grid_pos, footprint):
		return "Pole jest zajęte"

	if not GameManager.can_afford(current_building_data.cost):
		return "Brak pieniędzy"

	if current_building_data.building_type != "road":
		var has_road := false
		for x in range(footprint.x):
			for y in range(footprint.y):
				var check_pos := Vector2i(grid_pos.x + x, grid_pos.y + y)
				if GridManager.is_adjacent_to_road(check_pos):
					has_road = true
					break
		if not has_road:
			return "Brak drogi obok"

	return ""

# Postaw budynek
func place_building(grid_pos: Vector2i) -> bool:
	if not can_build_at(grid_pos):
		var reason := get_build_failure_reason(grid_pos)
		build_failed.emit(reason)
		return false

	if not buildings_container:
		build_failed.emit("Brak kontenera budynków")
		return false

	# Zabierz pieniądze
	GameManager.spend_money(current_building_data.cost)

	# Stwórz budynek
	var building := building_scene.instantiate()
	building.setup(current_building_data, grid_pos)
	buildings_container.add_child(building)

	# Zajmij pola w gridzie
	GridManager.occupy_cells(grid_pos, current_building_data.footprint, current_building_data.id, building)

	# Wyślij sygnał
	building_placed.emit(grid_pos, current_building_data)

	print("BuildSystem: Placed ", current_building_data.id, " at ", grid_pos)
	return true

# Usuń budynek
func remove_building(grid_pos: Vector2i) -> bool:
	var building := GridManager.get_building_at(grid_pos)
	if not building:
		build_failed.emit("Brak budynku")
		return false

	var building_data: Resource = building.building_data
	var footprint: Vector2i = building_data.footprint
	var building_grid_pos: Vector2i = building.grid_position

	# Zwróć część kosztów (50%)
	var refund := int(building_data.cost * 0.5)
	GameManager.add_money(refund)

	# Zwolnij pola
	GridManager.free_cells(building_grid_pos, footprint)

	# Usuń node
	building.queue_free()

	building_removed.emit(building_grid_pos)

	print("BuildSystem: Removed building at ", building_grid_pos, ", refunded ", refund)
	return true

# Obsługa tapa na mapie
func handle_tap(grid_pos: Vector2i) -> void:
	if is_demolish_mode:
		remove_building(grid_pos)
	elif is_build_mode and current_building_data:
		place_building(grid_pos)
