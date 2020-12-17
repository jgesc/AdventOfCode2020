import sequtils
import strscans
import strutils
import sugar
import tables


# Declare types
type
  Range = tuple
    min: int
    max: int

  TicketField = object
    name: string
    ranges: array[2, Range]

  UnidentifiedTicketValues = seq[int]

  Input = object
    ticketFields: seq[TicketField]
    myTicketValues: UnidentifiedTicketValues
    nearbyTicketValues: seq[UnidentifiedTicketValues]

  ParsingStage {.pure.} = enum
    Fields
    MyTicket
    NearbyTickets


# Parse ticket field
proc parseField(line: string): TicketField =
  discard line.scanf("$+: $i-$i or $i-$i", result.name, result.ranges[0].min,
    result.ranges[0].max, result.ranges[1].min, result.ranges[1].max)


# Parse input file
proc parseInput(inputFile: string): Input =
  var currentStage = ParsingStage.Fields

  for line in lines inputFile:
    case currentStage:
      # Parse possible fields
      of ParsingStage.Fields:
        if line.len > 0:
          result.ticketFields.add(parseField(line))
        else:
          currentStage = ParsingStage.MyTicket
      # Parse my ticket
      of ParsingStage.MyTicket:
        if line.len == 0:
          currentStage = ParsingStage.NearbyTickets
        elif not line.startsWith("your"):
          result.myTicketValues = line.split(",").map(parseInt)
      # Parse nearby ticket
      of ParsingStage.NearbyTickets:
        if not line.startsWith("nearby"):
          result.nearbyTicketValues.add(line.split(",").map(parseInt))


# Separates valid and invalid tickets and returns error rate
proc validateTickets(tickets: seq[UnidentifiedTicketValues],
  validRanges: seq[TicketField],
  validTickets, invalidTickets: var seq[UnidentifiedTicketValues]): int =

  # Go ticket by ticker
  for ticket in tickets:
    var isValid = true
    # Check field by field
    for field in ticket:
      block fieldChecking:
        # Check if valid in any range
        for validRange in validRanges:
          if field in validRange.ranges[0].min .. validRange.ranges[0].max or
            field in validRange.ranges[1].min .. validRange.ranges[1].max:
            break fieldChecking
        # If valid range not found, invalidate ticket and increase error rate
        result += field
        isValid = false

    # Separate ticket
    if isValid:
      validTickets.add(ticket)
    else:
      invalidTickets.add(ticket)


# Parse input data
let inputFile = "resources/day16_input.txt"
var inputData = parseInput(inputFile)

# Check valid and invalid tickets
var validTickets, invalidTickets: seq[UnidentifiedTicketValues]
let errorRate = validateTickets(inputData.nearbyTicketValues,
  inputData.ticketFields, validTickets, invalidTickets)

# Print results
echo "--- Part 1 Report ---"
echo "ErrorRate = " & $errorRate


## Part 2


# Identify each field
var possibleFields = newSeqWith(inputData.ticketFields.len,
  inputData.ticketFields)

# Filter fields that allow values in valid nearby tickets
for ticket in validTickets:
  for index, value in ticket:
    possibleFields[index].keepIf(x =>
      value in x.ranges[0].min .. x.ranges[0].max or
      value in x.ranges[1].min .. x.ranges[1].max)

# Identify fields with just one possibility
var identifiedFields: Table[int, TicketField]
while true:
  # Look for possitions with only allow one single field
  let possibleFieldCount = possibleFields.map(x => len(x))
  let trivialFieldIdx = possibleFieldCount.find(1)

  if trivialFieldIdx != -1:
    # Store identified field
    let identifiedField = possibleFields[trivialFieldIdx][0]
    identifiedFields[trivialFieldIdx] = identifiedField
    # Remove from list of possible fields
    for possibleFields in possibleFields.mitems:
      possibleFields.keepIf(x => x.name != identifiedField.name)
  else:
    # No more fields can be identified
    break

# Multiply values of my ticket of fields starting with "departre"
var accumulator = 1
for (possition, field) in toSeq(identifiedFields.pairs):
  if field.name.startsWith("departure"):
    accumulator *= inputData.myTicketValues[possition]

# Print results
echo "--- Part 2 Report ---"
echo "Product of fields = " & $accumulator
