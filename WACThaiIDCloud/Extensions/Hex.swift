import Foundation

class Hex {

    static func toHexString(buffer: [UInt8]) -> String {

        var bufferString = ""

        for i in 0..<buffer.count {
            if i == 0 {
                bufferString += String(format: "%02X", buffer[i])
            } else {
                bufferString += String(format: " %02X", buffer[i])
            }
        }

        return bufferString
    }

    static func toByteArray(hexString: String) -> [UInt8] {

        var byteArray = [UInt8]()
        var first = true
        var value: UInt32 = 0
        var byte: UInt8 = 0

        let digit0: Unicode.Scalar = "0"
        let digit9: Unicode.Scalar = "9"
        let letterA: Unicode.Scalar = "A"
        let letterF: Unicode.Scalar = "F"
        let lettera: Unicode.Scalar = "a"
        let letterf: Unicode.Scalar = "f"

        for c in hexString.unicodeScalars {

            if c >= digit0 && c <= digit9 {
                value = c.value - digit0.value
            } else if c >= letterA && c <= letterF {
                value = c.value - letterA.value + 10
            } else if c >= lettera && c <= letterf {
                value = c.value - lettera.value + 10
            } else {
                continue
            }

            if (first) {

                byte = UInt8(value << 4)

            } else {

                byte |= UInt8(value)
                byteArray.append(byte)
            }

            first = !first
        }

        return byteArray
    }
}
