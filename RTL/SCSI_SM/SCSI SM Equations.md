# SCSI State Machine Equations

These are the equations from the Commodore schmatics in the format that can be used in [https://github.com/hneemann/Digital](https://github.com/hneemann/Digital)

```text

let E0_ = !(!(CDREQ_ | FIFOEMPTY | DMADIR | CCPUREQ | RDFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q)  & scsidff5_q), 
let E1_ = !(!(CDREQ_ | FIFOFULL | !DMADIR | CCPUREQ | RIFIFO_o | scsidff1_q | scsidff2_q | scsidff4_q) & !scsidff3_q & !scsidff5_q),
let E2_ = !(FIFOFULL & !scsidff1_q & !scsidff2_q & !scsidff3_q & scsidff4_q & scsidff5_q),
let E3_ = !(BOEQ3 & scsidff1_q & !scsidff2_q & !scsidff4_q & !scsidff5_q),
let E4_ = !(BOEQ3 & !scsidff2_q & scsidff3_q & scsidff4_q & !scsidff5_q),
let E5_ = !(!DMADIR & !CCPUREQ & !scsidff2_q & !scsidff3_q & !scsidff4_q),
let E6_ = !(CCPUREQ & !scsidff1_q & !scsidff2_q & !scsidff3_q & !scsidff4_q),
let E7_ = !(!FIFOFULL & !scsidff1_q & !scsidff2_q & !scsidff3_q & scsidff4_q & scsidff5_q),
let E8_ = !(!RW & !scsidff1_q & !scsidff2_q & !scsidff3_q & scsidff4_q & !scsidff5_q),
let E9_ = !(!scsidff1_q & scsidff2_q & !scsidff3_q & !scsidff4_q & scsidff5_q),
let E10_ = !(!scsidff2_q & scsidff3_q & scsidff4_q & !scsidff5_q),
let E11_ = !(scsidff1_q & !scsidff2_q & !scsidff4_q & !scsidff5_q),
let E12_ = !(RW & !scsidff1_q & !scsidff3_q & scsidff4_q & !scsidff5_q),
let E13_ = !(!scsidff1_q & scsidff2_q & !scsidff3_q & !scsidff4_q & !scsidff5_q),
let E14_ = !(!CDSACK_ & scsidff2_q & scsidff4_q & !scsidff5_q),
let E15_ = !(scsidff2_q & scsidff3_q & !scsidff4_q & scsidff5_q),
let E16_ = !(!scsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q),
let E17_ = !(scsidff2_q & scsidff3_q & scsidff4_q & scsidff5_q),
let E18_ = !(scsidff2_q & !scsidff3_q & scsidff4_q & scsidff5_q),
let E19_ = !(!CDSACK_ & scsidff1_q & scsidff4_q),
let E20_ = !(!scsidff2_q & scsidff3_q & !scsidff4_q & scsidff5_q),
let E21_ = !(!scsidff2_q & scsidff3_q & !scsidff4_q & !scsidff5_q),
let E22_ = !(scsidff2_q & scsidff3_q & !scsidff4_q & !scsidff5_q),
let E23_ = !(scsidff1_q & scsidff4_q & !scsidff5_q),
let E24_ = !(scsidff1_q & !scsidff2_q & !scsidff4_q & scsidff5_q),
let E25_ = !(scsidff1_q & scsidff2_q & scsidff5_q),
let E26_ = !(scsidff1_q & scsidff2_q & !scsidff5_q),
let E27_ = !(scsidff2_q & !scsidff3_q & scsidff4_q & !scsidff5_q)

let scsidff1_d = !(E8_& E9_ & E17_ & E19_ & E23_ & E25_ & E26_),
let scsidff2_d = !(!(E12_& E13_& E14_ & E15_ & E16_ & E17_) | !(E18_ & E22_ & E24_ & E26_ & E27_)),
let scsidff3_d = !(!(E0_ & E2_ & E7_ & E14_) | !(E15_ & E18_ & E20_ & E21_ & E22_ & E27_)),         
let scsidff4_d = !(!(E0_ & E1_ & E6_ & E12_ & E14_ & E15_) | !(E19_ & E20_ & E23_ & E24_ & E25_ & E27_)),  
let scsidff5_d = !(!(E1_ & E5_ & E8_ & E11_ & E13_ & E19_) | !(E21_ & E22_ &  E23_ & E24_ & E26_ & E27_)),  

let DACK = !(E0_ & E1_ & E7_ & E9_ & E13_ & E16_ & E20_ & E21_),
let INCBO = !(E10_ & E11_),    
let INCNI = !(E2_ & E4_),        
let INCNO = !(E2_ & E3_),    
let RE = !(E7_& E12_ & E17_ & E20_ & E21_ & E25_ & E26_ & E27_),
let WE = !(E8_ & E9_ & E13_ & E16_ & E18_ & E24_),
let SCSI_CS = !(!(E8_& E12_ & E17_ & E18_) | !(E22_ & E24_& E25_ & E26_ & E27_)),
let SET_DSACK = !(E22_ & E25_),
let RIFIFO_d = E4_,
let RDFIFO_d = E3_,
let S2F = !(E7_ & E10_ & E20_ & E21_),
let F2S = !(E9_ & E11_ & E13_ & E16_),
let S2CPU = !(E12_ & E17_ & E19_ & E23_ & E25_ & E26_ & E27_), 
let CPU2S = !(E8_ & E18_ & E22_ & E24_)
```