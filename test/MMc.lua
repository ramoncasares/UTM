-- test/MMc.lua (RMCG20260131)

MM = require("MM")
mac = require("machine")
code = require("code")
test = require("test")

-- succ is very simple
--    convert TM to MM and back, states can be renamed
tabsucc = "A0H1< A1A1<"
TM1succ = mac:new(tabsucc)
TM1succ.rt = ">"
tpsucc = "000100"
TM1succ:tape(tpsucc)
prg1succ = MM.TM2MMc( TM1succ )
TM2succ = MM.MMc2TM( prg1succ )
prg2succ = MM.TM2MMc( TM2succ )

TM1succ:compute()
MM.UTMc:tape(prg1succ)
MM.UTMc:compute()
TM2succ:compute()
MM.UTMc:tape(prg2succ)
MM.UTMc:compute()

-- The 101 machine
tm101 = mac:new"A0B1> B0C0> C0H1<"
MM.UTMo:tape( MM.TM2MMo(tm101) )
MM.UTMr:tape( MM.TM2MMr(tm101) )
MM.UTMc:tape( MM.TM2MMc(tm101) )
tm101:compute()
MM.UTMo:steps(900)
MM.UTMr:compute()
MM.UTMc:compute()

-- The 101x machine
tm101x = mac:new"A0B1> B0C0> C0H1<"
tm101x:tape("000000")
MM.UTMo:tape( MM.TM2MMo(tm101x) )
MM.UTMr:tape( MM.TM2MMr(tm101x) )
MM.UTMc:tape( MM.TM2MMc(tm101x) )
tm101x:compute()
MM.UTMo:compute()
MM.UTMr:compute()
MM.UTMc:compute()

-- The 10101 machine to test bidirectionality
tm21rl = mac:new"A0B0> B0C0> C0D1< D0E0< E0F1< F0G0< G0H1<"
MM.UTMc:tape( MM.TM2MMc(tm21rl) )
tm21rl:compute()
MM.UTMc:compute()

-- The 10101 machine to test bidirectionality
tm21lr = mac:new"A0B0< B0C0< C0D1> D0E0> E0F1> F0G0> G0H1>"
tm21lr.rt = ">"
MM.UTMc:tape( MM.TM2MMc(tm21lr))
tm21lr:compute()
MM.UTMc:compute()

-- Now the BB3 that writes more 1's, from rosettacode.org
tmBB3r = mac:new"a0b1> a1c1< b0a1< b1b1> c0b1< c1H1>"
MM.UTMc:tape( MM.TM2MMc(tmBB3r) )
tmBB3r:compute()
MM.UTMc:compute()

-- And the BB3 that halts after more steps, from Aaronson (2020)
tmBB3 = mac:new"A.B1> A1H1> B.B1< B1C.> C.C1< C1A1<"
MM.UTMc:tape( MM.TM2MMc(tmBB3) )
tmBB3:compute()
MM.UTMc:compute()

-- The 30201 machine to test bidirectionality
tm321rl = mac:new"A0B0> B0C0> C0D1< D0E0< E0F2< F0G0< G0H3<"
tm321rlbin = code.tobinary(tm321rl)
MM.UTMc:tape( MM.TM2MMc(tm321rl) )
tm321rl:compute()
tm321rlbin:compute()
MM.UTMc:compute()

-- The 10203 machine to test bidirectionality
tm123lr = mac:new"A0B0< B0C0< C0D1> D0E0> E0F2> F0G0> G0H3>"
tm123lr.rt = ">"
tm123lrbin = code.tobinary(tm123lr)
MM.UTMc:tape( MM.TM2MMc(tm123lr) )
tm123lr:compute()
tm123lrbin:compute()
MM.UTMc:compute()

-- The 1022 machine
cs1022 = "A0B1> A1A1< B0C2> B1H0< B2A2< C0B2<"
tm1022 = mac:new(cs1022)
tb1022 = code.tobinary(tm1022)
pg1022 = MM.TM2MMc(tm1022)
dic1022 = {A="00",B="01",C="10",H="11",["0"]="00",["1"]="10",["2"]="11",["<"]="0",[">"]="1"}
prc1022 = "YMMY0000X"..MM.recode(cs1022,dic1022,"%S+",".","X","").."Y"

