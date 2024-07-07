##[

Build script for tbengine. Builds unit tester ROMs and tests them.
Built files are written to <projectDir>/build, use -d:buildDir:pathToBuildDir
when compiling to override this behavior.

Requires (in PATH):
- ninja
- rgbasm, rgblink, rgbfix
- bgb

]##

import
  std/[compilesettings, macros, os, osproc, paths, strformat]

type
  Test = object
    name: string
    tbengineFlags: string

func test(name: string; flags = ""): Test =
  result = Test(name: name, tbengineFlags: flags)

const
  testManifest = [
    test("schedule.0"),
    test("schedule.1"),
    test("schedule.2"),
    test("updateNr51.1"),
    test("updateNr51.2"),
    test("writeWaveform.0"),
    test("writeWaveform.1"),
    test("writeWaveform.badindex")
    #test("hookBankEnter", "-D TbeHookBankEnter"),
    #test("hookBankExit", "-D TbeHookBankExit")
  ]


type
  TestResultKind = enum
    emulatorError
    timedOut
    completed
  
  TestResult = object
    kind: TestResultKind
    code: int

const
  srcDir = getProjectPath()
  nimcacheDir = querySetting(SingleValueSetting.nimcacheDir)
  buildDir = nimcacheDir / "build"
  ninjaPath = buildDir / "build.ninja"
  ninjaSrcPrefix = "$srcDir" & DirSep

  cmdPrefix = block:
    when defined(windows):
      "cmd /c "
    else:
      ""

func passed(tr: TestResult): bool =
  result = tr.kind == completed and tr.code == 0

func codeStr(code: int): string =
  result = &"${code:02X}"

func `$`(tr: TestResult): string =
  if tr.passed:
    result = &"passed ({codeStr(tr.code)})"
  else:
    result = "failed ("
    case tr.kind
    of emulatorError:
      result.add(&"emulator exited with code {tr.code}")
    of timedOut:
      result.add("timed out")
    of completed:
      result.add(codeStr(tr.code))
    result.add(')')


func ninjaSrc(path: string): string =
  result = ninjaSrcPrefix & path

func ninjaBuild(output, input, rule: string;): string =
  result = &"build {output}: {rule} {input}"

func getTestPrefix(name: string): string =
  result = "tests" / &"test.{name}"

proc makeNinja() =

  createDir(buildDir)
  let f = open(ninjaPath, fmWrite)
  f.write("srcDir = ")
  f.writeLine(srcDir)
  
  f.write(&"""

asmFlags = -I {ninjaSrcPrefix}inc -I {ninjaSrcPrefix} -p 0xFF -h
linkFlags =
fixFlags = -f lhg -i TEST -t Tester -p 0xFF -m 0x03 -r 0x02

rule assemble
  command = rgbasm $asmFlags -M $out.d -o $out $in
  depfile = $out.d
  description = RGBASM $in

build tests/main.asm.obj: assemble $srcDir/tests/main.asm
build tests/tbengine.asm.obj: assemble $srcDir/tbengine.asm
  asmFlags = $asmFlags -E

""")

  for i, t in pairs(testManifest):
    let
      testPrefix = getTestPrefix(t.name)
      asmFile = &"{testPrefix}.asm"
      objFile = &"{asmFile}.obj"
    var depends = "tests/main.asm.obj"
    if t.tbengineFlags == "":
      # use base tbengine
      depends.add(" tests/tbengine.asm.obj")
    else:
      # use custom tbengine with test-specific flags
      let tbengineObj = &"{testPrefix}.tbengine.asm.obj"
      f.writeLine(ninjaBuild(tbengineObj, ninjaSrc("tbengine.asm"), "assemble"))
      f.writeLine(&"  asmFlags = $asmFlags -E {t.tbengineFlags}")
      depends.add(' ')
      depends.add(tbengineObj)

    depends.add(' ')
    depends.add(objFile)
    f.writeLine(ninjaBuild(objFile, ninjaSrc(asmFile), "assemble"))

    let
      ruleLink = &"romLink{i}"
      romFile = &"{testPrefix}.gb"

    f.writeLine(&"""
rule {ruleLink}
  command = {cmdPrefix}rgblink $linkFlags -n {testPrefix}.sym -o $out $in && rgbfix $fixFlags $out
  description = RGBLINK $out
""")

    f.writeLine(ninjaBuild(romFile, depends, ruleLink))

  f.close()

proc runTest(test: string): TestResult =
  let
    pathRom = &"{getTestPrefix(test)}.gb"
    bgb = startProcess(
      "bgb", buildDir,
      ["-hf", "-setting", "DebugSrcBrk=1", "-rom", pathRom],
      options = { poUsePath, poParentStreams }
    )
  let exitcode = bgb.waitForExit(3000)
  if bgb.running():
    bgb.terminate()
    result.kind = timedOut
  else:
    if exitcode == 0:
      let
        pathSav = changeFileExt(buildDir / pathRom, "sav")
        sav = open(pathSav, fmRead)
      result.code = sav.readChar().int
      result.kind = completed
      sav.close()
    else:
      result.kind = emulatorError
      result.code = exitcode
  bgb.close()

proc buildAll(): int =
  # build ninja file if needed (either not created yet or the build script was updated)
  if not fileExists(ninjaPath) or fileNewer(getAppFilename(), ninjaPath):
    makeNinja()
  
  # build
  result = execCmd(&"ninja -C {buildDir}")

proc testAll(): int =
  # run tests
  var 
    passCount = 0
    testResults: array[testManifest.len, TestResult]
  for i, test in pairs(testManifest):
    echo "running test: ", test.name
    let tr = runTest(test.name)
    if tr.passed:
      inc passCount
    testResults[i] = tr

  # display results
  for i, tr in pairs(testResults):
    echo &"{testManifest[i].name:<67} {tr}"

  result = int(passCount != testManifest.len)

proc debug(name: string): int =
  let romFile = quoteShell(buildDir / &"{getTestPrefix(name)}.gb")
  result = execCmd(&"bgb -rom {romFile} -br 100")

proc main(): int =
  # usage
  # build everything: tbengine
  # build a test rom: tbengine mktest <name> <srcFiles...>
  # debug a test rom: tbengine debug <name>


  result = buildAll()
  if result != 0:
    return

  let args = commandLineParams()
  if args.len == 2:
    if args[0] == "debug":
      result = debug(args[1])
    else:
      stderr.writeLine("usage: tbengine debug <testname>")
      result = 1
  else:
    result = testAll()


when isMainModule:
  import std/exitprocs
  setProgramResult(main())
