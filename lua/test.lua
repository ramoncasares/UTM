local test = {}

-- recreating C printf
function test.printf(format, ...)
  print(string.format(format,...))
end

-- Files
function test.tofile(fn, t)
  local f = assert(io.open(fn,"w"))
  if type(t) == "table" then
    f:write(table.concat(t,"\n"))
  elseif type(t) == "string" then
    f:write(t)
  end
  f:close()
end

function test.tostring(fn)
  local f = assert(io.open(fn,"r"))
  local s = f:read("*all")
  f:close()
  return s
end

test.fl = nil

function test.open(fn)
  if not test.fl then
    test.fl = assert(io.open(fn,"w"))
  end
end

function test.append(t, funcs2s)
  if not test.fl then error("Appending to file not found!"); return end
  funcs2s = funcs2s or function (...) return ... end
  if type(t) == "table" then
    test.fl:write(table.concat(funcs2s(t),"\n").."\n")
    return table.concat(t,"\n")
  elseif type(t) == "string" then
    test.fl:write(funcs2s(t).."\n")
    return t
  end
end

-- Used as funcs2s
function test.steps(s)
  local pre,st,post = s:match("(.*)%[(.*)%](.*)")
  return "\\tape{"..st.."}{"..pre.."\\="..post.."}"
end

function test.close()
  if test.fl then test.fl:close() end
end

function test.mp2csv(fn)
  local beginfig = '\\MTbeginfig%([^%)]+%); %%%% (%S+) Diagram' -- \MTbeginfig(15.5cm,23.5cm,0pt); %% MMc-UTM Diagram
  local state = '\\MTstate%((%w*)%)"(%w+)""([<>])";' --\MTstate(09)"q00"">";
  local tran = '\\MTinput%((%w+)%.%w+%)%((%w+)%.%w+%)"([%w%*]+)""([%w%*]+)";' -- \MTinput(09.ix)(11.iii)"X""X";
  local auto = '\\MTauto%((%w+)%)%([ivx,]+%)"([%w%*]+)""([%w%*]+)";' -- \MTauto(01)(x,viii)"*""0";
  local endfig = '\\MTendfig;' -- \MTendfig;
  local t = {}
  local s = test.tostring(fn)
  for line in string.gmatch(s,"[^\n]+") do t[#t+1] = line end
  local f, n,m, bf,filename, st,nm,mv, cr,nx,rd,wt
  for _,line in ipairs(t) do
    if not filename then
      bf = string.match(line,beginfig)
      if bf then filename = bf.."-x.csv"; f = {}; m = {}; n = {} end
    else
      st,nm,mv = string.match(line,state)
      if st then n[st] = nm; m[st] = mv; f[#f+1] = table.concat({nm,"*",nm,"*",mv},",") end
      cr,nx,rd,wt = string.match(line,tran)
      if cr then f[#f+1] = table.concat({n[cr],rd,n[nx],wt,m[nx]},",") end
      cr,rd,wt = string.match(line,auto)
      if cr then f[#f+1] = table.concat({n[cr],rd,n[cr],wt,m[cr]},",") end
      st = string.match(line,endfig)
      if st then test.tofile(filename,f); filename = nil end
    end
  end
end


return test
