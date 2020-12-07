import tables
import sugar

# Parse file
let inputFile = "resources/day6_input.txt"

# Store each form in a set and increment counter with length of the set
var questionSet: set[char]
var questionCount = 0
for line in lines inputFile:
  if line.len == 0:
    questionCount += questionSet.len
    questionSet = {}
  else:
    for question in line:
      questionSet.incl(question)
questionCount += questionSet.len

# Print results
echo "--- Part 1 Report ---"
echo "Question sum = " & $questionCount

## Part 2

# Use a CounterTable to store the number of 'yes' and collect and count those
# with a counter value equal to the number of lines per questionary
var questionCounterTable: CountTable[char]
var lineCounter = 0
questionCount = 0
for line in lines inputFile:
  if line.len == 0:
    let matchingElementsCounter = collect(newSeq):
      for v in questionCounterTable.values:
        if v == lineCounter: v
    questionCount += matchingElementsCounter.len
    questionCounterTable = initCountTable[char]()
    lineCounter = 0
  else:
    inc(lineCounter)
    for question in line:
      questionCounterTable.inc(question)
let matchingElementsCounter = collect(newSeq):
  for v in questionCounterTable.values:
    if v == lineCounter: v
questionCount += matchingElementsCounter.len

# Print results
echo "--- Part 2 Report ---"
echo "Question sum = " & $questionCount
