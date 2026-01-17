extends SubViewportContainer
class_name Building3DView
## Renderuje model 3D budynku w widoku izometrycznym

@onready var viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/Camera3D
@onready var model_container: Node3D = $SubViewport/ModelContainer
@onready var light: DirectionalLight3D = $SubViewport/DirectionalLight3D

# Ustawienia kamery izometrycznej (dimetric 2:1)
# Dla proporcji kafelka 128x64 (2:1), kąt = arctan(0.5) ≈ 26.565° od poziomu
const CAMERA_ROT_X: float = -30.0  # Pochylenie w dół (~30° dla dimetric 2:1)
const CAMERA_ROT_Y: float = 45.0   # Obrót wokół Y (widok z rogu)
const CAMERA_DISTANCE: float = 10.0

var current_model: Node3D = null
var _pending_model_path: String = ""
var _pending_footprint: Vector2i = Vector2i(1, 1)
var _is_ready: bool = false

func _ready() -> void:
	_is_ready = true
	_setup_camera()
	_setup_lighting()

	# Załaduj oczekujący model jeśli był
	if not _pending_model_path.is_empty():
		load_model(_pending_model_path, _pending_footprint)

func _setup_camera() -> void:
	if not camera:
		return

	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.rotation_degrees = Vector3(CAMERA_ROT_X, CAMERA_ROT_Y, 0)

	# Pozycja kamery - daleko, patrzy na origin
	var direction := Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(CAMERA_ROT_X))
	direction = direction.rotated(Vector3.UP, deg_to_rad(CAMERA_ROT_Y))
	camera.position = -direction * CAMERA_DISTANCE

func _setup_lighting() -> void:
	if not light:
		return

	# Światło z północnego-zachodu (góra-lewo), dopasowane do kąta kamery
	light.rotation_degrees = Vector3(-35, -45, 0)
	light.light_energy = 1.2

func load_model(model_path: String, footprint: Vector2i = Vector2i(1, 1)) -> void:
	# Jeśli nie jesteśmy gotowi, zapisz do późniejszego załadowania
	if not _is_ready:
		_pending_model_path = model_path
		_pending_footprint = footprint
		return

	# Wyczyść poprzedni model
	if current_model:
		current_model.queue_free()
		current_model = null

	if model_path.is_empty():
		return

	# Wyczyść oczekujące
	_pending_model_path = ""

	# Załaduj scenę GLB
	var scene := load(model_path) as PackedScene
	if not scene:
		push_error("Could not load model: " + model_path)
		return

	current_model = scene.instantiate()

	if model_container:
		model_container.add_child(current_model)
	else:
		push_error("model_container is null!")
		return

	# Dopasuj kamerę do rozmiaru budynku
	_fit_camera_to_model(footprint)

func _fit_camera_to_model(footprint: Vector2i) -> void:
	if not camera or not current_model:
		return

	# Oblicz AABB modelu
	var aabb := _get_model_aabb(current_model)
	var model_size := aabb.size

	# Wycentruj model w X/Z, podstawa na Y=0
	var center_xz := Vector3(aabb.get_center().x, 0, aabb.get_center().z)
	current_model.position = -center_xz
	current_model.position.y = -aabb.position.y

	# Ortho size kamery - musi objąć cały budynek
	var max_dim := maxf(model_size.x, maxf(model_size.y, model_size.z))
	camera.size = max_dim * 2.0

	# Viewport i kontener - nie zmieniamy rozmiaru, zostaje domyślny 128x128
	# Rozmiar będzie ustawiony w scenie

func _get_model_aabb(node: Node3D) -> AABB:
	var aabb := AABB()
	var first := true

	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh_inst := child as MeshInstance3D
			var mesh_aabb: AABB = mesh_inst.get_aabb()
			mesh_aabb = mesh_inst.transform * mesh_aabb
			if first:
				aabb = mesh_aabb
				first = false
			else:
				aabb = aabb.merge(mesh_aabb)

		if child is Node3D:
			var child_aabb: AABB = _get_model_aabb(child as Node3D)
			if child_aabb.size.length() > 0:
				if first:
					aabb = child_aabb
					first = false
				else:
					aabb = aabb.merge(child_aabb)

	return aabb

func set_rotation_y(degrees: float) -> void:
	if current_model:
		current_model.rotation_degrees.y = degrees
