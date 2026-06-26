local machine = {}

-- Given a string coding a Turing nmachine,
--   and an optional encoding,
--   it returns the corresponding Turing machine object
function machine:new(s, encoding)
  s = s or ""
  local tm = {
    code = s,    -- the string with the code
    t = {},      -- the table
    tp = {},     -- the tape, an array
    pt = 1,      -- the tape pointer
    -- st = "A", -- the current state
    -- zr = "A", -- the initial state
    -- bl = "0", -- symbol for blank squares
    -- rt = ">", -- right movement
    as = "*"     -- meta symbol meaning any symbol (and the same)
  }
  local row,rowc = machine.patterns(encoding)
  local indins = {}
  for ii in s:gmatch(row) do
    table.insert(indins, ii)
  end
  local cs,rs,ns,ws,mv
  for _,v in ipairs(indins) do
    cs,rs,ns,ws,mv = v:match(rowc)
    tm.zr = tm.zr or cs -- the first in table
    tm.bl = tm.bl or rs -- the first in table
    tm.rt = tm.rt or mv -- the first in table
    if not tm.t[cs] then tm.t[cs] = {} end
    tm.t[cs][rs] = {ns,ws,mv}
  end
  tm.zr = tm.zr or "A"
  tm.bl = tm.bl or "0"
  tm.rt = tm.rt or ">"
  tm.st = tm.zr; tm.tp[1] = tm.bl
  setmetatable(tm,self)
  self.__index = self
  self.__tostring = machine.tostring
  return tm
end -- machine:new(s, encoding)

-- Default encoding: it does not need separators
machine.default = {prefix="%s*", separator="%s*", postfix = "%s*",
 state = "%a+", symbol = "[%d%.%*]%d*", move = "[<>]" }

-- Maximal encoding: any alphanumeric goes, but it need separators
machine.max = {prefix="[^%w%.%*]+", separator="[^%w%.%*]+", postfix = "[^%w%.%*]+",
  state = "%w+", symbol = "[%w%.%*]%w*", move = "[<>]" }

-- Binary encoding: rigid but simple
machine.binary = {prefix="%s*", separator="%s+", postfix = "%s*",
  state = "[01]+", symbol = "[01]+", move = "[01]" }

-- Comma separated
machine.cencoding ={prefix="", separator=",", postfix = "",
  state = "[^,%s]+", symbol = "[^,%s]+", move = "[^,%s]+" }

-- Given an encoding,
--   it returns the corresponding pattern and capture
-- called from machine:new(s, encoding)
function machine.patterns(encoding)
  local enc = encoding or machine.default
  local pat,cap = {},{}
  pat[1] = enc.state;  cap[1] = "(" .. enc.state .. ")"
  pat[2] = enc.symbol; cap[2] = "(" .. enc.symbol .. ")"
  pat[3] = enc.state;  cap[3] = "(" .. enc.state .. ")"
  pat[4] = enc.symbol; cap[4] = "(" .. enc.symbol .. ")"
  pat[5] = enc.move;   cap[5] = "(" .. enc.move .. ")"
  return enc.prefix..table.concat(pat,enc.separator)..enc.postfix,
         enc.prefix..table.concat(cap,enc.separator)..enc.postfix
end -- machine.patterns(encoding)

-- It returs the string corresponding to itself
function machine:tostring()
  return machine.serialize(self)
end -- machine:tostring()

