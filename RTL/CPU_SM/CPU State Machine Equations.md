# CPU State Machine Equations

These are the equations from the Commodore schematics in the format that can be used in [https://github.com/hneemann/Digital](https://github.com/hneemann/Digital)

## inputs
Input terms for the state machine

```text
let E0 = !( !(!FIFOFULL & FIFOEMPTY & DMADIR & FLUSHFIFO) | !(!cpudff5_q & !cpudff4_q & !cpudff1_q & !cpudff2_q) | !(!cpudff3_q & !LASTWORD & DMAENA & 1) ),
let E1 = (FIFOEMPTY & !DMADIR & !DREQ_ & DMAENA & !cpudff1_q & !cpudff2_q & cpudff5_q & !cpudff4_q), 
let E2 = !( !(DMADIR & !FIFOEMPTY & FLUSHFIFO & DMAENA) | !(!cpudff1_q & !cpudff2_q & !cpudff4_q & cpudff5_q) | cpudff3_q),
let E3 = !( !(DMADIR & LASTWORD & FLUSHFIFO & DMAENA) | (!cpudff1_q & !cpudff2_q & !cpudff4_q & cpudff5_q) | cpudff3_q),
let E4 = !( !( !BOEQ3 & !cpudff1_q & !cpudff3_q & !cpudff5_q) | !(!A1 & CYCLEDONE & !BGRANT_& LASTWORD) | !(!cpudff2_q & cpudff4_q) ),
let E5 = !( !( BOEQ3 & !cpudff1_q & !cpudff3_q & !cpudff5_q) | !(!A1 & CYCLEDONE & !BGRANT_& LASTWORD) | !(!cpudff2_q & cpudff4_q) ),
let E6_d = (!DSACK1_ & cpudff1_q & cpudff2_q & !DSACK0_ & cpudff4_q & !cpudff3_q & cpudff5_q),
let E7 = (DMADIR & FIFOFULL & DMAENA & !cpudff1_q & !cpudff3_q & !cpudff2_q & !cpudff5_q & !cpudff4_q),
let E8 = !( !(!BGRANT_ & !A1 & CYCLEDONE & !cpudff3_q) | !(!cpudff1_q & !cpudff2_q & cpudff4_q & !cpudff5_q) | LASTWORD),
let E9_d = (!DSACK1_ & !DSACK0_ & cpudff1_q & !cpudff3_q &!cpudff4_q & !cpudff5_q), 
let E10 = (CYCLEDONE & A1 & !BGRANT_ & !cpudff1_q & !cpudff3_q & !cpudff2_q & !cpudff5_q & cpudff4_q),
let E11 = (CYCLEDONE & !A1 & !BGRANT_ & !cpudff1_q & !cpudff3_q & cpudff2_q & !cpudff5_q & !cpudff4_q),
let E12 = (CYCLEDONE & A1 & !BGRANT_ & !cpudff1_q & !cpudff3_q & cpudff2_q & !cpudff5_q & !cpudff4_q),
let E13 = (!DMADIR & DMAENA & !cpudff1_q & !cpudff2_q &!cpudff4_q & !cpudff5_q), 
let E14 = (!DMADIR & DREQ_ & !cpudff1_q & !cpudff4_q & cpudff5_q),
let E15 = !( !(!cpudff1_q & !cpudff4_q & cpudff5_q)| FIFOEMPTY | DMADIR ), 
let E16 = (BGRANT_ & !cpudff1_q & cpudff2_q & !cpudff3_q & !cpudff4_q & !cpudff5_q),
let E17 = (!CYCLEDONE & !cpudff1_q & cpudff2_q & !cpudff3_q & !cpudff4_q & !cpudff5_q),
let E18 = (BGRANT_  & !cpudff1_q & !cpudff2_q & !cpudff3_q & cpudff4_q & !cpudff5_q),
let E19 = (!CYCLEDONE & !cpudff1_q & !cpudff2_q & !cpudff3_q & cpudff4_q & !cpudff5_q),
let E20_d = (!DSACK1_ & cpudff1_q & !cpudff2_q & !cpudff3_q & !cpudff4_q & !cpudff5_q),
let E21 = !( !(FIFOEMPTY & LASTWORD & BOEQ3) | !(cpudff3_q & cpudff4_q & cpudff5_q) | cpudff2_q),
let E22 = (!DMAENA & !cpudff1_q & !cpudff4_q & cpudff5_q),
let E23_sd = (!DSACK1_ & DSACK0_ & cpudff2_q & cpudff3_q & cpudff4_q & !cpudff5_q),
let E24_sd = !( !(cpudff1_q & !cpudff2_q & !cpudff3_q) | cpudff4_q | cpudff5_q),
let E25_d = (!DSACK1_ & !DSACK0_ & cpudff2_q & cpudff3_q & cpudff4_q & !cpudff5_q),
let E26 = !( !(FIFOEMPTY & LASTWORD & !cpudff2_q) | !(cpudff3_q & cpudff4_q & cpudff5_q) | BOEQ3),
let E27 = (FIFOEMPTY & !LASTWORD & !cpudff2_q & cpudff3_q & cpudff4_q & cpudff5_q),
let E28_d = (!DSACK1_ & cpudff2_q & cpudff1_q & cpudff3_q & !cpudff4_q & !cpudff5_q), 
let E29_sd = (cpudff1_q & cpudff2_q & !cpudff3_q & !cpudff4_q & !cpudff5_q),
let E30_d = (!DSACK1_ & cpudff2_q & cpudff1_q & !cpudff3_q & !cpudff4_q & !cpudff5_q),
let E31 = (!DSACK1_ & cpudff1_q & !cpudff3_q & cpudff4_q & cpudff5_q),
let E32 = (FIFOFULL & cpudff1_q & cpudff2_q & !cpudff3_q & cpudff4_q & !cpudff5_q),
let E33_sd_E38_s = (cpudff2_q & cpudff1_q & cpudff3_q & !cpudff4_q & !cpudff5_q),
let E34 = (cpudff3_q & cpudff4_q & cpudff5_q & !FIFOEMPTY & !cpudff2_q),
let E35 = (cpudff2_q & cpudff3_q & cpudff4_q & cpudff5_q),
let E36_s_E47_s = (cpudff1_q & cpudff2_q & cpudff5_q & !cpudff3_q & !cpudff4_q),
let E37_s_E44_s = (!cpudff2_q & cpudff3_q & cpudff4_q & !cpudff5_q),
let E39_s = (cpudff1_q & !cpudff2_q & !cpudff3_q & !cpudff4_q & !cpudff5_q),
let E40_s_E41_s = (cpudff1_q & !cpudff2_q & cpudff5_q & !cpudff3_q & !cpudff4_q),
let E42_s = (cpudff2_q & cpudff1_q & !cpudff3_q & !cpudff4_q & !cpudff5_q),
let E43_s_E49_sd = (cpudff1_q & !cpudff3_q & cpudff4_q & cpudff5_q),
let E45 = (!cpudff1_q & !cpudff2_q & cpudff5_q & !cpudff3_q & cpudff4_q),
let E46_s_E59_s = (cpudff1_q & cpudff3_q & !cpudff2_q & cpudff5_q),
let E48 = (!FIFOFULL & cpudff2_q & !cpudff5_q & cpudff1_q & !cpudff3_q & cpudff4_q),
let E50_d_E52_d = (cpudff1_q & cpudff3_q & !cpudff2_q & !cpudff5_q),
let E51_s_E54_sd = (cpudff4_q & cpudff3_q & cpudff2_q & !cpudff5_q),
let E53 = (!cpudff1_q & !cpudff2_q & !cpudff5_q & cpudff3_q & !cpudff4_q),
let E55 = (!cpudff1_q & cpudff2_q & cpudff3_q),
let E56 = (!cpudff1_q & cpudff4_q & cpudff2_q & cpudff5_q),
let E57_s = (cpudff1_q & cpudff4_q & !cpudff2_q & cpudff5_q),
let E58 = (!cpudff1_q & !cpudff4_q & cpudff3_q & cpudff5_q),
let E60 = (!cpudff1_q & !cpudff4_q & cpudff2_q & cpudff5_q),
let E61 = (!cpudff1_q & cpudff4_q & cpudff2_q & !cpudff5_q),
let E62 = (cpudff1_q & cpudff4_q & !cpudff2_q & !cpudff5_q),
```
## Outputs

State machine output terms.
```text

let p1a = (!( !(!E56& !E62 & !E60 & !E58) | !(!E48 & !E55  & !E27 & !E32) | !(!E12 & !E53 & !E26) )&!( !(!E50_d_E52_d & !E25_d & !E6_d) & DSACKa)&!(E50_d_E52_d & !DSACKa)),
let p1b = !(!STERM1_ & !(!E43_s_E49_sd & !E46_s_E59_s & !E51_s_E54_sd)),
let p1c = !( (!(!(E23_sd & DSACKb) & !(!DSACKb & (E24_sd|E29_sd|E33_sd_E38_s|E43_s_E49_sd|E51_s_E54_sd)))| (E46_s_E59_s|E57_s|E36_s_E47_s|E40_s_E41_s|E37_s_E44_s)) & STERM1_),
let cpudff1_d = !(p1a & p1b & p1c),

let p2a = (!( !(!E1 & !E11 & !E16 & !E17) | !(!E26 & !E27 & !E31 & !E32) | !(!E35 & !E55 & !E58 & !E61) ) & !(!E25_d & !E50_d_E52_d & DSACKa)),
let p2b = !(!STERM1_ & !(!E43_s_E49_sd & !E46_s_E59_s & !E51_s_E54_sd)),
let p2c = !((!(!(E23_sd & DSACKb) & !(!DSACKb & (E33_sd_E38_s|E43_s_E49_sd|E51_s_E54_sd|E29_sd)))|(E36_s_E47_s|E57_s|E46_s_E59_s|E40_s_E41_s)) & STERM2_),
let cpudff2_d = !(p2a & p2b & p2c),








```