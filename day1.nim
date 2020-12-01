import lists
import strutils

# Reading variables
var numbers = initDoublyLinkedList[int]()
var maxVal = 0

# Open input file and read line by line
for line in lines "resources/day1_input.txt":
  # Parse line to int
  let number = parseInt(line)
  # Check max value
  if number > maxVal:
    maxVal = number
  # Append to list
  numbers.append(number)

# Create "check if exists" array
var exists: seq[bool] = newSeq[bool](maxVal + 1);
for number in numbers:
  exists[number] = true

# Find match
let target = 2020
var result: (int, int)
for number in numbers:
  # Check for each required number
  let diff = target - number
  # Check if exists
  if exists[diff]:
    # If exists store and break
    result = (number, diff)
    break

# Echo results
echo "--- Part 1 Report ---"
echo "Found pair " & $result
echo "Answer: " & $(result[0] * result[1])

## Part 2
# Create 'can add' array
var canAdd: seq[(bool, (int, int))]
canAdd = newSeq[(bool, (int, int))]((maxVal + 1) * 2);
# Store all possible sums
for number1 in numbers:
  for number2 in numbers:
    canAdd[number1 + number2] = (true, (number1, number2))

# Find match
var result2: (int, int, int)
for number in numbers:
  # Check for each required number
  let diff = target - number
  # Check if exists
  if canAdd[diff][0] and number != canAdd[diff][1][0] and
    number != canAdd[diff][1][1]:
    # If exists store and break
    result2 = (number, canAdd[diff][1][0], canAdd[diff][1][1])
    break

# Echo results
echo "--- Part 2 Report ---"
echo "Found triple " & $result2
echo "Answer: " & $(result2[0] * result2[1] * result2[2])
