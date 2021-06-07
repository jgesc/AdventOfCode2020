import algorithm
import bitops
import parseutils
import sequtils
import sets
import strscans
import strutils
import sugar
import tables

type
  Border = range[0 .. 1023]

  Image = object
    id: int
    top, bot, right, left: Border
    data: array[10, Border]
    openBorders: int

  Orientation = enum
    Top = 0
    Right = 1
    Bot = 2
    Left = 3

proc print(image: Image) =
  for i in 0..9:
    echo image.data[i].toBin(10).multiReplace(("0", "."), ("1", "#"))

proc printWithBorders(image: Image) =
  for i in 0..9:
    echo image.data[i].toBin(10).multiReplace(("0", "."), ("1", "#"))

proc printBorders(image: Image) =
  echo "==="
  echo "top = ", image.top
  echo "right = ", image.right
  echo "bot = ", image.bot
  echo "left = ", image.left
  echo "==="

proc flip(border: var Border) =
  border = ((uint16)border).reverseBits shr 6

proc flipped(border: Border): Border =
  ((uint16)border).reverseBits shr 6

proc normalize(border: Border): Border =
  min(border, border.flipped)

proc rotate(image: var Image) =
  # Hold border in temporal variable
  let tmp = image.top

  # Rotate borders
  image.top = image.left.flipped
  image.left = image.bot
  image.bot = image.right.flipped
  image.right = tmp

  # Data
  var rotatedData: array[10, Border]
  for i in 0..9:
    for j in 0..9:
      if image.data[i].testBit(9-j):
        rotatedData[j].setBit(i)
  image.data = rotatedData

proc flipVertical(image: var Image) =
  # Borders
  swap image.top, image.bot
  flip image.left
  flip image.right

  # Data
  reverse image.data

proc flipHorizontal(image: var Image) =
  swap image.left, image.right
  flip image.top
  flip image.bot

  # Data
  image.data.apply(flip)

proc getBorder(image: Image, n: 0..3): Border =
  case n:
    of 0:
      image.top
    of 1:
      image.right
    of 2:
      image.bot
    of 3:
      image.left

proc matchWith(image: var Image, target: Image) =
  # Find matching borders
  var targetBorderOrientation: Orientation
  var imageBorderOrientation: Orientation

  block borderMatching:
    for nTarget in 0..3:
      for nImage in 0..3:
        if image.getBorder(nImage).normalize == target.getBorder(nTarget).normalize:
          targetBorderOrientation = Orientation(nTarget)
          imageBorderOrientation = Orientation(nImage)
          break borderMatching

  # Find required rotations
  let requiredRotations =
    abs((ord(targetBorderOrientation) - (ord(imageBorderOrientation) - 2))) mod 4

  for i in 1..requiredRotations:
    image.rotate

  # Find required flip
  if image.getBorder((ord(targetBorderOrientation) + 2) mod 4) !=
    target.getBorder(ord(targetBorderOrientation)):

    if ord(targetBorderOrientation) mod 2 != 0:
      image.flipVertical
    else:
      image.flipHorizontal

# Border list
var borders: Table[Border, seq[Image]] = initTable[Border, seq[Image]]()
for i in 0 .. high(Border):
  borders[i] = newSeq[Image]()

let inputFile = "resources/day20_input.txt"
# Open and preprocess input
let rawImages = readFile(inputFile).
  multiReplace((".", "0"), ("#", "1")).
  split("\n\n")

# Parse individual images
var images: seq[Image]
var imageIds: Table[int, int]
for rawImage in rawImages[0 .. ^2]:
  let rawLines = rawImage.split("\n")
  # New image
  var newImage: Image
  # Read header
  discard scanf(rawLines[0], "Tile $i:", newImage.id)
  # Top border
  newImage.top = fromBin[uint16](rawLines[1])
  # Bot border
  newImage.bot = fromBin[uint16](rawLines[10])
  # Left and right border
  for line in rawLines[1 .. 10]:
    newImage.left = (newImage.left shl 1) or (int)(line[0] == '1')
    newImage.right = (newImage.right shl 1) or (int)(line[9] == '1')

  # Store data
  for i in 0..9:
    newImage.data[i] = fromBin[uint16](rawLines[i+1])

  # Register borders
  borders[newImage.top.normalize].add(newImage)
  borders[newImage.bot.normalize].add(newImage)
  borders[newImage.left.normalize].add(newImage)
  borders[newImage.right.normalize].add(newImage)

  # Append image to list
  images.add(newImage)
  imageIds[newImage.id] = images.len - 1

