//

import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appInfo = AppInfo.shared
    
    var body: some View {
        NavigationView {
            VStack {
                Text("WakeOnLan \(appInfo.version) (\(appInfo.build))")
            }.toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
}
