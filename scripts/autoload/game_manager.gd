extends Node
## GameManager - główny kontroler stanu gry
## Przechowuje zasoby gracza i zarządza stanem gry

signal money_changed(new_amount: int)
signal population_changed(new_amount: int)
signal jobs_changed(new_amount: int)
signal happiness_changed(new_amount: float)
signal game_over()

# Zasoby gracza
var money: int = 10000:
	set(value):
		money = max(0, value)
		money_changed.emit(money)

var population: int = 0:
	set(value):
		population = max(0, value)
		population_changed.emit(population)

var jobs: int = 0:
	set(value):
		jobs = max(0, value)
		jobs_changed.emit(jobs)

var happiness: float = 50.0:
	set(value):
		happiness = clamp(value, 0.0, 100.0)
		happiness_changed.emit(happiness)

# Pojemności (z budynków)
var population_capacity: int = 0
var jobs_capacity: int = 0
var happiness_bonus: float = 0.0

# Ustawienia ekonomii
const TAX_PER_WORKER: int = 10
const BASE_HAPPINESS: float = 50.0

# Stan gry
var is_paused: bool = false
var game_time: int = 0  # tick counter

func _ready() -> void:
	print("GameManager: Initialized")

func reset_game() -> void:
	money = 10000
	population = 0
	jobs = 0
	happiness = 50.0
	population_capacity = 0
	jobs_capacity = 0
	happiness_bonus = 0.0
	game_time = 0
	is_paused = false

func can_afford(cost: int) -> bool:
	return money >= cost

func spend_money(amount: int) -> bool:
	if can_afford(amount):
		money -= amount
		return true
	return false

func add_money(amount: int) -> void:
	money += amount

func calculate_income() -> int:
	# Dochód = min(populacja, praca) * tax
	var workers := mini(population, jobs)
	return workers * TAX_PER_WORKER

func calculate_upkeep() -> int:
	# Upkeep jest liczony przez Simulation na podstawie budynków
	return 0

func get_save_data() -> Dictionary:
	return {
		"money": money,
		"population": population,
		"jobs": jobs,
		"happiness": happiness,
		"game_time": game_time,
		"population_capacity": population_capacity,
		"jobs_capacity": jobs_capacity,
		"happiness_bonus": happiness_bonus
	}

func load_save_data(data: Dictionary) -> void:
	money = data.get("money", 10000)
	population = data.get("population", 0)
	jobs = data.get("jobs", 0)
	happiness = data.get("happiness", 50.0)
	game_time = data.get("game_time", 0)
	population_capacity = data.get("population_capacity", 0)
	jobs_capacity = data.get("jobs_capacity", 0)
	happiness_bonus = data.get("happiness_bonus", 0.0)
