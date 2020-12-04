import re
import strutils
import tables

# Passport fields
type
  PassportField = enum
    byr,
    iyr,
    eyr,
    hgt,
    hcl,
    ecl,
    pid,
    cid

# Set of required fields
let requiredFields = {byr, iyr, eyr, hgt, hcl, ecl, pid}

# Parse passport fields in line
proc getFieldsInLine(line: string, fieldSet: var set[PassportField]) =
  # Find field names using regex
  for match in line.findAll(re"(\s+|^)\S+:"):
    # Extract field name from match
    let fieldName = match[^4..^2]
    # Parse field name
    let field = parseEnum[PassportField](fieldName)
    # Include in set
    fieldSet.incl(field)

# Parse passports file
let inputFile = "resources/day4_input.txt"

var passportFields: set[PassportField] # Empty passport field set
var validPassportCtr = 0 # Valid passport counter
for line in lines inputFile:
  # Check last passport and create new passport if empty line found
  if line.len == 0:
    # Check if required fields is a subset of the passport fields
    if requiredFields <= passportFields:
      inc(validPassportCtr)
    # Create new empty passport
    passportFields = {}
  else:
  # Parse passport line
    getFieldsInLine(line, passportFields)

# Check last passport
if requiredFields <= passportFields:
  inc(validPassportCtr)

# Print results
echo "--- Part 1 Report ---"
echo "Valid passports found = " & $validPassportCtr

## Part 2

# Parse line with both field names and values
proc parseLine(line: string, passport: var Table[PassportField, string]) =
  # Find field names using regex
  for match in line.findAll(re"(?!\s+|^)?(\S+:\S+)(?=\s+|$)"):
    # Separate field name and value
    let splitMatch = match.split(':')
    let fieldName = splitMatch[0]
    let fieldValue = splitMatch[1]
    let field = parseEnum[PassportField](fieldName)
    # Store
    passport[field] = fieldValue

# Validate field
proc validateField(field: PassportField, value: string): bool =
  case field
  # Birth year
  of byr:
    let numValue = parseInt(value)
    result = numValue in 1920 .. 2020
  # Issue year
  of iyr:
    let numValue = parseInt(value)
    result = numValue in 2010 .. 2020
  # Expiration year
  of eyr:
    let numValue = parseInt(value)
    result = numValue in 2020 .. 2030
  # Height
  of hgt:
    var
      numValue: int
      unit: string

    let splitValue = value.findAll(re"((\d+)|(in|cm))")
    if splitValue.len != 2:
      return false
    numValue = splitValue[0].parseInt
    unit = splitValue[1]

    if unit == "cm":
      result = numValue in 150 .. 193
    elif unit == "in":
      result = numValue in 59 .. 76
    else:
      result = false
  # Hair color
  of hcl:
    result = value.match(re"#[0-9a-f]{6}")
  # Eye color
  of ecl:
    let allowedValues = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
    result = value in allowedValues
  # Passport ID
  of pid:
    result = value.match(re"\d{9}")
  # Country ID
  of cid:
    result = true

# Check all passports
var passport: Table[PassportField, string] # Empty passport
validPassportCtr = 0 # Reset counter
for line in lines inputFile:
  # Check last passport and create new passport if empty line found
  if line.len == 0:
    # Check if required fields is a subset of the passport fields
    # and validate field values
    var fieldList: set[PassportField]
    for field in passport.keys:
      fieldList.incl(field)
    if requiredFields <= fieldList:
      var validFields = true
      for k, v in passport.pairs:
        if not validateField(k, v):
          validFields = false
          break
      if validFields:
        inc(validPassportCtr)
    # Create new empty passport
    passport = initTable[PassportField, string]()
  else:
  # Parse passport line
    parseLine(line, passport)

# Print results
echo "--- Part 2 Report ---"
echo "Valid passports found = " & $validPassportCtr
