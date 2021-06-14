import sequtils
import sets
import sugar

# Types
type
  Direction = (float, float)
  StringParser = object
    stream: string
    pointer: int
  FloorPlan = HashSet[Direction]

# Constant directions
const
  East = (1.0, 0.0)
  West = (-1.0, 0.0)
  NorthEast = (0.5, 1.0)
  SouthEast = (0.5, -1.0)
  NorthWest = (-0.5, 1.0)
  SouthWest = (-0.5, -1.0)

  AllDirections = [
    East,
    West,
    NorthEast,
    SouthEast,
    NorthWest,
    SouthWest
  ]

proc `+`(a, b: Direction): Direction =
  (a[0] + b[0], a[1] + b[1])

# String parser
proc finished(parser: StringParser): bool =
  parser.pointer >= parser.stream.len

proc next(parser: var StringParser): char =
  if not parser.finished:
    let nextChar = parser.stream[parser.pointer]
    inc parser.pointer
    return nextChar
  '\0'

proc parser(stream: string): StringParser =
  StringParser(
    stream: stream,
    pointer: 0
  )

proc parseNextDirection(parser: var StringParser): Direction =
  case parser.next:
    of 'e':
      East
    of 'w':
      West
    of 'n':
      if parser.next == 'e':
        NorthEast
      else:
        NorthWest
    of 's':
      if parser.next == 'e':
        SouthEast
      else:
        SouthWest
    else:
      East

proc parseLine(line: string): seq[Direction] =
  var directions: seq[Direction]
  var parser = line.parser
  while not parser.finished:
    directions.add(parser.parseNextDirection)
  directions


# Parse input file
let inputFile = "resources/day24_input.txt"
var blackTiles: FloorPlan
for line in lines inputFile:
  let tile = toHashSet([line.parseLine().foldl(a + b)])
  blackTiles = blackTiles -+- tile

# Print results
echo "--- Part 1 Report ---"
echo "Black tiles = " & $blackTiles.card


## Part 2


# Utils
proc getSurrounding(tile: Direction): FloorPlan =
  collect(initHashSet):
    for direction in AllDirections:
      {tile + direction}

proc filterWhite(floor: FloorPlan, tiles: FloorPlan): FloorPlan =
  tiles - floor

proc filterBlack(floor: FloorPlan, tiles: FloorPlan): FloorPlan =
  tiles * floor

proc applyRules(floor: FloorPlan): FloorPlan =
  var nextState: FloorPlan

  # Calculate tiles not flipped to white
  for blackTile in floor:
    let surroundingBlackTiles = floor.filterBlack(blackTile.getSurrounding())
    if surroundingBlackTiles.card > 0 and surroundingBlackTiles.card <= 2:
      nextState.incl(blackTile)

  # Calculate white tiles flipped to black
  var updatedTiles: FloorPlan
  for blackTile in floor:
    updatedTiles.incl(blackTile.getSurrounding())

  let whiteTiles = floor.filterWhite(updatedTiles)
  for whiteTile in whiteTiles:
    let surroundingBlackTiles = floor.filterBlack(whiteTile.getSurrounding())
    if surroundingBlackTiles.card == 2:
      nextState.incl(whiteTile)

  nextState


for day in 1..100:
  blackTiles = blackTiles.applyRules


# Print results
echo "--- Part 2 Report ---"
echo "Black tiles = " & $blackTiles.card
