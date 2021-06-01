import sets
import strscans
import strutils
import sugar
import tables

type
  RuleType {.pure.} = enum
    Value
    RuleList
    RuleOption

  Rule = int

  RuleContent = object
    ruleType: RuleType
    value: char
    ruleList: seq[Rule]

var ruleDirectory = newTable[Rule, RuleContent]()
var auxiliaryRuleId = -1

proc ruleType(rule: Rule): RuleType =
  ruleDirectory[rule].ruleType

proc value(rule: Rule): char =
  ruleDirectory[rule].value

proc ruleList(rule: Rule): seq[Rule] =
  ruleDirectory[rule].ruleList

# Rule checking procedures
proc checkRule(rule: Rule, message: string, index: int): HashSet[int]

proc checkRuleValue(rule: Rule, message: string, index: int): HashSet[int] =
  if message[index] == rule.value:
    toHashSet([index + 1])
  else:
    initHashSet[int]()

proc checkRuleList(rules: Rule, message: string, index: int): HashSet[int] =
  var indexSet = toHashSet([index])

  for rule in rules.ruleList:
    var nextIndexSet = initHashSet[int]()
    for idx in indexSet:
      nextIndexSet.incl(checkRule(rule, message, idx))
    indexSet = nextIndexSet

  indexSet

proc checkRuleOption(rules: Rule, message: string, index: int): HashSet[int] =
  var indexSet = initHashSet[int]()

  for rule in rules.ruleList:
    indexSet.incl(checkRule(rule, message, index))

  indexSet

proc checkRule(rule: Rule, message: string, index: int): HashSet[int] =
  if index >= message.len:
    return initHashSet[int]()

  var handler: (Rule, string, int) -> HashSet[int]
  case rule.ruleType:
    of Value:
      handler = checkRuleValue
    of RuleList:
      handler = checkRuleList
    of RuleOption:
      handler = checkRuleOption
  handler(rule, message, index)

proc verifyMessage(message: string): bool =
  for parsedCharacters in checkRule(0, message, 0):
    if parsedCharacters == message.len:
      return true
  return false

proc parseRule(ruleString: string) =
  # Initial parsing
  var ruleId: Rule
  var ruleContentString: string
  discard scanf(ruleString, "$i: $+$.", ruleId, ruleContentString)

  # Parse rule conditions
  if '"' in ruleContentString:
    # Value
    ruleDirectory[ruleId] = RuleContent(ruleType: Value,
      value: ruleContentString[1], ruleList: @[])
  elif '|' in ruleContentString:
    # Rule options
    ruleDirectory[ruleId] = RuleContent(ruleType: RuleOption, value: '\0',
      ruleList: @[])

    for optionString in ruleContentString.split('|'):
      ruleDirectory[auxiliaryRuleId] = RuleContent(ruleType: RuleList,
        value: '\0', ruleList: @[])
      for optionStringElement in optionString.split(' '):
        if not optionStringElement.isEmptyOrWhitespace:
          ruleDirectory[auxiliaryRuleId].ruleList.add(parseInt(optionStringElement))
      ruleDirectory[ruleId].ruleList.add(auxiliaryRuleId)
      dec auxiliaryRuleId
  else:
    # Rule list
    ruleDirectory[ruleId] = RuleContent(ruleType: RuleList,
      value: ruleContentString[1], ruleList: @[])

    for optionStringElement in ruleContentString.split(' '):
      ruleDirectory[ruleId].ruleList.add(parseInt(optionStringElement))


# Parse input
let inputFile = "resources/day19_input.txt"

var parsingRules = true
var correctMessages = 0
for line in lines inputFile:
  if parsingRules:
    if not line.isEmptyOrWhitespace:
      line.parseRule
    else:
      parsingRules = false
  else:
    if line.verifyMessage:
      inc correctMessages

# Print results
echo "--- Part 1 Report ---"
echo "Correct messages = " & $correctMessages


## Part 2


# Parse new rules
"8: 42 | 42 8".parseRule
"11: 42 31 | 42 11 31".parseRule

parsingRules = true
correctMessages = 0
for line in lines inputFile:
  if parsingRules:
    if not line.isEmptyOrWhitespace:
      continue
    else:
      parsingRules = false
  else:
    if line.verifyMessage:
      inc correctMessages

echo "--- Part 2 Report ---"
echo "Correct messages = " & $correctMessages
