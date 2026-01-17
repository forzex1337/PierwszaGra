extends Node2D
class_name RoadVisual
## Proceduralne rysowanie drogi z auto-łączeniem

# Kierunki sąsiadów (w układzie grid)
enum Direction { NORTH, EAST, SOUTH, WEST }

# Kolory drogi
const COLOR_ASPHALT := Color(0.25, 0.25, 0.28, 1.0)  # Ciemny asfalt
const COLOR_SIDEWALK := Color(0.55, 0.53, 0.5, 1.0)  # Jasny chodnik
const COLOR_YELLOW_LINE := Color(0.9, 0.75, 0.1, 1.0)  # Żółte pasy
const COLOR_WHITE_LINE := Color(0.9, 0.9, 0.9, 1.0)  # Białe krawędzie

# Wymiary (izometryczne)
const CELL_W := 128.0
const CELL_H := 64.0
const HALF_W := CELL_W / 2.0  # 64
const HALF_H := CELL_H / 2.0  # 32

# Szerokość chodnika (jako ułamek)
const SIDEWALK_WIDTH := 0.15

# Połączenia z sąsiadami
var connections: Dictionary = {
	Direction.NORTH: false,
	Direction.EAST: false,
	Direction.SOUTH: false,
	Direction.WEST: false
}

var grid_position: Vector2i = Vector2i.ZERO

func _ready() -> void:
	# Początkowa aktualizacja
	call_deferred("update_connections")

func _draw() -> void:
	_draw_road_tile()

func update_connections() -> void:
	# Sprawdź sąsiadów
	var neighbors := {
		Direction.NORTH: Vector2i(0, -1),
		Direction.EAST: Vector2i(1, 0),
		Direction.SOUTH: Vector2i(0, 1),
		Direction.WEST: Vector2i(-1, 0)
	}

	for dir in neighbors:
		var neighbor_pos: Vector2i = grid_position + neighbors[dir]
		connections[dir] = GridManager.is_road(neighbor_pos)

	queue_redraw()

func _draw_road_tile() -> void:
	var connection_count := _count_connections()

	# Punkty izometrycznego rombu (środek na 0,0)
	var top := Vector2(0, -HALF_H)
	var right := Vector2(HALF_W, 0)
	var bottom := Vector2(0, HALF_H)
	var left := Vector2(-HALF_W, 0)

	# 1. Rysuj asfalt (cały romb)
	var asphalt_points := PackedVector2Array([top, right, bottom, left])
	draw_colored_polygon(asphalt_points, COLOR_ASPHALT)

	# 2. Rysuj chodniki tylko na krawędziach BEZ połączeń
	var inset := SIDEWALK_WIDTH
	_draw_sidewalks(top, right, bottom, left, inset)

	# 3. Rysuj żółte pasy w zależności od połączeń
	_draw_road_lines(connection_count)

func _draw_sidewalks(top: Vector2, right: Vector2, bottom: Vector2, left: Vector2, inset: float) -> void:
	# Krawędzie rombu odpowiadają kierunkom:
	# Top-Right edge = NORTH (grid 0,-1)
	# Bottom-Left edge = SOUTH (grid 0,+1)
	# Bottom-Right edge = EAST (grid +1,0)
	# Top-Left edge = WEST (grid -1,0)

	# Wewnętrzne punkty (przesunięte do środka)
	var inner_top := _lerp_point(Vector2.ZERO, top, 1.0 - inset)
	var inner_right := _lerp_point(Vector2.ZERO, right, 1.0 - inset)
	var inner_bottom := _lerp_point(Vector2.ZERO, bottom, 1.0 - inset)
	var inner_left := _lerp_point(Vector2.ZERO, left, 1.0 - inset)

	# Rysuj chodniki na krawędziach BEZ połączeń
	# Rogi przy połączeniach pokażą asfalt (akceptowalne wizualnie)
	if not connections[Direction.NORTH]:
		var sidewalk := PackedVector2Array([top, right, inner_right, inner_top])
		draw_colored_polygon(sidewalk, COLOR_SIDEWALK)

	if not connections[Direction.SOUTH]:
		var sidewalk := PackedVector2Array([left, bottom, inner_bottom, inner_left])
		draw_colored_polygon(sidewalk, COLOR_SIDEWALK)

	if not connections[Direction.EAST]:
		var sidewalk := PackedVector2Array([right, bottom, inner_bottom, inner_right])
		draw_colored_polygon(sidewalk, COLOR_SIDEWALK)

	if not connections[Direction.WEST]:
		var sidewalk := PackedVector2Array([left, top, inner_top, inner_left])
		draw_colored_polygon(sidewalk, COLOR_SIDEWALK)

