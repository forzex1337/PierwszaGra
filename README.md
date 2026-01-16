# GridTopia

**Relaksacyjna gra budowania miasta na urządzenia mobilne**

Zbuduj własne miasto od małej wioski do tętniącej życiem metropolii. Zarządzaj przestrzenią, zasobami i mieszkańcami w spokojnym tempie, bez presji czasu.

---

## Wizja gry

GridTopia to **single-player city builder** zaprojektowany z myślą o:
- Krótkich sesjach (5-15 minut)
- Długoterminowej progresji
- Relaksującej rozgrywce bez stresu
- Intuicyjnym sterowaniu dotykowym

**Główny cel:** Gracz buduje i rozwija miasto, dążąc do stabilnego wzrostu populacji i dochodu, utrzymując zadowolenie mieszkańców.

---

## Spis treści

1. [Podstawowe mechaniki](#1-podstawowe-mechaniki)
2. [Mapa i świat](#2-mapa-i-świat)
3. [Sterowanie](#3-sterowanie)
4. [System budowania](#4-system-budowania)
5. [Drogi i połączenia](#5-drogi-i-połączenia)
6. [Budynki](#6-budynki)
7. [Zasoby i ekonomia](#7-zasoby-i-ekonomia)
8. [Symulacja i czas](#8-symulacja-i-czas)
9. [Populacja](#9-populacja)
10. [Zadowolenie](#10-zadowolenie)
11. [Interfejs użytkownika](#11-interfejs-użytkownika)
12. [Progresja i cele](#12-progresja-i-cele)
13. [System zapisu](#13-system-zapisu)
14. [Funkcje dodatkowe](#14-funkcje-dodatkowe)
15. [Plan implementacji](#15-plan-implementacji)

---

## 1. Podstawowe mechaniki

### Pętla rozgrywki
```
Buduj → Obserwuj wzrost → Zarabiaj → Odblokuj → Rozszerzaj → Buduj...
```

### Kluczowe elementy
- **Budowanie** - stawianie budynków i dróg na siatce
- **Zarządzanie** - balansowanie zasobów i potrzeb mieszkańców
- **Rozwój** - odblokowywanie nowych budynków i powiększanie mapy
- **Obserwacja** - patrzenie jak miasto rośnie i żyje

### Charakter
| Cecha | Opis |
|-------|------|
| Tempo | Spokojne, bez presji czasu |
| Sesje | Krótkie (5-15 min) lub długie |
| Trudność | Przystępna, brak "game over" |
| Satysfakcja | Wizualny rozwój miasta |

---

## 2. Mapa i świat

### Siatka (Grid)
- **Typ:** Izometryczna siatka 2D
- **Rozmiar startowy:** 16x16 pól
- **Maksymalny rozmiar:** 64x64 pól (rozszerzany w trakcie gry)
- **Rozmiar pola:** 128x64 pikseli (izometria)

### Stany pola
| Stan | Opis |
|------|------|
| Puste | Można budować |
| Droga | Łączy budynki |
| Budynek | Zajęte przez strukturę |
| Zablokowane | Poza granicami / przeszkoda |

### Rozszerzanie mapy
- Gracz może kupić dodatkowe pola za pieniądze
- Koszt rośnie z każdym rozszerzeniem
- Nowe tereny mogą zawierać przeszkody (skały, woda)

### Typy terenu (Post-MVP)
| Teren | Efekt |
|-------|-------|
| Trawa | Standardowy |
| Woda | Nie można budować, dekoracyjne |
| Skała | Wymaga usunięcia za opłatą |
| Las | Bonus do happiness w okolicy |

---

## 3. Sterowanie

### Nawigacja kamerą
| Gest | Akcja |
|------|-------|
| 1 palec przeciągnięcie | Pan (przesuwanie mapy) |
| 2 palce rozciągnięcie | Zoom in/out |
| 2 palce ściśnięcie | Zoom out/in |
| Podwójne tapnięcie | Reset zoom (opcjonalnie) |

### Interakcja z mapą
| Gest | Akcja |
|------|-------|
| Tap na puste pole | Buduj (w trybie budowy) |
| Tap na budynek | Otwórz inspektor |
| Tap na drogę | Otwórz info o drodze |
| Long press | Tryb usuwania / multi-select |
| Swipe w trybie budowy | Buduj wiele obiektów (drogi) |

### Strefy dotykowe
- **Górna część ekranu:** HUD (nie blokuje mapy)
- **Dolna część ekranu:** Menu budowy (wysuwa się)
- **Środek:** Interakcja z mapą

---

## 4. System budowania

### Tryb budowy
1. Gracz wybiera obiekt z menu
2. Na mapie pojawia się "duch" budynku
3. Duch podąża za palcem gracza
4. Kolor wskazuje możliwość budowy:
   - 🟢 **Zielony** - można zbudować
   - 🔴 **Czerwony** - nie można zbudować
5. Tap potwierdza budowę

### Walidacja budowy
| Warunek | Opis |
|---------|------|
| Wolne pole | Nie nachodzi na inne obiekty |
| W granicach | Nie wykracza poza mapę |
| Stać gracza | Wystarczająco pieniędzy |
| Połączenie | Budynek przy drodze (większość) |
| Wymagania | Spełnione warunki odblokowania |

### Wyburzanie
- Zwraca 50% kosztów budowy
- Natychmiastowe (bez opóźnienia)
- Potwierdzenie przed usunięciem większych budynków

### Tryb "szybkiego budowania" dróg
- Przytrzymaj i przeciągnij aby budować ciąg dróg
- Automatyczne łączenie segmentów

---

## 5. Drogi i połączenia

### Funkcja dróg
- Łączą budynki z siecią miasta
- Budynek bez drogi = **offline** (nie działa)
- Drogi nie mają kosztu utrzymania

### System połączeń
```
[Budynek] ←→ [Droga] ←→ [Droga] ←→ [Centrum/Ratusz]
```

### Typy dróg
| Typ | Koszt | Opis |
|-----|-------|------|
| Ścieżka | $5 | Podstawowa, wolna |
| Droga | $15 | Standardowa |
| Aleja | $50 | Szeroka, bonus do prestiżu |

### Wizualizacja
- Drogi automatycznie łączą się wizualnie (T-skrzyżowania, zakręty)
- Budynki offline mają czerwoną ikonę ostrzeżenia
- Animacja "pulsowania" dla niepodłączonych budynków

---

## 6. Budynki

### Kategorie budynków

#### 🏠 Mieszkalne (Residential)
Zapewniają miejsce do życia dla mieszkańców.

| Budynek | Koszt | Utrzymanie | Mieszkańcy | Rozmiar | Odblokowanie |
|---------|-------|------------|------------|---------|--------------|
| Namiot | $100 | $0 | 2 | 1x1 | Start |
| Domek | $500 | $5 | 4 | 1x1 | Start |
| Dom | $1,200 | $12 | 8 | 2x1 | 20 pop |
| Kamienica | $3,000 | $30 | 20 | 2x2 | 50 pop |
| Blok mieszkalny | $8,000 | $80 | 50 | 2x2 | 150 pop |
| Wieżowiec | $25,000 | $200 | 150 | 3x3 | 500 pop |
| Apartamentowiec lux | $50,000 | $400 | 100 | 2x2 | 1000 pop |

#### 🏭 Praca (Commercial/Industrial)
Tworzą miejsca pracy i generują dochód.

| Budynek | Koszt | Utrzymanie | Praca | Dochód/tick | Rozmiar | Odblokowanie |
|---------|-------|------------|-------|-------------|---------|--------------|
| Stragan | $200 | $5 | 2 | +$5 | 1x1 | Start |
| Sklep | $800 | $15 | 5 | +$15 | 1x1 | Start |
| Warsztat | $1,500 | $25 | 10 | +$30 | 2x1 | 30 pop |
| Fabryka | $5,000 | $60 | 30 | +$100 | 2x2 | 100 pop |
| Biurowiec | $12,000 | $100 | 50 | +$200 | 2x2 | 300 pop |
| Centrum handlowe | $30,000 | $250 | 100 | +$500 | 3x3 | 600 pop |
| Korporacja | $80,000 | $500 | 200 | +$1000 | 3x3 | 1500 pop |

#### 🎭 Usługi (Services)
Zwiększają zadowolenie mieszkańców.

| Budynek | Koszt | Utrzymanie | Happiness | Zasięg | Rozmiar | Odblokowanie |
|---------|-------|------------|-----------|--------|---------|--------------|
| Ławka | $50 | $0 | +1 | 2 pola | 1x1 | Start |
| Fontanna | $300 | $5 | +3 | 3 pola | 1x1 | Start |
| Park | $1,000 | $15 | +8 | 5 pól | 2x2 | 50 pop |
| Plac zabaw | $800 | $10 | +5 | 4 pola | 1x1 | 30 pop |
| Restauracja | $2,000 | $30 | +10 | 4 pola | 1x1 | 100 pop |
| Kino | $5,000 | $50 | +15 | 6 pól | 2x1 | 200 pop |
| Stadion | $20,000 | $150 | +30 | 10 pól | 3x3 | 500 pop |
| Park rozrywki | $50,000 | $300 | +50 | 12 pól | 4x4 | 1000 pop |

#### 🏛️ Publiczne (Public)
Niezbędne do funkcjonowania miasta.

| Budynek | Koszt | Utrzymanie | Efekt | Rozmiar | Odblokowanie |
|---------|-------|------------|-------|---------|--------------|
| Ratusz | $0 | $0 | Centrum miasta (wymagany) | 2x2 | Start |
| Szkoła | $3,000 | $40 | +10% efektywności pracy | 2x2 | 100 pop |
| Szpital | $8,000 | $100 | +15 happiness, -50% spadku pop | 2x2 | 200 pop |
| Komisariat | $4,000 | $50 | +5 happiness w zasięgu | 2x1 | 150 pop |
| Straż pożarna | $3,500 | $45 | Ochrona przed pożarami | 2x1 | 150 pop |
| Biblioteka | $2,000 | $25 | +5 happiness | 1x1 | 80 pop |
| Uniwersytet | $15,000 | $150 | +20% efektywności pracy | 3x3 | 500 pop |

#### ⚡ Infrastruktura (Utilities) - Post-MVP
| Budynek | Koszt | Utrzymanie | Efekt | Zasięg |
|---------|-------|------------|-------|--------|
| Elektrownia węglowa | $10,000 | $100 | Prąd, -5 happiness | 15 pól |
| Elektrownia słoneczna | $20,000 | $50 | Prąd (czysty) | 10 pól |
| Wieża wodna | $5,000 | $30 | Woda | 12 pól |
| Oczyszczalnia | $8,000 | $60 | Usuwa zanieczyszczenie | 8 pól |

#### 🏆 Specjalne (Landmarks)
Unikalne budynki - można zbudować tylko jeden egzemplarz.

| Budynek | Koszt | Efekt | Odblokowanie |
|---------|-------|-------|--------------|
| Pomnik założyciela | $10,000 | +10 happiness globalnie | 200 pop |
| Wieża zegarowa | $25,000 | +5% dochodu globalnie | 500 pop |
| Wielka fontanna | $40,000 | +20 happiness w zasięgu 8 | 800 pop |
| Obelisk | $75,000 | +10% wszystkich bonusów | 1500 pop |
| Pałac kultury | $150,000 | +50 happiness globalnie | 3000 pop |

---

## 7. Zasoby i ekonomia

### Główne zasoby

| Zasób | Ikona | Opis |
|-------|-------|------|
| Pieniądze ($) | 💰 | Waluta do budowy i utrzymania |
| Populacja | 👥 | Aktualna liczba mieszkańców |
| Miejsca pracy | 💼 | Dostępne stanowiska |
| Zadowolenie | 😊 | Globalny wskaźnik 0-100% |

### Ekonomia - wzory

#### Dochód
```
Dochód = (Pracujący × Stawka_podatku) + Suma_dochodu_budynków
Pracujący = min(Populacja, Miejsca_pracy)
Stawka_podatku = $10 (domyślnie)
```

#### Koszty
```
Koszty = Suma_utrzymania_budynków
```

#### Bilans
```
Bilans_na_tick = Dochód - Koszty
```

### System podatkowy (Post-MVP)
| Stawka | Efekt na dochód | Efekt na happiness |
|--------|-----------------|-------------------|
| Niska (5%) | -50% | +10 |
| Średnia (10%) | 0% | 0 |
| Wysoka (15%) | +50% | -10 |
| Ekstremalna (20%) | +100% | -25 |

### Bankructwo
- Gdy pieniądze < 0 przez 5 minut
- Budynki zaczynają się wyłączać
- Brak "game over" - gracz może się odbudować

---

## 8. Symulacja i czas

### Tick system
| Parametr | Wartość |
|----------|---------|
| Bazowy tick | 1 sekunda |
| Aktualizacje per tick | Ekonomia, populacja, happiness |

### Kontrola czasu
| Tryb | Opis |
|------|------|
| ⏸️ Pauza | Czas zatrzymany, można budować |
| ▶️ Normalny | 1x prędkość |
| ⏩ Szybki | 2x prędkość |
| ⏩⏩ Turbo | 4x prędkość |

### Co się dzieje każdego ticka
1. Sprawdzenie połączeń budynków z drogami
2. Obliczenie pojemności (mieszkania, praca)
3. Aktualizacja happiness
4. Wzrost/spadek populacji
5. Naliczenie dochodu i kosztów
6. Sprawdzenie celów/osiągnięć
7. Auto-save (co 60 ticków)

---

## 9. Populacja

### Wzrost populacji
```
Warunki wzrostu:
- Wolne mieszkania > 0
- Miejsca pracy >= Populacja × 0.8
- Happiness >= 30%

Tempo wzrostu = Wolne_mieszkania × 0.1 × Modyfikator_happiness
```

### Spadek populacji
```
Warunki spadku:
- Happiness < 30%
- LUB Bezrobocie > 50%

Tempo spadku = Populacja × 0.05
```

### Modyfikatory wzrostu
| Warunek | Modyfikator |
|---------|-------------|
| Happiness > 80% | ×1.5 |
| Happiness 60-80% | ×1.2 |
| Happiness 40-60% | ×1.0 |
| Happiness 30-40% | ×0.5 |
| Happiness < 30% | ×0 (spadek) |
| Szpital w mieście | ×1.1 |
| Szkoła w mieście | ×1.1 |

---

## 10. Zadowolenie

### Obliczanie happiness
```
Happiness = Baza (50) + Suma_bonusów - Suma_kar

Zakres: 0% - 100%
```

### Czynniki pozytywne
| Czynnik | Bonus |
|---------|-------|
| Budynki usługowe | +X (w zasięgu) |
| Pełne zatrudnienie | +10 |
| Niskie podatki | +10 |
| Budynki specjalne | +X (globalnie) |

### Czynniki negatywne
| Czynnik | Kara |
|---------|------|
| Bezrobocie > 20% | -10 |
| Bezrobocie > 50% | -25 |
| Brak usług | -15 |
| Wysokie podatki | -10 do -25 |
| Zanieczyszczenie | -X (w zasięgu fabryk) |

### Wizualizacja
- Ikona emoji przy HUD: 😄 😊 😐 😟 😢
- Kolor tła HUD zmienia się z happiness
- Budynki w "smutnych" dzielnicach mają szary filtr

---

## 11. Interfejs użytkownika

### HUD (górna część ekranu)
```
┌─────────────────────────────────────────────┐
│ 💰 $12,500  👥 150/200  💼 120  😊 72%  ▶️  │
└─────────────────────────────────────────────┘
```

| Element | Opis |
|---------|------|
| 💰 Pieniądze | Aktualna kasa + trend (↑↓) |
| 👥 Populacja | Aktualna / Maksymalna |
| 💼 Praca | Zajęte miejsca / Dostępne |
| 😊 Happiness | Procent + emoji |
| ▶️ Czas | Przycisk pauzy/prędkości |

### Menu budowy (dolna część ekranu)
```
┌─────────────────────────────────────────────┐
│ [Drogi] [Mieszkalne] [Praca] [Usługi] [Pub] │
├─────────────────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐            │
│ │ 🏠  │ │ 🏢  │ │ 🏭  │ │ ...  │           │
│ │$500 │ │$1.2K│ │$5K  │ │      │           │
│ └─────┘ └─────┘ └─────┘ └─────┘            │
└─────────────────────────────────────────────┘
```

### Inspektor budynku (popup)
```
┌─────────────────────────────────┐
│         🏠 Dom                  │
│    "Mały dom rodzinny"          │
├─────────────────────────────────┤
│ Mieszkańcy: 8                   │
│ Utrzymanie: $12/tick            │
│ Status: ✅ Podłączony           │
├─────────────────────────────────┤
│ [Przenieś]  [Ulepsz]  [Wyburz]  │
└─────────────────────────────────┘
```

### Powiadomienia
- Toast messages dla ważnych wydarzeń
- Ikona dzwonka z licznikiem nieprzeczytanych
- Lista ostatnich wydarzeń w menu

### Tutorial (pierwsza gra)
1. "Witaj w GridTopia! Tapnij aby kontynuować"
2. "To jest twój Ratusz - centrum miasta"
3. "Zbuduj drogę tapując tutaj"
4. "Teraz zbuduj dom przy drodze"
5. "Obserwuj jak mieszkańcy się wprowadzają!"
6. "Buduj więcej i rozwijaj miasto!"

---

## 12. Progresja i cele

### System poziomów miasta
| Poziom | Nazwa | Wymagana pop | Odblokowania |
|--------|-------|--------------|--------------|
| 1 | Obozowisko | 0 | Start |
| 2 | Osada | 20 | Dom, Sklep |
| 3 | Wioska | 50 | Kamienica, Park |
| 4 | Miasteczko | 150 | Fabryka, Szkoła |
| 5 | Miasto | 300 | Biurowiec, Szpital |
| 6 | Duże miasto | 600 | Centrum handlowe |
| 7 | Metropolia | 1000 | Wieżowiec, Landmarks |
| 8 | Megapolis | 2000 | Wszystko |
| 9 | Światowa stolica | 5000 | Prestiżowe budynki |
| 10 | Legenda | 10000 | Złote wersje budynków |

### Cele (Quests)
| Typ | Przykłady |
|-----|-----------|
| Populacja | "Osiągnij 100 mieszkańców" |
| Budynki | "Zbuduj 5 parków" |
| Ekonomia | "Zarabiaj $500/tick" |
| Happiness | "Utrzymaj 80% przez 5 minut" |
| Wyzwania | "Zbuduj miasto bez fabryk" |

### Nagrody za cele
- Pieniądze
- Odblokowanie budynków wcześniej
- Kosmetyczne warianty budynków
- Tytuły ("Ekolog", "Przemysłowiec", "Architekt")

### Osiągnięcia (Achievements)
| Osiągnięcie | Warunek |
|-------------|---------|
| Pierwsze kroki | Zbuduj pierwszy budynek |
| Rozrastamy się | 100 populacji |
| Przemysłowiec | 10 fabryk |
| Zielone miasto | Happiness > 90% |
| Milioner | $100,000 w kasie |
| Urbanista | 500 budynków |
| Legendarne miasto | Poziom 10 |

---

## 13. System zapisu

### Auto-save
- Co 60 sekund
- Przy wyjściu z gry
- Przed ważnymi akcjami

### Format zapisu (JSON)
```json
{
  "version": 2,
  "timestamp": 1705432800,
  "city_name": "Moje Miasto",
  "level": 5,
  "stats": {
    "money": 25000,
    "population": 320,
    "jobs_capacity": 400,
    "happiness": 72.5,
    "total_playtime": 7200
  },
  "map": {
    "size": [32, 32],
    "unlocked_tiles": [[0,0], [0,1], ...]
  },
  "buildings": [
    {"id": "house", "x": 5, "y": 3, "level": 1},
    {"id": "road", "x": 4, "y": 3}
  ],
  "unlocks": ["factory", "park", "school"],
  "achievements": ["first_building", "100_pop"],
  "settings": {
    "music_volume": 0.8,
    "sfx_volume": 1.0
  }
}
```

### Wiele zapisów (Post-MVP)
- 3 sloty zapisu
- Możliwość nazwania miasta
- Podgląd statystyk przed wczytaniem

---

## 14. Funkcje dodatkowe

### MVP (Must Have)
- [x] Siatka izometryczna
- [x] Podstawowe budynki (4 typy)
- [x] System dróg
- [x] Ekonomia (tick-based)
- [x] Sterowanie mobile
- [x] HUD
- [x] Menu budowy
- [x] Zapis gry

### Post-MVP (Should Have)
- [ ] Pełna lista budynków (20+)
- [ ] System poziomów miasta
- [ ] Cele i osiągnięcia
- [ ] Tutorial
- [ ] Rozszerzanie mapy
- [ ] Kontrola prędkości czasu
- [ ] Powiadomienia
- [ ] Dźwięki i muzyka
- [ ] Grafika izometryczna (sprite'y)

### Nice-to-Have (Could Have)
- [ ] System prądu/wody
- [ ] System podatków
- [ ] Zanieczyszczenie
- [ ] Dzień/noc (wizualnie)
- [ ] Statystyki i wykresy
- [ ] Wiele zapisów
- [ ] Różne mapy startowe
- [ ] Sezonowość (śnieg, jesień)
- [ ] Mini-eventy
- [ ] System transportu
- [ ] Chmura (cloud save)

### Future (Won't Have - Yet)
- Multiplayer
- Handel między miastami
- Katastrofy naturalne
- Edytor map
- Mody

---

## 15. Plan implementacji

### Faza 1: Core (Ukończone ✅)
- [x] Projekt Godot 4.x
- [x] Siatka izometryczna
- [x] Sterowanie (pan/zoom)
- [x] Podstawowe budynki
- [x] System dróg
- [x] Ekonomia
- [x] UI podstawowe
- [x] Zapis/odczyt

### Faza 2: Content
- [ ] Dodanie wszystkich budynków z listy
- [ ] System poziomów miasta
- [ ] Odblokowania budynków
- [ ] Cele podstawowe (5-10)
- [ ] Balansowanie ekonomii

### Faza 3: Polish
- [ ] Sprite'y izometryczne
- [ ] Animacje budynków
- [ ] Efekty dźwiękowe
- [ ] Muzyka tła
- [ ] Tutorial
- [ ] Powiadomienia

### Faza 4: Advanced Features
- [ ] Rozszerzanie mapy
- [ ] Kontrola prędkości
- [ ] Statystyki szczegółowe
- [ ] Osiągnięcia
- [ ] System prestiżu

### Faza 5: Release
- [ ] Testy na urządzeniach mobilnych
- [ ] Optymalizacja wydajności
- [ ] Lokalizacja (PL/EN)
- [ ] Build Android
- [ ] Build iOS
- [ ] Publikacja

---

## Podsumowanie

**GridTopia** to gra o budowaniu i obserwowaniu. Gracz nie walczy z czasem ani przeciwnikami - walczy z własnymi ambicjami, próbując zbudować idealne miasto.

Kluczowe filary designu:
1. **Prostota** - łatwe do zrozumienia mechaniki
2. **Satysfakcja** - widoczny postęp i rozwój
3. **Relaks** - brak stresu i presji
4. **Głębia** - długoterminowa progresja dla zaangażowanych graczy

---

*Dokument projektowy GridTopia v1.0*
*Ostatnia aktualizacja: Styczeń 2026*
