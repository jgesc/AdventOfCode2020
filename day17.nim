import sets
import sequtils


# Declare types
type
  Coordinate = tuple
    x, y, z: int

  Cube = HashSet[Coordinate]


# Parse input file
proc parseInput(inputFile: string): Cube =
  var y: int

  for line in lines inputFile:
    for z, value in line:
      if value == '#':
        result.incl((0, y, z))
    inc(y)


# Neighbor iterator
iterator neighbors(cell: Coordinate): Coordinate =
  let (X, Y, Z) = cell
  for x in X-1 .. X+1:
    for y in Y-1 .. Y+1:
      for z in Z-1 .. Z+1:
        yield (x, y, z)


# Count active neighbors
proc countActiveNeighbors(cube: Cube, cell: Coordinate, earlyExit: int = 3): int =
  result = (if cell in cube: -1 else: 0) # Ignore the cell itself
  # Count active neighbors
  for neighbor in cell.neighbors:
    if neighbor in cube:
      inc(result)
      # Early exit to save cycles
      if result > earlyExit:
        break


# Update a cell in a cube
proc updateCell(input: Cube, output: var Cube, cell: Coordinate) =
  let activeNeighbors = input.countActiveNeighbors(cell)
  if cell in input:
    # Cell active
    if activeNeighbors in 2 .. 3:
      output.incl(cell)
  else:
    # Cell inactive
    if activeNeighbors == 3:
      output.incl(cell)


# Update cube
proc updateCube(input: Cube): Cube =
  var cellsNeedingUpdate: HashSet[Coordinate]

  # Get all cells that need to be updatedº
  for cell in input.items:
    cellsNeedingUpdate.incl(toSeq(cell.neighbors).toHashSet)

  # Update all cells
  for cell in cellsNeedingUpdate:
    updateCell(input, result, cell)


# Calculate boot sequence
let inputFile = "resources/day17_input.txt"
var cube: Cube = parseInput(inputFile)
for i in 1..6:
  cube = cube.updateCube()

# Print results
echo "--- Part 1 Report ---"
echo "Number of active cells = " & $cube.len


## Part 2


# Declare types
type
  Coordinate4D = tuple
    x, y, z, w: int

  Hypercube = HashSet[Coordinate4D]


# Parse input file
proc parseInput4D(inputFile: string): Hypercube =
  var y: int

  for line in lines inputFile:
    for z, value in line:
      if value == '#':
        result.incl((0, y, z, 0))
    inc(y)


# Neighbor iterator
iterator neighbors(cell: Coordinate4D): Coordinate4D =
  let (X, Y, Z, W) = cell
  for x in X-1 .. X+1:
    for y in Y-1 .. Y+1:
      for z in Z-1 .. Z+1:
        for w in W-1 .. W+1:
          yield (x, y, z, w)


# Count active neighbors
proc countActiveNeighbors(cube: Hypercube, cell: Coordinate4D, earlyExit: int = 3): int =
  result = (if cell in cube: -1 else: 0) # Ignore the cell itself
  # Count active neighbors
  for neighbor in cell.neighbors:
    if neighbor in cube:
      inc(result)
      # Early exit to save cycles
      if result > earlyExit:
        break


# Update a cell in a cube
proc updateCell(input: Hypercube, output: var Hypercube, cell: Coordinate4D) =
  let activeNeighbors = input.countActiveNeighbors(cell)
  if cell in input:
    # Cell active
    if activeNeighbors in 2 .. 3:
      output.incl(cell)
  else:
    # Cell inactive
    if activeNeighbors == 3:
      output.incl(cell)


# Update cube
proc updateCube(input: Hypercube): Hypercube =
  var cellsNeedingUpdate: HashSet[Coordinate4D]

  # Get all cells that need to be updatedº
  for cell in input.items:
    cellsNeedingUpdate.incl(toSeq(cell.neighbors).toHashSet)

  # Update all cells
  for cell in cellsNeedingUpdate:
    updateCell(input, result, cell)


# Calculate boot sequence
var hypercube: Hypercube = parseInput4D(inputFile)
for i in 1..6:
  hypercube = hypercube.updateCube()

# Print results
echo "--- Part 2 Report ---"
echo "Number of active cells = " & $hypercube.len
