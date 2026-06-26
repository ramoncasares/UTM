local MM = {}

local machine = require("machine")
local code = require("code")

function MM.file2string(filename)
  local f = assert(io.open(filename, "r"))
  local s = f:read("*all")
  f:close()
  return s
end

-- Encodings for the UTMs
MM.oencoding = {prefix="", separator=",", postfix = "",
  state = "q%d+", symbol = "[01ABMXYS%*]", move = "[<>]" }
MM.rencoding = {prefix="", separator=",", postfix = "",
  state = "q%d+", symbol = "[01ABMNXYS%*]", move = "[<>]" }
MM.cencoding = {prefix="", separator=",", postfix = "",
  state = "q%d+", symbol = "[01ABMNXYS%*]", move = "[<>]" }

-- Loading UTMo
MM.ocode = MM.file2string("../csv/MMo-UTM.csv")
MM.UTMo = machine:new(MM.ocode, MM.oencoding)
MM.UTMo.rt = ">"
MM.UTMo.resettape = function(self)
  local mink,first,last = machine.tapelimits(self)
  if first then
    local p = first
    while p <= last and self.tp[p] ~= "X" do p = p + 1 end
    if self.tp[p] == "X" then self.pt = p
    else self.pt = first end
  else
    self.pt = mink
  end
end

-- Loading UTMr
MM.rcode = MM.file2string("../csv/MMr-UTM.csv")
MM.UTMr = machine:new(MM.rcode, MM.rencoding)

-- Loading UTMc
MM.ccode = MM.file2string("../csv/MMc-UTM.csv")
MM.UTMc = machine:new(MM.ccode, MM.cencoding)

-- The encoding of programs (and data)
MM.pencoding = {prefix="", separator="", postfix = "",
   state = "[01]+", symbol = "[01]", move = "[01]" }
MM.ocapture = "([01]*)(M)([01]*)Y([01]+)X([01X]*)Y0*"
--~ MM.bcapture = "0*Y([01]*)(M)([01]*)Y([01]+)X([01X]*)Y0*"
MM.rcapture = "0*Y([01]*)([MN])([01]*)Y([01]+)X([01X]*)Y0*"
MM.ccapture = "0*Y([01]*)([MN]+)([01]*)Y([01]+)X([01X]*)Y0*"
MM.capture = "0*Y?([01]*)([MN]+)([01]*)Y([01]+)X([01X]*)Y0*"

-- From program (and data) to Turing machine
function MM.MM2TM(s, cap)
  s = s or ""
  cap = cap or MM.capture
  local pretape,pointer,postape,index,program = s:match(cap)
  local w = #pointer
  local s = #index - #pointer
  local MMcoding = { prefix="", separator="", postfix = "",
    state = string.rep("[01]",s), symbol = string.rep("[01]",w),
    move = "[01]" }
  local tm = machine:new(program,MMcoding) 
  tm.bl = string.rep("0",w)
  tm.rt = "1"
  tm.zr = index:sub(1, s); tm.st = tm.zr  
  local rdsy = index:sub(s+1)
  local prel = string.rep("0", (w - #pretape % w) % w) .. pretape
  local posl = postape .. string.rep("0", (w - #postape % w) % w)
  tm:tape(prel..index:sub(s+1)..posl,string.rep("[01]",w))
  tm.pt = #prel // w + 1
  return tm
end

function MM.MMo2TM(s)
  return MM.MM2TM(s, MM.ocapture) 
end

function MM.MMr2TM(s)
  return MM.MM2TM(s, MM.rcapture)
end

function MM.MMc2TM(s)
  return MM.MM2TM(s, MM.ccapture)
end

-- From Turing machine to program (and data)
function MM.TM2MM(tm) 
  local tm2,stdic,sydic,mvdic = code.tobinary(tm)
  local rdsy = tm2.tp[tm2.pt]
  local index = tm2.st .. rdsy
  tm2.tp[tm2.pt] = string.gsub(rdsy,".",{["0"]="M",["1"]="N"})
  local tape = tm2:show("","")
  local prg = {}
  for k,v in pairs(tm2.t) do
    for vk, vv in pairs(v) do
      table.insert(prg, k..vk..vv[1]..vv[2]..vv[3])
    end
  end
  table.sort(prg)
  local program = "Y"..tape.."Y"..index.."X"..table.concat(prg,"X").."Y"
  return program,stdic,sydic,mvdic
end

function MM.TM2MMo(tm)
  local pr,w = string.gsub(MM.TM2MM(tm),"[MN]","M")
  if w ~= 1 then pr = "YMY0X1Y" end
  return string.sub(pr,2)
end

function MM.TM2MMr(tm)
  local pr,_,syd,_ = MM.TM2MM(tm)
  local _,bl = next(syd)
  if not bl or #bl ~= 1 then pr = "YMY0XY" end
  return pr
end

function MM.TM2MMc(tm)
  return (MM.TM2MM(tm))
end

-- takes a string representing a table,
-- makes first records and then fields,
-- codes each field,
-- and reassembles first the fields into records
-- and then the records into a string
function MM.recode(s,dic,rpat,fpat,rsep,fsep)
  return MM.a2s(MM.a2a(MM.s2a(s,rpat,fpat),dic),rsep,fsep)
end -- MM.recode(s,dic,rpat,fpat,rsep,fsep)

-- takes a string s and
--   returns an array of arrays of strings
-- uses rsep as record pattern (default not eol) and
-- uses fsec as field pattern (default neither comma nor space)
-- called from MM.recode(s,dic,rpat,fpat,rsep,fsep)
function MM.s2a(s,rpat,fpat)
  rpat = rpat or "[^\n\r]+"
  fpat = fpat or "[^,%s]+"
  local t = {}
  local tt
  for line in s:gmatch(rpat) do
    tt = {}
    for field in line:gmatch(fpat) do
      tt[#tt+1] = field
    end
    t[#t+1] = tt
  end
  return t
end -- MM.s2a(s,rpat,fpat)

-- takes an array of arrays of strings and
--   returns an array of arrays of strings
--   uses dic to code each value
-- called from MM.recode(s,dic,rpat,fpat,rsep,fsep)
function MM.a2a(a,dic)
  if not dic then return a end
  local t = {}
  local tt
  for _,line in ipairs(a) do
    tt = {}
    for _,field in ipairs(line) do
      tt[#tt+1] = dic[field] or field.."!"
    end
    t[#t+1] = tt
  end
  return t
end -- MM.a2a(a,dic)

-- takes an array of arrays of strings and
--   returns a string
--   uses rsep to separate records (default eol)
--   used fsep to separate fields (default comma)
-- called from MM.recode(s,dic,rpat,fpat,rsep,fsep)
function MM.a2s(a,rsep,fsep)
  rsep = rsep or "\n"
  fsep = fsep or ","
  local t = {}
  local tt
  for _,line in ipairs(a) do
    tt = {}
    for _,field in ipairs(line) do
      tt[#tt+1] = field
    end
    t[#t+1] = table.concat(tt,fsep)
  end
  return table.concat(t,rsep)
end -- MM.a2s(a,rsep,fsep)


return MM
