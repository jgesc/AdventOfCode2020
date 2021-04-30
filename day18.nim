import sequtils
import strutils
import sugar

type
  Operation = enum
    Product = '*'
    Addition = '+'

  NextToken = enum
    Operator
    Value

# Recursively evaluate line
proc evaluate(input: string, counter: var int): int =
  var accumulator = 0
  var operation = Operation.Addition
  var next_token_type = NextToken.Value

  # Fetch tokens
  while counter < input.len:
    let token = input[counter]
    inc(counter)

    # Process token
    if next_token_type == Value:
      let value = if token == '(': evaluate(input, counter) else: parseInt($token)

      if operation == Product:
        accumulator *= value
      elif operation == Addition:
        accumulator += value

      next_token_type = Operator

    elif next_token_type == Operator:
      if token == ')':
        return accumulator
      else:
        operation = if token == '+': Addition else: Product

      next_token_type = Value

  return accumulator

# Parse file
proc parseInput(inputFile: string): int =
  let results = collect(newSeq):
    for line in lines inputFile:
      var ctr = 0
      evaluate(line.replace(" ", ""), ctr)

  results.foldl(a + b)

# Evaluate expressions
let inputFile = "resources/day18_input.txt"
let result = parseInput(inputFile)

# Print results
echo "--- Part 1 Report ---"
echo "Sum of results = " & $result


## Part 2


# Node object
type
  Node = ref object
    value: int
    operator: char
    left_node: Node
    right_node: Node

  TokenFetcher = object
    line: string
    carriage: int

proc initTokenFetcher(line: string): TokenFetcher =
  var new_token_fetcher: TokenFetcher
  new_token_fetcher.line = line
  new_token_fetcher.carriage = 0
  new_token_fetcher

proc nextToken(token_fetcher: var TokenFetcher): char =
  for character in token_fetcher.line[token_fetcher.carriage .. ^1]:
    inc token_fetcher.carriage
    if character != ' ':
      return character
  return '\0'

proc isLeaf(node: Node): bool =
  node.left_node == nil and node.right_node == nil

proc evaluateTree(tree: Node): int =
  # Return value for leafs
  if tree.isLeaf:
    return tree.value

  # Else evaluate sub-tree
  let left_value = evaluateTree(tree.left_node)
  let right_value = evaluateTree(tree.right_node)

  if tree.operator == '+':
    return left_value + right_value
  else:
    return left_value * right_value

proc buildTree(line: var TokenFetcher): Node =
  # Create parent node
  let first_token = line.next_token
  var parent_node: Node

  parent_node = new Node
  parent_node.operator = '+'
  parent_node.left_node = new Node
  parent_node.right_node = new Node
  parent_node.left_node.value = 0

  if first_token != '(':
    parent_node.right_node.value = parseInt $first_token
  else:
    let subtree = buildTree(line)
    parent_node.right_node.value = evaluateTree(subtree)

  # Parse line
  while true:
    let operator_token = line.nextToken
    if operator_token == '\0' or operator_token == ')':
      # Finish parsing
      return parent_node
    elif operator_token in "+*":
      # Get next value
      var value_node = new Node
      let value_token = line.next_token
      if value_token == '(':
        let subtree = buildTree(line)
        value_node.value = evaluateTree(subtree)
      else:
        value_node.value = parseInt $value_token

      # Create operator node
      var new_node = new Node
      new_node.operator = operator_token
      new_node.right_node = value_node

      # Restructure tree
      if operator_token == '*':
        new_node.left_node = parent_node
        parent_node = new_node
      else:
        new_node.left_node = parent_node.right_node
        parent_node.right_node = new_node

let results = collect(newSeq):
  for line in lines inputFile:
    var tokenFetcher = initTokenFetcher(line)
    evaluateTree buildTree(tokenFetcher)

let result2 = results.foldl(a + b)

# Print results
echo "--- Part 2 Report ---"
echo "Sum of results = " & $result2
