# WD33C93 Processor Access & DMA Timing Reference

This document defines and compares host-side timing for:

* **WD33C93A**
* **WD33C93B**

Covered:

1. Overall Summary
2. Processor Indirect Transfers
3. DMA Transfers
4. References

---

# 1. Overall Summary

The WD33C93A and WD33C93B share an identical processor interface architecture.
The WD33C93B improves DMA performance and supports a higher clock rate.


## Key Timing Differences: WD33C93A vs WD33C93B

| Category                                  | WD33C93A                 | WD33C93B                              | Short Description                                                |
| ----------------------------------------- | ------------------------ | ------------------------------------- | ---------------------------------------------------------------- |
| **Maximum Clock**                         | 16 MHz (62.5 ns)         | 20 MHz (50 ns)                        | B supports higher operating frequency.                           |
| **Processor Read Access (tRLDV)**         | 180 ns                   | 162 ns                                | B provides valid read data sooner.                               |
| **Negative Hold-Time Support**            | Not allowed (0 ns min)   | −5 ns allowed on some control timings | B tolerates slight signal overlap.                               |
| **tDHQL (DACK- high → DRQ- low)**         | 30 ns                    | 0 ns                                  | B allows immediate DRQ release.                                  |
| **tRHDL (RE- high → DRQ- low, DMA Read)** | 100 ns specified         | Not specified                         | A guarantees a DRQ drop delay; B omits this constraint.          |
| **Overall Characterisation**              | Original timing baseline | Speed-optimised revision              | Designing to A timings ensures compatibility with both variants. |


**General Characterisation**

  * WD33C93B is a speed-optimised revision of the A.
  * Using A-variant timing values guarantees compatibility with both devices.
  * Note: Amiga 3000 uses a Frequency of 14.18758 MHz with a time period of 70.4841841 ns for PAL. NTSC is 14.31815 MHZ / 69.8414250 ns 
---

# 2. Processor Indirect Transfers

Indirect mode:

* `ALE` grounded
* `A0=0` loads ADDRESS register
* `A0=1` accesses selected register

---

## 2.1 Processor Indirect Write

**References:**
- [1] (9.1.3)
- [2] (6.1.3) 

### Timing Diagram (Symbol Annotated)

```wavedrom
{
  "signal": [
    { "name": "A0",      "wave": "x3......x3..",	"node": ".a......i...", "data": ["ADDRESS VALID"] },
    { "name": "<o>CS",   "wave": "1.0.....1.0.",	"node": "..b.....h..." },
    { "name": "<o>WE",   "wave": "1..0.1.....0",  "node": "...c.f.....j" },
    { "name": "D[7:0]",  "wave": "x...5.x.....",  "node": "....d.g.....", "data": ["DATA VALID"] }
  ],
  "edge": [
    "a|-c tAVWL",
    "b~c tCLWL",
    "c<->f tWE",
    "d~f tDVWH",
    "f|-i tWHAI",
    "f~h tWHCH",
    "f~g tWHDI",
    "f<->j tWHWL"
  ],
  "config": { "hscale": 2 }
}
```
### Timing Parameters

| Symbol | Description              | WD33C93A (ns) | WD33C93B (ns) |
| ------ | ------------------------ | ------------- | ------------- |
| tAVWL  | A0 valid → WE low        | 0             | 0             |
| tCLWL  | CS low → WE low          | 0             | 0             |
| tWE    | CS low, WE low time      | 120           | 120           |
| tDVWH  | Data valid → WE high     | 70            | 70            |
| tWHAI  | WE high → A0 invalid     | 0             | 0             |
| tWHCH  | WE high → CS high        | **0**         | **-5**        |
| tWHDI  | WE high → Data invalid   | 0             | 0             |
| tWHWL  | WE high → next WE/RE low | 100           | 100           |

✅ Interpretation / Compatibility note

- The only A vs B difference here is tWHCH: A specifies 0 ns minimum, B specifies -5 ns minimum.
- Practically: B allows CS to rise slightly before WE rises (relative min), while A does not claim that allowance.
- For safest compatibility, keep CS deassertion aligned after WE deassertion.

#### ideal timing that satisfys both variants

1. A0, CS and WE are asserted at the same time to start the cycle.
2. Data becomes valid a maximum of 50 ns after cycle start.
3. 70ns later both CS and WE are negated.
4. Wait of 100ns till cycle ends.

```wavedrom
{
  "head":{
      text:'Processor Indirect Write',
      tick:-1,
      every:1
  },
  "signal": [
      { "name": "CLK",      "wave": "p........................", node:"ab"},
      { "name": "A0",      "wave": "x3...........x.........3.", "data": ["ADDRESS VALID"] },
      { "name": "<o>CS",   "wave": "10...........1.........0." },
      { "name": "<o>WE",   "wave": "10...........1.........0." },
      { "name": "D[7:0]",  "wave": "x.....5......x...........","data": ["DATA VALID"] }
  ],
  "edge": [
    "a<->b T"
  ],
  "config": { "hscale": 1 },
  "foot":{
    text: 'Ideal timing T = 10 ns'
  },
}
```

