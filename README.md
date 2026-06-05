# Proiect ALU (Unitate Aritmetică Logică) pe 8 biți

Acest repository conține proiectarea și implementarea în **Verilog** a unei Unități Aritmetice Logice (ALU). Proiectul este organizat structural și verificat prin simulare.

## Cerințele Proiectului

Conform specificațiilor, acest ALU implementează următoarele 9 funcții:

1. **Adunare** (Addition)
2. **Scădere** (Subtraction)
3. **Înmulțire** (Multiplication) - *implementată folosind algoritmul Booth*
4. **Împărțire** (Division) - *implementată folosind algoritmul SRT-2*
5. **AND** (ȘI logic)
6. **OR** (SAU logic)
7. **XOR** (SAU exclusiv)
8. **LEFT SHIFT** (Deplasare la stânga)
9. **RIGHT SHIFT** (Deplasare la dreapta)

### Semnale de Intrare și Ieșire

ALU-ul este prevăzut cu următoarele porturi:

* **Operanzi de intrare:** Doi operanzi pe 8 biți (`A` și `B`) care furnizează valorile ce urmează a fi procesate.
* **Semnale de control:** Folosite pentru a selecta operația pe care ALU-ul trebuie să o execute (selector de operație, semnal de start).
* **Rezultat:** Un semnal de ieșire pe 8 biți (`Result`) care reprezintă rezultatul operației selectate *(suplimentat cu `Result_High` pentru restul de la împărțire și partea superioară a produsului).*
* **Flag-uri (Indicatori de stare):**
  * **Zero (Z):** Setat pe 1 dacă rezultatul operației este zero.
  * **Negativ (N):** Setat pe 1 dacă rezultatul este negativ (cel mai semnificativ bit = 1).
  * **Overflow / Depășire (V):** Setat pe 1 dacă apare o depășire aritmetică într-o operație cu semn.

---

## Validare și Simulare (Testbench)

Sistemul a fost simulat și validat cu succes în ModelSim. Toate operațiile matematice, logice și flag-urile se actualizează corect.

<img width="1509" height="802" alt="TESTBENCHalu" src="https://github.com/user-attachments/assets/f6487815-5b46-4d0b-85aa-40dddeb038e1" />

### Analiza Formelor de Undă (Simulation Waveforms)

Imaginea de mai sus prezintă rezultatele simulării (Testbench-ului) la nivel de Top-Module, realizate în ModelSim. Semnalele au fost formatate în **Zecimal cu Semn (Signed Decimal)** pentru o verificare directă și ușoară a corectitudinii matematice.

Se pot observa clar următoarele 10 secvențe de test, validând toate operațiile instrucțiunilor:

* **1. Adunare (`sel = 0`):** Operanzii `A = 45` și `B = 5` generează corect rezultatul `Result = 50`.
* **2. Scădere (`sel = 1`):** `A = 10` minus `B = 15` generează rezultatul `-5`. Se observă cum flag-ul **N (Negative)** este ridicat automat la `1`.
* **3. Înmulțire Booth (`sel = 2`):** `A = 7` înmulțit cu `B = -3` generează rezultatul `-21`.
* **4. Împărțire SRT-2 (`sel = 3`):** Împărțirea `100 / 3` generează corect câtul `33` (pe semnalul `Result`) și restul `1` (pe semnalul `Result_High`).
* **5. ȘI Logic / AND (`sel = 4`):** Operanzii sunt `0xAA` (afișat ca `-86`) și `0xF0` (afișat ca `-16`). Rezultatul operației la nivel de bit este `0xA0` (afișat corect ca `-96` în signed decimal).
* **6. SAU Logic / OR (`sel = 5`):** Operanzii sunt `0x55` (afișat ca `85`) și `0xF0` (afișat ca `-16`). Rezultatul operației la nivel de bit este `0xF5` (afișat corect ca `-11`).
* **7. SAU Exclusiv / XOR (`sel = 6`):** Operanzii sunt `0xAA` (afișat ca `-86`) și `0x55` (afișat ca `85`). Rezultatul operației este `0xFF`, adică toți biții sunt 1 (afișat corect ca `-1` în format cu semn).
* **8. Deplasare la stânga / SHIFT LEFT (`sel = 7`):** Operația de deplasare la stânga (`A = 1` shiftat cu `3` poziții date de B) returnează corect `8`.
* **9. Deplasare la dreapta / SHIFT RIGHT (`sel = 8`):** Operația de deplasare la dreapta (`A = 16` shiftat cu `2` poziții date de B) returnează corect `4`.
* **10. Detectarea Depășirii / OVERFLOW (`sel = 0`):** La ultimul test, adunarea `120 + 10` depășește limita maximă pozitivă pentru reprezentarea pe 8 biți cu semn (+127). Rezultatul pe 8 biți dă peste cap, afișând `-126`, moment în care flag-ul **V (Overflow)** este ridicat corect la `1` pentru a semnala eroarea aritmetică.



