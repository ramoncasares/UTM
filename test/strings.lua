-- test/strings.lua (RMCG20260116)

str = require("strings")

AB2 = {"1","2"}
AB4 = {"1","2","3","4"}
AB8 = {"1","2","3","4","5","6","7","8"}
str.code(6,AB2)
print( str.code(6,AB2) == "22" )
str.decode("22",AB2)
print( str.decode("22",AB2) == 6 )
str.code(33,AB2)
str.decode("11121",AB2)
str.code(31,{"1","2"})
str.decode("11111",{"1","2"})
str.code(30,AB2)
str.decode("2222",AB2)
str.code(0,AB2)
str.decode("",AB2)
str.code(0,AB8)
str.decode("",AB8)
str.code(193,AB4)
str.decode("2341",AB4)
print( str.code(str.decode("423",AB4),AB4) == "423" )
str.code(85,AB4)
str.decode("1111",AB4)
str.code(24,AB2)
str.decode("2112",AB2)
str.code(42,AB2)
str.decode("12122",AB2)
str.code(8,{"1"})
str.decode("11111111",{"1"})

-- end test/strings.lua
