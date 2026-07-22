-- test/machine.lua (RMCG20260116)

mac = require("machine")

-- TM1022 on a blank tape returns 1022
TM1022t = "A0B1> A1A1< B0C2> B1H0< B2A2< C0B2<"
TM1022 = mac:new(TM1022t)
TM1022:compute(true)
TM1022:compute(true)
TM1022:compute(true)

-- TM1022b is TM1022 coded binary
code = require("code")
TM1022b = code.tobinary(TM1022)
TM1022b:tape("")
TM1022b:compute({prest = "[", postst = "]"})
TM1022b:compute({prest = "[", postst = "]"})
TM1022b:compute({prest = "[", postst = "]"})

-- TMS2 a typical Turing machine
TMS2t = "A0A0>A1B1>A2B2>B0C0<B1B1>B2B2>C0H1<C1H2<C2C1<"
TMS2 = mac:new(TMS2t)
TMS2:tape("2212")
TMS2:compute(true)
TMS2:tape("22")
TMS2:compute(true)
TMS2:compute()
TMS2:compute()
TMS2:compute()
TMS2:compute()
TMS2:compute()
TMS2:compute()
TMS2:compute()
TMS2:compute()
TMS2:compute()
TMS2:compute()

-- TM_S2x is TM_S2 with asterisk meta-symbols
TMS2xt = "A0A0>A*B*>B0C0<B*B*>C0H1<C1H2<C2C1<"
TMS2x = mac:new(TMS2xt)
TMS2x:tape("2212")
TMS2x:compute(true)
TMS2x:tape("22")
TMS2x:compute(true)
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()
TMS2x:compute()

-- TM_S2 is a typical Turing machine
TM_S2s = "A.T.<A0A0>A1A1>T.H1>T0H1>T1T0<"
TM_S2 = mac:new(TM_S2s)
TM_S2.rt = ">"
-- print(TM_S2)
TM_S2:tape("100","%d")
TM_S2:compute(true)
TM_S2:compute(true)
TM_S2:tape("111","(%d)")
TM_S2:compute{}
TM_S2:tape("000","([01])")
TM_S2:compute{}
TM_S2:tape{}
TM_S2:compute({prest="[",postst="]"})

-- TM_S2x is TM_S2 with asterisk meta-symbols
TM_S2x = mac:new("A.T.<A*A*>T.H1>T0H1>T1T0<")
TM_S2x.rt = ">"
TM_S2x:tape("1101")
mac.compute(TM_S2x,{})
TM_S2x:tape("1011")
TM_S2x:compute(true)
TM_S2x:tape("1011")
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps(5)
TM_S2x:reset()
TM_S2x:steps(2)
TM_S2x:steps()
TM_S2x:steps(10,"T")
TM_S2x:steps(10,"A")
TM_S2x:tape("1011")
TM_S2x:steps()
TM_S2x:steps()
TM_S2x:steps(10,"A")
TM_S2x:steps(10,"A")
TM_S2x:steps(10,"T")
TM_S2x:steps()
TM_S2x:steps(10,"A")

-- Edge case
NOP = mac:new()
NOP:tape"Hello world!"
NOP:compute()

NOP2 = code.tobinary()
NOP2:tape"Whatever!"
NOP2:compute()

-- Testing the minimal Minsky's UTM
-- Redoing §14.8 of Minsky (1967), pages 276-281
MM47table = [[
  q1yq10L q2yq10L q3yq3yL q4yq4yL q5yq5yR q6yq6yR q7yq70R
  q10q10L q20q2yR  halt   q40q5yR q50q3yL q60q3AL q70q6yR
  q11q21L q21q2AR q31q3AL q41q71L q51q5AR q61q6AR q71q71R
  q1Aq11L q2Aq6yR q3Aq41L q4Aq41L q5Aq51R q6Aq61R q7Aq20R
]]
MM47encoding = { state = "q[1-7]", symbol = "[y01A]", move = "[LR]",
                 prefix = "%s*", separator = "%s*", postfix = "%s*" }
MM47 = mac:new(MM47table,MM47encoding)
MM47.bl = "0"; MM47.rt ="R"
MM47:tape("110101110000010011011yyAyyAyy")
MM47.pt = 22
-- The initial situation in Minsky book page 280
MM47:show("["..MM47.st.."]")
-- The second situation in Minsky book page 280
MM47:steps(1000,"q3")
MM47:steps(1000,"q4")
MM47:steps(1000,"q3")
MM47:steps(1000,"q4")
MM47:steps(1000,"q3")
MM47:steps(1000,"q4")
MM47:steps(1000,"q3")
MM47:steps(1000,"q4")
MM47:steps(1000,"q3")
MM47:steps(1000,"q4")
MM47:steps(1000,"q3")
MM47:steps(1000,"q4")
MM47:steps(1000,"q3")
MM47:steps(1000,"q4")
MM47:steps(1000,"q3")
-- The third situation in Minsky book page 280
MM47:steps()
-- The fourth and last situation in Minsky book page 280
MM47:steps(1000,"q2")
MM47:steps(1000,"q3")
-- The next string a3a2a3, referred to but not shown in the book
MM47:steps(1000,"q2")
MM47:steps(1000,"q3")
-- The last string a3, not shown in the book
MM47:steps(1000,"q2")
-- The halting situation, not shown in the book
MM47:steps(1000,{"q3","0"})

-- tm1 goes to the right until finding a blank
tm1s = [=[ S . H 0 >  S 0 S 0 > ]=]
tm1 = mac:new(tm1s)
tm1:tape("000","[01]","#")
tm1:compute()
tm1:tape("000")
tm1:show("["..tm1.st.."]")
tm1:steps()
tm1:steps()
tm1:steps()
tm1:steps()
tm1:steps()
tm1:steps(25)
tm1:tape{}
tm1:compute()
tm1:tape("00")
tm1:compute({})
mac.compute(tm1)
mac.compute(tm1)
mac.compute(tm1)

-- tm2_L goes much to the left
tm2_L = mac:new"A.B1< B.C.< C.D.< D.H.<"
tm2_L.rt = ">"
tm2_L:compute(true)

-- tm2_R goes much to the right
tm2_R = mac:new"A.B1> B.C.> C.D.> D.H.>"
tm2_R:compute(true)

-- tm3 is not completely defined, and it uses an array as tape
tm3 = mac:new" A 0 A 0 >"
tm3.bl = "."
tm3:tape{"0","0"}
tm3:compute{}

-- tm4 completes tm3
tm4 = mac:new" A . H . > A 0 A 0 > "
tm4:tape{"0","0"}
tm4:compute{}

-- tm5 uses strings instead of chars
--     "00" = 1, "0" = 0  ==  States S, SS and H
tm5 = mac:new("S.SS.< S0S0> SS.H00> S00S00> SS0H00> SS00SS0<")
tm5.rt = ">"
tm5:tape{"00","00","0","00"}
tm5:show("|")
tm5:compute(true)

-- tm6 deletes each 1
tm6 = mac:new("A.H.>A0A0>A1A.>")
tm6:tape("001001100","[01]")
tm6:compute(true)

-- tm7 
tm7 = mac:new"A.T.<A1A1>A2A2>T.H1>T1H2>T2T1<"
tm7.rt = ">"
tm7:tape("2212")
tm7:steps(10,"T")
tm7:steps(10,"H") 
tm7:compute(true)
tm7:compute(true)

-- end test/machine.lua
