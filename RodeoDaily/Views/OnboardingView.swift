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
            VStack {
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
                            icon: "sparkles",
                            text: NSLocalizedString("A complete visual refresh with cleaner layouts, improved readability, and smoother transitions.", comment: "")
                        )
                        whatsNewRow(
                            icon: "menubar.rectangle",
                            text: NSLocalizedString("New tab bar navigation makes it faster to move between Standings, Results, and More Features.", comment: "")
                        )
                        whatsNewRow(
                            icon: "person.crop.rectangle.stack",
                            text: NSLocalizedString("Rebuilt Athlete Bio with enhanced header behavior and upgraded stats, results, and detail browsing.", comment: "")
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

            Text(text)
                .font(.title3.weight(.medium))
                .foregroundColor(.white)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewOnboardingView(version: "preview")
    }
}
