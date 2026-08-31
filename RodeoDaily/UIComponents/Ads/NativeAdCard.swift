//
//  NativeAdCard.swift
//  RodeoDaily
//
//  Created by Codex on 5/17/26.
//

import GoogleMobileAds
import SwiftUI
import UIKit

struct NativeAdCard: View {
    @ObservedObject private var adMobService = AdMobService.shared
    @ObservedObject private var adEntitlementService = AdEntitlementService.shared
    @StateObject private var loader: NativeAdLoader
    @State private var didFailBannerFallback = false

    private let placement: AdPlacement

    init(placement: AdPlacement) {
        self.placement = placement
        _loader = StateObject(wrappedValue: NativeAdLoader(placement: placement))
    }

    var body: some View {
        VStack(spacing: 0) {
            if adEntitlementService.canShowAds && adMobService.canRequestAds {
                if let nativeAd = loader.nativeAd {
                    NativeAdRepresentable(nativeAd: nativeAd)
                        .frame(height: 148)
                        .transition(.opacity)
                } else if loader.shouldUseBannerFallback {
                    BannerAd(placement: placement) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            didFailBannerFallback = true
                        }
                    }
                } else {
                    NativeAdPlaceholder()
                        .frame(height: 148)
                }
            }
        }
        .frame(minHeight: minimumContainerHeight)
        .onAppear(perform: loadIfAllowed)
        .onChange(of: adMobService.canRequestAds) { _, _ in
            loadIfAllowed()
        }
        .animation(.easeOut(duration: 0.2), value: loader.nativeAd != nil)
        .animation(.easeInOut(duration: 0.25), value: minimumContainerHeight)
    }

    private var minimumContainerHeight: CGFloat {
        if loader.nativeAd != nil {
            return 148
        }
        if loader.shouldUseBannerFallback {
            if didFailBannerFallback {
                return 0
            }
            return placement.style == .mediumRectangle ? 250 : 50
        }
        if adEntitlementService.canShowAds && adMobService.canRequestAds {
            return 148
        }
        return 1
    }

    private func loadIfAllowed() {
        guard adEntitlementService.canShowAds, adMobService.canRequestAds else {
            return
        }
        loader.load()
    }
}

private final class NativeAdLoader: NSObject, ObservableObject {
    @Published private(set) var nativeAd: GADNativeAd?
    @Published private(set) var shouldUseBannerFallback = false

    private let placement: AdPlacement
    private var adLoader: GADAdLoader?
    private var isLoading = false

    init(placement: AdPlacement) {
        self.placement = placement
    }

    func load() {
        guard nativeAd == nil, !isLoading else { return }

        isLoading = true
        shouldUseBannerFallback = false
        let adLoader = GADAdLoader(
            adUnitID: placement.nativeAdUnitID,
            rootViewController: UIApplication.shared.getRootViewController(),
            adTypes: [.native],
            options: nil
        )
        adLoader.delegate = self
        self.adLoader = adLoader

#if DEBUG
        let placementDescription = placement.description
        let adUnitID = placement.nativeAdUnitID
        Task { @MainActor in
            AdMobService.debugLog("Loading native ad placement=\(placementDescription) unit=\(adUnitID)")
        }
#endif
        AnalyticsService.shared.track(
            .adLifecycle(
                format: "native",
                placement: placement.description,
                phase: "load_started",
                adUnitID: placement.nativeAdUnitID
            )
        )

        adLoader.load(GADRequest())
        scheduleFallbackTimeout()
    }

    private func scheduleFallbackTimeout() {
        let placementDescription = placement.description
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            guard let self, self.nativeAd == nil, self.isLoading else { return }
            self.isLoading = false
            self.shouldUseBannerFallback = true

#if DEBUG
            Task { @MainActor in
                AdMobService.debugLog("Native ad timed out; using banner fallback placement=\(placementDescription)")
            }
#endif
        }
    }
}

extension NativeAdLoader: GADNativeAdLoaderDelegate, GADAdLoaderDelegate, GADNativeAdDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        nativeAd.delegate = self

        Task { @MainActor in
            self.nativeAd = nativeAd
            self.isLoading = false
            self.shouldUseBannerFallback = false
        }

#if DEBUG
        let placementDescription = placement.description
        Task { @MainActor in
            AdMobService.debugLog("Loaded native ad placement=\(placementDescription)")
        }
#endif
        AnalyticsService.shared.track(
            .adLifecycle(
                format: "native",
                placement: placement.description,
                phase: "loaded",
                adUnitID: placement.nativeAdUnitID,
                responseID: nativeAd.responseInfo.responseIdentifier,
                adapter: nativeAd.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName
            )
        )
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            self.shouldUseBannerFallback = true
        }

