const
  SubjectNumber = 7
  Modulo = 20201227

proc transformStep(value: uint64): uint64 =
  (value * SubjectNumber) mod Modulo

proc transform(subjectNumber, loopSize: uint64): uint64 =
  var value: uint64 = 1
  for i in 1..loopSize:
    value = (value * subjectNumber) mod Modulo
  value

proc findLoopSize(publicKey: uint64): uint64 =
  var
    loopSize: uint64 = 0
    value: uint64 = 1

  while value != publicKey:
    value = value.transformStep
    inc(loopSize)

  loopSize

const
  CardPublicKey = 2069194
  DoorPublicKey = 16426071

let cardLoopSize = CardPublicKey.findLoopSize
let doorLoopSize = DoorPublicKey.findLoopSize
let encryptionKey = DoorPublicKey.transform(cardLoopSize)

# Print results
echo "--- Part 1 Report ---"
echo "Encryption key = " & $encryptionKey
