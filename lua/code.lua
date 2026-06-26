local code = {}

local machine = require("machine")

-- Given a Turing machine,
--   it returns another one which is the same
--   but recoded in binary
-- It also returns the dictionaries
function code.tobinary(tm)
  tm = tm or machine:new("")
  local st,sy,nx,mv = code.sets(tm)
  local tm2 = machine:new("")
  local ast = code.value(sy,tm.as)
  if ast then table.remove(sy,ast) end
  local twoast = code.fillast(tm,sy)
  local stdic = code.makestdict(st,nx)
  local sydic = code.makesydict(sy,tm.bl)
  local mvdic = code.makemvdict(mv,tm.rt)
  local t = {}
  for k,v in pairs(twoast) do
    t[stdic[k]] = {}
    for kk,vv in pairs(v) do
      if tm.t[k][kk] then
        t[stdic[k]][sydic[kk]] = {stdic[tm.t[k][kk][1]],sydic[tm.t[k][kk][2]],mvdic[tm.t[k][kk][3]]}
      else
        t[stdic[k]][sydic[kk]] = {stdic[vv[1]],sydic[vv[2]],mvdic[vv[3]]}
      end
    end
  end
  tm2.t = t
  tm2.code = code.t2s(t)
  tm2.st = stdic[tm.st] or "0"; tm2.zr = stdic[tm.zr] or "0"
  tm2.bl = sydic[tm.bl] or "0"; tm2.as = ""
  tm2.rt = mvdic[tm.rt] or "1"
  local tp = {}
  for k,v in pairs(tm.tp) do tp[k] = sydic[v] end
  tm2.tp = tp; tm2.pt = tm.pt
  if not next(tm2.tp) then tm2.tp[1] = tm2.bl; tm2.pt = 1 end
  return tm2, stdic,sydic,mvdic
end -- code.tobinary(tm)

