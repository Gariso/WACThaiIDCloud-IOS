import UIKit
import RxSwift
import SwiftyJSON
import Alamofire
import RxAlamofire

enum NetworkType:String {
    case wifi = "en0"
    case cellular = "pdp_ip0"
}

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var settingBtn: UIButton!
    
    private let network = WACThaiIDCloudAPI()
    private let disposeBag = DisposeBag()
    var deviceId = ""
    var networkIP = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTF.placeholder = "username"
        passwordTF.placeholder = "password"
        
        usernameTF.text = "ios@serverwac"  //"ios@serverwac"//"123ios"
        passwordTF.text = "iotd+chIC=" //"iotd+chIC="//"NqqOO.~Us+"
        
        usernameTF.delegate = self
        passwordTF.delegate = self
        
        usernameTF.text = AuthRecord.getAuthUsername()
        passwordTF.text = AuthRecord.getAuthPassword()
        
        let dnsValue = DnsAndPortRecord.getDnsOrIp()
        let port = DnsAndPortRecord.getPort()
        
        if dnsValue.isEmpty {
            GlobalVariable.URL = GlobalVariable.DEFAULT_URL
            GlobalVariable.PORT = GlobalVariable.DEFAULT_PORT
        } else {
            GlobalVariable.URL = dnsValue
            GlobalVariable.PORT = port
        }
        
        deviceId = UIDevice.current.name //UIDevice.current.identifierForVendor!.uuidString
        print("deviceId: ", deviceId)
        networkIP = getNetworkIPAddress(network: NetworkType.cellular.rawValue) ?? ""
        
        let settingImage = UIImage(named: "ic_setting")
        let tintedImage = settingImage?.withRenderingMode(.alwaysTemplate)
        self.settingBtn.setImage(tintedImage, for: .normal)
        self.settingBtn.tintColor = .lightGray
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
       textField.resignFirstResponder()
       return true
    }
    
    
    // MARK: Function
    func login(username: String, password: String, deviceId: String) {
        self.showProgress()
        let baseUrl = GlobalVariable.URL + GlobalVariable.PORT
        print(baseUrl)
        self.network.login(username: username, password: password, deviceId: deviceId)
            .asObservable()
            .subscribe(onNext: { response in
                if let error = response["error"].dictionary {
                    print("login Success with Error: \(error)")
                    self.hideProgress()
                    self.showAlertOfflineUse {
                        GlobalVariable.ID_USER_NAME = self.usernameTF.text ?? ""
                        GlobalVariable.IS_OFFLINE = true
                        let story = UIStoryboard(name: "Main", bundle:nil)
                        let vc = story.instantiateViewController(withIdentifier: "navScan") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                } else {
                    print("login response: ", response)
                    if response["message"].stringValue != "" {
                        self.hideProgress()
                        self.showAlertFail(message: response["message"].stringValue)
                        
                    } else if  response["message"].stringValue != "No address associated with hostname" {
                        self.hideProgress()
                        self.showAlertOfflineUse {
                            GlobalVariable.ID_USER_NAME = self.usernameTF.text ?? ""
                            GlobalVariable.IS_OFFLINE = true
                            let story = UIStoryboard(name: "Main", bundle:nil)
                            let vc = story.instantiateViewController(withIdentifier: "navScan") as! UINavigationController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                    } else {
                        if response["refresh_token"].stringValue.isEmpty {
                            let refreshToken = response["message","refresh_token"].stringValue
                            self.getUserInfo(refreshToken: refreshToken)
                        }
                    }
                }
            }, onError: { err in
                print("login ERROR: \(err)")
                self.hideProgress()
                self.showAlertFail()
            })
            .disposed(by: self.disposeBag)
    }
    
    func getUserInfo(refreshToken: String) {
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
                        GlobalVariable.REFRESH_TOKEN = response["message","refresh_token"].stringValue
                        GlobalVariable.USER_NAME = self.usernameTF.text ?? ""
                        GlobalVariable.IS_OFFLINE = false
                        if let userInfo = self.decodeToken(refreshToken) {
                            GlobalVariable.USER_ID = userInfo["userId"] as? String ?? ""
                            GlobalVariable.UID = userInfo["uId"] as? String ?? ""
                            GlobalVariable.USER_RULE = userInfo["rule"] as? String ?? ""
                        }
                        
                        AuthRecord.setAuthUsername(username: self.usernameTF.text ?? "")
                        AuthRecord.setAuthPassword(password: self.passwordTF.text ?? "")
                        
                        if OfflineRecord.getDataOffLine().isEmpty {
                            self.hideProgress()
                            GlobalVariable.IS_OFFLINE = true
                            let story = UIStoryboard(name: "Main", bundle:nil)
                            let vc = story.instantiateViewController(withIdentifier: "navScan") as! UINavigationController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        } else {
                            for (index, data) in OfflineRecord.getDataOffLine().enumerated() {
                                self.uploadData(nativeCardInfo: data, index: index)
                            }
                        }
                    } else {
                        self.hideProgress()
                        self.showAlertFail()
                    }
                }
            }, onError: { err in
                print("getUserInfo ERROR: \(err)")
                self.hideProgress()
                self.showAlertFail()
            })
            .disposed(by: self.disposeBag)
    }
    
    func uploadData(nativeCardInfo: NativeCardInfo, index: Int) {
        let url = WACThaiIDCloudAPI().baseUrl + WACThaiIDCloudAPI().cardDataPath
        
        let byteRawHex = nativeCardInfo.strPicture.stringToBytes()
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
        print("params: ", params)
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
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
                 print("response: ", dictionary)
                 if index == OfflineRecord.getDataOffLine().count - 1 {
                     self.hideProgress()
                     OfflineRecord.removeDataOffLine()
                     let story = UIStoryboard(name: "Main", bundle:nil)
                     let vc = story.instantiateViewController(withIdentifier: "navScan") as! UINavigationController
                     UIApplication.shared.keyWindow?.rootViewController = vc
                 }
            }
            catch { print("catch error") }
                self.hideProgress()
                break
            case .failure(_):
                print("failure")
                self.hideProgress()
                break
             
            }
        })
    }
    
    func decodeToken(_ token: String) -> [String: AnyObject]? {
        let string = token.components(separatedBy: ".")
        let toDecode = string[1] as String


        var stringtoDecode: String = toDecode.replacingOccurrences(of: "-", with: "+")
        stringtoDecode = stringtoDecode.replacingOccurrences(of: "_", with: "/")
        switch (stringtoDecode.utf16.count % 4) {
        case 2: stringtoDecode = "\(stringtoDecode)=="
        case 3: stringtoDecode = "\(stringtoDecode)="
        default:
            print("")
        }
        let dataToDecode = Data(base64Encoded: stringtoDecode, options: [])
        let base64DecodedString = NSString(data: dataToDecode!, encoding: String.Encoding.utf8.rawValue)

        var values: [String: AnyObject]?
        if let string = base64DecodedString {
            if let data = string.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: true) {
                values = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]
            }
        }
        return values
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
    
    func showAlertSettingDnsAndPort() {
        let alertController = UIAlertController(title: "Configure IP or DNS and Port", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            let dnsTF = alertController.textFields?.first?.text ?? ""
            let portTF = alertController.textFields?[1].text ?? ""
            DnsAndPortRecord.setDnsOrIp(dnsOrIp: dnsTF)
            DnsAndPortRecord.setPort(port: portTF)
        }
        let defaultlAction = UIAlertAction(title: "Default", style: .default) { (_) in
            DnsAndPortRecord.removeDnsOrIpAndPort()
            GlobalVariable.URL = GlobalVariable.DEFAULT_URL
            GlobalVariable.PORT = GlobalVariable.DEFAULT_PORT
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "IP Or DNS"
            let dnsValue = DnsAndPortRecord.getDnsOrIp()
            if dnsValue.isEmpty {
                textField.text = GlobalVariable.DEFAULT_URL
            } else {
                textField.text = dnsValue
            }
        }
    
        alertController.addTextField { (textField) in
            textField.placeholder = "PORT"
            let portValue = DnsAndPortRecord.getPort()
            if portValue.isEmpty {
                textField.text = GlobalVariable.PORT
            } else {
                textField.text = portValue
            }
        }
        let cancalAction = UIAlertAction(
            title: "Cancal",
            style: .cancel) { (action) in
   
        }
        alertController.addAction(confirmAction)
        alertController.addAction(defaultlAction)
        alertController.addAction(cancalAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Action
    @IBAction func actionSettingBtn(_ sender: Any) {
        showAlertSettingDnsAndPort()
    }
    
    @IBAction func actionLoginBtn(_ sender: Any) {
        if usernameTF.text != "" && passwordTF.text != "" {
            login(username: usernameTF.text ?? "", password: passwordTF.text ?? "", deviceId: self.deviceId)
        } else {
            self.showAlertFailText()
        }
    }
}
