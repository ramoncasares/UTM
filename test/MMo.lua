-- test/MMo.lua (RMCG20260409)

mac = require("machine")
MM = require("MM")
test = require("test")

-- The 101 machine
TM101 = mac:new"A0B1> B0C0> C0H1<"
TM101po = MM.TM2MMo(TM101)
TM101:compute(true)
MM.UTMo:tape(TM101po)
MM.UTMo:steps(900)
TM101xo = string.gsub(TM101po, "M", "M00")
MM.UTMo:tape(TM101xo)
MM.UTMo:compute()

-- Testing the original Minsky's UTM
-- Redoing §7.3 of Minsky (1967), pages 143-144
MM73table = "00001X01110X10011X11100".."Y0"
MM73tape = "000M000".."Y01X"
MM.UTMo:tape(MM73tape..MM73table)
test.open("MM73.out")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
test.append(MM.UTMo:steps(1000,"q21"),test.steps)
test.append(MM.UTMo:steps(1000,"q33"),test.steps)
test.append(MM.UTMo:steps(1000,"q35"),test.steps)
test.append(MM.UTMo:steps(1000,"q41","q42"),test.steps)
test.append(MM.UTMo:steps(1000,"q45","q46"),test.steps) -- error in Minsky
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
MM.UTMo:steps(1000,"q21")
test.append(MM.UTMo:steps(1000,"q11"),test.steps)
test.close()

-- The empty table edge case
NOP = mac:new""
NOP.zr = "0"; NOP.bl = "0"; NOP.rt = "1"
NOP:tape("000000")
MM.UTMo:tape( MM.TM2MMo(NOP) )
NOP:compute()
MM.UTMo:steps(7)
-- it should not trespass the rightmost Y
MM.UTMo:steps()
-- but it does it
MM.UTMo:steps()
-- And this is not the expected middle Y
-- So it enters an infinite loop
-- always working to the right of the rightmost Y
-- q15 q12 q13 q15 q15 q12 q12 q13 q15_n q12_n q13 ...
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()
MM.UTMo:steps()

-- Delete first two 1
TMD11 = mac:new("A0A0> A1B0> B0B0> B1H0>")
TMD11:tape("010011000111")
prD11 = MM.TM2MMo(TMD11)
TMD11:compute()
MM.UTMo:tape(prD11)
MM.UTMo:compute()

-- The 1022 machine, which is not binary
TM1022 = mac:new("A0B1> A1A1< B0C2> B1H0< B2A2< C0B2<")
MM.UTMo:tape( MM.TM2MMo(TM1022) )
MM.UTMo:compute({prest = "[", postst = "]"})

-- The 10101 machine
TM10101 = mac:new"A0B0> B0C0> C0D1< D0E0< E0F1< F0G0< G0H1<"
TM10101:tape("000000")
MM.UTMo:tape( MM.TM2MMo(TM10101) )
TM10101:compute()
MM.UTMo:compute()

-- end test/MMo.lua
