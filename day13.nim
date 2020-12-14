import algorithm
import bitops
import re
import sequtils
import strutils
import sugar

# Parse input
let inputFileName = "resources/day13_input.txt"
let inputFile = open(inputFileName)
# First line is always time of arrival
let timeOfArrival = parseInt(inputFile.readLine())
# Extract IDs from second line using regex
let rawIds = inputFile.readLine()
let pattern = re"\d+"
let busIds = rawIds.findAll(pattern).map(parseInt)
# Calculate text bus times
let nextBus = busIds.map(x => x - timeOfArrival mod x)
# Find earliest departure
let earliestBusIndex = nextBus.minIndex
let earliestBusId = busIds[earliestBusIndex]
let earliestBusTime = nextBus[earliestBusIndex]

# Print results
echo "--- Part 1 Report ---"
echo "ID * Waiting time = " & $(earliestBusId * earliestBusTime)


## Part 2


# Modular exponentiation
proc modpow(base, exp, modulus: uint64): uint64 =
  result = 1;
  var exp = exp
  var base = base mod modulus
  while (exp > 0):
    if exp.testBit(0):
      result = (result * base) mod modulus
    base = (base * base) mod modulus
    exp = exp shr 1


# Modular division
proc moddiv(a, b, modulus: uint64): uint64 =
  let a = a mod modulus
  let inv = modpow(b, modulus - 2, modulus)

  result = (inv * a) mod modulus


# Parse input
var unsortedBusTable: seq[(uint64, uint64)]
for idx, val in @(rawIds.split(',')):
  if val[0] != 'x':
    let id = parseInt(val)
    unsortedBusTable.add((uint64(id), uint64(idx mod id)))
let busTable = unsortedBusTable.sorted((x, y) => system.cmp[uint64](x[1], y[1]))

# Find timestamp making use of the fact that every bus ID is a prime number
var compPeriod: uint64 = 1
var time: uint64 = 0
# time + compPeriod * t mod period = period - phase mod period
# (period - phase - sum) / compPeriod mod period = t
for (period, phase) in busTable:
  let t = moddiv(period - (phase + time mod period), compPeriod, period)
  time += t * compPeriod
  compPeriod *= period # Gets LCM as all the IDs are coprimes

# Print results
echo "--- Part 2 Report ---"
echo "Timestamp = " & $time
