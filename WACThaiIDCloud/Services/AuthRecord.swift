import Foundation

class AuthRecord {
    private static let authKey = "AUTHENTICATION_FILE_NAME"
    private static let authUsername = "Username"
    private static let authPassword = "Password"
    
    class func setAuthUsername(username: String) {
        UserDefaults.standard.set(username, forKey: "\(authKey)\(authUsername)")
        UserDefaults.standard.synchronize()
    }
    
    class func setAuthPassword(password: String) {
        UserDefaults.standard.set(password, forKey: "\(authKey)\(authPassword)")
        UserDefaults.standard.synchronize()
    }
    
    class func getAuthUsername() -> String {
        return UserDefaults.standard.string(forKey: "\(authKey)\(authUsername)") ?? ""
    }
    
    class func getAuthPassword() -> String {
        return UserDefaults.standard.string(forKey: "\(authKey)\(authPassword)") ?? ""
    }
    
    class func removeAuthUsernameAndPassword() {
        UserDefaults.standard.removeObject(forKey: "\(authKey)\(authUsername)")
        UserDefaults.standard.removeObject(forKey: "\(authKey)\(authPassword)")
    }
}
