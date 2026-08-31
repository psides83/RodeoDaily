//
//  OnboardingView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/15/22.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        GeometryReader { proxy in
            VStack {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Spacer()
                        Image.appLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .padding(.vertical, -42)
                        Spacer()
                    }
                    
                    Text("Allow tracking in the following alert for:")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundColor(.rdGreen)
                            .padding(8)
                            .background(.white)
                            .clipShape(Circle())
                        
                        Text("Advertisements that match your interests")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("You can change this option later in the Settings app.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                    
                        Button {
//                            isShowingAlert = true
//                            requestTracking()
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text("Continue")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.rdGreen)
                                    .padding(.vertical)
                                
                                Spacer()
                            }
                            .background(RoundedRectangle(cornerRadius: 12))
                            .tint(.white)
                        }
//                        .opacity(isShowingAlert ? 0 : 1)
                }
                .padding(.horizontal, 24)
                .offset(y: -proxy.safeAreaInsets.top / 2)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(Color.rdGreen.gradient)
        }
    }
}

struct WhatsNewOnboardingView: View {
    @AppStorage("lastSeenWhatsNewVersion") private var lastSeenWhatsNewVersion = ""

    let version: String

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Spacer()
                        Image.appLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 180)
                        Spacer()
                    }

                    Text(NSLocalizedString("What’s New", comment: ""))
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 14) {
                        whatsNewRow(
                            icon: "list.bullet.rectangle",
                            text: NSLocalizedString("Results now let you switch events without leaving the rodeo detail view.", comment: "")
                        )
                        whatsNewRow(
                            icon: "doc.text.magnifyingglass",
                            text: NSLocalizedString("Daysheets are available from results when a rodeo provides them, with quick Results and Daysheets switching.", comment: "")
                        )
                        whatsNewRow(
                            icon: "calendar.badge.clock",
                            text: NSLocalizedString("Schedule filtering now shows current rodeos and supports custom date ranges.", comment: "")
                        )
                        whatsNewRow(
                            icon: "sparkles",
                            text: NSLocalizedString("Other minor bugs and UI issues have been corrected.", comment: "")
                        )
                    }

                    Text(NSLocalizedString("Thanks for using Rodeo Daily.", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.95))

                    Button {
                        lastSeenWhatsNewVersion = version
                    } label: {
                        HStack {
                            Spacer()
                            Text(NSLocalizedString("Continue", comment: ""))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.rdGreen)
                                .padding(.vertical, 14)
                            Spacer()
                        }
                        .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, max(24, proxy.safeAreaInsets.top + 8))
                .padding(.bottom, max(24, proxy.safeAreaInsets.bottom + 16))
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(Color.rdGreen.gradient)
        }
    }

    private func whatsNewRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.rdGreen)
                .padding(8)
                .background(.white)
                .clipShape(Circle())
                .fixedSize()

            Text(text)
                .font(.title3.weight(.medium))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewOnboardingView(version: "preview")
    }
}
