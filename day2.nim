import sequtils
import strscans
import strutils

# Declare password type
type
  Password = tuple
    min: int
    max: int
    token: char
    value: string

# Parse passwords from file
proc parsePasswords(file: string) : seq[Password] =
  # Allocate sequence
  result = newSeq[Password]()

  # Iterate for each line
  for password in lines file:
    var min, max: int
    var token: string
    var value: string
    # Parse passwords
    if scanf(password, "$i-$i $w: $+$.", min, max, token, value):
      result.add((min, max, token[0], value))

# Validate a password
proc validatePassword(password: Password) : bool =
  # Count number of occurrences of token
  let nOccurrences = password.value.count(password.token)
  # Check with maximum and minimum
  result = nOccurrences in password.min .. password.max

# Read passwords
let passwordsPath = "resources/day2_input.txt"
let passwords = parsePasswords(passwordsPath)
# Check passwords
let correctPasswords = passwords.filter(validatePassword).len
echo "Correct passwords: " & $correctPasswords

## Part 2
# New validation
proc validatePassword2(password: Password) : bool =
  # Check token is in only one of the possitions
  let firstPos = password.value[password.min-1]
  let secondPos = password.value[password.max-1]

  result = (firstPos == password.token) xor (secondPos == password.token)

# Check passwords
let correctPasswords2 = passwords.filter(validatePassword2).len
echo "Correct passwords (2nd part): " & $correctPasswords2
