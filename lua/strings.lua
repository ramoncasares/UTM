local strings = {}

-- Codes number n (positional decimal)
-- as its corresponding string in alphabet a;
-- sep is an optional symbol separator
function strings.code(n,a, sep)
  local t = {}
  local r
  while n > 0 do
    n,r = n // #a, n % #a  -- Euclidean division
    if r == 0 then r = #a; n = n - 1 end
    t[#t+1] = a[r]
  end
  return table.concat(strings.reverse(t), sep)
end -- strings.code(n,a, sep)

-- Reverses array: a[1]...a[#a] -> b[#a]...b[1]
-- Called from strings.code(n,a, sep)
function strings.reverse(a)
  local b = {}
  local n = #a
  while n > 0 do b[#b+1] = a[n]; n = n - 1 end
  return b
end -- strings.reverse(a)

-- Decodes string s in alphabet a,
-- as a positional decimal number
function strings.decode(s,a)
  local ai = strings.inverse(a)
  local n = 0
  local i = 1
  while i <= #s do
    n = #a * n + ai[s:sub(i,i)]
    i = i + 1
  end
  return n
end -- strings.decode(s,a)

-- Inverses table: k[v] -> v[k]
-- Called from strings.decode(s,a)
function strings.inverse(t)
  local r = {}
  for k,v in pairs(t) do r[v] = k end
  return r
end -- strings.inverse(t)

return strings
