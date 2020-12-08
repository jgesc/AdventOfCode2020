import sets
import strscans
import strutils
import tables

# Input file path
let inputFile = "input.txt"


# Declare bag type as string
type
  Bag = string

# Parse line to get bag containers
proc parseLineContainer(containerTable: var Table[Bag, HashSet[Bag]],
  line: string) =
  # Divide into container and content
  let subStrings = line.split(" contain ")
  let containerString = subStrings[0]
  let contentString = subStrings[1]

  # Extract container
  let container = containerString[0 .. ^6]

  # Parse content
  var contentList: HashSet[Bag]
  if containerString != "no other bags":
    let splitContentString = contentString[0 .. ^2].split(", ")
    for contentSection in splitContentString:
      var
        count: int
        bag: string
        description, color: string
      discard scanf(contentSection, "$i $* $* ", count, description, color)
      bag = description & " " & color
      contentList.incl(bag)

  # Store in container table
  for content in contentList:
    if content notin containerTable:
      var hashSet: HashSet[Bag]
      containerTable[content] = hashSet
    containerTable[content].incl(container)

# Find containers for a bag recursively
proc findContainers(containedTable: Table[Bag, HashSet[Bag]],
  currentNode: Bag, canBeHoldIn: var HashSet[Bag]) =
  if currentNode in containedTable:
    for node in containedTable[currentNode]:
      if node notin canBeHoldIn:
        canBeHoldIn.incl(node)
        findContainers(containedTable, node, canBeHoldIn)

# Parse input to get containers
var containedIn: Table[Bag, HashSet[Bag]]
for line in lines inputFile:
  containedIn.parseLineContainer(line)

# Find containers for the bag
var canBeHoldIn: HashSet[Bag]
let myBag: Bag = "shiny gold"
findContainers(containedIn, myBag, canBeHoldIn)

# Print results
echo "--- Part 1 Report ---"
echo "Containers found = " & $canBeHoldIn.len


## Part 2


# Bag content type
type
  BagContent = tuple
    bag: Bag
    count: int

# Parse line to get bag containers
proc parseLineContent(contentTable: var Table[Bag, HashSet[BagContent]],
  line: string) =
  let subStrings = line.split(" contain ")
  let containerString = subStrings[0]
  let contentString = subStrings[1]

  let container = containerString[0 .. ^6]

  var contentList: HashSet[Bag]
  if containerString != "no other bags":
    let splitContentString = contentString[0 .. ^2].split(", ")
    for contentSection in splitContentString:
      var
        count: int
        bag: string
        description, color: string
      discard scanf(contentSection, "$i $* $* ", count, description, color)
      bag = description & " " & color
      contentList.incl(bag)

      if container notin contentTable:
        var hashSet: HashSet[BagContent]
        contentTable[container] = hashSet
      contentTable[container].incl((bag, count))

# Find number of bags to be hold
proc countContainedBags(contentTable: Table[Bag, HashSet[BagContent]],
  currentBag: Bag): int =
  if currentBag in contentTable:
    for content in contentTable[currentBag]:
      # Bags contained plus the bag itself multiplied by the number of bags
      # of that type
      result += content.count * (1 + countContainedBags(contentTable,
        content.bag))

# Parse input to get contents
var mustHold: Table[Bag, HashSet[BagContent]]
for line in lines inputFile:
  mustHold.parseLineContent(line)

# Count contained bags
let containedBagCount = countContainedBags(mustHold, myBag)

# Print results
echo "--- Part 2 Report ---"
echo "Contents found = " & $containedBagCount
