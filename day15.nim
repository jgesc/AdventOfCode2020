import tables


proc nextNumber(numberHistory: var OrderedTable[int, int], currentTurn: int,
  lastNumber: int): int =
  let lastTurn = numberHistory.getOrDefault(lastNumber)
  let nextNumber = (if lastTurn == 0: 0 else: currentTurn - lastTurn)
  numberHistory[lastNumber] = currentTurn
  return nextNumber


# Get input sequence
let puzzleInput = [1,0,15,2,10,13]

var numberHistory: OrderedTable[int, int]
for turn, number in puzzleInput[0..^2]:
  numberHistory[number] = turn + 1

let startingTurn = numberHistory.len + 1

var lastNumber = puzzleInput[^1]
for currentTurn in startingTurn .. 2020 - 1 :
  lastNumber = nextNumber(numberHistory, currentTurn, lastNumber)

# Print results
echo "--- Part 1 Report ---"
echo "Number = " & $lastNumber


## Part 2


numberHistory = initOrderedTable[int, int]()
for turn, number in puzzleInput[0..^2]:
  numberHistory[number] = turn + 1
lastNumber = puzzleInput[^1]
for currentTurn in startingTurn .. 30000000 - 1 :
  lastNumber = nextNumber(numberHistory, currentTurn, lastNumber)

# Print results
echo "--- Part 2 Report ---"
echo "Number = " & $lastNumber
