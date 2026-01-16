# GridTopia - Roadmapa Projektu

Izometryczna gra budowania miasta na mobile w Godot 4.x

---

## Status Projektu

| Etap | Nazwa | Status |
|------|-------|--------|
| 0-1 | Fundamenty projektu | ✅ Ukończone |
| 2 | Mapa i budowanie na gridzie | ✅ Ukończone |
| 3 | Sterowanie mobilne | ✅ Ukończone |
| 4 | Symulacja tick + ekonomia | ✅ Ukończone |
| 5 | Połączenia i sens dróg | ✅ Ukończone |
| 6 | UI/UX i pętla rozgrywki | ✅ Ukończone (podstawy) |
| 7 | Zapisywanie gry | ✅ Ukończone |
| 8 | Balans + content | 🔲 Do zrobienia |
| 9 | Optymalizacja i build mobilny | 🔲 Do zrobienia |

---

## Założenia MVP

- Widok 2D izometryczny, mapa na gridzie 32x32
- Budowanie: droga + 3 typy budynków (dom, fabryka, sklep)
- Ekonomia: kasa, dochód/cost co tick (1 sekunda)
- Zadowolenie (happiness) i limit populacji
- Mobile: pan + zoom + tap i UI

---

## Etap 0-1 — Fundamenty projektu ✅

### Co zostało stworzone:

#### Struktura folderów
```
PierwszaGra/
├── project.godot
├── icon.svg
├── scenes/
├── scripts/
│   ├── autoload/
│   ├── resources/
│   └── ui/
└── resources/
    └── buildings/
```

#### Autoloady (Singletony)
| Plik | Opis |
|------|------|
| `game_manager.gd` | Zarządzanie zasobami gracza (money, population, jobs, happiness) |
| `grid_manager.gd` | Konwersje world↔grid, sprawdzanie zajętości pól |
| `build_system.gd` | Tryb budowy, walidacja, placement budynków |
| `simulation.gd` | Tick ekonomii, wzrost populacji, obliczanie zasobów |
| `save_system.gd` | Zapis/odczyt gry do JSON |

#### BuildingData Resource
Plik: `scripts/resources/building_data.gd`

Właściwości:
- `id` - identyfikator budynku
- `display_name` - nazwa wyświetlana
- `description` - opis
- `building_type` - typ (road/residential/commercial/industrial/service)
- `footprint` - rozmiar na gridzie (Vector2i)
- `cost` - koszt budowy
- `upkeep` - koszt utrzymania na tick
- `population_capacity` - ile osób może mieszkać
- `jobs_capacity` - ile miejsc pracy
- `happiness_bonus` - bonus do zadowolenia
- `requires_road` - czy wymaga drogi obok

---

## Etap 2 — Mapa i budowanie na gridzie ✅

### Co zostało stworzone:

#### Siatka izometryczna
- Rozmiar: 32x32 pól
- Rozmiar pola: 128x64 pikseli
- Transformacje izometryczne w `GridManager`

#### System budowania
- Kursor budowy z podświetlaniem
- Walidacja: granice mapy, wolne pole, czy stać, czy jest droga
- Placement przez tap
- Wyburzanie z 50% zwrotem kosztów

#### Budynki startowe

| ID | Nazwa | Koszt | Utrzymanie | Efekty |
|----|-------|-------|------------|--------|
| `road` | Droga | $10 | $0 | Łączy budynki |
| `house` | Dom | $500 | $5 | +4 populacji |
| `factory` | Fabryka | $2000 | $30 | +20 pracy, -5 happiness |
| `shop` | Sklep | $800 | $15 | +5 pracy, +10 happiness |

---

## Etap 3 — Sterowanie mobilne ✅

### Co zostało stworzone:

#### Kamera (`game.gd`)
- **1 palec**: pan (przesuwanie mapy)
- **2 palce**: pinch zoom
- **Scroll myszy**: zoom (dla testów na PC)
- Limity zoom: 0.5x - 2.0x
- Ograniczenie kamery do granic mapy

#### Blokada budowy na UI
- Tap na UI nie stawia budynku pod spodem

---

## Etap 4 — Symulacja tick + ekonomia ✅