# Count open borders
images.apply(
  proc(image: var Image) =
    image.openBorders = @[
      borders[image.top.normalize].len == 1,
      borders[image.bot.normalize].len == 1,
      borders[image.left.normalize].len == 1,
      borders[image.right.normalize].len == 1
    ].count(false))

# Find borders
let corners = images
  .filter(
    (image: Image) -> bool => image.openBorders < 3)
  .map(
    (image: Image) -> int => image.id)

# Print results
echo "--- Part 1 Report ---"
echo "Correct messages = " & $foldl(corners, a * b)


# Part 2


# Map elements
const SideLength = 12

type
  Coordinate = tuple
    x: int
    y: int
  Map = Table[Coordinate, Image]

var map: Map

proc findMatching(image: Image, side: Orientation): Image =
  let matchingBorders = borders[image.getBorder(ord(side)).normalize]
  let matchId =
    if matchingBorders[0].id != image.id:
      matchingBorders[0].id
    else:
      matchingBorders[1].id

  images[imageIds[matchId]]

const DataWidth = 8

proc get(map: Map, coordinate: Coordinate): bool =
  if not (coordinate.x in 0 .. DataWidth * SideLength - 1) or
    not (coordinate.y in 0 .. DataWidth * SideLength - 1):

    return false

  let imageX = coordinate.x div DataWidth
  let imageY = coordinate.y div DataWidth
  let pixelX = coordinate.x mod DataWidth
  let pixelY = coordinate.y mod DataWidth

  map[(imageX, imageY)].data[pixelY+1].testBit(9 - (pixelX+1))

proc matchPattern(map: Map, pattern: openArray[Coordinate]): HashSet[Coordinate] =
  var monsterPixels: HashSet[Coordinate]
  for y in 0..DataWidth * SideLength - 1:
    for x in 0..DataWidth * SideLength - 1:
      block patternMatching:
        var foundPatternCoord: HashSet[Coordinate]
        for offset in pattern:
          let coord = (x + offset.x, y + offset.y)
          if not map.get(coord):
            break patternMatching
          foundPatternCoord.incl(coord)
        monsterPixels.incl(foundPatternCoord)
  monsterPixels


# Initialize map
map[(0, 0)] = images[imageIds[corners[0]]]

while borders[map[(0, 0)].right.normalize].len < 2 or
  borders[map[(0, 0)].bot.normalize].len < 2 or
  borders[map[(0, 0)].top.normalize].len > 1 or
  borders[map[(0, 0)].left.normalize].len > 1:

  map[(0, 0)].rotate

# Match first row to the right
for x in 1..SideLength-1:
  map[(x, 0)] = map[(x-1, 0)].findMatching(Right)
  map[(x, 0)].matchWith(map[(x-1, 0)])

# Match all other rows to the bottom
for y in 1..SideLength-1:
  for x in 0..SideLength-1:
    map[(x, y)] = map[(x, y-1)].findMatching(Bot)
    map[(x, y)].matchWith(map[(x, y-1)])

# Sea monster pattern
var pattern: array[15, Coordinate] = [
  (0, 1),
  (1, 2),
  (4, 2),
  (5, 1),
  (6, 1),
  (7, 2),
  (10, 2),
  (11, 1),
  (12, 1),
  (13, 2),
  (16, 2),
  (17, 1),
  (18, 1),
  (19, 1),
  (18, 0)
]

# Rotate and flip pattens
let patternVariations = [
  pattern.mapIt((it.x, it.y)),
  pattern.mapIt((-it.x, it.y)),
  pattern.mapIt((it.x, -it.y)),
  pattern.mapIt((-it.x, -it.y)),
  pattern.mapIt((it.y, it.x)),
  pattern.mapIt((-it.y, it.x)),
  pattern.mapIt((it.y, -it.x)),
  pattern.mapIt((-it.y, -it.x))
]

# Search patterns
var monsterPixels: HashSet[Coordinate]
for pattern in patternVariations:
  monsterPixels = map.matchPattern(pattern)
  if monsterPixels.len > 0:
    break

# Count total '#'
var totalHashes = 0
for y in 0..11:
  for x in 0..11:
    let image = map[(x, y)]
    for z in 1..8:
      totalHashes += image.data[z].bitsliced(1 .. 8).countSetBits

let waterRoughness = totalHashes - monsterPixels.len


# Print results
echo "--- Part 1 Report ---"
echo "Pixels not part of sea monsters = " & $waterRoughness