func _draw_road_lines(connection_count: int) -> void:
	# Punkty na środkach KRAWĘDZI rombu (izometryczne kierunki)
	# NORTH (grid 0,-1) = top-right edge → midpoint between Top and Right
	# SOUTH (grid 0,+1) = bottom-left edge → midpoint between Left and Bottom
	# EAST (grid +1,0) = bottom-right edge → midpoint between Right and Bottom
	# WEST (grid -1,0) = top-left edge → midpoint between Left and Top
	var edge_inset := 1.0 - SIDEWALK_WIDTH

	# Środki krawędzi (z uwzględnieniem chodnika)
	var edge_north := Vector2(HALF_W * 0.5, -HALF_H * 0.5) * edge_inset  # top-right
	var edge_south := Vector2(-HALF_W * 0.5, HALF_H * 0.5) * edge_inset  # bottom-left
	var edge_east := Vector2(HALF_W * 0.5, HALF_H * 0.5) * edge_inset   # bottom-right
	var edge_west := Vector2(-HALF_W * 0.5, -HALF_H * 0.5) * edge_inset # top-left

	match connection_count:
		0:
			# Brak połączeń - mały znacznik
			_draw_center_marking()
		1:
			# Ślepy zaułek
			_draw_dead_end_lines(edge_north, edge_south, edge_east, edge_west)
		2:
			# Prosta lub zakręt
			if _is_straight():
				_draw_straight_lines(edge_north, edge_south, edge_east, edge_west)
			else:
				_draw_corner_lines(edge_north, edge_south, edge_east, edge_west)
		3:
			# Skrzyżowanie T
			_draw_junction_lines(edge_north, edge_south, edge_east, edge_west)
		4:
			# Pełne skrzyżowanie
			_draw_junction_lines(edge_north, edge_south, edge_east, edge_west)

func _draw_center_marking() -> void:
	# Mały znacznik w centrum dla pojedynczej drogi
	var size := 6.0
	var rect := Rect2(-size/2, -size/2, size, size)
	draw_rect(rect, COLOR_YELLOW_LINE)

func _draw_dead_end_lines(edge_n: Vector2, edge_s: Vector2, edge_e: Vector2, edge_w: Vector2) -> void:
	var center := Vector2.ZERO

	if connections[Direction.NORTH]:
		_draw_dashed_line(center, edge_n, COLOR_YELLOW_LINE, 2.0)
	elif connections[Direction.SOUTH]:
		_draw_dashed_line(center, edge_s, COLOR_YELLOW_LINE, 2.0)
	elif connections[Direction.EAST]:
		_draw_dashed_line(center, edge_e, COLOR_YELLOW_LINE, 2.0)
	elif connections[Direction.WEST]:
		_draw_dashed_line(center, edge_w, COLOR_YELLOW_LINE, 2.0)

func _draw_straight_lines(edge_n: Vector2, edge_s: Vector2, edge_e: Vector2, edge_w: Vector2) -> void:
	if connections[Direction.NORTH] and connections[Direction.SOUTH]:
		# Północ-Południe (ukośnie: top-right ↔ bottom-left)
		_draw_dashed_line(edge_n, edge_s, COLOR_YELLOW_LINE, 2.0)
	else:
		# Wschód-Zachód (ukośnie: top-left ↔ bottom-right)
		_draw_dashed_line(edge_w, edge_e, COLOR_YELLOW_LINE, 2.0)

func _draw_corner_lines(edge_n: Vector2, edge_s: Vector2, edge_e: Vector2, edge_w: Vector2) -> void:
	var center := Vector2.ZERO

	# Narysuj linie od centrum do połączonych krawędzi
	if connections[Direction.NORTH]:
		_draw_dashed_line(center, edge_n, COLOR_YELLOW_LINE, 2.0)
	if connections[Direction.EAST]:
		_draw_dashed_line(center, edge_e, COLOR_YELLOW_LINE, 2.0)
	if connections[Direction.SOUTH]:
		_draw_dashed_line(center, edge_s, COLOR_YELLOW_LINE, 2.0)
	if connections[Direction.WEST]:
		_draw_dashed_line(center, edge_w, COLOR_YELLOW_LINE, 2.0)

func _draw_junction_lines(edge_n: Vector2, edge_s: Vector2, edge_e: Vector2, edge_w: Vector2) -> void:
	var center := Vector2.ZERO

	# Rysuj linie do wszystkich połączonych kierunków
	if connections[Direction.NORTH]:
		_draw_dashed_line(center, edge_n, COLOR_YELLOW_LINE, 2.0)
	if connections[Direction.EAST]:
		_draw_dashed_line(center, edge_e, COLOR_YELLOW_LINE, 2.0)
	if connections[Direction.SOUTH]:
		_draw_dashed_line(center, edge_s, COLOR_YELLOW_LINE, 2.0)
	if connections[Direction.WEST]:
		_draw_dashed_line(center, edge_w, COLOR_YELLOW_LINE, 2.0)

func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	var dash_length := 8.0
	var gap_length := 6.0
	var total_length := from.distance_to(to)
	var direction := (to - from).normalized()

	var current_pos := from
	var drawn := 0.0
	var is_dash := true

	while drawn < total_length:
		var segment_length: float
		if is_dash:
			segment_length = minf(dash_length, total_length - drawn)
		else:
			segment_length = minf(gap_length, total_length - drawn)

		var next_pos := current_pos + direction * segment_length

		if is_dash:
			draw_line(current_pos, next_pos, color, width)

		current_pos = next_pos
		drawn += segment_length
		is_dash = not is_dash

func _count_connections() -> int:
	var count := 0
	for dir in connections:
		if connections[dir]:
			count += 1
	return count

func _is_straight() -> bool:
	# Prosta jeśli połączone przeciwległe kierunki
	return (connections[Direction.NORTH] and connections[Direction.SOUTH]) or \
		   (connections[Direction.EAST] and connections[Direction.WEST])

func _lerp_point(from: Vector2, to: Vector2, t: float) -> Vector2:
	return from + (to - from) * t
