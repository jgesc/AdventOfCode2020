import algorithm
import deques
import sequtils
import sets
import strutils
import sugar

proc parseInput(inputFile: string): seq[Deque[int]] =
  # Initialize player hands
  var players: seq[Deque[int]]
  # Iterate input
  for line in lines inputFile:
    if line.startsWith("Player"):
      players.add(initDeque[int]())
    elif not line.isEmptyOrWhitespace:
      players[^1].addLast(parseInt(line))

  players

proc playCombat(hands: var seq[Deque[int]]): Deque[int] =
  # While all players have cards
  while hands.allIt(it.len > 0):
    # Draw cards
    let draws = collect(newSeq):
      for hand in hands.mitems:
        hand.popFirst()
    # Highest draw wins
    let winningDraw = maxIndex(draws)
    # Add cards to winner
    for draw in draws.sorted(SortOrder.Descending):
      hands[winningDraw].addLast(draw)

  for hand in hands:
    if hand.len > 0:
      return hand

# Read input
let inputFile = "resources/day22_input.txt"
var hands = parseInput(inputFile)

# Play Combat
let winningHand = hands.playCombat
let winnerScore = toSeq(winningHand.pairs()).foldl(a + (winningHand.len - b[0]) * b[1], 0)


# Print results
echo "--- Part 1 Report ---"
echo "Winner score = " & $winnerScore


## Part 2


proc playRecursiveCombat(hands: var seq[Deque[int]]): (int, Deque[int]) =
  var previousGames: HashSet[seq[seq[int]]]
  # While all players have cards
  while hands.allIt(it.len > 0):
    # Check if same game configuration already seen
    let seqHands = hands.mapIt(it.toSeq)
    if seqHands in previousGames:
      return (0, hands[0])
    else:
      previousGames.incl(seqHands)
    # Draw cards
    let draws = collect(newSeq):
      for hand in hands.mitems:
        hand.popFirst()
    # Check winning hand
    let winningDraw =
      # If draw >= number of cards on deck
      if zip(draws, hands).allIt(it[1].len >= it[0]):
        var handsCopy = collect(newSeq):
          for (draw, hand) in zip(draws, hands):
            toDeque(toSeq(hand)[0..draw-1])
        let (winningPlayer, _) = playRecursiveCombat(handsCopy)
        winningPlayer
      else:
        maxIndex(draws)
    # Add cards to winner
    hands[winningDraw].addLast(draws[winningDraw])
    hands[winningDraw].addLast(draws[1-winningDraw])

  for player, hand in hands.pairs:
    if hand.len > 0:
      return (player, hand)


# Read input
hands = parseInput(inputFile)

# Play Combat
let (_, winningHand2) = hands.playRecursiveCombat
let winnerScore2 = toSeq(winningHand2.pairs()).foldl(a + (winningHand2.len - b[0]) * b[1], 0)


# Print results
echo "--- Part 2 Report ---"
echo "Winner score = " & $winnerScore2