---

## 2.2 Processor Indirect Read

**References:**
- [1] (9.1.4) 
- [2] (6.1.4) 

### Timing Diagram (Symbol Annotated)

```wavedrom
{
  "signal": [
    { "name": "A0",      "wave": "x3.....x3..",	"node": ".a.....i...", "data": ["ADDRESS VALID"] },
    { "name": "<o>CS",  "wave": "1.0....1.0.", "node": "..b....f." },
    { "name": "<o>RE",  "wave": "1..0..1...0", "node": "...c..e...h" },
    { "name": "D[7:0]",  "wave": "x...5..x...", "node": "....d..g", "data": ["DATA VALID"] }
  ],
  "edge": [
    "a|-c tAVRL",
    "b~c tCLRL",
    "c<->e tRE",
    "c~d tRLDV",
    "e~f tRHCH",
    "e~g tRHDI",
    "e<->h tRHRL",
    "e|-i tRHAI"     
    
    
  ],
  "config": { "hscale": 2 }
}
```

### Timing Parameters

| Symbol | Description              | WD33C93A (ns) | WD33C93B (ns) |
| ------ | ------------------------ | ------------- | ------------- |
| tAVRL  | A0 valid → RE low        | 0             | 0             |
| tCLRL  | CS low → RE low          | 0             | 0             |
| tRE    | CS low, RE low time      | 180–10000     | 180–10000     |
| tRLDV  | RE low → Data valid      | **180**       | **162**       |
| tRHCH  | RE high → CS high        | **0**         | **-5**        |
| tRHDI  | RE high → Data invalid   | **10–40**     | **5–40**      |
| tRHRL  | RE high → next RE/WE low | 100           | 100           |
| tRHAI  | RE high → A0 invalid     | 0             | 0             |

✅ Interpretation / Compatibility note

- B is faster for data access: tRLDV 162 ns vs A 180 ns.
- B allows earlier CS deassertion relative to RE deassertion (tRHCH -5 ns) whereas A uses 0 ns minimum.
- B tightens data invalid minimum (5 ns vs A’s 10 ns). If you’re sampling data, rely on tRLDV and hold through RE high.

#### ideal timing that satisfys both variants

1. A0, CS and RE are asserted at the same time to start the cycle.
2. Data becomes valid a maximum of 180 ns after cycle start.
3. 20ns later both CS and RE are negated.
4. Wait of 100ns till cycle ends.

```wavedrom
{
  "head":{
      text:'Processor Indirect Read',
      tick:-1,
      every:1
  },
  "signal": [
      { "name": "CLK",      "wave": "p................................", node:"ab"},
      { "name": "A0",      "wave": "x3...................x.........3.", "data": ["ADDRESS VALID"] },
      { "name": "<o>CS",   "wave": "10...................1.........0." },
      { "name": "<o>RE",   "wave": "10...................1.........0." },
      { "name": "D[7:0]",  "wave": "x..................5..x..........","data": ["DATA VALID"] }
  ],
  "edge": [
    "a<->b T"
  ],
  "config": { "hscale": 1 },
  "foot":{
    text: 'Ideal timing T = 10 ns'
  },
}
```

---

# 3. DMA Transfers

Handshake lines:

* `DRQ-` (Data Request)
* `DACK-` (DMA Acknowledge)
* `RE-` / `WE-` strobes

Interface description: 

---

## 3.1 DMA Write (Host → WD33C93x)

**References:**
- [1] (9.1.7)
- [2] (6.1.7) 

### Timing Diagram (Symbol Annotated)

```wavedrom
{
  "signal": [
    { "name": "<o>DRQ",  "wave": "10..1..0..", "node": ".a..e..i." },
    { "name": "<o>DACK", "wave": "1.0...1.0.", "node": "..b...h." },
    { "name": "<o>WE",   "wave": "1..0.1...0", "node": "...c.f...j" },
    { "name": "D[7:0]",  "wave": "x...5.x...", "node": "....d.g.", "data": ["DATA VALID"] }
  ],
  "edge": [
    "b~c tDLWL",
    "b~e tDLQH",
    "c<->f tWR",
    "f<->j tWHWL",
    "d~f tDVWH",
    "f~h tWHDH",
    "f~g tWHDI",
    "h~i tDHQL"
  ],
  "config": { "hscale": 2 }
}
```

### Timing Parameters

