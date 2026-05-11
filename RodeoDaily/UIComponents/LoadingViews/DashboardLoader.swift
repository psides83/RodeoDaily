import SwiftUI

struct DashboardLoader: View {
    @State private var opacity = 0.22

    var body: some View {
        VStack(spacing: AppSpace.md) {
            favoriteLeadersSkeleton
            inProgressRodeosSkeleton
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                opacity = 0.42
            }
        }
    }

    private var favoriteLeadersSkeleton: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack {
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(Color.appPrimary.opacity(opacity))
                    .frame(width: 140, height: 16)
                Spacer()
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(Color.appSecondary.opacity(opacity))
                    .frame(width: 92, height: 12)
            }

            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.appSecondary.opacity(opacity))
                        .frame(width: 28, height: 12)

                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .fill(Color.appPrimary.opacity(opacity))
                        .frame(width: 140, height: 12)

                    Spacer()

                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .fill(Color.appTertiary.opacity(opacity))
                        .frame(width: 72, height: 10)
                }
            }
        }
        .appCardStyle()
    }

    private var inProgressRodeosSkeleton: some View {
        VStack(alignment: .leading, spacing: AppSpace.sm) {
            HStack {
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(Color.appPrimary.opacity(opacity))
                    .frame(width: 130, height: 16)
                Spacer()
                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                    .fill(Color.appSecondary.opacity(opacity))
                    .frame(width: 80, height: 12)
            }

            ForEach(0..<2, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppSpace.xs) {
                    HStack {
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .fill(Color.appPrimary.opacity(opacity))
                            .frame(width: 170, height: 14)
                        Spacer()
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .fill(Color.appSecondary.opacity(opacity))
                            .frame(width: 66, height: 10)
                    }

                    HStack {
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .fill(Color.appTertiary.opacity(opacity))
                            .frame(width: 124, height: 10)
                        Spacer()
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .fill(Color.appTertiary.opacity(opacity))
                            .frame(width: 72, height: 10)
                    }

                    ForEach(0..<2, id: \.self) { _ in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .fill(Color.appSecondary.opacity(opacity))
                                .frame(width: 24, height: 10)
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .fill(Color.appPrimary.opacity(opacity))
                                .frame(width: 130, height: 10)
                            Spacer()
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .fill(Color.appTertiary.opacity(opacity))
                                .frame(width: 40, height: 10)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .appCardStyle()
    }
}

#Preview {
    DashboardLoader()
}
