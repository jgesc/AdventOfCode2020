import algorithm
import strutils

# Parse input
let inputFile = "resources/day5_input.txt"

var seatIds: seq[uint16]
for line in lines inputFile:
  # Convert to number in binary
  let asBin = line.multiReplace(("F", "0"), ("B", "1"), ("L", "0"), ("R", "1"))
  # Convert to number
  let seatId = fromBin[uint16](asBin)
  # Add to the list
  seatIds.add(seatId)

# Get highest seat ID
let highestId = seatIds.max

# Print results
echo "--- Part 1 Report ---"
echo "Highest seat ID found = " & $highestId

## Part 2
# Find missing seat
let sortedIds = sorted(seatIds)
let firstSeatId = sortedIds[0]
# Find missing element
var missingId: uint16
for index, seatId in sortedIds:
  if seatId != uint16(index) + firstSeatId:
    missingId = seatId - 1
    break

# Print results
echo "--- Part 2 Report ---"
echo "Missing seat ID found = " & $missingId
