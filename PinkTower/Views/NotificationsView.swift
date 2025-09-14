import SwiftUI

struct NotificationsView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("No notifications yet")
            }
            .navigationTitle("Notifications")
        }
    }
}