-- simple table to string
function machine.serialize(o,level,tab)
  level = level or 0
  tab = tab or "  "
  local t = {}
  if     type(o) == "string"  then t[#t+1] = '"'..o..'"'
  elseif type(o) == "table"   then
    level = level + 1
    t[#t+1] = "{\n"
    for k,v in pairs(o) do
      t[#t+1] = string.rep(tab,level)
      if type(k) == "string" and k:find("^[_%a][_%w]*$") then
        t[#t+1] = k
      else
        t[#t+1] = "["
        t[#t+1] = machine.serialize(k,level,tab)
        t[#t+1] = "]"
      end
      t[#t+1] = " = "
      t[#t+1] = machine.serialize(v,level,tab)
      t[#t+1] = ",\n"
    end
    level = level - 1
    t[#t+1] = string.rep(tab,level)
    t[#t+1] =  "}"
  else
    t[#t+1] = tostring(o)
  end
  return table.concat(t)
end -- machine.serialize(o,level,tab)

-- Resets the machine, but it does not change the tape
-- Current state is the initial state
-- Tape points to the leftmost non-blank symbol
function machine:reset()
  self.st = self.zr
  self:resettape()
end -- machine:reset()

-- Inspects the whole tape (self.tp array) to find its limits,
--   total limits from mink to maxk
--   and ignoring marginal blanks from first to last
--   w is the length of the longest symbol string
function machine:tapelimits()
  if not next(self.tp) then self.tp[1] = self.bl end
  local maxk,mink,first,last,w
  for k,v in pairs(self.tp) do
    w = w or #v
    w = (#v > w) and #v or w
    maxk = maxk or k; maxk = (k > maxk) and k or maxk
    mink = mink or k; mink = (k < mink) and k or mink
    if v ~= self.bl then
      first = first or k; first = (k < first) and k or first
      last = last or k; last = (k > last) and k or last
    end
  end
  return mink,first,last,maxk,w
end -- machine:tapelimits()

-- Moves the tape pointer (self.pt) to the first non blank symbol
function machine:resettape()
  local mink,first = self:tapelimits()
  self.pt = first or mink 
end -- machine:resettape()

-- Define the tape (self.tp) contents
-- tp can be an array or a string
-- cap is a regex capture used when tp is a string,
--   default each char a symbol
-- ... optional passed to show to format the output
function machine:tape(tp, cap, ...)
  if type(tp) == "table" then
    self.tp = tp     -- it should be an array
  elseif type(tp) == "string" then
    cap = cap or "." -- default: any single char is a symbol 
    self.tp = {}
    for d in tp:gmatch(cap) do
      table.insert(self.tp, d)
    end
  end
  self:reset()
  return self:show(...)
end -- machine:tape(tp, cap, ...)

-- Shows the current tape
-- state: if nil, it returns a string of the significant part;
--   else it returns the whole with state preceding the pointed to cell
-- sep: if nil and not single char symbols, use space as separator,
--   else use it as separator
function machine:show(state,sep)
  local mink,first,last,maxk,w = self:tapelimits()
  if not sep and w > 1 then sep = " " end
  if not first then first,last = self.pt,self.pt end
  local t = {}
  if state then
    for i = mink,maxk do
      if self.pt == i then t[#t+1] = state end
      t[#t+1] = self.tp[i]
    end
  else
    for i = first,last do
      t[#t+1] = self.tp[i]
    end
  end
  return table.concat(t,sep)
end -- machine:show(state,sep)

-- Execute computation after resetting the machine
-- history: if it is nil, then it counts the number of steps;
--   if it is not nil, then it recollects every step into ht
-- if it halts, it returns the resulting tape and the history
function machine:compute(history)
  self:reset()
  local ins
  local ht
  if history then
    if type(history) == "table" then
      ht = {bl = history.bl or "->", sq = history.sq or "|",
            prest = history.prest or "", postst = history.postst or ""}
    else  
      ht = {bl = "->", sq = "|", prest = "", postst = ""}
    end
    setmetatable(ht,ht)
    ht.__tostring = function() return table.concat(ht,ht.bl) end
    table.insert(ht, ht.sq..self:show(ht.prest..self.st..ht.postst)..ht.sq)
  else ht = 0 end
  while self:step() do
    if history then
      table.insert(ht, ht.sq..self:show(ht.prest..self.st..ht.postst)..ht.sq)
    else ht = ht + 1 end
  end
  return self:show(), ht
end -- machine:compute(history)

-- Executes one step
function machine:step()
  local ins = self.t[self.st] and
    ( self.t[self.st][self.tp[self.pt]] or self.t[self.st][self.as] )
  if ins then
    if ins[1] ~= self.as then self.st = ins[1] end
    if ins[2] ~= self.as then self.tp[self.pt] = ins[2] end
    if ins[3] == self.rt then self.pt = self.pt + 1
                         else self.pt = self.pt - 1 end
    self.tp[self.pt] = self.tp[self.pt] or self.bl
    return true
  else
    return false
  end
end -- machine:step()

-- It computes another n steps (or 1 if n is nil),
--    or until it halts,
--    or until it reaches any of the states or transitions in ...
--    each arg in ... is either state or {state,read}
-- It returns the resulting tape and the number of steps executed
function machine:steps(n,...)
  n = n or 1
  local m = 0
  local stt = {...}
  local halt
  if #stt == 0 then
    while m < n and self:step() do m = m + 1 end
  elseif #stt == 1 then
    if type(stt[1]) == "table" then
      while m < n and (self.st ~= stt[1][1] or self.tp[self.pt] ~= stt[1][2]) and self:step()
      do m = m + 1 end
    else
      while m < n and self.st ~= stt[1] and self:step() do m = m + 1 end
    end
  else
    while m < n do
      halt = false
      for _,st in ipairs(stt) do
        if type(st) == "table" then
          halt = halt or (self.st == st[1] and self.tp[self.pt] == st[2])
        else
          halt = halt or self.st == st
        end
      end
      if halt or not self:step() then break else m = m + 1 end
    end
  end
  return self:show("["..self.st.."]"), m
end -- machine:steps(n,...)


return machine
