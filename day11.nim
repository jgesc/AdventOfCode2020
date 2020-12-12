import sequtils
import sugar

# Define types
type
  Cell = enum
    Occupied = '#'
    Nothing = '.'
    Empty = 'L'

  Grid = seq[seq[Cell]]


# Get element from grid
proc get(grid: Grid, x, y: int) : Cell =
  let width = grid.len
  let length = grid[0].len

  if x notin 0 .. width - 1 or y notin 0 .. length - 1:
    result = Empty
  else:
    result = grid[x][y]


# Apply rules, return if the grid changed
proc applyRules(grid: var Grid) : bool =
  var newGrid = grid
  # Get grid dimensions
  let width: int = grid.len
  let length: int = grid[0].len

  # Iterate through the grid
  for x in 0 .. width - 1:
    for y in 0 .. length - 1:
      case grid[x][y]:
        of Empty:
          # Check there are no surrounding occupied seats
          block outer:
            for offset in -1 .. 1:
              if grid.get(x + offset, y - 1) == Occupied or
                grid.get(x + offset, y) == Occupied or
                grid.get(x + offset, y + 1) == Occupied:
                break outer
            # Occupy seat
            result = true
            newGrid[x][y] = Occupied
        of Occupied:
          # Check if surrounded by 4 occupied seats
          var counter = 0
          for offset in -1 .. 1:
            if grid.get(x + offset, y - 1) == Occupied: inc(counter)
            if grid.get(x + offset, y) == Occupied: inc(counter)
            if grid.get(x + offset, y + 1) == Occupied: inc(counter)
          # Clear seat
          if counter >= 5:
            result = true
            newGrid[x][y] = Empty
        of Nothing:
          discard
  # Switch grids
  grid = newGrid


# Parse input
let inputFile = "resources/day11_input.txt"
var grid: Grid
for line in lines inputFile:
  grid.add(line.mapIt(Cell(it)))

# Simulate
while grid.applyRules(): discard

# Count occupied seats
let occupiedSeats = grid.map(row => row.count(Occupied)).foldl(a + b)

# Print results
echo "--- Part 1 Report ---"
echo "Occupied seats = " & $occupiedSeats


## Part 2


proc raycast(grid: Grid, x0, y0, dx, dy: int): Cell =
  var x = x0 + dx
  var y = y0 + dy

  while x in 0 .. grid.len and y in 0 .. grid[0].len:
    let cell = grid.get(x, y)
    if cell != Nothing:
      return cell
    x += dx
    y += dy
  return Nothing

# Apply rules, return if the grid changed
proc applyNewRules(grid: var Grid) : bool =
  var newGrid = grid
  # Get grid dimensions
  let width: int = grid.len
  let length: int = grid[0].len

  # Iterate through the grid
  for x in 0 .. width - 1:
    for y in 0 .. length - 1:
      case grid[x][y]:
        of Empty:
          # Check there are no surrounding occupied seats
          block outer:
            for dx in -1 .. 1:
              for dy in -1 .. 1:
                if grid.raycast(x, y, dx, dy) == Occupied:
                  break outer
            # Occupy seat
            result = true
            newGrid[x][y] = Occupied
        of Occupied:
          # Check if surrounded by 5 occupied seats
          var counter = 0
          for dx in -1 .. 1:
            for dy in -1 .. 1:
              if grid.raycast(x, y, dx, dy) == Occupied:
                inc(counter)
                # Clear seat
                if counter >= 6:
                  result = true
                  newGrid[x][y] = Empty
        of Nothing:
          discard
  # Switch grids
  grid = newGrid


# Parse input
var grid2: Grid
for line in lines inputFile:
  grid2.add(line.mapIt(Cell(it)))

# Simulate
while grid2.applyNewRules(): discard


# Count occupied seats
let occupiedSeats2 = grid2.map(row => row.count(Occupied)).foldl(a + b)

# Print results
echo "--- Part 2 Report ---"
echo "Occupied seats = " & $occupiedSeats2
