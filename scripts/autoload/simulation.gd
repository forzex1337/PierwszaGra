extends Node
## Simulation - symulacja ekonomii miasta
## Zarządza tickami, wzrostem populacji, obliczaniem zasobów

signal tick_processed(tick_number: int)
signal population_grew(amount: int)
signal population_left(amount: int)

# Ustawienia ticków
const TICK_INTERVAL: float = 1.0  # sekunda na tick
var tick_timer: float = 0.0

# Ustawienia symulacji
const POPULATION_GROWTH_RATE: float = 0.1  # procent wolnej pojemności
const POPULATION_LEAVE_RATE: float = 0.05  # gdy happiness < 30
const MIN_HAPPINESS_THRESHOLD: float = 30.0
const HAPPINESS_JOB_RATIO: float = 0.8  # min jobs/population dla pełnego happiness

# Całkowity upkeep budynków (aktualizowany co tick)
var total_upkeep: int = 0

func _ready() -> void:
	print("Simulation: Initialized")

func _process(delta: float) -> void:
	if GameManager.is_paused:
		return

	tick_timer += delta
	if tick_timer >= TICK_INTERVAL:
		tick_timer -= TICK_INTERVAL
		process_tick()

func process_tick() -> void:
	GameManager.game_time += 1

	# 1. Zbierz dane z budynków
	recalculate_capacities()

	# 2. Oblicz happiness
	calculate_happiness()

	# 3. Wzrost/spadek populacji
	update_population()

	# 4. Ekonomia - dochód i koszty
	process_economy()

	tick_processed.emit(GameManager.game_time)

func recalculate_capacities() -> void:
	var pop_cap := 0
	var jobs_cap := 0
	var happiness_bonus := 0.0
	var upkeep := 0

	for building in GridManager.get_all_buildings():
		if not building or not building.is_connected_to_road:
			continue

		var data: Resource = building.building_data
		if not data:
			continue

		pop_cap += data.population_capacity
		jobs_cap += data.jobs_capacity
		happiness_bonus += data.happiness_bonus
		upkeep += data.upkeep

	GameManager.population_capacity = pop_cap
	GameManager.jobs_capacity = jobs_cap
	GameManager.happiness_bonus = happiness_bonus
	total_upkeep = upkeep

func calculate_happiness() -> void:
	var base := GameManager.BASE_HAPPINESS

	# Bonus z budynków (usługi)
	var building_bonus := GameManager.happiness_bonus

	# Modyfikator z pracy (jeśli mało pracy, ludzie niezadowoleni)
	var job_modifier := 0.0
	if GameManager.population > 0:
		var job_ratio := float(GameManager.jobs) / float(GameManager.population)
		if job_ratio < HAPPINESS_JOB_RATIO:
			# Brak pracy = spadek happiness
			job_modifier = -20.0 * (1.0 - job_ratio / HAPPINESS_JOB_RATIO)

	GameManager.happiness = base + building_bonus + job_modifier

func update_population() -> void:
	var current_pop := GameManager.population
	var capacity := GameManager.population_capacity
	var happiness := GameManager.happiness

	# Sprawdź czy ludzie odchodzą (niskie happiness)
	if happiness < MIN_HAPPINESS_THRESHOLD and current_pop > 0:
		var leave_amount := maxi(1, int(current_pop * POPULATION_LEAVE_RATE))
		GameManager.population -= leave_amount
		population_left.emit(leave_amount)
		return

	# Sprawdź czy jest miejsce na wzrost
	var free_capacity := capacity - current_pop
	if free_capacity <= 0:
		return

	# Sprawdź czy są miejsca pracy
	var available_jobs := GameManager.jobs_capacity
	if available_jobs <= current_pop:
		# Bez pracy wolniejszy wzrost
		free_capacity = int(free_capacity * 0.2)

	# Wzrost populacji
	if free_capacity > 0 and happiness >= MIN_HAPPINESS_THRESHOLD:
		var growth := maxi(1, int(free_capacity * POPULATION_GROWTH_RATE))
		GameManager.population += growth
		GameManager.jobs = mini(GameManager.population, GameManager.jobs_capacity)
		population_grew.emit(growth)

func process_economy() -> void:
	# Dochód
	var income := GameManager.calculate_income()

	# Koszty utrzymania
	var upkeep := total_upkeep

	# Bilans
	var balance := income - upkeep
	GameManager.money += balance

	# Game over check
	if GameManager.money <= 0 and total_upkeep > 0:
		# Daj szansę - nie game over od razu
		pass

# Funkcje pomocnicze do debugowania
func get_debug_info() -> Dictionary:
	return {
		"tick": GameManager.game_time,
		"money": GameManager.money,
		"population": GameManager.population,
		"population_capacity": GameManager.population_capacity,
		"jobs": GameManager.jobs,
		"jobs_capacity": GameManager.jobs_capacity,
		"happiness": GameManager.happiness,
		"upkeep": total_upkeep,
		"income": GameManager.calculate_income()
	}
