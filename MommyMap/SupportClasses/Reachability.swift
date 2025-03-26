
//
//  Constant.swift
//  Dating
//
//  Created by Getyoteam on 09/07/21.
//


import Foundation
import SystemConfiguration

public class Reachabilty
{
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
struct DataUsageInfo {
    var wifiReceived: UInt32 = 0
    var wifiSent: UInt32 = 0
    var wirelessWanDataReceived: UInt32 = 0
    var wirelessWanDataSent: UInt32 = 0
    
    mutating func updateInfoByAdding(_ info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
}


class DataUsage {
    
    private static let wwanInterfacePrefix = "pdp_ip"
    private static let wifiInterfacePrefix = "en"
    
    class func getDataUsage() -> DataUsageInfo {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var dataUsageInfo = DataUsageInfo()
        
        guard getifaddrs(&ifaddr) == 0 else { return dataUsageInfo }
        while let addr = ifaddr {
            guard let info = getDataUsageInfo(from: addr) else {
                ifaddr = addr.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info)
            ifaddr = addr.pointee.ifa_next
        }
        
        freeifaddrs(ifaddr)
        
        return dataUsageInfo
    }
    
    private class func getDataUsageInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let pointer = infoPointer
        let name: String! = String(cString: pointer.pointee.ifa_name)
        let addr = pointer.pointee.ifa_addr.pointee
        guard addr.sa_family == UInt8(AF_LINK) else { return nil }
        
        return dataUsageInfo(from: pointer, name: name)
    }
    
    private class func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo {
        var networkData: UnsafeMutablePointer<if_data>?
        var dataUsageInfo = DataUsageInfo()
        
        if name.hasPrefix(wifiInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            if let data = networkData {
                dataUsageInfo.wifiSent += data.pointee.ifi_obytes
                dataUsageInfo.wifiReceived += data.pointee.ifi_ibytes
            }
            
        } else if name.hasPrefix(wwanInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            if let data = networkData {
                dataUsageInfo.wirelessWanDataSent += data.pointee.ifi_obytes
                dataUsageInfo.wirelessWanDataReceived += data.pointee.ifi_ibytes
            }
        }
        
        return dataUsageInfo
    }
}

