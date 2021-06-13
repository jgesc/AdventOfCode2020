# NOTE: if an exception is thrown during execution, stack size has
# to be increased with command 'ulimit -s unlimited'

import sequtils
import strutils

# Types
type
  Cup = int

# Input data parser
proc parseInput(inputData: string): (array[9,Cup], int) =
  # Parse input
  let cups = (@inputData).mapIt(ord(it) - ord('0') - 1)
  # Initialize next cup
  var nextCup: array[9, Cup]
  for i in 0..8:
    nextCup[cups[i]] = cups[(i+1) mod 9]

  (nextCup, cups[0])

# Move
proc move(cups: var openArray[Cup], current: Cup): Cup =
  let l = cups.len
  # Pick three clockwise cups
  let pickedCups = [
    cups[current], cups[cups[current]], cups[cups[cups[current]]]]
  cups[current] = cups[cups[cups[cups[current]]]]

  # Select destination cup
  var destination: Cup
  for i in 1..l-1:
    destination = (l-1) - (((l-1) - current + i) mod l)
    if destination notin pickedCups:
      break

  # Place clockwise
  cups[pickedCups[^1]] = cups[destination]
  cups[destination] = pickedCups[0]

  # Pick new current
  cups[current]

# Print cup ordering
proc order(cups: openArray[Cup]): seq[Cup] =
  let l = cups.len
  var ordering = newSeq[Cup](l)
  ordering[0] = 0
  var index = 0
  for i in 1..l-1:
    index = cups[index]
    ordering[i] = index
  ordering

# Input data
let inputData = "716892543"

# Parse input data
var (cups, current) = parseInput(inputData)

# Perform 100 moves
for _ in 1..100:
  current = cups.move(current)

# Get final cup ordering
var ordering = cups.order()
ordering.delete(0, 0)

# Print results
echo "--- Part 1 Report ---"
echo "Cup ordering = " & ordering.mapIt(intToStr(it + 1)).join()


## Part 2


const Ncups: int = 1000000
# Input data parser
proc parseInputExtended(inputData: string): (array[Ncups,Cup], int) =
  # Parse input
  let cups = (@inputData).mapIt(ord(it) - ord('0') - 1)

  # Initialize next cup
  var nextCup: array[Ncups, Cup]
  for i in 0..7:
    nextCup[cups[i]] = cups[(i+1)]
  nextCup[cups[^1]] = 9

  for i in 9..Ncups-2:
    nextCup[i] = (i+1) mod Ncups
  nextCup[^1] = cups[0]

  (nextCup, cups[0])


# Parse input data
var cups2: array[Ncups,Cup]
(cups2, current) = parseInputExtended(inputData)

# Perform 10000000 moves
for i in 1..10000000:
  current = cups2.move(current)

# Print results
echo "--- Part 2 Report ---"
echo "Clockwise cups product = " & $((cups2[0]+1) * (cups2[cups2[0]]+1))