tm1022:compute()
tb1022:compute()

trc1022 = MM.recode(cs1022,dic1022,"%S+","."," "," ")
tr1022 = mac:new(trc1022, mac.binary)
tr1022:compute()

MM.UTMc:tape(pg1022)
MM.UTMc:compute()

MM.UTMc:tape(prc1022)
MM.UTMc:compute()

MM.UTMc:tape(prc1022)
test.open("pr1022.out")
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
test.append(MM.UTMc:steps(1000,"q11"),test.steps)
test.append(MM.UTMc:steps(1000,"q21"),test.steps)
test.append(MM.UTMc:steps(1000,"q35"),test.steps)
test.append(MM.UTMc:steps(1000,"q41"),test.steps)
test.append(MM.UTMc:steps(1000,"q37"),test.steps)
test.append(MM.UTMc:steps(1000,"q51"),test.steps)
test.append(MM.UTMc:steps(1000,"q61"),test.steps)
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
MM.UTMc:steps(1000,"q35")
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
MM.UTMc:steps(1000,"q15")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q34")
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
MM.UTMc:steps(1000,"q51")
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
test.append(MM.UTMc:steps(1000,"q00"),test.steps)
test.append(MM.UTMc:steps(1000,"q71"),test.steps)
test.append(MM.UTMc:steps(1000,"q72"),test.steps)
test.append(MM.UTMc:steps(1000,"q99"),test.steps)
test.close()

MM.UTMc:tape(prc1022)
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q11")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q35")
MM.UTMc:steps(1000,"q41")
MM.UTMc:steps(1000,"q51")
MM.UTMc:steps(1000,"q61")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q35")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q15")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q34")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q51")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q71")
MM.UTMc:steps(1000,"q72")
MM.UTMc:steps(1000,"q99")

prcx1022 = "Y0MM0Y0000X"..MM.recode(cs1022,dic1022,"%S+",".","X","").."Y"
MM.UTMc:tape(prcx1022)
MM.UTMc:compute()

-- The 1023 machine
cs1023 = "A0B1> A1A1< B0C2> B1H0< B2A2< C0B3<"
dic1023 = {A="00",B="01",C="10",H="11",
           ["0"]="000",["1"]="101",["2"]="110",["3"]="111",
           ["<"]="0",[">"]="1"}
tm1023 = mac:new(cs1023)
tm1023:compute()
trc1023 = MM.recode(cs1023,dic1023,"%S+","."," "," ")
tr1023 = mac:new(trc1023, mac.binary)
tr1023:compute()

prc1023 = "YMMMY00000X"..MM.recode(cs1023,dic1023,"%S+",".","X","").."Y"
MM.UTMc:tape(prc1023)
MM.UTMc:compute()

MM.UTMc:tape(prc1023)
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q11")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q35")
MM.UTMc:steps(1000,"q41")
MM.UTMc:steps(1000,"q51")
MM.UTMc:steps(1000,"q61")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q35")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q34")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q51")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q21")
MM.UTMc:steps(1000,"q31")
MM.UTMc:steps(1000,"q00")
MM.UTMc:steps(1000,"q71")
MM.UTMc:steps(1000,"q72")
MM.UTMc:steps(1000,"q99")

dicx1023 = {A="00",B="01",C="10",H="11",["0"]="00000",["1"]="10110",["2"]="11010",["3"]="11110",["<"]="0",[">"]="1"}
prcx1023 = "Y0MMMMM0Y0000000X"..MM.recode(cs1023,dicx1023,"%S+",".","X","").."Y"
MM.UTMc:tape(prcx1023)
MM.UTMc:compute()

-- 123, aka noh, a machine without halting state, but lacking transitions
csnoh = "A,0,B,1,>\n B,0,C,2,>\n C,0,A,3,<\n A,1,B,1,<"
dicnoh = {A="00",B="01",C="10",
          ["0"]="00000",["1"]="10110",["2"]="11010",["3"]="11110",
          ["<"]="0",[">"]="1"}
