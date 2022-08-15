import Foundation
import UIKit
import ISO8859

extension ReaderViewController: MPayBleLibDelegate {
    
    func onMPayBleResponse_Error(_ iErrorCode: Int32, message sMessage: String!) {
        print("error sMessage: ", sMessage as Any)
        self.hideProgress()
        if iErrorCode == -36 {
            self.showAlertNoCard()
        }
    }
    
    func onMPayBleResponse_UpdateState(_ iStateCode: Int32, message sMessage: String!) {
        print("sMessage: ", sMessage as Any)
    }
    
    func onMPayBleResponse_IsConnected(_ bSucceed: Bool) {
        print("isConnect: ", bSucceed)
    }
    
    func onMPayBleResponse_IccStatus(_ bSucceed: Bool, isInserted: Bool) {
        if bSucceed && isInserted {
            smPayBleLib.mPayBle_IccPowerOn()
        }
    }

    func onMPayBleResponse_IccSelect(_ bSucceed: Bool) {
        print("IccSelect: ", bSucceed)
    }
    
    func onMPayBleResponse_IccPower(on bSucceed: Bool, atr sAtr: String!) {
        print("ICC Power: ", bSucceed)
        countData = 1
        countAPDU = 1
        countCodephoto = 1
        
        if (bSucceed) {
            if (sAtr.count > 1) {
                print("onICCPowerOn: >> ATR : ", sAtr as Any)
                smPayBleLib.mPayBle_IccAccess(CHIP_ID_APDU_COMMAND)
            }
        }
    }
    
