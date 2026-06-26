% UTM

This is the `README.md` file of the
[`github.com/ramoncasares/UTM`](https://github.com/ramoncasares/UTM.git)
repository.
It contains tools to run and test Turing machines,
including universal Turing machines.
It is organized in directories:

- `lua/`: programs (modules) in [Lua](https://www.lua.org/).
   - `lua/strings.lua`: implementation of the bijection from strings to naturals.
   - `lua/machine.lua`: Turing machine interpreter.
   - `lua/code.lua`: translates a Turing machine into a binary one.
   - `lua/MM.lua`: translates a Turing machine into a MMx-UTM program, and back.
   - `lua/test.lua`: auxiliary functions.
- `test/`: testing suites (scripts) in Lua.
  - `test/strings.lua`: testing suite for `lua/strings.lua`.
  - `test/machine.lua`: testing suite for `lua/machine.lua`.
  - `test/BB.lua`: testing suite for BusyBeavers.
  - `test/MMo.lua`: testing suite for MMo-UTM.
  - `test/MMr.lua`: testing suite for MMr-UTM.
  - `test/MMc.lua`: testing suite for MMc-UTM.
- `csv/`: universal Turing machines tables.
  - `csv/MMo-UTM.csv`: the table read from the diagram by Minsky.
  - `csv/MMr-UTM.csv`: the previous one plus start, bidirectionality, and cleaning.
  - `csv/MMc-UTM.csv`: the table of the universal Turing machine.
- `doc/`: document sources.
  - `doc/UTM.tex`: the main TeX source of the
    [PDF document](https://doi.org/10.6084/m9.figshare.32261133).
  - `doc/TM.tex`: aditional TeX macros to draw the state diagrams.
  - `doc/MAKE.sh`: script to build the PDF.

This was developed on
a standard Debian Trixie 13 Linux computer,
with Lua and TeX.
It could need some adjustments on other systems.
Regarding Lua, version 5.4 works.
For TeX, the `texlive` standard packages in Trixie work;
but it requires programs `dvipdfm` and `mpost` (metapost).


lua
----

To run a program, go to dir `lua`,
call the `lua` interpreter in interactive mode,
load the module, and try yourself.
To exit the interactive mode,
enter `os.exit()` or just Ctrl-D.
If you run a non-halting computation,
use Ctrl-C to abort.

```
UTM $ cd lua
UTM/lua $ lua -i
Lua 5.4.7  Copyright (C) 1994-2024 Lua.org, PUC-Rio
> str = require("strings")
> str.code(33,{"1","2"})
11121
> str.decode("11121",{"1","2"})
33
> os.exit()
UTM/lua $
```


test
----

To run a test suite, go to dir `test`,
where you can find some `lua` scripts
with which to test the Turing machine interpreter
and the universal Turing machines.
They also create files used in the document.
Please do not forget to set `LUA_PATH`.
For example, in bash, to run `test/MMo.lua`, you can do:

```
UTM/lua $ cd ../test
UTM/test$ LUA_PATH="../lua/?.lua" lua -i < MMo.lua
```

While in bash, you can export `LUA_PATH` to call
several testing scripts in a single shell session.

```
UTM/test$ export LUA_PATH="../lua/?.lua"
UTM/test$ lua -i < strings.lua
UTM/test$ lua -i < machine.lua
UTM/test$ lua -i < BB.lua
UTM/test$ lua -i < MMo.lua
UTM/test$ lua -i < MMr.lua
UTM/test$ lua -i < MMc.lua
```

You can also redirect the output to a file.

```
UTM/test$ lua -i < MMo.lua > MMo.out
```

In order to see the output,
we have always called `lua -i`, that is,
Lua in the interactive mode.
However, after reading each file, an EOF is sent,
and then every time `lua` returns.
When we want to continue inside a Lua session,
we do `lua -i MMo.lua`.
Now we do not see any output,
though it was written to `MMo.out` by the previous command,
but we can use the objects defined in the script.
So this is the lua session that takes place
if you enter what is after the prompts,
that is, `lua -i MMo.lua` to enter the Lua session,
 and then `MM.UTMo:compute()`, `MM.UTMo:show("["..MM.UTMo.st.."]")`,
and so on inside the Lua session.

```
UTM/test$ lua -i MMo.lua
Lua 5.4.7  Copyright (C) 1994-2024 Lua.org, PUC-Rio
> MM.UTMo:compute()
M10101000Y1BBAXAAAAAABABXAABAABAABXABAAABBBAXABBABAAAAXBAAABABBAXBABABBAAAXBBAA11110Y	81
> MM.UTMo:show("["..MM.UTMo.st.."]")
M10101000Y1BBAXAAAAAABABXAABAABAABXABAAABBBAXABBABAAAAXBAAABABBAXBABABBAAAXBBAA11110Y[q99]0
> MM.UTMo:compute()
M10101000Y1110XAAAAAABABXAABAABAABXABAAABBBAXABBABAAAAXBAAABABBAXBABABBAAAXBBAABBBB0Y	507
> MM.UTMo:show("["..MM.UTMo.st.."]")
M10101000Y1110XAAAAAABABXAABAABAABXABAAABBBAXABBABAAAAXBAAABABBAXBABABBAAAXBBAABBBB0Y[q99]0
> os.exit()
UTM/test$
```

Or, you can get both, the output and the definitions, thus:

```
UTM/test$ cat MMo.lua - | lua -i
```

csv
----

The complete tables of some universal Turing machines.
They are presented in detail in the document.


doc
----

Directory `doc` contains the
plain TeX macros to build the [PDF file](https://doi.org/10.6084/m9.figshare.32261133),
LaTeX is not required.
The `Make.sh` file is a bash script that makes the PDF document.
It requires some programs and macros defined in my texmf repository,
[`github.com/ramoncasares/texmf`](https://github.com/ramoncasares/texmf.git).


```
UTM/test$ cd ../doc
UTM/doc$ ./MAKE.sh
```

In addition to the files in my texmf repo,
these are the files needed to compose the document.
The first two are in this directory (`doc`),
and the last three in directory `csv`.
Running `MAKE.sh` create some other files
in dirs `doc`, `csv`, and `test`.


```
./UTM.tex
./TM.tex
../csv/MMo-UTM.csv
../csv/MMr-UTM.csv
../csv/MMc-UTM.csv
```

