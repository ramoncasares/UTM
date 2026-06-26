#!/bin/dash

cd ../csv/

diff MMo-UTM.csv MMr-UTM.csv > MMo2MMr.patch

cd ../test/

export LUA_PATH="../lua/?.lua"

lua -l test -e 'test.mp2csv("../doc/UTM.tex")'

cat MMo-UTM-x.csv | tr '*' 'Z' | sort | tr 'Z' '*' > MMo-UTM-s.csv
cat MMr-UTM-x.csv | tr '*' 'Z' | sort | tr 'Z' '*' > MMr-UTM-s.csv
cat MMc-UTM-x.csv | tr '*' 'Z' | sort | tr 'Z' '*' > MMc-UTM-s.csv

diff MMo-UTM-s.csv ../csv/MMo-UTM.csv > MMo-UTM.patch
diff MMr-UTM-s.csv ../csv/MMr-UTM.csv > MMr-UTM.patch
diff MMc-UTM-s.csv ../csv/MMc-UTM.csv > MMc-UTM.patch

lua -i < strings.lua > strings.out
lua -i < machine.lua > machine.out
lua -i < BB.lua > BB.out
lua -i < MMo.lua > MMo.out
lua -i < MMr.lua > MMr.out
lua -i < MMc.lua > MMc.out

cd ../doc/
clrtex UTM
touch auxiliar.abc
wpdf UTM tex
