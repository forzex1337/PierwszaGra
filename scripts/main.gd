extends Node
## Main - główny kontroler gry, łączy Game i UI

@onready var game: Node2D = $Game
@onready var ui: CanvasLayer = $UI
@onready var build_menu: Control = $UI/BuildMenu
@onready var building_info: Control = $UI/BuildingInfo
@onready var build_button: Button = $UI/HUD/BuildButton

func _ready() -> void:
	print("GridTopia: Game started!")

	# Połącz sygnały UI
	if build_button:
		build_button.pressed.connect(_on_build_button_pressed)

	if build_menu:
		build_menu.building_selected.connect(_on_building_selected)
		build_menu.demolish_selected.connect(_on_demolish_selected)
		build_menu.menu_closed.connect(_on_menu_closed)

	if building_info:
		building_info.demolish_requested.connect(_on_demolish_requested)

	# Połącz sygnały Game
	if game:
		game.building_tapped.connect(_on_building_tapped)
		game.empty_cell_tapped.connect(_on_empty_cell_tapped)

func _on_build_button_pressed() -> void:
	if BuildSystem.is_build_mode or BuildSystem.is_demolish_mode:
		# Wyjdź z trybu budowania
		BuildSystem.exit_build_mode()
		build_button.text = "BUDUJ"
	else:
		# Otwórz menu budowania
		build_menu.show_menu()

func _on_building_selected(building_data: BuildingData) -> void:
	BuildSystem.enter_build_mode(building_data)
	build_button.text = "ANULUJ"

func _on_demolish_selected() -> void:
	BuildSystem.enter_demolish_mode()
	build_button.text = "ANULUJ"

func _on_menu_closed() -> void:
	BuildSystem.exit_build_mode()
	build_button.text = "BUDUJ"

func _on_building_tapped(building: Building) -> void:
	# Jeśli w trybie wyburzania, wyburz
	if BuildSystem.is_demolish_mode:
		BuildSystem.remove_building(building.grid_position)
		return

	# Jeśli nie w trybie budowania, pokaż info
	if not BuildSystem.is_build_mode:
		building_info.show_building(building)

func _on_empty_cell_tapped(_grid_pos: Vector2i) -> void:
	# Zamknij info panel jeśli otwarty
	if building_info.visible:
		building_info.hide()

func _on_demolish_requested(building: Building) -> void:
	BuildSystem.remove_building(building.grid_position)

func _input(event: InputEvent) -> void:
	# ESC - wyjdź z trybu budowania
	if event.is_action_pressed("ui_cancel"):
		if BuildSystem.is_build_mode or BuildSystem.is_demolish_mode:
			BuildSystem.exit_build_mode()
			build_button.text = "BUDUJ"
		elif build_menu.visible:
			build_menu.hide()
		elif building_info.visible:
			building_info.hide()
