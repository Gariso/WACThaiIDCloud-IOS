import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import SwiftyJSON

class WACThaiIDCloudAPI {
    
    // MARK: - Variable
    internal let manager = Session.default
    
    var baseUrl = GlobalVariable.DEFAULT_URL + GlobalVariable.DEFAULT_PORT
    let loginPath = "login"
    let tokenPath = "token"
    let cardDataPath = "smartData"
    
    func login(username: String, password: String, deviceId: String) -> Observable<JSON> {
        baseUrl =  GlobalVariable.URL + GlobalVariable.PORT
        let url = baseUrl + loginPath
        print("url: ", url)
        let params: Parameters = ["username": username,
                                  "password": password,
                                  "deviceId": deviceId]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        return manager.rx.request(.post, url, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .flatMap {
                $0.validate(contentType: ["application/json"]).rx.json()
            }
            .map { response -> JSON in
                return JSON(response)
            }
    }
    
    func getUserInfo(token: String) -> Observable<JSON> {
        baseUrl =  GlobalVariable.URL + GlobalVariable.PORT
        let url = baseUrl + tokenPath
        let headers: HTTPHeaders = ["Authorization": "\(token)",
                                    "Content-Type": "application/json"]
        return manager.rx.request(.post, url, encoding: JSONEncoding.default, headers: headers)
            .flatMap {
                $0.validate(contentType: ["application/json"]).rx.json()
            }
            .map { response -> JSON in
                return JSON(response)
            }
    }
    
}
