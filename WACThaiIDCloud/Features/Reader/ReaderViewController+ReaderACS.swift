import Foundation
import UIKit
import SmartCardIO
import ACSSmartCardIO
import ISO8859

extension ReaderViewController {
    
    func runScript(card: Card,
                   filename: String,
                   send: (Card, [UInt8]) throws -> [UInt8]) {

        print("Running the script...")

        // Open the script file.
        print("Opening " + filename + "...")
        let hScriptFile = openFile(name: filename)
        if (hScriptFile == nil) {

            print("Error: Script file not found")
            return
        }

        do {

            var numResponse = 1
            var numCodephoto = 1
            var numCommands = 0
            while true {

                var commandLoaded = false
                var responseLoaded = false
                var command = [UInt8]()

                // Read the first line.
                var line = readLine(hFile: hScriptFile!)
                while line.count > 0 {

                    // Skip the comment line.
                    if !line.contains(";") {

                        if !commandLoaded {
                            command = Hex.toByteArray(hexString: line)
                            if command.count > 0 {
                                commandLoaded = true
                            }

                        } else {

                            if checkLine(line) > 0 {
                                responseLoaded = true
                            }
                        }
                    }

                    if commandLoaded && responseLoaded {
                        break
                    }

                    // Read the next line.
                    line = readLine(hFile: hScriptFile!)
                }

                if !commandLoaded || !responseLoaded {
                    break
                }

                // Increment the number of loaded commands.
                numCommands += 1

                // Send the command.
                let response = try send(card, command)
                
                var str = ""
                if let string = String(response, iso8859Encoding: ISO8859.part11) {
                    str = string.trimmingCharacters(in: .whitespaces)
                }
                str = str.replacingOccurrences(of: "\n", with: "", options: [.regularExpression])
                str = str.replacingOccurrences(of: #"\u0090"#, with: "", options: [.regularExpression])
                str = str.replacingOccurrences(of: #"\u0010"#, with: "", options: [.regularExpression])
                str = str.replacingOccurrences(of: "\\s+", with: "", options: [.regularExpression])
                str = str.replacingOccurrences(of: "\\0", with: "", options: [.regularExpression]).replacingOccurrences(of: #"\u0000"#, with: "")
                str = str.replacingOccurrences(of: "\0", with: "", options: [.regularExpression])
                str = str.replacingOccurrences(of: #"\u{08}"#, with: "", options: [.regularExpression])
                str = str.replacingOccurrences(of: #"\u{0F}"#, with: "", options: [.regularExpression])
                str = str.replacingOccurrences(of: "", with: "", options: [.regularExpression])
                
                switch numResponse {
                case 1:
                    let hexapdu = toHexString(buffer: response).replacingOccurrences(of: " ", with: "")
                    var chip_card = ""
                    for i in 0...15 {
                        chip_card = chip_card + String(hexapdu[i + 26])
                    }
                    print("\(numResponse) responseAPDU the card ", chip_card)
                    nativeCardInfo?.chipId = chip_card
                case 2:
                    print("laserId: ", str)
                    nativeCardInfo?.laserId = str
                case 3:
                    break
                case 4:
                    print("cardNumber: ", str)
                    nativeCardInfo?.cardNumber = str
                case 5:
                    let thaiNames = str.components(separatedBy: "#")
                    print("thai title Name: ", thaiNames[0])
                    print("thai fName: ", thaiNames[1])
                    print("thai mName: ", thaiNames[2])
                    print("thai lName: ", thaiNames[3])
                    
                    nativeCardInfo?.thaiTitle = thaiNames[0]
                    nativeCardInfo?.thaiFirstName = thaiNames[1]
                    nativeCardInfo?.thaiMiddleName = thaiNames[2]
                    nativeCardInfo?.thaiLastName = thaiNames[3]
                case 6:
                    let enNames = str.components(separatedBy: "#")
                    print("en title Name: ", enNames[0])
                    print("en fName: ", enNames[1])
                    print("en mName: ", enNames[2])
                    print("en lName: ", enNames[3])
                    
                    nativeCardInfo?.engTitle = enNames[0]
                    nativeCardInfo?.engFirstName = enNames[1]
                    nativeCardInfo?.engMiddleName = enNames[2]
                    nativeCardInfo?.engLastName = enNames[3]
                case 7:
                    if str == "1" {
                        str = "ชาย"
                    } else if str == "2"{
                        str = "หญิง"
                    }
                    print("sex", str)
                    nativeCardInfo?.sex = str
                case 8:
                    let birthDate = str.subString(from: 6, to: 8) + "/" + str.subString(from: 4, to: 6) + "/" + str.subString(from: 0, to: 4)
                    print("Birth Date: ", birthDate)
                    nativeCardInfo?.dateOfBirth = birthDate
                case 9:
                    let address = str.components(separatedBy: "#")
                    print("homeNo: ", address[0])
                    print("moo: ", address[1])
                    print("trok: ", address[2])
                    print("soi: ", address[3])
                    
                    print("road: ", address[4])
                    print("subDistrict: ", address[5])
                    print("district: ", address[6])
                    print("province: ", address[7])
                    
                    let cardAddress = CardAddress()
                    cardAddress.homeNo = address[0]
                    cardAddress.moo = address[1]
                    cardAddress.trok = address[2]
                    cardAddress.soi = address[3]
                    cardAddress.road = address[4]
                    cardAddress.subDistrict = address[5]
                    cardAddress.district = address[6]
                    cardAddress.province = address[7]
                    cardAddress.postalCode = findPostalCode(
                        province: cardAddress.province,
                        district: cardAddress.district
                    )
                    cardAddress.country = "ประเทศไทย"
                    nativeCardInfo?.address = cardAddress
                    nativeCardInfo?.cardCountry = cardAddress.country
                case 10:
                    print("bp1No: ", str)
                    nativeCardInfo?.bp1No = str
                case 11:
                    print("cardIssuePlace: ", str)
                    nativeCardInfo?.cardIssuePlace = str
                case 12:
                    print("cardIssueNo: ", str)
                    nativeCardInfo?.cardIssueNo = str
                case 13:
                    var strIssue = str.subString(from: 0, to: 8)
                    var strExpire = str.subString(from: 8, to: 16)
                    strIssue = strIssue.subString(from: 6, to: 8) + "/" + strIssue.subString(from: 4, to: 6) + "/" + strIssue.subString(from: 0, to: 4)
                    strExpire = strExpire.subString(from: 6, to: 8) + "/" + strExpire.subString(from: 4, to: 6) + "/" + strExpire.subString(from: 0, to: 4)
                    print("cardIssueDate: ", strIssue)
                    print("cardExpiryDate: ", strExpire)
                    nativeCardInfo?.cardIssueDate = strIssue
                    nativeCardInfo?.cardExpiryDate = strExpire
                case 14:
                    print("cardType: ", str)
                    nativeCardInfo?.cardType = str
                case 15:
                    print("versionCard: ", str)
                    nativeCardInfo?.versionCard = str
                case 16:
                    print("cardPhotoIssueNo: ", str)
                    nativeCardInfo?.cardPhotoIssueNo = str
                default:
                    if numResponse > 16 {
                        var newResult = Data([UInt8]())
                        for i in 0...254 {
                            newResult.append(response[i % response.count])
                        }
                        if numCodephoto != 1 {
                            strPicture += newResult.hexEncodedString()
                        }
                        if numCodephoto == 20 {
                            print("strPicture: ", strPicture)
                            guard let byteRawHex = stringToBytes(strPicture) else { return }
                            let datos: NSData = NSData(bytes: byteRawHex, length: byteRawHex.count)
                            let image = UIImage(data: datos as Data)
                            DispatchQueue.main.sync {
                                self.personImageView.image = image
                                self.nativeCardInfo?.strPicture = self.strPicture
                                self.nativeCardInfo?.strPicture = self.strPicture
                                let dipChipDateTime = DateFormatter()
                                dipChipDateTime.dateFormat = "yyyy-MM-dd hh:mm:ss"
                                self.nativeCardInfo?.dipChipDateTime = dipChipDateTime.string(from: Date())
                                
                                var expDate: Date? = nil
                                if let exp = self.nativeCardInfo?.cardExpiryDate {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "dd/MM/yyyy"
                                    expDate = dateFormatter.date(from: exp)
                                }
                                if expDate != nil {
                                    if Date() > expDate! {
                                        self.hideProgress()
                                        self.showAlertExp {
                                            if GlobalVariable.IS_OFFLINE {
                                                self.hideProgress()
                                                if OfflineRecord.addDataOffLine(data: self.nativeCardInfo ?? NativeCardInfo()) {
                                                    self.showAlertSuccess()
                                                    self.tableView.reloadData()
                                                } else {
                                                    self.showAlertFail()
                                                }
                                            } else {
                                                self.uploadData(nativeCardInfo: self.nativeCardInfo ?? NativeCardInfo())
                                                self.tableView.reloadData()
                                            }
                                        }
                                    } else {
                                        if GlobalVariable.IS_OFFLINE {
                                            self.hideProgress()
                                            if OfflineRecord.addDataOffLine(data: self.nativeCardInfo ?? NativeCardInfo()) {
                                                self.showAlertSuccess()
                                                self.tableView.reloadData()
                                            } else {
                                                self.showAlertFail()
                                            }
                                        } else {
                                            self.uploadData(nativeCardInfo: self.nativeCardInfo ?? NativeCardInfo())
                                            self.tableView.reloadData()
                                        }
                                    }
                                } else {
                                    self.hideProgress()
                                    self.showAlertFail()
                                }
                            }
                        }
                        numCodephoto += 1
                    } else {
                        break
                    }
                }
                numResponse += 1

            }

            if numCommands == 0 {
                print("Error: Cannot load the command")
                DispatchQueue.main.sync {
                    self.hideProgress()
                    self.showAlertFail()
                }
                
            }

        } catch {
            print("Error: " + error.localizedDescription)
            
            DispatchQueue.main.sync {
                self.hideProgress()
                if error.localizedDescription == "No card present: Card is removed" {
                    self.showAlertNoCard()
                } else {
                    self.showAlertFail()
                    
                }
            }
        }

        hScriptFile!.closeFile()
    }
    
    func openFile(name: String) -> FileHandle? {
        let bundle = Bundle.main
        let path = bundle.path(forResource: "scripts/acos3", ofType: "txt")
        let filePath = NSString(string: path!)
        return FileHandle(forReadingAtPath: filePath as String)
    }

    func readLine(hFile: FileHandle) -> String {

        var line = ""

        // Read the first byte.
        var buffer = hFile.readData(ofLength: 1)
        while buffer.count > 0 {

            // Append the byte to the line.
            if let byteString = String(data: buffer,
                                       encoding: String.Encoding.ascii) {
                line += byteString
                if byteString == "\n" {
                    break
                }
            }

            // Read the next byte.
            buffer = hFile.readData(ofLength: 1)
        }

        return line
    }

    /// Checks the line.
    ///
    /// - Parameter line: the line
    /// - Returns: the number of characters
    func checkLine(_ line: String) -> Int {

        var count = 0

        for c in line {
            if c >= Character("0") && c <= Character("9")
                || c >= Character("A") && c <= Character("F")
                || c >= Character("a") && c <= Character("f")
                || c == Character("X")
                || c == Character("x") {
                count += 1
            }
        }

        return count
    }
    
    func readACR() {
        // Check the selected card terminal.
        let terminal: CardTerminal! = self.terminal
        if terminal == nil {
            print("Error: Card terminal not selected")
        }

        // Check the selected filename.
        let filename: String! = "acos3"
        if filename == nil {
            print("Error: File not selected")
        }

        // Check the selected protocol.
        let protocolString = "T=0"

        DispatchQueue.global().async {
            do {

                // Connect to the card.
                print("Connecting to the card ("
                    + terminal.name + ", " + protocolString + ")...")
                let card = try terminal.connect(
                    protocolString: protocolString)
                
                self.runScript(card: card, filename: filename) {

                    let channel = try $0.basicChannel()
                    let commandAPDU = try CommandAPDU(apdu: $1)
                    let responseAPDU = try channel.transmit(
                        apdu: commandAPDU)

                    return responseAPDU.bytes
                }

                // Disconnect from the card.
                print("Disconnecting the card ("
                    + terminal.name + ")...")
                try card.disconnect(reset: false)

            } catch {
                print("Error: " + error.localizedDescription)
                DispatchQueue.main.sync {
                    self.hideProgress()
                    if error.localizedDescription == "No card present: Card is removed" {
                        self.showAlertNoCard()
                    } else {
                        self.showAlertFail()
                        
                    }
                }
            }
        }
    }
}
