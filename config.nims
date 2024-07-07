
import std/strutils

proc run(args: varargs[string]) =
  --hints:off
  selfExec("r -d:release tbengine.nim " & join(args, " "))

task test, "Builds and runs all unit tests":
  run()

task debug, "Opens BGB debugger for a single test":
  run("debug", paramStr(paramCount()))
