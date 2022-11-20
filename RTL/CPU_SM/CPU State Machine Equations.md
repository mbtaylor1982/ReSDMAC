# CPU State Machine Equations

These are the equations from the Commodore schmatics in the format that can be used in [https://github.com/hneemann/Digital](https://github.com/hneemann/Digital)

```text


let E0 = !( !(!FIFOFULL & FIFOEMPTY & DMADIR & FLUSHFIFO) | !(!cpudff5_a & !cpudff4_a & !cpudff1_a & !cpudff2_a) | !(!cpudff3_a & !LASTWORD & DMAENA & 1) ),
let E1 = (FIFOEMPTY & !DMADIR & !DREQ_ & DMAENA & !cpudff1_a & !cpudff2_a & cpudff5_a & !cpudff4_a), 
let E2 = !( !(DMADIR & !FIFOEMPTY & FLUSHFIFO & DMAENA) | !(!cpudff1_a & !cpudff2_a & !cpudff4_a & cpudff5_a) | cpudff3_a),
let E3 = !( !(DMADIR & LASTWORD & FLUSHFIFO & DMAENA) | (!cpudff1_a & !cpudff2_a & !cpudff4_a & cpudff5_a) | cpudff3_a),
let E4 = !( !( !BOEQ3 & !cpudff1_a & !cpudff3_a & !cpudff5_a) | !(!A1 & CYCLEDONE & !BGRANT_& LASTWORD) | !(!cpudff2_a & cpudff4_a) ),
let E5 = !( !( BOEQ3 & !cpudff1_a & !cpudff3_a & !cpudff5_a) | !(!A1 & CYCLEDONE & !BGRANT_& LASTWORD) | !(!cpudff2_a & cpudff4_a) ),
let E6_d = (!DSACK1_ & cpudff1_a & cpudff2_a & !DSACK0_ & cpudff4_a & !cpudff3_a & cpudff5_a),
let E7 = (DMADIR & FIFOFULL & DMAENA & !cpudff1_a & !cpudff3_a & !cpudff2_a & !cpudff5_a & !cpudff4_a),
let E8 = !( !(!BGRANT_ & !A1 & CYCLEDONE & !cpudff3_a) | !(!cpudff1_a & !cpudff2_a & cpudff4_a & !cpudff5_a) | LASTWORD),
let E9_d = (!DSACK1_ & !DSACK0_ & cpudff1_a & !cpudff3_a &!cpudff4_a & !cpudff5_a), 
let E10 = (CYCLEDONE & A1 & !BGRANT_ & !cpudff1_a & !cpudff3_a & !cpudff2_a & !cpudff5_a & cpudff4_a),
let E11 = (CYCLEDONE & !A1 & !BGRANT_ & !cpudff1_a & !cpudff3_a & cpudff2_a & !cpudff5_a & !cpudff4_a),
let E12 = (CYCLEDONE & A1 & !BGRANT_ & !cpudff1_a & !cpudff3_a & cpudff2_a & !cpudff5_a & !cpudff4_a),
let E13 = (!DMADIR & DMAENA & !cpudff1_b & !cpudff2_a &!cpudff4_a & !cpudff5_b), 
let E14 = (!DMADIR & DREQ_ & !cpudff1_b & !cpudff4_b & cpudff5_a),
let E15 = !( !(!cpudff1_b & !cpudff4_b & cpudff5_a)| FIFOEMPTY | DMADIR ), 
let E16 = (BGRANT_ & !cpudff1_b & cpudff2_a & !cpudff3_b & !cpudff4_b & !cpudff5_b),
let E17 = (!CYCLEDONE & !cpudff1_b & cpudff2_a & !cpudff3_b & !cpudff4_b & !cpudff5_b),
let E18 = (BGRANT_  & !cpudff1_b & !cpudff2_b & !cpudff3_b & cpudff4_a & !cpudff5_b),
let E19 = (!CYCLEDONE & !cpudff1_b & !cpudff2_b & !cpudff3_b & cpudff4_a & !cpudff5_b),
let E20_d = (!DSACK1_ & cpudff1_a & !cpudff2_b & !cpudff3_b & !cpudff4_b & !cpudff5_b),
let E21 = !( | | )



```