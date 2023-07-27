# Package

version       = "0.1.0"
author        = "ZenoABC"
description   = "PB2 Interface for map objects."
license       = "Proprietary"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.14"

# Tasks

task cr, "Shorthand for nim c -r main.nim":
    exec("nim c -r main.nim")