//

import SwiftUI

enum ValidationStatus {
    case valid
    case invalidName
    case invalidMac
    case invalidIP
    case invalidSubnet
    case invalidPort
}

struct DeviceAddSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var deviceManager = DeviceManagerClass.shared
    
    @State public var deviceId: String?
    
    @State private var name: String = ""
    @State private var mac: String = ""
    @State private var ip: String = ""
    @State private var subnet: String = ""
    @State private var port: String = "9"
    
    @State private var validationStatus: ValidationStatus = .valid
    @State private var isInvalidAlert = false
    
    func validateInputs() -> ValidationStatus {
        if name.isEmpty { return .invalidName }

        let macAddressRegex = "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$"
        let macAddressPredicate = NSPredicate(format: "SELF MATCHES %@", macAddressRegex)
        if !macAddressPredicate.evaluate(with: mac) {
            return .invalidMac
        }

        if !isValidIPAddress(ip) {
            return .invalidIP
        }

        if !isValidSubnet(subnet) {
            return .invalidSubnet
        }

        if let portNumber = UInt16(port), portNumber >= 0 && portNumber <= 65535 {
               // Port is valid
        } else {
           return .invalidPort
        }

        return .valid
    }
    
    func isValidIPAddress(_ ipAddress: String) -> Bool {
        let ipAddressPredicate = NSPredicate(format: "SELF MATCHES %@", "^((25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9]?[0-9])$")
        return ipAddressPredicate.evaluate(with: ipAddress)
    }

    // Helper function to validate Subnet
    func isValidSubnet(_ subnet: String) -> Bool {
        let subnetPredicate = NSPredicate(format: "SELF MATCHES %@", "^((25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9]?[0-9])\\.){3}(25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9]?[0-9])$")
        return subnetPredicate.evaluate(with: subnet)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Mac Address")) {
                    TextField("Mac Address", text: $mac)
                }
                
                Section(header: Text("IP Address")) {
                    TextField("IP Address", text: $ip)
                }
                
                Section(header: Text("Subnet Mask")) {
                    TextField("Subnet Mask", text: $subnet)
                }
                
                Section(header: Text("Port"), footer: Text("Enter the Wake-on-LAN port. 9 is usually supported by Ethernet cards, otherwise you can try 7 or 0.")) {
                    TextField("Port", text: $port)
                }
            }.toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        validationStatus = validateInputs()
                        
                        if validationStatus != .valid { isInvalidAlert = true; return  }
                        
                        let device = Device(name: name, ip: ip, mac: mac, subnet: subnet, port: UInt16(port) ?? 9)
                        
                        if let deviceId = deviceId {
                            deviceManager.updateDevice(device: device, removeId: deviceId)
                        } else {
                            deviceManager.addDevice(device: device)
                        }
                        
                        dismiss()
                    } label: {
                        Text("Save")
                    }
                }
            }.navigationTitle("Add Device")
                .navigationBarTitleDisplayMode(.inline)
                .alert(isPresented: $isInvalidAlert) {
                    switch validationStatus {
                    case .invalidName:
                        return Alert(
                            title: Text("Invalid Name"),
                            message: Text("Name cannot be empty."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .invalidMac:
                        return Alert(
                            title: Text("Invalid MAC Address"),
                            message: Text("Please enter a valid MAC address in the format XX:XX:XX:XX:XX:XX."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .invalidIP:
                        return Alert(
                            title: Text("Invalid IP Address"),
                            message: Text("Please enter a valid IP address."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .invalidSubnet:
                        return Alert(
                            title: Text("Invalid Subnet"),
                            message: Text("Please enter a valid subnet mask."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .invalidPort:
                        return Alert(
                            title: Text("Invalid Port"),
                            message: Text("Please enter a valid port number between 0 and 65535."),
                            dismissButton: .default(Text("OK"))
                        )
                    case .valid:
                        // This case should not happen for an alert
                        return Alert(
                            title: Text("Success"),
                            message: Text("All inputs are valid."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }.onAppear() {
                    print(deviceId)
                    
                    if let deviceId = deviceId {
                        let device = deviceManager.getDevice(id: deviceId)
                        
                        if let device = device {
                            name = device.name
                            mac = device.mac
                            ip = device.ip
                            subnet = device.subnet
                            port = String(device.port)
                        } else {
                            dismiss()
                        }
                    }
                }
        }
    }
}