#if DEBUG
        let placementDescription = placement.description
        let errorMessage = error.localizedDescription
        Task { @MainActor in
            AdMobService.debugLog("Failed native ad placement=\(placementDescription) error=\(errorMessage)")
        }
#endif
        let nsError = error as NSError
        AnalyticsService.shared.track(
            .adLifecycle(
                format: "native",
                placement: placement.description,
                phase: "failed",
                adUnitID: placement.nativeAdUnitID,
                errorDomain: nsError.domain,
                errorCode: nsError.code
            )
        )
    }
}

private struct NativeAdRepresentable: UIViewRepresentable {
    let nativeAd: GADNativeAd

    func makeUIView(context: Context) -> GADNativeAdView {
        let nativeAdView = RodeoNativeAdView()
        nativeAdView.backgroundColor = .secondarySystemBackground
        nativeAdView.layer.cornerRadius = AppRadius.lg
        nativeAdView.layer.cornerCurve = .continuous
        nativeAdView.layer.borderColor = UIColor.separator.withAlphaComponent(0.25).cgColor
        nativeAdView.layer.borderWidth = AppStroke.hairline
        nativeAdView.clipsToBounds = true

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true

        let adBadge = UILabel()
        adBadge.translatesAutoresizingMaskIntoConstraints = false
        adBadge.text = "Ad"
        adBadge.font = .systemFont(ofSize: 11, weight: .semibold)
        adBadge.textColor = .secondaryLabel
        adBadge.backgroundColor = UIColor.tertiarySystemFill
        adBadge.textAlignment = .center
        adBadge.layer.cornerRadius = 5
        adBadge.clipsToBounds = true

        let headlineLabel = UILabel()
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.font = .systemFont(ofSize: 17, weight: .bold)
        headlineLabel.textColor = .label
        headlineLabel.numberOfLines = 2

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 2

        let mediaView = GADMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.contentMode = .scaleAspectFill
        mediaView.backgroundColor = .tertiarySystemFill
        mediaView.layer.cornerRadius = AppRadius.md
        mediaView.clipsToBounds = true

        let callToActionButton = UIButton(type: .system)
        callToActionButton.translatesAutoresizingMaskIntoConstraints = false
        var callToActionConfiguration = UIButton.Configuration.filled()
        callToActionConfiguration.baseForegroundColor = .white
        callToActionConfiguration.baseBackgroundColor = UIColor(Color.appSecondary)
        callToActionConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        callToActionButton.configuration = callToActionConfiguration
        callToActionButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        callToActionButton.layer.cornerRadius = 14
        callToActionButton.clipsToBounds = true
        callToActionButton.isUserInteractionEnabled = false

        let textStack = UIStackView(arrangedSubviews: [headlineLabel, bodyLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4

        let contentStack = UIStackView(arrangedSubviews: [mediaView, textStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .top
        contentStack.spacing = AppSpace.lg

        nativeAdView.addSubview(containerView)
        containerView.addSubview(adBadge)
        containerView.addSubview(contentStack)
        containerView.addSubview(callToActionButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor),

            adBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: AppSpace.lg),
            adBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AppSpace.lg),
            adBadge.widthAnchor.constraint(equalToConstant: 28),
            adBadge.heightAnchor.constraint(equalToConstant: 22),

            contentStack.topAnchor.constraint(equalTo: adBadge.bottomAnchor, constant: AppSpace.sm),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AppSpace.lg),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AppSpace.lg),

            mediaView.widthAnchor.constraint(equalToConstant: 56),
            mediaView.heightAnchor.constraint(equalToConstant: 56),

            callToActionButton.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: AppSpace.lg),
            callToActionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AppSpace.lg),
            callToActionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -AppSpace.lg)
        ])

        nativeAdView.layoutIfNeeded()
        nativeAdView.headlineView = headlineLabel
        nativeAdView.bodyView = bodyLabel
        nativeAdView.mediaView = mediaView
        nativeAdView.callToActionView = callToActionButton

        return nativeAdView
    }

    func updateUIView(_ nativeAdView: GADNativeAdView, context: Context) {
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        nativeAdView.mediaView?.isHidden = false
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.nativeAd = nativeAd
    }
}

private final class RodeoNativeAdView: GADNativeAdView {
    override func layoutSubviews() {
        super.layoutSubviews()

        for assetView in [headlineView, bodyView, mediaView, callToActionView].compactMap({ $0 }) {
            guard assetView.superview != nil else { continue }

            let assetFrame = assetView.convert(assetView.bounds, to: self)
            if !bounds.insetBy(dx: -0.5, dy: -0.5).contains(assetFrame) {
                assetView.clipsToBounds = true
            }
        }
    }
}
