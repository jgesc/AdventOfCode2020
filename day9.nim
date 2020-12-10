import algorithm
import strutils
import sugar

# Read file
let inputFile = "resources/day9_input.txt"
let numbers = collect(newSeq):
  for line in lines inputFile:
    parseInt(line)

# Find if two numbers in the sequence can be added to get a target number
proc findSum(sequence: seq[int], target: int): bool =
  for i in 1 .. sequence.len - 1:
    let matchingNumber = target - sequence[i - 1]
    if matchingNumber in sequence[i .. ^1]:
      return true
  return false

# Find the first number without the property
var number = 0
var index = 0
for i in 25 .. numbers.len:
  if not findSum(numbers[i - 25 .. i - 1], numbers[i]):
    number = numbers[i]
    index = i
    break

# Print results
echo "--- Part 1 Report ---"
echo "Number = " & $number


## Part 2


# Find number set that adds to the target number
let reversedNumbers = reversed(numbers[0 .. index - 1])
var slice = (0, 0)
block outer:
  for i in 0 .. index:
    var sum = 0
    for j in i .. index:
      sum += reversedNumbers[j]

      if sum > number:
        break
      if sum == number:
        slice = (i, j)
        break outer

var minNumber = min(reversedNumbers[slice[0] .. slice[1]])
var maxNumber = max(reversedNumbers[slice[0] .. slice[1]])

# Print results
echo "--- Part 2 Report ---"
echo "Min + Max = " & $(minNumber + maxNumber)
