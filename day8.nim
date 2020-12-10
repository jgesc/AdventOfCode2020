import strscans
import strutils

# Declare 'Processor' type
type
  Processor = object
    accumulator: int16
    programCounter: uint16
    visitedLines: set[uint16]

  Opcode = enum
    acc
    jmp
    nop


# Instruction parsing, returns 'true' when program finishes
proc operation(processor: var Processor, opcode: Opcode, argument: int16):bool =
  # Check if line was already visited
  if processor.programCounter in processor.visitedLines:
    return true # Program finished
  # Else record operation
  processor.visitedLines.incl(processor.programCounter)

  # Perform operation
  case opcode
  of acc:
    processor.accumulator += argument
  of jmp:
    processor.programCounter += uint16(argument) - 1
  of nop:
    discard

  # Increase program counter
  processor.programCounter += 1


proc reset(processor: var Processor) =
  var newProcessor: Processor
  processor = newProcessor


# Parse file
proc parseBoot(file: string): seq[(Opcode, int16)] =
  # Parse file
  var ops: seq[(Opcode, int16)]
  for line in lines file:
    # Read line
    var opStr: string
    var opArg: int
    discard line.scanf("$+ $i", opStr, opArg)

    # Convert and store
    let op = (parseEnum[Opcode](opStr), int16(opArg))
    ops.add(op)

  return ops


# Run boot file on processor, returns 'true' on normal termination
proc run(processor: var Processor, ops: seq[(Opcode, int16)]): bool =
  # Run program
  var repeatedInstruction = false
  while not repeatedInstruction:
    # Check for normal termination
    if processor.programCounter >= uint16(ops.len):
      return true
    # Execute operation
    let (op, arg) = ops[processor.programCounter]
    repeatedInstruction = processor.operation(op, arg)
  return false


# Run boot file on processor while recording programCounter
proc debug(processor: var Processor, ops: seq[(Opcode, int16)]): seq[uint16] =
  # Run program
  var repeatedInstruction = false
  while not repeatedInstruction:
    result.add(processor.programCounter)
    # Check for normal termination
    if processor.programCounter >= uint16(ops.len):
      break
    # Execute operation
    let (op, arg) = ops[processor.programCounter]
    repeatedInstruction = processor.operation(op, arg)

# Run boot file
let inputFile = "resources/day8_input.txt"
var processor: Processor

var bootCode = parseBoot(inputFile)
discard processor.run(bootCode)

# Print results
echo "--- Part 1 Report ---"
echo "Accumulator = " & $processor.accumulator


## Part 2


# Run boot code on debug mode
processor.reset
let trace = processor.debug(bootCode)

# Find last instruction run of type JMP or NOP
for instruction in trace:
  var opcodePtr: ptr Opcode = bootCode[instruction][0].addr
  if opcodePtr[] in [jmp, nop]:
    # Store old reference
    let oldOpcode = opcodePtr[]
    # Switch instruction
    opcodePtr[] = (if opcodePtr[] == jmp: nop else: jmp)
    # Run boot code
    processor.reset
    if processor.run(bootCode):
      break
    else:
      # Restore instruction and move on
      opcodePtr[] = oldOpcode

# Print results
echo "--- Part 2 Report ---"
echo "Accumulator = " & $processor.accumulator
