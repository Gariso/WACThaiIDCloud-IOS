import Foundation

class DnsAndPortRecord {
    private static let configureDnsAndPortKey = "CONFIGURE_DNS_PORT"
    private static let configureDnsKey = "DnsOrIp"
    private static let configurePortKey = "Port"
    
    class func setDnsOrIp(dnsOrIp: String) {
        UserDefaults.standard.set(dnsOrIp, forKey: "\(configureDnsAndPortKey)\(configureDnsKey)")
        UserDefaults.standard.synchronize()
    }
    
    class func setPort(port: String) {
        UserDefaults.standard.set(port, forKey: "\(configureDnsAndPortKey)\(configurePortKey)")
        UserDefaults.standard.synchronize()
    }
    
    class func getDnsOrIp() -> String {
        return UserDefaults.standard.string(forKey: "\(configureDnsAndPortKey)\(configureDnsKey)") ?? ""
    }
    
    class func getPort() -> String {
        return UserDefaults.standard.string(forKey: "\(configureDnsAndPortKey)\(configurePortKey)") ?? ""
    }
    
    class func removeDnsOrIpAndPort() {
        UserDefaults.standard.removeObject(forKey: "\(configureDnsAndPortKey)\(configureDnsKey)")
        UserDefaults.standard.removeObject(forKey: "\(configureDnsAndPortKey)\(configurePortKey)")
    }
}
