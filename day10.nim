import algorithm
import strutils
import sugar
import tables

# Read input
let inputFile = "resources/day10_input.txt"
var unsortedAdapters = collect(newSeq):
  for line in lines inputFile:
    parseInt(line)
let sourceJolts = 0
unsortedAdapters.add(sourceJolts)
let deviceJolts = max(unsortedAdapters) + 3
unsortedAdapters.add(deviceJolts)

# Count differences
let sortedAdapters = sorted(unsortedAdapters)
var differences = {1: 0, 2: 0, 3: 0}.toTable
for i in 1 .. sortedAdapters.len - 1:
  differences[sortedAdapters[i] - sortedAdapters[i - 1]] += 1

# Print results
echo "--- Part 1 Report ---"
echo "Number = " & $(differences[1] * differences[3])


## Part 2


# Calculate and sum paths backwards
# Allocate subpath count array
var paths = newSeq[int](sortedAdapters.len)
# Initialize last element's number of paths to 1
paths[sortedAdapters.len - 1] = 1
# Iterate backwards
for ii in 0 .. sortedAdapters.len - 2:
  let i = sortedAdapters.len - 2 - ii # Reverse index
  # Subpath counter
  var counter = 0
  # Find valid subpaths
  for j in i + 1 .. sortedAdapters.len - 1:
    if sortedAdapters[j] - sortedAdapters[i] > 3:
      break
    # Add each subpath's subpath count
    counter += paths[j]
  # Store subpath count
  paths[i] = counter
# Subpath count of the first element is the total number of paths

# Print results
echo "--- Part 2 Report ---"
echo "Count = " & $paths[0]
