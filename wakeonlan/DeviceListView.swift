//

import SwiftUI

struct DeviceListView: View {
    @State private var keyword: String = ""
    @State private var activeSheet: ActiveSheet? = nil  // Enum to manage sheets
    
    @ObservedObject var deviceManager = DeviceManagerClass.shared
    
    // Enum to track the current action (Add or Edit)
    enum ActiveSheet: Identifiable {
        case add
        case about
        case edit(deviceId: String)
        
        var id: String {
            switch self {
            case .add:
                return "add"
            case .about:
                return "about"
            case .edit(let deviceId):
                return deviceId
            }
        }
    }
    
    func setDeviceEditSheet(deviceId: String) {
        activeSheet = .edit(deviceId: deviceId)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Manage")) {
                        Button {
                            activeSheet = .add
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add Device")
                            }.foregroundStyle(.blue)
                        }
                    }
                    
                    Section(header: Text("Devices")) {
                        ForEach(deviceManager.devices) {
                            device in
                            DeviceListRow(device: device, setDeviceEditSheet: setDeviceEditSheet)
                        }
                    }
                }.searchable(text: $keyword)
            }.navigationTitle("Devices")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            Button {
                                activeSheet = .about
                            } label: {
                                Label("About", systemImage: "info.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }.fullScreenCover(item: $activeSheet) { item in
                    switch item {
                    case .add:
                        DeviceAddSheet()  // Full screen add sheet
                    case .about:
                        AboutSheet()
                    case .edit(let deviceId):
                        DeviceAddSheet(deviceId: deviceId)  // Full screen edit sheet
                    }
                }
        }
    }
}
