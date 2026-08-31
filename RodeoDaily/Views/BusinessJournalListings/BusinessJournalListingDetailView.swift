import SwiftUI

struct BusinessJournalListingDetailView: View {
    let item: BusinessJournalFeedItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpace.xl) {
                if let publishDate {
                    Text("Publish Date: \(publishDate)")
                        .font(.appCaption)
                        .italic()
                        .foregroundStyle(Color.appTertiary)
                }

                listingHeader

                if !orderedDetailFields.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpace.sm) {
                        ForEach(orderedDetailFields) { field in
                            detailLine(field)
                        }
                    }
                }

                if let link = item.link {
                    Link(destination: link) {
                        HStack(spacing: AppSpace.xs) {
                            Image(systemName: "arrow.up.right.square")
                            Text("Open Full Listing")
                                .font(.appBodyStrong)
                        }
                        .foregroundStyle(Color.appSecondary)
                        .padding(.top, AppSpace.sm)
                    }
                    .buttonStyle(.plain)
                }

                BannerAd(placement: .rodeoListingsList)
            }
            .padding(.horizontal)
            .padding(.top, AppSpace.md)
            .padding(.bottom, AppSpace.xxl)
        }
        .background(Color.appBg)
        .navigationTitle("Rodeo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.track(.rodeoListingDetailViewed)
        }
    }

    private var listingHeader: some View {
        VStack(alignment: .leading, spacing: AppSpace.xs) {
            Text(item.title)
                .font(.appCardTitle)
                .foregroundStyle(Color.appPrimary)
                .multilineTextAlignment(.leading)

            if let dateText = item.dateText, !dateText.isEmpty {
                Text(dateText)
                    .font(.appBodyStrong)
                    .foregroundStyle(Color.appPrimary)
            }

            if let subtitle = item.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.appBody)
                    .foregroundStyle(Color.appSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var publishDate: String? {
        item.detailFields.first(where: { field in
            field.key.contains("publish_date") || field.label.lowercased().contains("publish date")
        })?.value
    }
    
    private var orderedDetailFields: [PBJDetailField] {
        let excluded = [
            "publish_date", "rodeo_name", "rodeoname", "title", "name", "date", "start_date", "end_date"
        ]

        let preferredOrder = [
            "arena", "address", "perfs", "slacks", "events", "special_entry_fees", "permits",
            "ground_rules", "stk_cont", "stock_contractor", "eo", "ec", "entry_open", "entry_close"
        ]
        
        let filtered = item.detailFields.filter { field in
            let normalized = field.key.lowercased()
            return !excluded.contains(where: { normalized.contains($0) })
        }
        
        return filtered.sorted { lhs, rhs in
            let li = indexForField(lhs, preferredOrder: preferredOrder)
            let ri = indexForField(rhs, preferredOrder: preferredOrder)
            if li == ri {
                return lhs.label < rhs.label
            }
            return li < ri
        }
    }
    
    private func indexForField(_ field: PBJDetailField, preferredOrder: [String]) -> Int {
        let key = field.key.lowercased()
        let label = field.label.lowercased().replacingOccurrences(of: " ", with: "_")
        for (index, token) in preferredOrder.enumerated() {
            if key.contains(token) || label.contains(token) {
                return index
            }
        }
        return preferredOrder.count + 1
    }
    
    @ViewBuilder
    private func detailLine(_ field: PBJDetailField) -> some View {
        let formattedLabel = "\(field.label.uppercased()): "
        
        (
            Text(formattedLabel)
                .font(.appBodyStrong)
                .foregroundStyle(Color.appPrimary)
            +
            Text(field.value)
                .font(.appBody)
                .foregroundStyle(Color.appPrimary)
        )
        .multilineTextAlignment(.leading)
        .textSelection(.enabled)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
