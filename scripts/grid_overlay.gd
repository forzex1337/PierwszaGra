extends Node2D
## GridOverlay - rysuje siatkę izometryczną

@export var grid_color: Color = Color(1, 1, 1, 0.1)
@export var border_color: Color = Color(1, 1, 1, 0.3)

func _ready() -> void:
	queue_redraw()

func draw_grid() -> void:
	queue_redraw()

func _draw() -> void:
	var cell_w := GridManager.CELL_WIDTH
	var cell_h := GridManager.CELL_HEIGHT
	var map_w := GridManager.MAP_WIDTH
	var map_h := GridManager.MAP_HEIGHT

	# Rysuj linie poziome (wschód-zachód)
	for y in range(map_h + 1):
		var start := GridManager.grid_to_world(Vector2i(0, y))
		var end := GridManager.grid_to_world(Vector2i(map_w, y))
		var color := border_color if y == 0 or y == map_h else grid_color
		draw_line(start, end, color, 1.0)

	# Rysuj linie pionowe (północ-południe)
	for x in range(map_w + 1):
		var start := GridManager.grid_to_world(Vector2i(x, 0))
		var end := GridManager.grid_to_world(Vector2i(x, map_h))
		var color := border_color if x == 0 or x == map_w else grid_color
		draw_line(start, end, color, 1.0)