### Co zostało stworzone:

#### Zegar symulacji (`simulation.gd`)
- Tick co 1 sekundę
- Przeliczanie pojemności z budynków
- Obliczanie happiness
- Wzrost/spadek populacji
- Ekonomia (dochód - koszty)

#### Zasady ekonomii

```
Dochód = min(Population, Jobs) × 10 (tax per worker)
Koszty = suma upkeep wszystkich budynków
Bilans = Dochód - Koszty
```

#### Wzrost populacji
- Rośnie jeśli: jest wolna pojemność w domach + happiness >= 30%
- Szybkość: 10% wolnej pojemności na tick
- Wolniejszy wzrost bez wystarczającej pracy

#### Happiness
```
Happiness = 50 (base) + bonus z budynków + modyfikator pracy
```
- Brak pracy = spadek happiness (do -20%)
- Happiness < 30% = ludzie odchodzą (5% na tick)

---

## Etap 5 — Połączenia i sens dróg ✅

### Co zostało stworzone:

#### System połączeń (`building.gd`)
- Budynek działa tylko jeśli sąsiaduje z drogą
- Czerwony wskaźnik na niepodłączonych budynkach
- Drogi są zawsze "podłączone"

#### Walidacja budowania
- Nie można postawić budynku (oprócz drogi) bez sąsiadującej drogi

---

## Etap 6 — UI/UX ✅

### Co zostało stworzone:

#### HUD (`ui/hud.gd`)
- Wyświetlanie: Kasa, Populacja, Praca, Happiness
- Format: aktualna/pojemność
- Kolorowanie happiness (zielony/żółty/czerwony)

#### Menu budowy (`ui/build_menu.gd`)
- Lista budynków z cenami
- Przycisk wyburzania
- Blokada przycisków gdy brak kasy

#### Panel informacji (`ui/building_info.gd`)
- Nazwa i opis budynku
- Statystyki (mieszkańcy, praca, happiness, utrzymanie)
- Status połączenia z drogą
- Przycisk wyburzania

#### Komunikaty (`ui/message_popup.gd`)
- "Brak pieniędzy"
- "Brak drogi obok"
- "Poza granicami mapy"

---

## Etap 7 — Zapisywanie gry ✅

### Co zostało stworzone:

#### SaveSystem (`save_system.gd`)
- Zapis do JSON: `user://savegame.json`
- Auto-save co 60 sekund
- Ręczny zapis/odczyt

#### Format zapisu
```json
{
  "version": 1,
  "timestamp": 1234567890,
  "game_manager": {
    "money": 10000,
    "population": 50,
    "jobs": 30,
    "happiness": 65.0,
    "game_time": 120
  },
  "grid_manager": {
    "buildings": [
      {"id": "road", "grid_x": 5, "grid_y": 5},
      {"id": "house", "grid_x": 6, "grid_y": 5}
    ]
  }
}
```

---

## Etap 8 — Balans + content 🔲 DO ZROBIENIA

### Planowane:

#### Nowe budynki
| ID | Nazwa | Koszt | Efekty |
|----|-------|-------|--------|
| `apartment` | Blok mieszkalny | $2000 | +16 populacji, 2x2 |
| `office` | Biurowiec | $3000 | +30 pracy, 2x2 |
| `park` | Park | $500 | +15 happiness |
| `school` | Szkoła | $1500 | +5 happiness, wymaga 50 pop |
| `hospital` | Szpital | $3000 | +20 happiness, wymaga 100 pop |
| `power_plant` | Elektrownia | $5000 | Wymagana dla przemysłu |

#### Problemy do rozwiązania
- Odpływ populacji gdy happiness < 30%
- Brak prądu = budynki offline
- Zanieczyszczenie od fabryk

#### Cele/wyzwania
- "Osiągnij 100 populacji"
- "Utrzymaj happiness > 60% przez 5 minut"
- "Zbuduj 10 domów"
- Odblokowanie budynków przy progach populacji

---

## Etap 9 — Optymalizacja i build mobilny 🔲 DO ZROBIENIA

### Planowane:

