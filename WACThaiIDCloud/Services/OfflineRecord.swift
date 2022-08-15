import Foundation

class OfflineRecord {
    
    class func addDataOffLine(data: NativeCardInfo) -> Bool {
        let userDefaults = UserDefaults.standard
        var nativeCardInfos: [NativeCardInfo] = getDataOffLine()
        nativeCardInfos.append(data)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(nativeCardInfos){
            userDefaults.set(encoded, forKey: "SharedPrefs\(GlobalVariable.ID_USER_NAME)")
            return true
        } else {
            return false
        }
    }
    
    class func getDataOffLine() -> [NativeCardInfo] {
        if let objects = UserDefaults.standard.value(forKey: "SharedPrefs\(GlobalVariable.ID_USER_NAME)") as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [NativeCardInfo] {
                return objectsDecoded
            } else {
                return []
            }
        } else {
            return []
        }
    }
    
    class func removeDataOffLine() {
        UserDefaults.standard.removeObject(forKey: "SharedPrefs\(GlobalVariable.ID_USER_NAME)")
    }
}
