extends Node
## GridManager - zarządzanie siatką izometryczną
## Konwersje world↔grid, sprawdzanie zajętości pól

signal cell_occupied(grid_pos: Vector2i)
signal cell_freed(grid_pos: Vector2i)

# Rozmiar mapy w polach
const MAP_WIDTH: int = 32
const MAP_HEIGHT: int = 32

# Rozmiar pojedynczego pola izometrycznego (w pikselach)
const CELL_WIDTH: int = 128
const CELL_HEIGHT: int = 64

# Słownik zajętości: grid_pos -> building_id lub null
var _occupied_cells: Dictionary = {}

# Słownik budynków: grid_pos -> Building node reference
var _buildings: Dictionary = {}

func _ready() -> void:
	print("GridManager: Initialized (", MAP_WIDTH, "x", MAP_HEIGHT, " grid)")

# Konwersja pozycji świata na pozycję grid (izometryczna)
func world_to_grid(world_pos: Vector2) -> Vector2i:
	# Odwrotna transformacja izometryczna
	var grid_x := (world_pos.x / (CELL_WIDTH * 0.5) + world_pos.y / (CELL_HEIGHT * 0.5)) / 2.0
	var grid_y := (world_pos.y / (CELL_HEIGHT * 0.5) - world_pos.x / (CELL_WIDTH * 0.5)) / 2.0
	return Vector2i(floori(grid_x), floori(grid_y))

# Konwersja pozycji grid na pozycję świata (środek pola)
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	# Transformacja izometryczna
	var world_x := (grid_pos.x - grid_pos.y) * (CELL_WIDTH * 0.5)
	var world_y := (grid_pos.x + grid_pos.y) * (CELL_HEIGHT * 0.5)
	return Vector2(world_x, world_y)

# Sprawdza czy pozycja jest w granicach mapy
func is_in_bounds(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < MAP_WIDTH and \
		   grid_pos.y >= 0 and grid_pos.y < MAP_HEIGHT

# Sprawdza czy pole jest wolne
func is_cell_free(grid_pos: Vector2i) -> bool:
	if not is_in_bounds(grid_pos):
		return false
	return not _occupied_cells.has(grid_pos)

# Sprawdza czy wszystkie pola dla budynku są wolne (footprint)
func are_cells_free(grid_pos: Vector2i, footprint: Vector2i) -> bool:
	for x in range(footprint.x):
		for y in range(footprint.y):
			var check_pos := Vector2i(grid_pos.x + x, grid_pos.y + y)
			if not is_cell_free(check_pos):
				return false
	return true

# Zajmij pole
func occupy_cell(grid_pos: Vector2i, building_id: String, building_ref: Node = null) -> bool:
	if not is_cell_free(grid_pos):
		return false
	_occupied_cells[grid_pos] = building_id
	if building_ref:
		_buildings[grid_pos] = building_ref
	cell_occupied.emit(grid_pos)
	return true

# Zajmij wiele pól (footprint)
func occupy_cells(grid_pos: Vector2i, footprint: Vector2i, building_id: String, building_ref: Node = null) -> bool:
	if not are_cells_free(grid_pos, footprint):
		return false
	for x in range(footprint.x):
		for y in range(footprint.y):
			var cell_pos := Vector2i(grid_pos.x + x, grid_pos.y + y)
			_occupied_cells[cell_pos] = building_id
			if building_ref and x == 0 and y == 0:
				_buildings[cell_pos] = building_ref
	cell_occupied.emit(grid_pos)
	return true

# Zwolnij pole
func free_cell(grid_pos: Vector2i) -> void:
	if _occupied_cells.has(grid_pos):
		_occupied_cells.erase(grid_pos)
		_buildings.erase(grid_pos)
		cell_freed.emit(grid_pos)

# Zwolnij wiele pól
func free_cells(grid_pos: Vector2i, footprint: Vector2i) -> void:
	for x in range(footprint.x):
		for y in range(footprint.y):
			free_cell(Vector2i(grid_pos.x + x, grid_pos.y + y))

# Pobierz budynek na danym polu
func get_building_at(grid_pos: Vector2i) -> Node:
	return _buildings.get(grid_pos, null)

# Pobierz ID budynku na danym polu
func get_building_id_at(grid_pos: Vector2i) -> String:
	return _occupied_cells.get(grid_pos, "")

# Sprawdza czy pole jest drogą
func is_road(grid_pos: Vector2i) -> bool:
	return get_building_id_at(grid_pos) == "road"

# Pobierz sąsiadów (4 kierunki)
func get_neighbors(grid_pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for dir: Vector2i in directions:
		var neighbor: Vector2i = grid_pos + dir
		if is_in_bounds(neighbor):
			neighbors.append(neighbor)
	return neighbors

# Sprawdza czy budynek sąsiaduje z drogą
func is_adjacent_to_road(grid_pos: Vector2i) -> bool:
	for neighbor in get_neighbors(grid_pos):
		if is_road(neighbor):
			return true
	return false

# Pobierz wszystkie budynki
func get_all_buildings() -> Array:
	return _buildings.values()

# Wyczyść całą mapę
func clear_all() -> void:
	_occupied_cells.clear()
	_buildings.clear()

# Dane do zapisu
func get_save_data() -> Dictionary:
	var buildings_data := []
	for pos in _buildings:
		var building = _buildings[pos]
		if building and building.has_method("get_save_data"):
			buildings_data.append(building.get_save_data())
	return {"buildings": buildings_data}