#### Optymalizacja
- [ ] Ograniczenie update'ów per tick
- [ ] Chunkowanie mapy (tylko przeliczaj zmienione obszary)
- [ ] Object pooling dla budynków
- [ ] LOD dla oddalonych budynków

#### Mobile build
- [ ] Test na Android
- [ ] Test na iOS
- [ ] Skalowanie UI dla różnych rozdzielczości
- [ ] Obsługa notch/safe area
- [ ] Optymalizacja baterii

#### Docelowe platformy
- Android 8.0+ (API 26)
- iOS 13+

---

## Architektura systemu

```
┌─────────────────────────────────────────────────────┐
│                      Main                            │
│  (Kontroler główny - łączy Game i UI)               │
└─────────────────────┬───────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             │             ▼
┌───────────────┐     │     ┌───────────────┐
│     Game      │     │     │      UI       │
│ (Mapa+Kamera) │     │     │ (HUD+Menu)    │
└───────────────┘     │     └───────────────┘
                      │
    ┌─────────────────┼─────────────────┐
    ▼                 ▼                 ▼
┌─────────┐    ┌───────────┐    ┌─────────────┐
│GridMgr  │    │BuildSystem│    │ Simulation  │
│(Siatka) │    │(Budowanie)│    │ (Ekonomia)  │
└─────────┘    └───────────┘    └─────────────┘
    │                 │                 │
    └─────────────────┼─────────────────┘
                      ▼
              ┌───────────────┐
              │  GameManager  │
              │  (Zasoby)     │
              └───────────────┘
                      │
                      ▼
              ┌───────────────┐
              │  SaveSystem   │
              │  (Zapis)      │
              └───────────────┘
```

---

## Pliki projektu

### Sceny (.tscn)
| Plik | Opis |
|------|------|
| `scenes/main.tscn` | Główna scena gry |
| `scenes/game.tscn` | Mapa, kamera, grid overlay |
| `scenes/ui.tscn` | HUD, menu budowy, panele |
| `scenes/building.tscn` | Pojedynczy budynek |

### Skrypty (.gd)
| Plik | Opis |
|------|------|
| `scripts/main.gd` | Kontroler główny |
| `scripts/game.gd` | Sterowanie kamerą, obsługa tap |
| `scripts/building.gd` | Logika budynku |
| `scripts/grid_overlay.gd` | Rysowanie siatki |
| `scripts/autoload/game_manager.gd` | Zasoby gracza |
| `scripts/autoload/grid_manager.gd` | Zarządzanie gridem |
| `scripts/autoload/build_system.gd` | System budowania |
| `scripts/autoload/simulation.gd` | Symulacja ekonomii |
| `scripts/autoload/save_system.gd` | Zapis/odczyt |
| `scripts/resources/building_data.gd` | Klasa BuildingData |
| `scripts/ui/hud.gd` | Wyświetlanie zasobów |
| `scripts/ui/build_menu.gd` | Menu budynków |
| `scripts/ui/building_info.gd` | Panel info |
| `scripts/ui/message_popup.gd` | Komunikaty |

### Zasoby (.tres)
| Plik | Opis |
|------|------|
| `resources/buildings/road.tres` | Droga |
| `resources/buildings/house.tres` | Dom |
| `resources/buildings/factory.tres` | Fabryka |
| `resources/buildings/shop.tres` | Sklep |

---

## Jak uruchomić

1. Otwórz folder `PierwszaGra` w Godot 4.3+
2. Kliknij "Import" jeśli to pierwszy raz
3. Naciśnij F5 lub przycisk Play
4. Klikaj "BUDUJ" aby otwierać menu budynków
5. Wybierz budynek i tapnij na mapę
6. Używaj myszy/palca do przesuwania i zoomowania

---

## Następne kroki

1. **Grafika** - dodać sprite'y izometryczne zamiast kolorowych prostokątów
2. **Dźwięki** - efekty budowania, tło muzyczne
3. **Więcej budynków** - park, szkoła, szpital, elektrownia
4. **System prądu** - elektrownie i zasięg
5. **Tutorial** - wprowadzenie dla nowych graczy
6. **Cele/osiągnięcia** - motywacja do gry

---

*Ostatnia aktualizacja: Styczeń 2026*
