import sequtils
import sugar

# Count trees on a slope
proc treeCount(input: string, dx, dy: int) : int =
  let treeChar = '#'
  var
    x = 0
    y = 0
  result = 0

  # Go line by line
  for line in lines input:
    # Check y and x position
    if y == 0:
      if line[x] == treeChar:
        result += 1
      # Increase x poisition
      x = (x + dx) mod line.len
    # Increase y position
    y = (y + 1) mod dy

let inputFile = "resources/day3_input.txt"

echo "--- Part 1 Report ---"
echo "Trees = " & $treeCount(inputFile, 3, 1)

## Part 2
# Define slopes
let slopes = [
  (1, 1),
  (3, 1),
  (5, 1),
  (7, 1),
  (1, 2)
]

# Calculate the tree count from all slopes
let treesPerSlope = collect(newSeq):
  for x, y in slopes.items:
    treeCount(inputFile, x, y)

# Calculate product
let product = treesPerSlope.foldl(a * b)

echo "--- Part 2 Report ---"
echo "Trees per slope = " & $treesPerSlope
echo "Tree product = " & $product
