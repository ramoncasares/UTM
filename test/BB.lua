-- test/BB.lua (RMCG20260116)

mac = require("machine")

-- Notice that BusyBeavers do only count non-halting states.
-- In particular, state H, which is a halting state, is not counted

-- From Aaronson (2020)

-- Lin (1963): 4 ones, 6 steps
tmBB2 = mac:new"A.B1> A1B1< B.A1< B1H1>"
tmBB2:compute()

-- Lin (1963): 5 ones, 21 steps
tmBB3 = mac:new"A.B1> A1H1> B.B1< B1C.> C.C1< C1A1<"
tmBB3:compute()

-- rosettacode.org: 6 ones, 13 steps
tmBB3r = mac:new"a0b1> a1c1< b0a1< b1b1> c0b1< c1H1>"
tmBB3r:compute()

-- Brady (1983): 13 ones, 107 steps
BB4 = "A0B1> A1B1< B0A1< B1C0< C0H1> C1D1< D0D1> D1A0>"
tmBB4 = mac:new(BB4)
tmBB4:compute()

-- Marxen & Buntrock (1990): 4098 ones, 47176870 steps
--     see https://wiki.bbchallenge.org/wiki/BB(5)
BB5 = "A.B1> A1C1< B.C1> B1B1> C.D1> C1E.< D.A1< D1D1< E.H1> E1A.<"
tmBB5 = mac:new(BB5)
-- let history = null or it will waste lots of resources, including time!
io.stderr:write("Be patient! Running BB5 can take some time.\n");
starttime = os.clock()
tpBB5,stBB5 = tmBB5:compute()
print(string.format("  elapsed time: %.2fs", os.clock() - starttime))
print( stBB5 )
f = assert(io.open("tpBB5.out","w"))
f:write( tpBB5 ); f:close()
os.execute("grep -Fo '1' tpBB5.out | wc -l");

-- end test/BB.lua