    func onMPayBleResponse_IccAccess(_ bSucceed: Bool, rapdu sRapdu: String!) {
        print(bSucceed)
        print("sRapdu: ", sRapdu as Any)
        if !(sRapdu == "610A" || sRapdu == "610D" || sRapdu == "6164" || sRapdu == "6101" || sRapdu == "6108" ||
            sRapdu == "6114" || sRapdu == "6112" || sRapdu == "6102" || sRapdu == "6104" || sRapdu == "610E" ||
            sRapdu == "61FF")
        {
            var str = ""
            guard let bytes = stringToBytes(sRapdu) else { return }
            if let string = String(bytes, iso8859Encoding: ISO8859.part11) {
                str = string.trimmingCharacters(in: .whitespaces)
            }
//            print("str Test: ", String(decoding: bytes, as: UTF8.self))
            str = str.replacingOccurrences(of: "\n", with: "", options: [.regularExpression])
            str = str.replacingOccurrences(of: #"\u0090"#, with: "", options: [.regularExpression])
            str = str.replacingOccurrences(of: #"\u0010"#, with: "", options: [.regularExpression])
            str = str.replacingOccurrences(of: "\\s+", with: "", options: [.regularExpression])
            str = str.replacingOccurrences(of: "\\0", with: "", options: [.regularExpression]).replacingOccurrences(of: #"\u0000"#, with: "")
            str = str.replacingOccurrences(of: "\0", with: "", options: [.regularExpression])
            str = str.replacingOccurrences(of: #"\u{0F}"#, with: "", options: [.regularExpression]).trimmingCharacters(in: .whitespaces)
            str = str.replacingOccurrences(of: #"\u{08}"#, with: "", options: [.regularExpression]).trimmingCharacters(in: .whitespaces)
            str = str.replacingOccurrences(of: "", with: "", options: [.regularExpression])
            print("string encode: ", str)
            
            
            switch countData {
            case 1:
                var chip_card = ""
                for i in 0...15 {
                    chip_card = chip_card + String(sRapdu[i + 26])
                }
                print("chip_card: ", chip_card)
                nativeCardInfo?.chipId = chip_card
            case 2:
                print("2")
                print("laserId: ", str)
                nativeCardInfo?.laserId = str
            case 3:
                print("3")
                print("cardNumber: ", str)
                nativeCardInfo?.cardNumber = str
            case 4:
                print("4")
                let thaiNames = str.components(separatedBy: "#")
                print("thai title Name: ", thaiNames[0])
                print("thai fName: ", thaiNames[1])
                print("thai mName: ", thaiNames[2])
                print("thai lName: ", thaiNames[3])
                
                nativeCardInfo?.thaiTitle = thaiNames[0]
                nativeCardInfo?.thaiFirstName = thaiNames[1]
                nativeCardInfo?.thaiMiddleName = thaiNames[2]
                nativeCardInfo?.thaiLastName = thaiNames[3]
                
                
            case 5:
                print("5")
                let enNames = str.components(separatedBy: "#")
                print("en title Name: ", enNames[0])
                print("en fName: ", enNames[1])
                print("en mName: ", enNames[2])
                print("en lName: ", enNames[3])
                
                nativeCardInfo?.engTitle = enNames[0]
                nativeCardInfo?.engFirstName = enNames[1]
                nativeCardInfo?.engMiddleName = enNames[2]
                nativeCardInfo?.engLastName = enNames[3]
            case 6:
                print("6")
                if str == "1" {
                    str = "ชาย"
                } else if str == "2"{
                    str = "หญิง"
                }
                print("sex", str)
                nativeCardInfo?.sex = str
            case 7:
                print("7")
                let birthDate = str.subString(from: 6, to: 8) + "/" + str.subString(from: 4, to: 6) + "/" + str.subString(from: 0, to: 4)
                print("Birth Date: ", birthDate)
                nativeCardInfo?.dateOfBirth = birthDate
            case 8:
                print("8")
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
            case 9:
                print("9")
                print("bp1No: ", str)
                nativeCardInfo?.bp1No = str
            case 10:
                print("10")
                print("cardIssuePlace: ", str)
                nativeCardInfo?.cardIssuePlace = str
            case 11:
                print("11")
                print("cardIssueNo: ", str)
                nativeCardInfo?.cardIssueNo = str
            case 12:
                print("12")
                var strIssue = str.subString(from: 0, to: 8)
                var strExpire = str.subString(from: 8, to: 16)
                strIssue = strIssue.subString(from: 6, to: 8) + "/" + strIssue.subString(from: 4, to: 6) + "/" + strIssue.subString(from: 0, to: 4)
                strExpire = strExpire.subString(from: 6, to: 8) + "/" + strExpire.subString(from: 4, to: 6) + "/" + strExpire.subString(from: 0, to: 4)
                print("cardIssueDate: ", strIssue)
                print("cardExpiryDate: ", strExpire)
                nativeCardInfo?.cardIssueDate = strIssue
                nativeCardInfo?.cardExpiryDate = strExpire
            case 13:
                print("13")
                print("cardType: ", str)
                nativeCardInfo?.cardType = str
            case 14:
                print("14")
                print("versionCard: ", str)
                nativeCardInfo?.versionCard = str
            case 15:
                print("15")
                print("cardPhotoIssueNo: ", str)
                nativeCardInfo?.cardPhotoIssueNo = str
                smPayBleLib.mPayBle_IccAccess(codephoto[countCodephoto - 1])
                smPayBleLib.mPayBle_IccAccess(Code_APDU_LE)
                countCodephoto += 1
            default:
                if countData > 15 {
                    guard let bytes = stringToBytes(sRapdu) else { return }
                    var newResult = Data([UInt8]())
                    for i in 0...254 {
                        newResult.append(bytes[i % bytes.count])
                    }
                    print("newResult: ", newResult)
                    strPicture += newResult.hexEncodedString()
                    print("strPicture: ", strPicture)
                    if countCodephoto <= 20 {
                        smPayBleLib.mPayBle_IccAccess(codephoto[countCodephoto - 1])
                        smPayBleLib.mPayBle_IccAccess(Code_APDU_LE)
                        countCodephoto += 1
                    } else if countCodephoto == 21 {
                        guard let byteRawHex = stringToBytes(strPicture) else { return }
                        let datos: NSData = NSData(bytes: byteRawHex, length: byteRawHex.count)
                        let image = UIImage(data: datos as Data)
                        self.personImageView.image = image
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
                } else {
                    break
                }
            }
            countData += 1
        }
        
        if countAPDU <= 29 {
            smPayBleLib.mPayBle_IccAccess(listAPDU[countAPDU - 1])
            countAPDU += 1
        }
    }
}
