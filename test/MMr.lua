-- test/MMr.lua (RMCG20260115)

MM = require("MM")
mac = require("machine")
test = require("test")

-- The 111 machine
TM111 = mac:new"A0B1> B0C1> C0H1<"
TM111pr = MM.TM2MMr(TM111)
TM111:compute(true)
MM.UTMr:tape(TM111pr)
MM.UTMr:compute()

-- Convert MM to TM and back, states can be renamed
--  table 1 1 1 1 0(<)  tape blank
--        1 0 0 1 0(<)
MMsucc = "YMY10X11110X10010Y"
TMsucc = MM.MMr2TM(MMsucc)
MM2succ = MM.TM2MMr(TMsucc)

TMsucc:compute({prest = "_", postst = "_"})

MM.UTMr:tape(MMsucc,"[01ABXYMNS]")
tprsucc, htrsucc = MM.UTMr:compute({prest = "_", postst = "_"})
do return tprsucc end
test.tofile("htrsucc.out", htrsucc)

MM.UTMr:tape(MM2succ,"[01ABXYMNS]")
tpr2succ, htr2succ = MM.UTMr:compute({prest = "_", postst = "_"})
do return tpr2succ end
test.tofile("htr2succ.out", htr2succ)

-- The 101 machine
tm101 = mac:new"A0B1> B0C0> C0H1<"
MM.UTMo:tape( MM.TM2MMo(tm101) )
MM.UTMr:tape( MM.TM2MMr(tm101) )
tm101:compute()
MM.UTMo:steps(900)
MM.UTMr:compute()

-- The 101x machine
tm101x = mac:new"A0B1> B0C0> C0H1<"
tm101x:tape("000000")
MM.UTMo:tape( MM.TM2MMo(tm101x) )
MM.UTMr:tape( MM.TM2MMr(tm101x) )
tm101x:compute()
MM.UTMo:compute()
MM.UTMr:compute()

-- The 10101 machine to test bidirectionality
tm21rl = mac:new"A0B0> B0C0> C0D1< D0E0< E0F1< F0G0< G0H1<"
MM.UTMr:tape( MM.TM2MMr(tm21rl) )
tm21rl:compute()
MM.UTMr:compute()

-- The 10101 machine to test bidirectionality
tm21lr = mac:new"A0B0< B0C0< C0D1> D0E0> E0F1> F0G0> G0H1>"
tm21lr.rt = ">"
MM.UTMr:tape( MM.TM2MMr(tm21lr) )
tm21lr:compute()
MM.UTMr:compute()

-- A corner case, the NOP machine that always halts
NOP = mac:new""
NOP.zr = "0"; NOP.bl = "0"; NOP.rt = "1"
NOPp = MM.TM2MMr(NOP)
NOP2 = MM.MMr2TM(NOPp)
NOP:compute()
MM.UTMr:tape(NOPp)
MM.UTMr:compute()
NOP2:compute()
NOPx = mac:new()
NOPx:compute()

-- Delete first two 1
TMD11 = mac:new("A0A0> A1B0> B0B0> B1H0>")
TMD11:tape("010011000111")
prD11 = MM.TM2MMr(TMD11)
TMD11:compute()
MM.UTMr:tape(prD11)
MM.UTMr:compute()

-- The 1022 machine, which is not binary
TM1022 = mac:new("A0B1> A1A1< B0C2> B1H0< B2A2< C0B2<")
MM.UTMr:tape( MM.TM2MMr(TM1022) )
MM.UTMr:compute()

-- Now the BB3 that writes more 1's (6), from rosettacode.org
tmBB3r = mac:new"a0b1> a1c1< b0a1< b1b1> c0b1< c1H1>"
MM.UTMr:tape( MM.TM2MMr(tmBB3r) )
tmBB3r:compute()
MM.UTMr:compute()

-- And the BB3 that halts after more steps (21), from Aaronson (2020)
tmBB3 = mac:new"A.B1> A1H1> B.B1< B1C.> C.C1< C1A1<"
MM.UTMr:tape( MM.TM2MMr(tmBB3) )
tmBB3:compute()
MM.UTMr:compute()

-- end test/MMr.lua
