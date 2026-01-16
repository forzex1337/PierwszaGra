extends Node2D
## Game - główna scena gry z mapą i kamerą

signal building_tapped(building: Building)
signal empty_cell_tapped(grid_pos: Vector2i)

@onready var camera: Camera2D = $Camera2D
@onready var buildings_container: Node2D = $BuildingsContainer
@onready var grid_overlay: Node2D = $GridOverlay
@onready var build_cursor: Node2D = $BuildCursor

# Sterowanie kamerą
var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO
var camera_start_pos: Vector2 = Vector2.ZERO

# Pinch zoom
var touches: Dictionary = {}
var initial_pinch_distance: float = 0.0
var initial_zoom: Vector2 = Vector2.ONE

# Limity kamery
const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 2.0
const PAN_SPEED: float = 1.0

# Build cursor
var cursor_grid_pos: Vector2i = Vector2i.ZERO
var is_cursor_valid: bool = false

func _ready() -> void:
	# Ustaw referencję do kontenera budynków w BuildSystem
	BuildSystem.buildings_container = buildings_container

	# Połącz sygnały
	BuildSystem.build_mode_changed.connect(_on_build_mode_changed)
	BuildSystem.building_placed.connect(_on_building_placed)

	# Ustaw kamerę na środek mapy
	var map_center := GridManager.grid_to_world(Vector2i(GridManager.MAP_WIDTH / 2, GridManager.MAP_HEIGHT / 2))
	camera.position = map_center

	# Rysuj siatkę
	_draw_grid()

func _process(_delta: float) -> void:
	# Aktualizuj kursor budowy
	if BuildSystem.is_build_mode:
		_update_build_cursor()

func _input(event: InputEvent) -> void:
	# Obsługa dotyku (mobile)
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)
	# Obsługa myszy (desktop/debug)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		touches[event.index] = event.position
		if touches.size() == 1:
			# Pojedynczy dotyk - start drag lub tap
			is_dragging = false
			drag_start_pos = event.position
			camera_start_pos = camera.position
		elif touches.size() == 2:
			# Dwa palce - start pinch zoom
			var touch_positions := touches.values()
			initial_pinch_distance = touch_positions[0].distance_to(touch_positions[1])
			initial_zoom = camera.zoom
	else:
		# Palec podniesiony
		if touches.size() == 1 and not is_dragging:
			# To był tap (nie drag)
			_handle_tap(event.position)
		touches.erase(event.index)

func _handle_drag(event: InputEventScreenDrag) -> void:
	touches[event.index] = event.position

	if touches.size() == 1:
		# Pan kamerą
		is_dragging = true
		var drag_delta := event.position - drag_start_pos
		camera.position = camera_start_pos - drag_delta / camera.zoom.x
		_clamp_camera()
	elif touches.size() == 2:
		# Pinch zoom
		var touch_positions := touches.values()
		var current_distance := touch_positions[0].distance_to(touch_positions[1])
		if initial_pinch_distance > 0:
			var zoom_factor := current_distance / initial_pinch_distance
			var new_zoom := initial_zoom * zoom_factor
			camera.zoom = new_zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = false
			drag_start_pos = event.position
			camera_start_pos = camera.position
		else:
			if not is_dragging:
				_handle_tap(event.position)
			is_dragging = false
	# Scroll zoom
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera.zoom *= 1.1
		camera.zoom = camera.zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera.zoom *= 0.9
		camera.zoom = camera.zoom.clamp(Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var drag_delta := event.position - drag_start_pos
		if drag_delta.length() > 10:
			is_dragging = true
		camera.position = camera_start_pos - drag_delta / camera.zoom.x
		_clamp_camera()

	# Aktualizuj pozycję kursora budowy
	if BuildSystem.is_build_mode:
		var world_pos := get_global_mouse_position()
		cursor_grid_pos = GridManager.world_to_grid(world_pos)
		_update_build_cursor()

func _handle_tap(screen_pos: Vector2) -> void:
	# Konwertuj pozycję ekranu na świat
	var world_pos := camera.get_global_transform().affine_inverse() * screen_pos
	world_pos = get_viewport_transform().affine_inverse() * screen_pos
	world_pos = camera.get_screen_center_position() + (screen_pos - get_viewport_rect().size / 2) / camera.zoom.x

	var grid_pos := GridManager.world_to_grid(world_pos)

	if BuildSystem.is_build_mode or BuildSystem.is_demolish_mode:
		BuildSystem.handle_tap(grid_pos)
	else:
		# Sprawdź czy kliknięto budynek
		var building := GridManager.get_building_at(grid_pos)
		if building:
			building_tapped.emit(building)
		else:
			empty_cell_tapped.emit(grid_pos)

func _clamp_camera() -> void:
	# Ogranicz kamerę do granic mapy
	var min_pos := GridManager.grid_to_world(Vector2i(0, 0))
	var max_pos := GridManager.grid_to_world(Vector2i(GridManager.MAP_WIDTH, GridManager.MAP_HEIGHT))
	camera.position.x = clamp(camera.position.x, min_pos.x - 200, max_pos.x + 200)
	camera.position.y = clamp(camera.position.y, min_pos.y - 200, max_pos.y + 200)

func _update_build_cursor() -> void:
	if not build_cursor:
		return

	build_cursor.visible = BuildSystem.is_build_mode
	if not BuildSystem.is_build_mode:
		return

	# Pozycja kursora
	var world_pos := GridManager.grid_to_world(cursor_grid_pos)
	build_cursor.position = world_pos

	# Sprawdź czy można budować
	is_cursor_valid = BuildSystem.can_build_at(cursor_grid_pos)

	# Zmień kolor kursora
	var cursor_rect: ColorRect = build_cursor.get_node_or_null("CursorRect")
	if cursor_rect:
		cursor_rect.color = Color(0, 1, 0, 0.5) if is_cursor_valid else Color(1, 0, 0, 0.5)

func _draw_grid() -> void:
	# Siatka jest rysowana przez GridOverlay
	if grid_overlay and grid_overlay.has_method("draw_grid"):
		grid_overlay.draw_grid()

func _on_build_mode_changed(is_active: bool, _building_data: Resource) -> void:
	if build_cursor:
		build_cursor.visible = is_active

func _on_building_placed(_grid_pos: Vector2i, _building_data: Resource) -> void:
	# Aktualizuj połączenia dróg dla wszystkich budynków
	for building in GridManager.get_all_buildings():
		if building and building.has_method("update_road_connection"):
			building.update_road_connection()
