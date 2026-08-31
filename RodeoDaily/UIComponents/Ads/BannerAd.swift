//
//  SwiftUIView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import SwiftUI
import GoogleMobileAds

struct BannerAd: View {
    @ObservedObject private var adMobService = AdMobService.shared
    @ObservedObject private var adEntitlementService = AdEntitlementService.shared
    let placement: AdPlacement
    private let onAdFailed: (() -> Void)?
    @State private var adHeight: CGFloat = 50
    @State private var hasLoadedAd = false
    @State private var hasFailedToLoad = false
    
    init(style: BannerAdStyle = .adaptive, onAdFailed: (() -> Void)? = nil) {
        self.placement = style == .mediumRectangle ? .generalMediumRectangle : .generalAdaptive
        self.onAdFailed = onAdFailed
        _adHeight = State(initialValue: style == .mediumRectangle ? 250 : 50)
    }

    init(placement: AdPlacement, onAdFailed: (() -> Void)? = nil) {
        self.placement = placement
        self.onAdFailed = onAdFailed
        _adHeight = State(initialValue: placement.style == .mediumRectangle ? 250 : 50)
    }
    
    var body: some View {
        Group {
            if adEntitlementService.canShowAds && adMobService.canRequestAds {
                ZStack {
                    if placement.style == .mediumRectangle && !hasLoadedAd && !hasFailedToLoad {
                        MRECAdPlaceholder()
                            .frame(height: 250)
                    }

                    GeometryReader { proxy in
                        BannerAdRepresentable(
                            width: max(proxy.size.width, 1),
                            placement: placement,
                            adHeight: $adHeight,
                            hasLoadedAd: $hasLoadedAd,
                            hasFailedToLoad: $hasFailedToLoad,
                            onAdFailed: onAdFailed
                        )
                        .frame(height: adHeight)
                    }
                    .opacity(placement.style == .mediumRectangle && !hasLoadedAd ? 0 : 1)
                }
                .frame(height: reservedHeight)
                .opacity(hasFailedToLoad ? 0 : 1)
                .clipped()
                .animation(.easeInOut(duration: 0.25), value: reservedHeight)
                .animation(.easeInOut(duration: 0.2), value: hasFailedToLoad)
            }
        }
    }

    private var reservedHeight: CGFloat {
        guard !hasFailedToLoad else { return 0 }
        return placement.style == .mediumRectangle ? 250 : adHeight
    }
}

enum BannerAdStyle {
    case adaptive
    case mediumRectangle
}

extension AdPlacement: CustomStringConvertible {
    var description: String {
        switch self {
        case .generalAdaptive: return "generalAdaptive"
        case .generalMediumRectangle: return "generalMediumRectangle"
        case .resultsListInline: return "resultsListInline"
        case .resultsDetailSection: return "resultsDetailSection"
        case .scheduleListInline: return "scheduleListInline"
        case .scheduleDetailBottom: return "scheduleDetailBottom"
        case .standingsListInline: return "standingsListInline"
        case .athleteBioSection: return "athleteBioSection"
        case .pastChampionsList: return "pastChampionsList"
        case .rodeoListingsList: return "rodeoListingsList"
        }
    }
}

private struct BannerAdRepresentable: UIViewRepresentable {
    let width: CGFloat
    let placement: AdPlacement
    @Binding var adHeight: CGFloat
    @Binding var hasLoadedAd: Bool
    @Binding var hasFailedToLoad: Bool
    let onAdFailed: (() -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let adSize = adSize(for: width)
        let bannerView = GADBannerView(adSize: adSize)
        
        bannerView.adUnitID = placement.adUnitID
        bannerView.rootViewController = UIApplication.shared.getRootViewController()
        bannerView.delegate = context.coordinator
        context.coordinator.lastWidth = width
        
#if DEBUG
        AdMobService.debugLog("Loading banner placement=\(placement.description) unit=\(placement.adUnitID) width=\(Int(width))")
#endif
        AnalyticsService.shared.track(
            .adLifecycle(
                format: "banner",
                placement: placement.description,
                phase: "load_started",
                adUnitID: placement.adUnitID
            )
        )
        bannerView.load(GADRequest())
        
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        if placement.style == .mediumRectangle {
            return
        }

        guard abs(context.coordinator.lastWidth - width) > 1 else {
            return
        }
        
        context.coordinator.lastWidth = width
        let newAdSize = adSize(for: width)
        uiView.adSize = newAdSize
        
#if DEBUG
        AdMobService.debugLog("Reloading adaptive banner placement=\(placement.description) width=\(Int(width))")
#endif
        uiView.load(GADRequest())
    }
    
    func adSize(for width: CGFloat) -> GADAdSize {
        switch placement.style {
        case .adaptive:
            return GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width)
        case .mediumRectangle:
            return GADAdSizeMediumRectangle
        }
    }

    private func targetHeight(for adSize: GADAdSize) -> CGFloat {
        if placement.style == .mediumRectangle {
            return 250
        }
        return adSize.size.height
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        var parent: BannerAdRepresentable
        var lastWidth: CGFloat = 0
        
        init(_ parent: BannerAdRepresentable) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            let receivedHeight = parent.placement.style == .mediumRectangle ? 250 : bannerView.adSize.size.height
#if DEBUG
            Self.debugLog("Loaded banner placement=\(parent.placement.description) height=\(Int(receivedHeight))")
#endif
            AnalyticsService.shared.track(
                .adLifecycle(
                    format: "banner",
                    placement: parent.placement.description,
                    phase: "loaded",
                    adUnitID: parent.placement.adUnitID,
                    responseID: bannerView.responseInfo?.responseIdentifier,
                    adapter: bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName
                )
            )
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.parent.hasLoadedAd = true
                    self.parent.hasFailedToLoad = false
                }
            }

            guard receivedHeight > 0, parent.adHeight != receivedHeight else {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.adHeight = receivedHeight
            }
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
#if DEBUG
            Self.debugLog("Failed banner placement=\(parent.placement.description) error=\(error.localizedDescription)")
#endif
            let nsError = error as NSError
            AnalyticsService.shared.track(
                .adLifecycle(
                    format: "banner",
                    placement: parent.placement.description,
                    phase: "failed",
                    adUnitID: parent.placement.adUnitID,
                    errorDomain: nsError.domain,
                    errorCode: nsError.code,
                    responseID: bannerView.responseInfo?.responseIdentifier,
                    adapter: bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adNetworkClassName
                )
            )
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.parent.hasFailedToLoad = true
                    self.parent.adHeight = 0
                }
                self.parent.onAdFailed?()
            }
        }

#if DEBUG
        private static func debugLog(_ message: String) {
            Task { @MainActor in
                AdMobService.debugLog(message)
            }
        }
#endif
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        BannerAd()
            .padding()
    }
}

extension UIApplication {
    func getRootViewController() -> UIViewController {
        let scenes = connectedScenes.compactMap { $0 as? UIWindowScene }
        let foregroundScene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let root = foregroundScene?.windows.first { $0.isKeyWindow }?.rootViewController
            ?? foregroundScene?.windows.first?.rootViewController
            ?? scenes.flatMap(\.windows).first { $0.isKeyWindow }?.rootViewController

        return root?.topMostPresentedViewController ?? .init()
    }
}

private extension UIViewController {
    var topMostPresentedViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topMostPresentedViewController
        }

        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topMostPresentedViewController
        }

        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topMostPresentedViewController
        }

        return self
    }
}
