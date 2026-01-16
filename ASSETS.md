# GridTopia - Specyfikacja Assetów Graficznych

## Parametry Techniczne Rzutu

### Typ projekcji
- **Nazwa:** Dimetric Projection (potocznie "2:1 Isometric")
- **Proporcja:** 2:1 (szerokość:wysokość)
- **Kąt:** 26.565° (arctan 0.5)
- **NIE jest to:** Prawdziwa izometria (30°)

### Wymiary podstawowego kafelka (tile)
```
Szerokość: 128 px
Wysokość:  64 px
```

### Kształt kafelka podłoża
```
        64px (góra)
         /\
        /  \
       /    \
      /      \    32px (wysokość połowy)
     /        \
    /          \
    \          /
     \        /
      \      /
       \    /
        \  /
         \/
        64px (dół)

Całkowita szerokość: 128px
Całkowita wysokość: 64px
```

### Orientacja osi
```
          N (y-)
           \
            \
             \
    W (x-) ---+--- E (x+)
             /
            /
           /
          S (y+)

Kierunek "kamery": patrzy z południowego-wschodu na północny-zachód
Oświetlenie: z północnego-zachodu (góra-lewo)
```

---

## Wymiary Budynków według Footprint

### 1x1 (jeden kafelek)
```
Podstawa: 128 x 64 px
Maksymalna wysokość sprite'a: 128-192 px (1-3 kafelki w górę)
Zalecana wysokość dla małych budynków: 96-128 px
```

### 2x1 (dwa kafelki szerokości)
```
Podstawa: 192 x 96 px
        (128 + 64) x (64 + 32)
Maksymalna wysokość: 160-224 px
```

### 2x2 (cztery kafelki)
```
Podstawa: 256 x 128 px
        (128 + 128) x (64 + 64)
Maksymalna wysokość: 192-320 px
```

### 3x3 (dziewięć kafelków)
```
Podstawa: 384 x 192 px
Maksymalna wysokość: 256-448 px
```

### 4x4 (szesnaście kafelków)
```
Podstawa: 512 x 256 px
Maksymalna wysokość: 320-512 px
```

---

## Punkt zakotwiczenia (Anchor/Origin)

```
Dla wszystkich sprite'ów:
- Origin X: środek podstawy (50% szerokości)
- Origin Y: dolny róg diamentu (100% wysokości podstawy, NIE sprite'a)

Przykład dla budynku 1x1 o wysokości 128px:
- Sprite size: 128 x 128 px
- Origin: (64, 96) - środek-dół diamentu podstawy
  (96 = 128 - 32, bo dolny róg diamentu jest 32px od dołu sprite'a)
```

---

## Paleta i Styl

### Zalecany styl
- **Pixel art** lub **clean vector**
- **Bez outline** lub cienki outline (1-2px)
- **Flat shading** z subtelnymi gradientami
- **Ciepła, przyjazna paleta** (relaksacyjna gra)

### Oświetlenie
- Źródło światła: góra-lewo (północny-zachód)
- Cienie: prawo-dół (południowy-wschód)
- Kontrast: umiarkowany (nie za ostry)

### Kolory tła/terenu
```
Trawa:      #7EC850 (jasna zieleń)
Trawa cień: #5EAA30 (ciemniejsza zieleń)
Droga:      #8B8680 (szary kamień)
Woda:       #4A90D9 (błękit)
```

---

## Lista Assetów do Wygenerowania

### Tereny (Tiles) - 128x64 px

| ID | Nazwa | Opis | Warianty |
|----|-------|------|----------|
| `tile_grass` | Trawa | Podstawowy teren | 4 (dla urozmaicenia) |
| `tile_water` | Woda | Animowana woda | 4 klatki animacji |
| `tile_rock` | Skała | Przeszkoda | 2 |
| `tile_forest` | Las | Drzewa | 3 |
| `tile_sand` | Piasek | Opcjonalny | 2 |

### Drogi - 128x64 px (podstawa)

| ID | Nazwa | Warianty potrzebne |
|----|-------|-------------------|
| `road_straight` | Prosta | NS, EW (2) |
| `road_corner` | Zakręt | NE, SE, SW, NW (4) |
| `road_t` | T-skrzyżowanie | N, E, S, W (4) |
| `road_cross` | Skrzyżowanie | 1 |
| `road_end` | Koniec | N, E, S, W (4) |
| `path_*` | Ścieżka | Te same co road (15) |
| `avenue_*` | Aleja | Te same co road (15) |

