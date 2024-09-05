//

import SwiftUI
import Network

class DeviceManagerClass: ObservableObject {
    static public let shared = DeviceManagerClass()
    private var defaults = UserDefaults.standard
    
    @Published public var devices: [Device] = []
    
    init() {
        loadDefaults()
    }
    
    func loadDefaults() {
        let jsonDecoder = JSONDecoder()
        if let devicesJson = defaults.data(forKey: "devices") {
            do {
                devices = try jsonDecoder.decode([Device].self, from: devicesJson)
            } catch {
                defaults.removeObject(forKey: "devices")
                print(error)
            }
        }
    }
    
    func updateDefaults() {
        let jsonEncoder = JSONEncoder()
        let devicesJson = try? jsonEncoder.encode(devices)
        defaults.setValue(devicesJson, forKey: "devices")
    }
    
    func addDevice(device: Device) {
        devices.append(device)
        updateDefaults()
    }
    
    func updateDevice(device: Device, removeId: String) {
        devices.removeAll(where: {
            device in
            return device.id == removeId
        })
        devices.append(device)
        updateDefaults()
    }
    
    func removeDevice(id: String) {
        devices.removeAll(where: {
            device in
            return device.id == id
        })
        updateDefaults()
    }
    
    func getDevice(id: String) -> Device? {
        return devices.first(where: {device in device.id == id})
    }
}