-- Given a Turing machine,
--   it returns the sets of states and of symbols
-- Called from code.tobinary(tm)
function code.sets(tm)
  local st,nx,sy,mv = {},{},{},{}
  for k,_ in pairs(tm.t) do
    st[#st+1] = k
    for kk,vv in pairs(tm.t[k]) do
      sy[#sy+1] = kk
      nx[#nx+1] = vv[1]
      sy[#sy+1] = vv[2]
      mv[#mv+1] = vv[3]
    end
  end
  local ust = code.unique(st); table.sort(ust)
  setmetatable(ust,code.setmt)
  local unx = code.unique(nx); table.sort(unx)
  setmetatable(unx,code.setmt)
  local usy = code.unique(sy); table.sort(usy)
  setmetatable(usy,code.setmt)
  local umv = code.unique(mv); table.sort(umv)
  setmetatable(umv,code.setmt)
  return ust, usy, unx, umv
end -- code.sets(tm)

-- Given a set,
--   it returns its string
-- Called via a metatable from code.sets(tm)
function code.set2s(a)
  local t = {}
  for _,v in ipairs(a) do
    table.insert(t, '"'..v..'"')
  end
  return "{"..table.concat(t,",").."}"
end

code.setmt = { __tostring = code.set2s }

-- Given an array,
--   it returns another without repetitions
-- Called from code.sets(tm)
function code.unique(a)
  local h,r = {},{}
  for _,v in ipairs(a) do
    if not h[v] then
      r[#r+1] = v
      h[v] = true
    end
  end
  return r
end -- code.unique(a)

-- Given an array and a value
--  it returns the last position of the value,
--             or nil if not found
-- Called from code.tobinary(tm)
function code.value(a, val)
  local i
  for k,v in ipairs(a) do
    if v == val then i = k end
  end
  return i
end -- code.value(a, val)

-- Fill all * in a table
-- Called from code.tobinary(tm)
function code.fillast(tm,sy)
  local t = {}
  for k,v in pairs(tm.t) do
    t[k] = {}
    for kk,vv in pairs(v) do
      if kk == tm.as then
        for _,vvv in ipairs(sy) do
          if vv[2] == tm.as then
            t[k][vvv] = {vv[1],vvv,vv[3]}
          else
            t[k][vvv] = {vv[1],vv[2],vv[3]}
          end
        end
      end
    end
  end
  for k,v in pairs(tm.t) do
    for kk,vv in pairs(v) do
      if kk ~= tm.as then t[k][kk] = {vv[1],vv[2],vv[3]} end
    end
  end
  return t
end -- code.fillast(tm,sy)

-- Given sets st (states in index) and nx (states in instructions)
--  it returns a dictionary with
--    a key for every state
--    with its corresponding binary string as value
-- Called from code.tobinary(tm)
function code.makestdict(st,nx)
  local dic = {}
  local hl = code.halting(st,nx)
  for _,v in ipairs(hl) do st[#st+1] = v end
  local l = code.log2(#st)
  for k,v in ipairs(st) do dic[v] = code.binary(k-1,l) end
  setmetatable(dic,code.dicmt)
  return dic
end -- code.makestdict(st,nx)

-- Given sets st (states in index) and nx (states in instructions)
--   it returns an array with the halting states
-- Called from code.makestdict(st,nx)
function code.halting(st,nx)
  local t = {}
  for _,s in ipairs(nx) do
    if not code.value(st,s) then t[#t+1] = s end
  end
  setmetatable(t, code.setmt)
  return t
end -- code.halting(st,nx)

-- Given an array of strings
--  it returns a dictionary with
--    a key for every string
--    with its corresponding binary string as value
--    prefixing every value with 1, except zr
-- Called from code.tobinary(tm)
function code.makesydict(set,zr)
  local dic = {}
  if #set <= 2 then
    for _,v in ipairs(set) do
      if v == zr then dic[v] = "0" else dic[v] = "1" end
    end
  else
    local l = code.log2(#set - 1)
    local nx = 0
    for _,v in ipairs(set) do
      if v == zr then
        dic[v] = string.rep("0",l+1)
      else
        dic[v] = "1"..code.binary(nx,l)
        nx = nx + 1
      end
    end
  end
  setmetatable(dic,code.dicmt)
  return dic
end -- code.makesydict(set,zr)

-- Given an array of strings
--  it returns a dictionary with
--    a key for every string
--    with value "1" if is rt and "0" if it is not
-- Called from code.tobinary(tm)
function code.makemvdict(set,rt)
  local dic = {}
  for _,v in ipairs(set) do
    dic[v] = (v == rt) and "1" or "0"
  end
  setmetatable(dic,code.dicmt)
  return dic
end -- code.makemvdict(set,rt)

-- Given a dictionary
--   it returns its string
-- Called via a metatable from code.makexxdict(set,xx)
function code.dict2s(d)
  local t = {}
  for k,v in pairs(d) do
    if k:find("^[_%a][_%w]*$") then
      table.insert(t, k..'="'..v..'"')
    else
      table.insert(t,'"'..k..'"="'..v..'"')
    end
  end
  table.sort(t)
  return "{"..table.concat(t,",").."}"
end

code.dicmt = { __tostring = code.dict2s }

-- Given number n,
--   it returns its log2
-- Called from code.makexxdict(set,xx)
function code.log2(n)
  local p,r = 1,0
  while p < n do
    p = p * 2
    r = r + 1
  end
  if n == 1 then r = 1 end
  return r
end -- code.log2(n)

-- Given a name and a size
--   it returns the binary string of that size
-- Called from code.makexxdict(set,xx)
function code.binary(n,size)
  local t = {}
  for i=1,size do t[i] = "0" end
  local r
  local j = size
  while n > 0 and j > 0 do
    n,r = n // 2, n % 2
    t[j] = tostring(r)
    j = j - 1
  end
  return table.concat(t)
end -- code.binary(n,size)

-- Given a Turing machine table,
--   it returns its coded form
-- Called from code.tobinary(tm)
function code.t2s(t)
  local r = {}
  local s = " "
  for k,v in pairs(t) do
    for kk,vv in pairs(v) do
      r[#r+1] = k..s..kk..s..vv[1]..s..vv[2]..s..vv[3]
    end
  end
  table.sort(r)
  return "{"..s..table.concat(r,s)..s.."}"
end -- code.t2s(t)


return code