**Łącznie drogi: ~45 sprite'ów**

### Budynki Mieszkalne

| ID | Nazwa | Footprint | Wysokość px | Opis promptu |
|----|-------|-----------|-------------|--------------|
| `tent` | Namiot | 1x1 | 80 | Mały namiot kempingowy, płócienny, brązowo-zielony |
| `cottage` | Domek | 1x1 | 96 | Mały drewniany domek, czerwony dach, komin |
| `house` | Dom | 2x1 | 128 | Rodzinny dom, dwa piętra, ogródek |
| `townhouse` | Kamienica | 2x2 | 192 | 3-4 piętrowa kamienica, pastelowa fasada |
| `apartment` | Blok mieszkalny | 2x2 | 256 | Socjalistyczny blok, szary/beżowy, balkony |
| `skyscraper` | Wieżowiec | 3x3 | 384 | Nowoczesny wieżowiec mieszkalny, szklany |
| `luxury_apt` | Apartamentowiec lux | 2x2 | 224 | Elegancki, biały, nowoczesny, penthouse |

### Budynki Pracy (Handel/Przemysł)

| ID | Nazwa | Footprint | Wysokość px | Opis promptu |
|----|-------|-----------|-------------|--------------|
| `stall` | Stragan | 1x1 | 64 | Drewniany stragan targowy, kolorowy daszek |
| `shop` | Sklep | 1x1 | 96 | Mały sklep spożywczy, witryna, markiza |
| `workshop` | Warsztat | 2x1 | 112 | Warsztat rzemieślniczy, drewno, narzędzia |
| `factory` | Fabryka | 2x2 | 160 | Industrialna fabryka, komin, dym |
| `office` | Biurowiec | 2x2 | 256 | Biurowiec szklano-stalowy, korporacyjny |
| `mall` | Centrum handlowe | 3x3 | 192 | Nowoczesne centrum handlowe, duże okna |
| `corporation` | Korporacja | 3x3 | 384 | Wieżowiec korporacyjny, logo na szczycie |

### Budynki Usługowe

| ID | Nazwa | Footprint | Wysokość px | Opis promptu |
|----|-------|-----------|-------------|--------------|
| `bench` | Ławka | 1x1 | 48 | Parkowa ławka, drewniana, metalowe nogi |
| `fountain` | Fontanna | 1x1 | 80 | Kamienna fontanna, tryskająca woda |
| `park` | Park | 2x2 | 96 | Zielony park, drzewa, ścieżki, ławki |
| `playground` | Plac zabaw | 1x1 | 96 | Huśtawki, zjeżdżalnia, kolorowe |
| `restaurant` | Restauracja | 1x1 | 112 | Restauracja z ogródkiem, parasole |
| `cinema` | Kino | 2x1 | 144 | Kino retro, neon, plakaty filmowe |
| `stadium` | Stadion | 3x3 | 128 | Stadion sportowy, trybuny, boisko |
| `theme_park` | Park rozrywki | 4x4 | 256 | Karuzela, roller coaster, kolorowe |

### Budynki Publiczne

| ID | Nazwa | Footprint | Wysokość px | Opis promptu |
|----|-------|-----------|-------------|--------------|
| `town_hall` | Ratusz | 2x2 | 192 | Klasyczny ratusz, zegar, flaga, kolumny |
| `school` | Szkoła | 2x2 | 144 | Szkoła podstawowa, plac zabaw, żółty autobus |
| `hospital` | Szpital | 2x2 | 192 | Biały szpital, czerwony krzyż, karetka |
| `police` | Komisariat | 2x1 | 128 | Komisariat policji, radiowóz, niebieskie światło |
| `fire_station` | Straż pożarna | 2x1 | 128 | Remiza strażacka, wóz strażacki, czerwony |
| `library` | Biblioteka | 1x1 | 112 | Mała biblioteka, książki w oknach |
| `university` | Uniwersytet | 3x3 | 224 | Kampus uniwersytecki, wieża, studenci |

### Budynki Infrastruktury (Post-MVP)

| ID | Nazwa | Footprint | Wysokość px | Opis promptu |
|----|-------|-----------|-------------|--------------|
| `power_coal` | Elektrownia węglowa | 3x3 | 256 | Elektrownia, kominy, dym, industrialna |
| `power_solar` | Elektrownia słoneczna | 2x2 | 64 | Panele słoneczne, nowoczesna, czysta |
| `water_tower` | Wieża wodna | 1x1 | 160 | Wysoka wieża wodna, zbiornik na górze |
| `sewage` | Oczyszczalnia | 2x2 | 96 | Oczyszczalnia ścieków, zbiorniki, rury |

