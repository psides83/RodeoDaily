import SwiftData
import SwiftUI

struct FollowAlertsView: View {
    @Environment(\.modelContext) var modelContext

    @Query(sort: \FollowAlertEvent.createdAt, order: .reverse) var alerts: [FollowAlertEvent]

    var body: some View {
        List {
            if alerts.isEmpty {
                ContentUnavailableView {
                    Label("No Alerts Yet", systemImage: "bell.slash")
                } description: {
                    Text("Follow athletes to receive rank and result updates.")
                }
            } else {
                ForEach(alerts, id: \.id) { alert in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(alert.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Spacer()

                            if !alert.isRead {
                                Circle()
                                    .fill(Color.appSecondary)
                                    .frame(width: 8, height: 8)
                            }
                        }

                        Text(alert.message)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(alert.createdAt.relativeTime)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        alert.isRead = true
                        try? modelContext.save()
                        Task { @MainActor in
                            await AppBadgeManager.syncUnreadBadgeCount(using: modelContext)
                        }
                    }
                }
                .onDelete(perform: deleteAlerts)
            }
        }
        .navigationTitle("Follow Alerts")
        .onAppear {
            Task { @MainActor in
                FollowNotificationRouter.shared.syncDeliveredNotifications()
                await AppBadgeManager.clearBadge()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Mark All Read") {
                    markAllRead()
                }
                .disabled(alerts.isEmpty)
            }
        }
    }

    private func markAllRead() {
        alerts.forEach { $0.isRead = true }
        try? modelContext.save()
        Task { @MainActor in
            await AppBadgeManager.syncUnreadBadgeCount(using: modelContext)
        }
    }

    private func deleteAlerts(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(alerts[index])
        }
        try? modelContext.save()
        Task { @MainActor in
            await AppBadgeManager.syncUnreadBadgeCount(using: modelContext)
        }
    }
}