| Symbol    | Description                         | WD33C93A (ns) | WD33C93B (ns) |
| --------- | ----------------------------------- | ------------- | ------------- |
| tDLWL     | DACK- low → WE- low                 | 0             | 0             |
| **tDLQH** | DACK low → DRQ high                 | **40–90**     | **75**        |
| **tWR**   | WE- pulse width                     | **50**        | **50**        |
| tWHWL     | WE- high → WE- low                  | 100           | 100           |
| tDVWH     | Data valid → WE- high               | 25            | 25            |
| tWHDH     | WE- high → DACK- high               | 0             | 0             |
| tWHDI     | WE- high → Data invalid             | 0             | 0             |
| **tDHQL** | DACK- high → DRQ- low               | **30**        | **0**         |


#### ideal timing that satisfys both variants

1. DRQ is asserted, then DACK and WE are asserted at the same time to start the cycle.
2. Data becomes valid a maximum of 25 ns after cycle start.
3. 30ns later both DACK and WE are negated.
4. Wait of 100ns till cycle ends.

```wavedrom
{
  "head":{
      text:'DMA Write (Host to WD33C93x)',
      tick:-1,
      every:1
  },
  "signal": [
      { "name": "CLK",      "wave": "p.................", node:"ab"},
      { "name": "<o>DRQ",   "wave": "10.......1.0......" },
      { "name": "<o>DACK",  "wave": "10....1.........0." },
      { "name": "<o>WE",    "wave": "10....1.........0." },
      { "name": "D[7:0]",   "wave": "x..5..x...........","data": ["DATA VALID"] }
  ],
  "edge": [
    "a<->b T"
  ],
  "config": { "hscale": 1 },
  "foot":{
    text: 'Ideal timing T = 10 ns'
  },
}
```

---

## 3.2 DMA Read (WD33C93x → Host)

**References:**
- [1] (9.1.8)
- [2] (6.1.8) 

### Timing Diagram (Symbol Annotated)

```wavedrom
{
  "signal": [
    { "name": "<o>DRQ",  "wave": "10..1..0..", "node": ".a..e..i." },
    { "name": "<o>DACK", "wave": "1.0...1.0.", "node": "..b...h." },
    { "name": "<o>RE",   "wave": "1..0.1...0", "node": "...c.f...j" },
    { "name": "D[7:0]",  "wave": "x...5.x...", "node": "....d.g.", "data": ["DATA VALID"] }
  ],
  "edge": [
    "b~c tDLRL",
    "b~e tDLQH",
    "c<->f tRD",
    "f<->j tRHRL",
    "c~d tRLDV",
    "f~h tRHDH",
    "f~g tRHDI",
    "e<->i tRHDL",
    "h~i tRHQL",


  ],
  "config": { "hscale": 2 }
}
```

### Timing Parameters

| Symbol | Description            | WD33C93A (ns) | WD33C93B (ns) |
| ------ | ---------------------- | ------------- | ------------- |
| tDLRL  | DACK low → RE low      | 0             | 0             |
| tDLQH  | DACK low → DRQ high    | **40–90**     | **75**        |
| tRD    | RE pulse width         | 80            | 80            |
| tRHRL  | RE high → RE low       | 100           | 100           |
| tRLDV  | RE low → Data valid    | 70            | 70            |
| tRHDH  | RE high → DACK high    | 0             | 0             |
| tRHDI  | RE high → Data invalid | 5–40          | 5–40          |
| tRHDL  | DRQ high → DRQ low     | **100**       | —             |
| tRHQL  | DACK high → DRQ low    | **30**        | **0**         |

#### ideal timing that satisfys both variants

1. DRQ is asserted, then DACK and RE are asserted at the same time to start the cycle.
2. Data becomes valid a maximum of 70 ns after cycle start.
3. 10ns later both DACK and RE are negated.
4. Wait of 100ns till cycle ends.

```wavedrom
{
  "head":{
      text:'DMA Read (WD33C93x to Host)',
      tick:-1,
      every:1
  },
  "signal": [
      { "name": "CLK",      "wave": "p....................", node:"ab"},
      { "name": "<o>DRQ",   "wave": "10.......1.........0." },
      { "name": "<o>DACK",  "wave": "10.......1.........0." },
      { "name": "<o>RE",    "wave": "10.......1.........0." },
      { "name": "D[7:0]",   "wave": "x.......5.x..........","data": ["DATA VALID"] }
  ],
  "edge": [
    "a<->b T"
  ],
  "config": { "hscale": 1 },
  "foot":{
    text: 'Ideal timing T = 10 ns'
  },
}
```

---

## 4. References

[1] Western Digital Corporation, *WD33C93A SCSI Bus Interface Controller*, 
    Document No. WD2088S, September 1988.

[2] Western Digital Corporation, *WD33C93B Enhanced SCSI Bus Interface Controller*, 
    Advance Information, December 10, 1990.
