import strutils

type
  Direction {.pure.} = enum
    North = 0
    West = 1
    South = 2
    East = 3

  Action = enum
    East = 'E'
    Forward = 'F'
    Left = 'L'
    North = 'N'
    Right = 'R'
    South = 'S'
    West = 'W'

  Instruction = tuple
    action: Action
    value: int

  Waypoint = tuple
    east: int
    north: int

  Ship = object
    north: int
    east: int
    direction: Direction
    waypoint: Waypoint


proc newShip(): Ship =
  result.direction = Direction.East
  result.waypoint = (10, 1)


# Parses an instruction file and returns it as a sequence of instructions
proc parseInstructions(inputFile: string): seq[Instruction] =
  for line in lines inputFile:
    # Extract substrings
    let actionSubstring = line[0]
    let valueSubstring = line[1 .. ^1]

    # Convert to action and value
    let action = Action(actionSubstring)
    let value = parseInt(valueSubstring)
    let instruction = (action, value)

    # Append to instruction sequence
    result.add(instruction)


proc doInstruction(ship: var Ship, instruction: Instruction) =
  case instruction.action:
    of North:
      ship.north += instruction.value
    of South:
      ship.north -= instruction.value
    of East:
      ship.east += instruction.value
    of West:
      ship.east -= instruction.value
    of Forward:
      case ship.direction:
        of Direction.North:
          ship.north += instruction.value
        of Direction.South:
          ship.north -= instruction.value
        of Direction.East:
          ship.east += instruction.value
        of Direction.West:
          ship.east -= instruction.value
    of Left, Right:
      let turns = int(instruction.value / 90)
      for turn in 1 .. turns:
        var intDirection = int(ship.direction)
        intDirection += (if instruction.action == Left: 1 else: -1)
        if intDirection < 0:
          intDirection = 3
        else:
          intDirection = intDirection mod 4
        ship.direction = Direction(intDirection)


# Parse input file
let inputFile = "resources/day12_input.txt"
let instructions = parseInstructions(inputFile)

# Follow instructions
var ship = newShip()
for instruction in instructions:
  ship.doInstruction(instruction)

# Print results
echo "--- Part 1 Report ---"
echo "Manhattan distance = " & $(abs(ship.north) + abs(ship.east))


## Part 2


proc doInstructionWaypoint(ship: var Ship, instruction: Instruction) =
  case instruction.action:
    of North:
      ship.waypoint.north += instruction.value
    of South:
      ship.waypoint.north -= instruction.value
    of East:
      ship.waypoint.east += instruction.value
    of West:
      ship.waypoint.east -= instruction.value
    of Forward:
      ship.north += ship.waypoint.north * instruction.value
      ship.east += ship.waypoint.east * instruction.value
    of Left, Right:
      let sign = (if instruction.action == Left: 1 else: -1)
      let turns = int(instruction.value / 90)
      for turn in 1 .. turns:
        let oldNorth = ship.waypoint.north
        let oldEast = ship.waypoint.east

        ship.waypoint.north = oldEast * sign
        ship.waypoint.east = -oldNorth * sign


# Follow instructions
ship = newShip()
for instruction in instructions:
  ship.doInstructionWaypoint(instruction)

# Print results
echo "--- Part 2 Report ---"
echo "Manhattan distance = " & $(abs(ship.north) + abs(ship.east))
