@tool
class_name BuildingData
extends Resource
## BuildingData - definicja danych budynku
## Używane jako Resource do definiowania typów budynków

@export_category("Identyfikacja")
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export_enum("road", "residential", "commercial", "industrial", "service") var building_type: String = "residential"

@export_category("Wygląd")
@export var icon: Texture2D
@export var sprite: Texture2D
@export var model_path: String = ""  # Ścieżka do modelu 3D (.glb)
@export var color: Color = Color.WHITE  # Kolor placeholder jeśli brak sprite/model

@export_category("Rozmiar")
@export var footprint: Vector2i = Vector2i(1, 1)  # Rozmiar na gridzie

@export_category("Koszty")
@export var cost: int = 100  # Koszt budowy
@export var upkeep: int = 0  # Koszt utrzymania na tick

@export_category("Efekty")
@export var population_capacity: int = 0  # Ile osób może mieszkać
@export var jobs_capacity: int = 0  # Ile miejsc pracy
@export var happiness_bonus: float = 0.0  # Bonus do happiness

@export_category("Wymagania")
@export var requires_road: bool = true  # Czy wymaga drogi obok
@export var min_population: int = 0  # Minimalna populacja do odblokowania

func _init() -> void:
	resource_name = "BuildingData"

func get_category() -> String:
	match building_type:
		"road":
			return "Drogi"
		"residential":
			return "Mieszkalne"
		"commercial":
			return "Handel"
		"industrial":
			return "Przemysł"
		"service":
			return "Usługi"
		_:
			return "Inne"
