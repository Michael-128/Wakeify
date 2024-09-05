//

import SwiftUI

struct DeviceListRow: View {
    @State public var device: Device
    @ObservedObject var deviceManager = DeviceManagerClass.shared
    
    public var setDeviceEditSheet: ((String) -> Void)?
    
    @State private var isRemoveAlert = false
    
    var body: some View {
        Button {
            device.sendWakeOnLan()
        } label: {
            VStack {
                HStack {
                    Text("\(device.name)")
                    Spacer()
                    Image(systemName: "power")
                }
            }.contextMenu(ContextMenu(menuItems: {
                Button {
                    if let setDeviceEditSheet = setDeviceEditSheet {
                        setDeviceEditSheet(device.id)
                    }
                } label: {
                    Image(systemName: "pencil")
                    Text("Edit")
                }
                
                Button(role: .destructive) {
                    isRemoveAlert = true
                } label: {
                    Image(systemName: "trash")
                    Text("Remove")
                }
            })).alert(isPresented: $isRemoveAlert) {
                Alert(title: Text("Remove Device"), message: Text("Are you sure you want to remove this device?"), primaryButton: .destructive(Text("Remove")) { deviceManager.removeDevice(id: device.id) }, secondaryButton: .cancel())
            }
        }
    }
}