### Budynki Specjalne (Landmarks)

| ID | Nazwa | Footprint | Wysokość px | Opis promptu |
|----|-------|-----------|-------------|--------------|
| `monument` | Pomnik założyciela | 1x1 | 144 | Posąg na piedestale, brązowy |
| `clock_tower` | Wieża zegarowa | 1x1 | 224 | Wysoka wieża z wielkim zegarem |
| `grand_fountain` | Wielka fontanna | 2x2 | 128 | Monumentalna fontanna, kaskady |
| `obelisk` | Obelisk | 1x1 | 192 | Wysoki obelisk, granitowy |
| `palace` | Pałac kultury | 3x3 | 320 | Pałac w stylu socrealizmu, monumentalny |

---

## Ikony UI - 64x64 px

Każdy budynek potrzebuje ikony do menu budowy:
- Format: 64x64 px, PNG z przezroczystością
- Styl: uproszczona wersja budynku, czytelna w małym rozmiarze
- Tło: przezroczyste lub lekki cień

---

## Efekty i Dekoracje

| ID | Nazwa | Rozmiar | Opis |
|----|-------|---------|------|
| `smoke_1-4` | Dym | 64x128 | Animacja dymu z kominów (4 klatki) |
| `water_splash` | Plusk | 64x64 | Animacja fontanny (4 klatki) |
| `car_1-3` | Samochody | 48x32 | Małe autka na drogach (3 warianty) |
| `tree_1-4` | Drzewa | 64x96 | Pojedyncze drzewa dekoracyjne |
| `bush_1-3` | Krzewy | 32x32 | Małe krzewy |
| `flag` | Flaga | 16x32 | Animowana flaga (4 klatki) |

---

## Wskaźniki Stanu

| ID | Nazwa | Rozmiar | Opis |
|----|-------|---------|------|
| `icon_no_road` | Brak drogi | 32x32 | Czerwony wykrzyknik - budynek offline |
| `icon_no_power` | Brak prądu | 32x32 | Żółta błyskawica |
| `icon_happy` | Zadowolony | 32x32 | Zielona buźka |
| `icon_sad` | Niezadowolony | 32x32 | Czerwona smutna buźka |

---

## Prompt Template dla AI

```
Isometric game asset, dimetric projection 2:1 ratio, 26.5 degree angle,
[NAZWA BUDYNKU], [OPIS],
pixel art style, clean lines, warm color palette,
top-down isometric view from south-east,
lighting from north-west (top-left),
transparent background, game ready sprite,
[SZEROKOŚĆ]x[WYSOKOŚĆ] pixels
```

### Przykładowy prompt dla "Dom":
```
Isometric game asset, dimetric projection 2:1 ratio, 26.5 degree angle,
small family house with red roof and chimney, white walls, small garden,
pixel art style, clean lines, warm color palette,
top-down isometric view from south-east,
lighting from north-west (top-left),
transparent background, game ready sprite,
192x128 pixels, cozy suburban home
```

---

## Podsumowanie Ilościowe

| Kategoria | Ilość assetów |
|-----------|---------------|
| Tereny | ~15 |
| Drogi (3 typy × 15 wariantów) | ~45 |
| Budynki mieszkalne | 7 |
| Budynki pracy | 7 |
| Budynki usługowe | 8 |
| Budynki publiczne | 7 |
| Budynki infrastruktury | 4 |
| Budynki specjalne | 5 |
| Ikony UI | ~38 |
| Efekty/dekoracje | ~20 |
| Wskaźniki | ~4 |
| **ŁĄCZNIE** | **~160 assetów** |

---

## Priorytety Implementacji

### Faza 1 (MVP)
1. `tile_grass` (1 wariant)
2. `road_straight`, `road_corner`, `road_t`, `road_cross`
3. `cottage`, `house`
4. `shop`, `factory`
5. Ikony dla powyższych

### Faza 2 (Content)
1. Pozostałe drogi i ścieżki
2. Wszystkie budynki mieszkalne
3. Wszystkie budynki pracy
4. Budynki usługowe (park, fontanna, restauracja)

### Faza 3 (Polish)
1. Budynki publiczne
2. Warianty terenów
3. Efekty i dekoracje
4. Animacje

### Faza 4 (Advanced)
1. Infrastruktura
2. Landmarks
3. Dodatkowe warianty

---

*Ostatnia aktualizacja: Styczeń 2026*
