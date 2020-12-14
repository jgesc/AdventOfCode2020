import bitops
import sequtils
import strutils
import sugar
import tables


type
  Memory = object
    data: Table[uint64, uint64]
    orMask: uint64
    andMask: uint64
    maskString: string


proc setMask(memory: var Memory, mask: string) =
  # Parse and create OR mask and AND mask
  memory.orMask = fromBin[uint64](mask.replace('X', '0'))
  memory.andMask = fromBin[uint64](mask.replace('X', '1'))
  memory.maskString = mask


proc write(memory: var Memory, address: uint64, value: uint64) =
  # Mask value
  let maskedValue = (value or memory.orMask) and memory.andMask
  # Store value
  memory.data[address] = maskedValue


proc parseInstruction(memory: var Memory, instruction: string) =
  # Identify instruction
  if instruction.startsWith("mask"):
    let maskString = instruction.split('=')[^1][1 .. ^1]
    memory.setMask(maskString)
  else:
    let addressValuePair = instruction.split('=')
    let memoryAddress = parseBiggestUint(addressValuePair[0][4 .. ^3])
    let memoryValue = parseBiggestUint(addressValuePair[1][1 .. ^1])
    
    memory.write(memoryAddress, memoryValue)


# Parse input
var memory: Memory
let inputFile = "resources/day14_input.txt"

for line in lines inputFile:
  memory.parseInstruction(line)

# Print results
echo "--- Part 1 ---"
echo "Sum = " & $(toSeq(memory.data.values).foldl(a + b))


## Part 2


proc write2(memory: var Memory, address: uint64, value: uint64, xmask: uint64) =
  if xmask == 0:
    memory.data[address] = value
  else:
    var nextXmask = xmask
    let switchingBit = xmask.firstSetBit() - 1
    nextXmask.clearBit(switchingBit)
    
    var switchedAddress = address
    switchedAddress.setBit(switchingBit)
    memory.write2(switchedAddress, value, nextXmask)
    switchedAddress.clearBit(switchingBit)
    memory.write2(switchedAddress, value, nextXmask)


proc write2(memory: var Memory, address: uint64, value: uint64) =
  let xmask = fromBin[uint64](memory.maskString.map(x => (if x == 'X': '1' else: '0')).join)
  let orMask = fromBin[uint64](memory.maskString.map(x => (if x == '1': '1' else: '0')).join)
  memory.write2(address or orMask, value, xmask)


proc parseInstruction2(memory: var Memory, instruction: string) =
  # Identify instruction
  if instruction.startsWith("mask"):
    let maskString = instruction.split('=')[^1][1 .. ^1]
    memory.setMask(maskString)
  else:
    let addressValuePair = instruction.split('=')
    let memoryAddress = parseBiggestUint(addressValuePair[0][4 .. ^3])
    let memoryValue = parseBiggestUint(addressValuePair[1][1 .. ^1])
    
    memory.write2(memoryAddress, memoryValue)


# Parse input
var memory2: Memory

for line in lines inputFile:
  memory2.parseInstruction2(line)

# Print results
echo "--- Part 2 ---"
echo "Sum = " & $(toSeq(memory2.data.values).foldl(a + b))