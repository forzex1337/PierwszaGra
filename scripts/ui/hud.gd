extends Control
## HUD - wyświetla zasoby gracza

@onready var money_label: Label = $TopBar/MoneyLabel
@onready var population_label: Label = $TopBar/PopulationLabel
@onready var jobs_label: Label = $TopBar/JobsLabel
@onready var happiness_label: Label = $TopBar/HappinessLabel

func _ready() -> void:
	# Połącz sygnały
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.population_changed.connect(_on_population_changed)
	GameManager.jobs_changed.connect(_on_jobs_changed)
	GameManager.happiness_changed.connect(_on_happiness_changed)

	# Inicjalizacja
	_update_all()

func _update_all() -> void:
	_on_money_changed(GameManager.money)
	_on_population_changed(GameManager.population)
	_on_jobs_changed(GameManager.jobs)
	_on_happiness_changed(GameManager.happiness)

func _on_money_changed(amount: int) -> void:
	if money_label:
		money_label.text = "$" + _format_number(amount)

func _on_population_changed(amount: int) -> void:
	if population_label:
		var capacity := GameManager.population_capacity
		population_label.text = str(amount) + "/" + str(capacity)

func _on_jobs_changed(amount: int) -> void:
	if jobs_label:
		var capacity := GameManager.jobs_capacity
		jobs_label.text = str(amount) + "/" + str(capacity)

func _on_happiness_changed(amount: float) -> void:
	if happiness_label:
		happiness_label.text = str(int(amount)) + "%"
		# Kolor w zależności od poziomu
		if amount >= 70:
			happiness_label.add_theme_color_override("font_color", Color.GREEN)
		elif amount >= 40:
			happiness_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			happiness_label.add_theme_color_override("font_color", Color.RED)

func _format_number(num: int) -> String:
	if num >= 1000000:
		return str(num / 1000000) + "M"
	elif num >= 1000:
		return str(num / 1000) + "K"
	return str(num)
