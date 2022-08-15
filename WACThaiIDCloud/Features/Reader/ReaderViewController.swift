//
//  ReaderViewController.swift
//  WACThaiIDCloud
//
//  Created by Thananchai Pinyo on 28/7/2565 BE.
//

import UIKit
import Foundation
import CoreBluetooth
import ISO8859
import SmartCardIO
import ACSSmartCardIO
import SwiftyJSON
import RxSwift
import Alamofire
import RxAlamofire

class ReaderViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var personImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var stateOneLabel: UILabel!
    @IBOutlet private weak var stateTwoLabel: UILabel!
    @IBOutlet private weak var stateThreeLabel: UILabel!
    @IBOutlet private weak var stateOneTapView: UIView!
    @IBOutlet private weak var stateTwoTapView: UIView!
    @IBOutlet private weak var stateThreeTapView: UIView!
    
    private let network = WACThaiIDCloudAPI()
    private let disposeBag = DisposeBag()
    
    let CHIP_ID_APDU_COMMAND = "80ca9f7f00"
//    let DEFAULT_3901_MASTER_KEY = "FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF FF"
    let LASER_ID_APDU_COMMAND = "00a4040008a000000084060002"
    let LASER_ID_APDU_LE = "8000000017"
    let DEFAULT_3901_APDU_COMMAND = "00A4040008A000000054480001"
    let IDCARD_APDU_COMMAND = "80B0000402000D"
    let IDCARD_APDU_LE = "00C000000D"
    let NAME_TH_APDU_COMMAND = "80B00011020064"
    let NAME_TH_APDU_LE = "00C0000064"
    let NAME_EN_APDU_COMMAND = "80B00075020064"
    let NAME_EN_APDU_LE = "00C0000064"
    let GENDER_APDU_COMMAND = "80B000E1020001"
    let GENDER_APDU_LE = "00C0000001"
    let DOB_APDU_COMMAND = "80B000D9020008"
    let DOB_APDU_LE = "00C0000008"
    let Address_APDU_COMMAND = "80B01579020064"
    let Address_APDU_LE = "00C0000064"
    let RequestNum_APDU_COMMAND = "80B000E2020014"
    let RequestNum_APDU_LE = "00C0000014"
    let Issue_place_APDU_COMMAND = "80B000F6020064"
    let Issue_place_APDU_LE = "00C0000064"
    let Issue_code_APDU_COMMAND = "80B0015A02000D"
    let Issue_code_APDU_LE = "00C000000D"
    let ISSUE_EXPIRE_APDU_COMMAND = "80B00167020012"
    let ISSUE_EXPIRE_APDU_LE = "00C0000012"
    let Card_Type_APDU_COMMAND = "80B00177020002"
    let Card_Type_APDU_LE = "00C0000002"
    let Version_APDU_COMMAND = "80B00000020004"
    let Version_APDU_LE = "00C0000004"
    let Image_code_APDU_COMMAND = "80b0161902000e"
    let Image_code_APDU_LE = "00c000000e"
    let Code_APDU_LE = "00C00000FF"
    let codephoto = [
        "80B0017B0200FF",
        "80B0027A0200FF",
        "80B003790200FF",
        "80B004780200FF",
        "80B005770200FF",
        "80B006760200FF",
        "80B007750200FF",
        "80B008740200FF",
        "80B009730200FF",
        "80B00A720200FF",
        "80B00B710200FF",
        "80B00C700200FF",
        "80B00D6F0200FF",
        "80B00E6E0200FF",
        "80B00F6D0200FF",
        "80B0106C0200FF",
        "80B0116B0200FF",
        "80B0126A0200FF",
        "80B013690200FF",
        "80B014680200FF"
    ]
    
    var listAPDU = [String]()
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var smPayBleLib: MPayBleLib!
    
    var itemDataState = 0
    var countData = 1
    var countAPDU = 1
    var countCodephoto = 1
    var strPicture = ""
    
    var terminal: CardTerminal?
    
    var typeReader: TypeReader? = .mbr20
    var manager: BluetoothTerminalManager?
    
    var nativeCardInfo: NativeCardInfo? = NativeCardInfo()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        stateOneLabel.text = "SECTION 1"
        stateOneLabel.layer.cornerRadius = 3
        
        stateTwoLabel.text = "SECTION 2"
        stateTwoLabel.layer.cornerRadius = 3
        
        stateThreeLabel.text = "SECTION 3"
        stateThreeLabel.layer.cornerRadius = 3
        
        updateItemDataState()
        
        tableView.register(UINib(nibName: "ItemDataCell", bundle: nil), forCellReuseIdentifier: "ItemDataCell")
        self.navigationController?.isNavigationBarHidden = true
        switch typeReader {
        case .acr:
            self.titleLabel.text = terminal?.name
        case .mbr20:
            self.titleLabel.text  = peripheral?.name
            self.smPayBleLib.delegate = self
            
            listAPDU.append(LASER_ID_APDU_COMMAND)
            listAPDU.append(LASER_ID_APDU_LE)
            listAPDU.append(DEFAULT_3901_APDU_COMMAND)
            listAPDU.append(IDCARD_APDU_COMMAND)
            listAPDU.append(IDCARD_APDU_LE)
            listAPDU.append(NAME_TH_APDU_COMMAND)
            listAPDU.append(NAME_TH_APDU_LE)
            listAPDU.append(NAME_EN_APDU_COMMAND)
            listAPDU.append(NAME_EN_APDU_LE)
            listAPDU.append(GENDER_APDU_COMMAND)
            listAPDU.append(GENDER_APDU_LE)
            listAPDU.append(DOB_APDU_COMMAND)
            listAPDU.append(DOB_APDU_LE)
            listAPDU.append(Address_APDU_COMMAND)
            listAPDU.append(Address_APDU_LE)
            listAPDU.append(RequestNum_APDU_COMMAND)
            listAPDU.append(RequestNum_APDU_LE)
            listAPDU.append(Issue_place_APDU_COMMAND)
            listAPDU.append(Issue_place_APDU_LE)
            listAPDU.append(Issue_code_APDU_COMMAND)
            listAPDU.append(Issue_code_APDU_LE)
            listAPDU.append(ISSUE_EXPIRE_APDU_COMMAND)
            listAPDU.append(ISSUE_EXPIRE_APDU_LE)
            listAPDU.append(Card_Type_APDU_COMMAND)
            listAPDU.append(Card_Type_APDU_LE)
            listAPDU.append(Version_APDU_COMMAND)
            listAPDU.append(Version_APDU_LE)
            listAPDU.append(Image_code_APDU_COMMAND)
            listAPDU.append(Image_code_APDU_LE)

            self.smPayBleLib.mPayBle_IccSelect(0)
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch typeReader {
        case .acr:
            break
//            self.manager.delegate = self
        case .mbr20:
            self.smPayBleLib.delegate = self
        case .none:
            break
        }
        
    }
    
    // MARK: Function
    
    func toHexString(buffer: [UInt8]) -> String {

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

    
    func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    func updateItemDataState() {
        switch self.itemDataState {
        case 0:
            stateOneLabel.textColor = .pinkColor
            stateTwoLabel.textColor = UIColor.lightGray
            stateThreeLabel.textColor = UIColor.lightGray
            stateOneTapView.isHidden = false
            stateTwoTapView.isHidden = true
            stateThreeTapView.isHidden = true
        case 1:
            stateTwoLabel.textColor = .pinkColor
            stateOneLabel.textColor = UIColor.lightGray
            stateThreeLabel.textColor = UIColor.lightGray
            stateTwoTapView.isHidden = false
            stateOneTapView.isHidden = true
            stateThreeTapView.isHidden = true
        case 2:
            stateThreeLabel.textColor = .pinkColor
            stateTwoLabel.textColor = UIColor.lightGray
            stateOneLabel.textColor = UIColor.lightGray
            stateThreeTapView.isHidden = false
            stateTwoTapView.isHidden = true
            stateOneTapView.isHidden = true
        default:
            break
        }
        self.tableView.reloadData()
    }
    
    func findPostalCode(province: String, district: String) -> String {
        if let fileZipcode = Bundle.main.url(forResource: "zipcode", withExtension: "json") {
            do {
                let zipcodeData = try Data(contentsOf: fileZipcode)
                let jsonDecoder = JSONDecoder()
                let postalCodeList = try jsonDecoder.decode([PostalCode].self, from: zipcodeData)
                let newProvince = province.replacingOccurrences(of: "จังหวัด", with: "", options: [.regularExpression])
                let newDistrict = district.replacingOccurrences(of: "อำเภอ", with: "", options: [.regularExpression])
                let findPostalCodeList = postalCodeList.filter {
                    $0.province == newProvince
                    && $0.district == newDistrict }
                return findPostalCodeList.first?.zip ?? ""
            } catch {
                print(error)
                return ""
            }
        } else {
            return ""
        }
    }
    
    func getAccessToken(refreshToken: String) {
        self.network.getUserInfo(token: refreshToken)
            .asObservable()
            .subscribe(onNext: { response in
                if let error = response["error"].dictionary {
                    print("getUserInfo with Error: \(error)")
                    self.hideProgress()
                    self.showAlertFail()
                } else {
                    print("getUserInfo response : ", response)
                    if response["status"].intValue != 400 {
                        GlobalVariable.ACCESS_TOKEN = response["message","access_token"].stringValue
                    } else {
                        self.hideProgress()
                        let story = UIStoryboard(name: "Main", bundle:nil)
                        let vc = story.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                }
            }, onError: { err in
                print("getUserInfo ERROR: \(err)")
                self.hideProgress()
                self.showAlertFail()
            })
            .disposed(by: self.disposeBag)
    }
    
    func uploadData(nativeCardInfo: NativeCardInfo) {
        let url = GlobalVariable.URL + GlobalVariable.PORT + WACThaiIDCloudAPI().cardDataPath
        
        let byteRawHex = stringToBytes(nativeCardInfo.strPicture)
        let datos: NSData = NSData(bytes: byteRawHex, length: byteRawHex!.count)
        let image = UIImage(data: datos as Data)
        let imageData = image?.pngData()
        
        let params: Parameters = ["mId": GlobalVariable.USER_ID,
                                  "uId": GlobalVariable.UID,
                                  "bp1No": nativeCardInfo.bp1No,
                                  "chipId": nativeCardInfo.chipId,
                                  "cardNumber": nativeCardInfo.cardNumber,
                                  "thaiTitle": nativeCardInfo.thaiTitle,
                                  "thaiFirstName": nativeCardInfo.thaiFirstName,
                                  "thaiMiddleName": nativeCardInfo.thaiMiddleName,
                                  "thaiLastName": nativeCardInfo.thaiLastName,
                                  "engTitle": nativeCardInfo.engTitle,
                                  "engFirstName": nativeCardInfo.engFirstName,
                                  "engMiddleName": nativeCardInfo.engMiddleName,
                                  "engLastName": nativeCardInfo.engLastName,
                                  "dateOfBirth": nativeCardInfo.dateOfBirth,
                                  "sex": nativeCardInfo.sex,
                                  "cardIssueNo": nativeCardInfo.cardIssueNo,
                                  "cardIssuePlace": nativeCardInfo.cardIssuePlace,
                                  "cardIssueDate": nativeCardInfo.cardIssueDate,
                                  "cardPhotoIssueNo": nativeCardInfo.cardPhotoIssueNo,
                                  "laserId": nativeCardInfo.laserId,
                                  "cardExpiryDate": nativeCardInfo.cardExpiryDate,
                                  "cardType": nativeCardInfo.cardType,
                                  "homeNo": nativeCardInfo.address?.homeNo ?? "",
                                  "soi": nativeCardInfo.address?.soi ?? "",
                                  "trok": nativeCardInfo.address?.trok ?? "",
                                  "moo": nativeCardInfo.address?.moo ?? "",
                                  "road": nativeCardInfo.address?.road ?? "",
                                  "subDistrict": nativeCardInfo.address?.subDistrict ?? "",
                                  "district": nativeCardInfo.address?.district ?? "",
                                  "province": nativeCardInfo.address?.province ?? "",
                                  "postalCode": nativeCardInfo.address?.postalCode ?? "",
                                  "country": nativeCardInfo.address?.country ?? "",
                                  "cardCountry": nativeCardInfo.cardCountry,
                                  "channel": "dipchip via MOBILE",
                                  "dipChipDateTime": nativeCardInfo.dipChipDateTime,
                                  "ipaddress": getNetworkIPAddress(network: NetworkType.cellular.rawValue) ?? ""]

        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Authorization": "\(GlobalVariable.ACCESS_TOKEN)"]
        Session.default.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData!, withName: "smartDataImage",fileName: "image.png" , mimeType: "image/png")
            for (key, value) in params {
                print("\(key) \(value)")
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, to: url, usingThreshold:UInt64.init(), method: .post, headers: headers)
        .uploadProgress(queue: .main, closure: { progress in
                    //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseJSON(completionHandler: { data in
            
            switch data.result {

            case .success(_):
             do {
        
                 let dictionary = try JSONSerialization.jsonObject(with: data.data!, options: .fragmentsAllowed) as! NSDictionary
               
                 print("Success!")
                 self.hideProgress()
                 let data = JSON(dictionary)
                 if data["message"] == "add completed" {
                     self.showAlertSuccess()
                 } else if data["message"] == "Unauthorized" {
                     self.getAccessToken(refreshToken: GlobalVariable.REFRESH_TOKEN)
                 } else {
                     self.showAlertFail()
                 }
            }
            catch { print("catch error") }
                self.hideProgress()
                self.showAlertFail()
                break
            case .failure(_):
                print("failure")
                self.hideProgress()
                self.showAlertFail()
                break
             
            }
        })
    }
    
    func getNetworkIPAddress(network:String) -> String? {
        var address : String?

        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                let name = String(cString: interface.ifa_name)
                if  name == network {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return address
    }
    
    func selectOptionType() {
        let typeAction0 = UIAlertAction(
            title: "About Us",
            style: .default) { (action) in
                self.showAlertAboutUs()
        }
        
        let typeAction1 = UIAlertAction(
            title: "Log Out",
            style: .default) { (action) in
                let story = UIStoryboard(name: "Main", bundle:nil)
                let vc = story.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                UIApplication.shared.keyWindow?.rootViewController = vc
        }
        
        let typeAction2 = UIAlertAction(
            title: "Cancal",
            style: .cancel) { (action) in
   
        }
        
        let alert = UIAlertController(title: "Select Option",
                                      message: "",
                                      preferredStyle: .actionSheet)

        alert.addAction(typeAction0)
        alert.addAction(typeAction1)
        alert.addAction(typeAction2)

        self.present(alert, animated: true)
    }
    
    // MARK: Action
    
    @IBAction func actionBackBtn(_ sender: Any) {
        switch typeReader {
        case .acr:
            break
        case .mbr20:
            self.smPayBleLib.mPayBle_DisconnectDevice()
        case .none:
            break
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func actionOptionBtn(_ sender: Any) {
        selectOptionType()
    }
    
    @IBAction func actionPowerOnBtn(_ sender: Any) {
        self.nativeCardInfo = NativeCardInfo()
        self.personImageView.image = UIImage(systemName: "person")
        tableView.reloadData()
        switch typeReader {
        case .acr:
            self.showProgress()
            readACR()
        case .mbr20:
            self.showProgress()
            self.smPayBleLib.mPayBle_IccPowerOn()
        case .none:
            break
        }
    }
    
    @IBAction func actionItemDataStateOneBtn(_ sender: Any) {
        self.itemDataState = 0
        updateItemDataState()
    }
    
    @IBAction func actionItemDataStateTwoBtn(_ sender: Any) {
        self.itemDataState = 1
        updateItemDataState()
    }
    
    @IBAction func actionItemDataStateThreeBtn(_ sender: Any) {
        self.itemDataState = 2
        updateItemDataState()
    }
    
}
