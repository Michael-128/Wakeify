//

import Foundation
import Network

struct Device: Codable, Identifiable {
    var id = UUID().uuidString
    let name: String
    let ip: String
    let mac: String
    let subnet: String
    let port: UInt16
    
    func sendWakeOnLan() {
        // Remove any separators from the MAC address (e.g., ":")
        let cleanedMacAddress = mac.replacingOccurrences(of: ":", with: "")
        
        // Convert the MAC address to binary data
        guard cleanedMacAddress.count == 12 else {
            print("Invalid MAC address length")
            return
        }
        
        var macData = Data()
        for i in 0..<6 {
            let start = cleanedMacAddress.index(cleanedMacAddress.startIndex, offsetBy: i*2)
            let end = cleanedMacAddress.index(start, offsetBy: 2)
            let byteString = cleanedMacAddress[start..<end]
            print(byteString)
            if let byte = UInt8(byteString, radix: 16) {
                macData.append(byte)
            } else {
                print("Failed to convert byte string \(byteString) to UInt8")
            }
        }
        print(macData)
        
        // The magic packet consists of 6 bytes of 0xFF followed by 16 repetitions of the MAC address
        var packet = Data(repeating: 0xFF, count: 6)
        for _ in 0..<16 {
            packet.append(macData)
        }
        print(packet.count)
        
        // Send the packet using UDP to the broadcast address
        guard let broadcastAddress = calculateBroadcastAddress(ipAddress: ip, subnetMask: subnet) else {
            print("Failed to calculate broadcast address")
            return
        }
        
        let connection = NWConnection(
            host: NWEndpoint.Host(broadcastAddress),
            port: NWEndpoint.Port(integerLiteral: port),
            using: .udp
        )
        
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                connection.send(content: packet, completion: .contentProcessed { error in
                    if let error = error {
                        print("Failed to send magic packet: \(error)")
                    } else {
                        print("Magic packet sent successfully")
                    }
                    connection.cancel()
                })
            default:
                break
            }
        }
        
        connection.start(queue: .global(qos: .background))
    }
    
    private func calculateBroadcastAddress(ipAddress: String, subnetMask: String) -> String? {
        let ipParts = ipAddress.split(separator: ".").compactMap { UInt8($0) }
        let maskParts = subnetMask.split(separator: ".").compactMap { UInt8($0) }

        guard ipParts.count == 4 && maskParts.count == 4 else { return nil }

        let broadcastParts = zip(ipParts, maskParts).map { (ip, mask) -> UInt8 in
            return ip | ~mask
        }

        return broadcastParts.map(String.init).joined(separator: ".")
    }
}