prnoh = "Y0MMMMM0Y0000000X"..MM.recode(csnoh,dicnoh,"[^\n%s]+","[^,]","X","").."Y"
tmnoh = mac:new(csnoh, mac.cencoding)
tmnoh:compute(true)
trcnoh = MM.recode(csnoh,dicnoh)
trnoh = mac:new(trcnoh, mac.cencoding)
trnoh:compute(true)
MM.UTMc:tape(prnoh)
MM.UTMc:steps(10000,"q00")
MM.UTMc:steps(10000,{"q63","Y"},"q99")
MM.UTMc:steps()
MM.UTMc:steps(10000,{"q63","Y"},"q99")
MM.UTMc:steps()
MM.UTMc:steps(10000,{"q63","Y"},"q99")
MM.UTMc:steps()
MM.UTMc:steps(10000,{"q63","Y"},"q99")

MM.UTMc:tape(prnoh)
MM.UTMc:compute()

-- The succx machine to test *
succxtb = "A0B0< A*A*> B0H1> B1H2< B2H3< B3B0<"
succxtm = mac:new( succxtb )
succxtm.rt = ">"
succxtm:tape("1233")
succxbi = code.tobinary(succxtm)
succxpg = MM.TM2MMc(succxtm)
MM.UTMc:tape( succxpg )
succxtm:compute()
succxbi:compute()
MM.UTMc:compute()

-- The succo machine to test *
succotb = "A0A0> A*B*> B0C0< B*B*> C1H2< C2H3< C3C0< C0H1<"
succotm = mac:new( succotb )
succotm:tape("001233")
succobi = code.tobinary(succotm)
succopg = MM.TM2MMc(succotm)
succot2 = MM.MMc2TM(succopg)
MM.UTMc:tape( succopg )
succotm:compute()
succobi:compute()
MM.UTMc:compute()
succot2:compute()

-- The S2 machine
S2tb = "A0A0> A1B1> A2B2> B0C0< B1B1> B2B2> C0H1< C1H2< C2C1<"
S2tm = mac:new( S2tb )
S2tm:tape("2212")
S2pg = MM.TM2MMc(S2tm)
S2bn = code.tobinary(S2tm)
S2p2 = MM.TM2MMc(S2bn)
S2tm:compute(true)
S2bn:compute()
MM.UTMc:tape( S2pg )
MM.UTMc:compute()
MM.UTMc:tape( S2p2 )
MM.UTMc:compute()

-- The S2* machine
S2tbx = "A0A0> A*B*> B0C0< B*B*> C0H1< C1H2< C2C1<"
S2tmx = mac:new( S2tbx )
S2tmx:tape("2212")
S2pgx = MM.TM2MMc(S2tmx)
S2bnx = code.tobinary(S2tmx)
S2p2x = MM.TM2MMc(S2bnx)
S2tmx:compute(true)
S2bnx:compute()
MM.UTMc:tape( S2pgx )
MM.UTMc:compute()
MM.UTMc:tape( S2p2x )
MM.UTMc:compute()

-- A corner case, the NOP machine that always halts
NOP = mac:new""
NOPp = MM.TM2MMc(NOP)
NOP2 = MM.MMc2TM(NOPp)
NOP:compute()
MM.UTMc:tape(NOPp)
MM.UTMc:compute()
NOP2:compute()
NOPx = mac:new()
NOPx:compute()

-- Another corner case: emulating itself
tm11 = mac:new"A0B1> B0H1<"
pr11 = MM.TM2MMc(tm11)
tm11:compute(true)

MM.UTMc:tape(pr11)
MM.UTMc:compute()
MM.UTMc:tape(pr11)
pr11c,st11cdic,sy11cdic,mv11cdic = MM.TM2MM(MM.UTMc)
MM.UTMc:tape( pr11c )
io.stderr:write("Be patient! MMc-UTM auto-emulation can take some time.\n");
starttime = os.clock()
MM.UTMc:compute()
print(string.format("  elapsed time: %.2fs", os.clock() - starttime))
print(sy11cdic)

-- end test/MMc.lua
