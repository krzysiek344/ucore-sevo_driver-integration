# ucore - integracja sterownika servo

Repozytorium zawiera integracje sprzetowego sterownika silnika krokowego z mikroprocesorowym SoC opartym o rdzen RISC-V `ucore`. 

## Spis tresci
1. [Opis repozytorium](#1-opis-repozytorium)
   - [Pochodzenie projektu](#pochodzenie-projektu)
2. [Relacja do repozytorium z modulem servo](#2-relacja-do-repozytorium-z-modulem-servo)
3. [Struktura projektu](#3-struktura-projektu)
4. [Architektura integracji](#4-architektura-integracji)
5. [Sterownik hardware servo](#5-sterownik-hardware-servo)
6. [Wrapper magistralowy servo](#6-wrapper-magistralowy-servo)
7. [Integracja z SoC](#7-integracja-z-soc)
8. [Sterownik software](#8-sterownik-software)
9. [Aplikacja demonstracyjna UART](#9-aplikacja-demonstracyjna-uart)
10. [Integracja z FPGA Basys3](#10-integracja-z-fpga-basys3)
11. [Testy](#11-testy)
12. [Narzędzia i uruchamianie](#12-narzedzia-i-uruchamianie)
13. [Generowanie bitstreamu](#13-generowanie-bitstreamu)
14. [Podlaczenie hardware](#14-podlaczenie-hardware)
15. [Znane ograniczenia](#15-znane-ograniczenia)

## 1. Opis repozytorium

Projekt rozszerza bazowy SoC `ucore` o sprzetowy sterownik silnika krokowego. Sterownik z założenia ma być możliwie samodzielny w celu możliwie dużego odciążenia 'ucore'. Dzięki implementacji sterownika, jesteśmy w stanie sterować silnikiem krokowym równolegle do zadań, które już byliśmy w stanie na tym układzie wykonywać, bez wykorzystania przerwań, które nie są zaimplementowane w tym układzie.

### Pochodzenie projektu

Repozytorium jest forkiem bazowego projektu [`asicsagh/ucore`](https://github.com/asicsagh/ucore), rozwijanego jako mikroprocesorowy SoC RISC-V. Oryginalny projekt zostal przygotowany przez dr. Pawla Skrzypca i stanowi punkt wyjscia dla tej integracji.

Zmiany w tym forku dotycza przede wszystkim dodania sprzetowego sterownika servo/steppera, wrappera memory-mapped, sterownika software, testow oraz integracji z FPGA Basys3.

Glowny przeplyw sterowania:

```text
Host UART -> sw/app -> libsoc/servo -> dbus -> servo.sv -> top_servo_drv -> stepper_phases
                                                            ^
                                                            |
                                                    servo_sensor_raw
```

Dzieki takiemu podzialowi CPU moze obslugiwac komunikacje UART i logike aplikacji, podczas gdy czasowo krytyczne sterowanie silnikiem dziala niezaleznie w hardware.

## 2. Relacja do repozytorium z modulem servo

Sam sterownik servo byl rozwijany w osobnym repozytorium: [servo-hw-driver](https://github.com/krzysiek344/servo-hw-driver). To repozytorium integruje ten sterownik z `ucore` i dodaje warstwy potrzebne do uruchomienia go jako peryferium SoC oraz na plytce Basys3.

## 3. Struktura projektu

Najwazniejsze katalogi:

| Sciezka | Opis |
| --- | --- |
| `hw/rtl/core/` | rdzen RISC-V |
| `hw/rtl/soc/` | SoC, pamieci, GPIO, timer, UART, arbiter magistrali i wrapper servo |
| `hw/rtl/soc/servo_driver/` | wewnetrzne bloki sterownika servo |
| `hw/sim/` | testy symulacyjne Xcelium |
| `hw/fpga/` | top Basys3, constraints XDC i skrypt Vivado |
| `sw/libs/soc/` | biblioteka C do obslugi peryferiow SoC |
| `sw/app/` | główna aplikacja |
| `tools/` | skrypty do symulacji i generowania bitstreamu |

## 4. Architektura integracji

Najwazniejsze warstwy:

1. `top_servo_drv.sv` - czysty sterownik hardware silnika krokowego.
2. `servo.sv` - wrapper rejestrowy zgodny z magistrala `dbus`.
3. `soc.sv` - instancja peryferium servo w SoC.
4. `servo.c` / `servo.h` - API C dla firmware.
5. `main.c` - aplikacja uzytkownika sterowana przez UART.
6. `ucore_basys3.sv` - wyprowadzenie sygnalow servo na piny FPGA.

## 5. Sterownik hardware servo

### `top_servo_drv.sv`

Top driver spina wszystkie bloki wykonawcze sterownika. Przyjmuje sygnaly sterujace `enable`, `callib`, `go_to`, `target_pos`, `scale_val`, `inversion` oraz surowy sygnal czujnika `sensor_raw`. Na wyjsciu wystawia fazy silnika `stepper_phases`, flage `callib_done` i aktualna pozycje `current_pos`.

Parametry:

| Parametr | Domyslnie | Opis |
| --- | --- | --- |
| `POS_RANGE` | `32` | szerokosc rejestrow pozycji |
| `SCALE_WIDTH` | `32` | szerokosc wartosci preskalera |
| `DELAY_CYCLES` | `1000000` | czas stabilizacji wejscia czujnika w debouncerze |
| `COILS_NUM` | `4` | liczba faz silnika |

### `master_fsm.sv`

Glowna maszyna stanow sterownika. Odpowiada za tryby pracy:

- `IDLE` - brak ruchu.
- `CALLIB_FIND` - ruch w kierunku czujnika pozycji zerowej.
- `CALLIB_DONE` - potwierdzenie zakonczenia kalibracji i wyzerowanie pozycji.
- `MOVE_EVALUATE` - wybor kierunku ruchu do pozycji docelowej.
- `MOVE_RUN` - ruch do zadanej pozycji.
- `MOVE_DONE` - zakonczenie ruchu.

Istotne zalozenia:

- `enable = 0` zatrzymuje sterownik i wymusza powrot do `IDLE`.
- Kalibracja moze przerwac trwajacy ruch.
- W trybie kalibracji kierunek jest wymuszony przez FSM.
- `callib_done` dziala jako handshake: FSM czeka, az nadrzedna logika zdejmie sygnal `callib`.

### `prescaler.sv`

Prescaler generuje impuls `step_tick` co `scale_val` cykli zegara, gdy `enable` jest aktywne. Impuls ma szerokosc jednego taktu zegara i steruje wykonaniem pojedynczego kroku przez sekwencer oraz licznik pozycji.

`scale_val` definiuje szybkosc ruchu. Jest to dzielnik zegara. 

### `sequencer.sv`

Sequencer zamienia impulsy `step_tick` na sekwencje faz silnika krokowego. Kierunek przesuwania sekwencji okresla `dir`, a `inversion` pozwala odwrocic poziomy logiczne na wyjsciach.

Wyjscie:

```text
stepper_phases[3:0]
```

jest przeznaczone do sterowania zewnetrznym driverem cewek. Nie nalezy podlaczac cewek silnika bezposrednio do pinow FPGA.

### `step_counter.sv`

Licznik pozycji aktualizuje `current_pos` na podstawie `step_tick` i `dir`. Sygnał `set_zero` zeruje pozycje po zakonczonej kalibracji.

### `debouncer.sv`

Debouncer filtruje surowy sygnal czujnika pozycji `sensor_raw` i wystawia zsynchronizowany sygnal `sensor_clean` dla FSM. Chroni logike przed drganiami stykow oraz przed bezposrednim uzyciem asynchronicznego wejscia w sterowniku.

## 6. Wrapper magistralowy servo

`hw/rtl/soc/servo.sv` opakowuje `top_servo_drv` w peryferium memory-mapped dostepne z poziomu CPU przez `dbus`.

Adres bazowy:

```text
SERVO_BASE_ADDRESS = 0x5000_0000
```

Mapa rejestrow:

| Offset | Rejestr | Dostep | Opis |
| --- | --- | --- | --- |
| `0x000` | `CR` | R/W | rejestr sterujacy |
| `0x004` | `SR` | R | rejestr statusu |
| `0x008` | `TARGET_POS` | R/W | pozycja docelowa |
| `0x00c` | `CURRENT_POS` | R | aktualna pozycja |
| `0x010` | `SCALE` | R/W | wartosc preskalera krokow |

Bity `CR`:

| Bit | Nazwa | Opis |
| --- | --- | --- |
| `0` | `enable` | globalne zezwolenie na prace sterownika |
| `1` | `callib` | rozpoczecie kalibracji |
| `2` | `go_to` | rozpoczecie ruchu do `TARGET_POS` |
| `3` | `inversion` | odwrocenie faz wyjsciowych |

Bity `SR`:

| Bit | Nazwa | Opis |
| --- | --- | --- |
| `0` | `callib_done` | kalibracja zakonczona |
| `1` | `go_to_done` | ruch do pozycji zakonczony |
| `2` | `busy` | trwa kalibracja lub ruch |
| `3` | `sensor_raw` | aktualny surowy stan czujnika |

Wrapper zdejmuje bity `callib` i `go_to` po zakonczeniu odpowiedniej operacji oraz ustawia flagi statusu `callib_done` i `go_to_done`.

## 7. Integracja z SoC

Servo jest dodane do SoC jako osobne peryferium:

- `hw/rtl/soc/memory_map.sv` definiuje zakres `0x5000_0000` - `0x5000_0fff`.
- `hw/rtl/soc/dbus_arbiter.sv` dekoduje adresy i kieruje transakcje do `servo_dbus`.
- `hw/rtl/soc/soc.sv` instancjonuje `servo u_servo`.
- Top SoC ma porty `stepper_phases[3:0]` oraz `servo_sensor_raw`.

W SoC dostepne sa tez pozostale peryferia: `code_rom`, `data_ram`, `gpio`, `timer` i `uart`.

## 8. Sterownik software

Sterownik C znajduje sie w:

```text
sw/libs/soc/include/soc/servo.h
sw/libs/soc/src/servo.c
```

Udostepnione API:

| Funkcja | Opis |
| --- | --- |
| `servo_set_enable(en)` | ustawia bit `enable` w `CR` |
| `servo_set_inversion(inv)` | ustawia bit `inversion` w `CR` |
| `servo_set_scale(val)` | zapisuje `SCALE`, z ograniczeniem minimalnej wartosci do `2` |
| `servo_callib(en)` | ustawia lub zdejmuje bit `callib` |
| `servo_go_to(target_pos)` | zapisuje `TARGET_POS` i ustawia bit `go_to` |
| `servo_get_status()` | odczytuje `SR` |
| `servo_get_current_pos()` | odczytuje `CURRENT_POS` |
| `servo_get_target_pos()` | odczytuje `TARGET_POS` |
| `servo_is_busy()` | sprawdza bit `busy` w `SR` |
| `servo_is_sensor_active()` | sprawdza bit `sensor_raw` w `SR` |

## 9. Aplikacja demonstracyjna UART

Firmware w `sw/app/src/main.c` uruchamia UART, wlacza servo i czeka na tekstowe komendy zakonczone znakiem nowej linii.

Konfiguracja:

```text
Baud rate: 92160
```

Dostepne komendy:

| Komenda | Opis |
| --- | --- |
| `callib` | rozpoczyna kalibracje, jesli servo nie jest zajete |
| `goto <pos>` | rozpoczyna ruch do pozycji `<pos>` |
| `pos?` | odsyla aktualna pozycje |
| `status?` | odsyla `STATUS BUSY` lub `STATUS IDLE` |

Przykladowa sesja:

```text
booted
goto 100
status?
STATUS BUSY
pos?
POS: 42
status?
STATUS IDLE
```

Odczyt UART w aktualnej aplikacji jest blokujacy, ale ruch servo nie jest blokowany przez CPU. Po przyjeciu komendy `goto` lub `callib` sterownik RTL pracuje dalej samodzielnie.

## 10. Integracja z FPGA Basys3

Top FPGA znajduje sie w:

```text
hw/fpga/rtl/ucore_basys3.sv
```

Najwazniejsze polaczenia:

- `refclk` zasila PLL generujacy zegar systemowy.
- `btnC` dziala jako reset zewnetrzny.
- `RsTx` / `RsRx` sa podlaczone do USB-UART Basys3.
- `sw[3:0]` trafia do `gpio_din[3:0]`.
- `stepper_phases[3:0]` wychodzi z SoC na piny FPGA.
- `servo_sensor_raw` wchodzi do SoC jako sygnal czujnika.
- `led[3:0]` pokazuje aktualne `stepper_phases`.
- `led[4]` pokazuje `sw[2]`, a `led[8:5]` pokazuje `sw[3:0]`.

Constraints znajduja sie w:

```text
hw/fpga/constraints/basys3.xdc
```

## 11. Testy

Testy sa uruchamiane przez `tools/sim_runner.sh`. Kazdy test ma katalog w `hw/sim/` oraz plik `commands.tcl`.

### Testy jednostkowe servo

| Test | Sprawdzany blok |
| --- | --- |
| `servo_master_fsm` | stany FSM, kalibracja, ruch, enable |
| `servo_prescaler` | generowanie `step_tick` dla roznych wartosci `scale_val` |
| `servo_sequencer` | sekwencja faz, kierunek i inwersja |
| `servo_step_counter` | licznik pozycji, kierunek, zerowanie |
| `servo_debouncer` | filtracja sygnalu czujnika |
| `servo_top_driver` | wspolpraca FSM, prescalera, sekwencera, licznika i debouncera |

### Testy integracyjne servo

| Test | Opis |
| --- | --- |
| `servo_wrapper` | test `servo.sv` jako peryferium z recznie sterowana magistrala `dbus` |
| `soc_servo` | test calego SoC z firmware wykonujacym ruch servo |
| `fpga_ucore_basys3` | test polaczen topu Basys3 z uproszczonymi stubami PLL i SoC |

### Pozostale testy

Repozytorium zawiera rowniez testy rdzenia i standardowych peryferiow:

- `core_alu`
- `core_cu`
- `core_idu`
- `core_ifu`
- `core_rf`
- `soc_gpio`
- `soc_timer`
- `soc_uart`
- `soc_data_ram`

## 12. Narzedzia i uruchamianie

### Klonowanie repozytorium

```bash
git clone --recursive git@github.com:asicsagh/ucore.git
```

### Inicjalizacja srodowiska

Przed uruchamianiem narzedzi nalezy zaladowac srodowisko:

```bash
. env.sh
```

Skrypt ustawia m.in. `ROOTDIR`, sciezki do toolchaina RISC-V, Xcelium oraz Vivado.

### Lista testow

```bash
sim_runner.sh -l
```

### Uruchomienie pojedynczego testu

Tryb GUI:

```bash
sim_runner.sh -t servo_wrapper
```

Tryb konsolowy:

```bash
sim_runner.sh -ct servo_wrapper
```

### Uruchomienie regresji

```bash
sim_all_sim_runner.sh
```

## 13. Generowanie bitstreamu

Bitstream jest generowany przez:

```bash
fpga_bitstream_generator.sh
```

Skrypt wykonuje:

1. Budowanie firmware w `sw/app`.
2. Wygenerowanie `sw/app/build/app.mem`.
3. Uruchomienie Vivado w `hw/fpga` ze skryptem `ucore.tcl`.
4. Synteze, implementacje i zapis bitstreamu.

Wygenerowany plik `.bit` znajduje sie standardowo tutaj:

```text
hw/fpga/build/ucore.runs/impl_1/ucore_basys3.bit
```

## 14. Podlaczenie hardware

### Servo na PMOD JA

| Sygnal | PMOD | Pin FPGA |
| --- | --- | --- |
| `stepper_phases[0]` | JA1 | `J1` |
| `stepper_phases[1]` | JA2 | `L2` |
| `stepper_phases[2]` | JA3 | `J2` |
| `stepper_phases[3]` | JA4 | `G2` |
| `servo_sensor_raw` | JA7 | `H1` |

### UART

UART zostaje na wbudowanym USB-UART Basys3:

| Sygnal | Pin FPGA |
| --- | --- |
| `RsRx` | `B18` |
| `RsTx` | `A18` |

### Uwagi sprzetowe

- Piny FPGA pracuja w standardzie `LVCMOS33`.
- `stepper_phases` sa sygnalami logicznymi 3.3 V i nie moga bezposrednio zasilac cewek silnika.
- Do sterowania silnikiem wymagany jest zewnetrzny driver cewek.
- Czujnik pozycji powinien wystawiac poziomy logiczne zgodne z 3.3 V.
- Przy zewnetrznym driverze i czujniku nalezy polaczyc wspolna mase z Basys3.

## 15. Znane ograniczenia

- Aktualna aplikacja UART uzywa blokujacego odczytu `uart_read()`.
- Projekt nie korzysta z przerwan; firmware odpytuje peryferia programowo.
- `scale_val` powinien byc wiekszy lub rowny `2`; sterownik C zabezpiecza `servo_set_scale()` przed mniejsza wartoscia.
- Kalibracja zalezy od poprawnego podlaczenia i stabilnosci czujnika pozycji.
- `stepper_phases` wymagaja zewnetrznego stopnia mocy do sterowania rzeczywistym silnikiem.
