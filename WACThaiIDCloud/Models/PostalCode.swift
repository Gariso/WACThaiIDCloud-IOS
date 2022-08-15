import Foundation
import SwiftyJSON

class PostalCode: Codable {
    var id: String = ""
    var zip: String = ""
    var province: String = ""
    var district: String = ""
    var lat: Double
    var lng: Double
}
