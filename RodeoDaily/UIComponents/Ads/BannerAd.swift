//
//  SwiftUIView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import SwiftUI
import GoogleMobileAds

struct BannerAd: View {
    let style: BannerAdStyle
    @State private var adHeight: CGFloat = 50
    
    init(style: BannerAdStyle = .adaptive) {
        self.style = style
        _adHeight = State(initialValue: style == .mediumRectangle ? 250 : 50)
    }
    
    var body: some View {
        GeometryReader { proxy in
            BannerAdRepresentable(
                width: max(proxy.size.width, 1),
                style: style,
                adHeight: $adHeight
            )
            .frame(height: adHeight)
        }
        .frame(height: style == .mediumRectangle ? 250 : adHeight)
    }
}

enum BannerAdStyle {
    case adaptive
    case mediumRectangle
}

private struct BannerAdRepresentable: UIViewRepresentable {
    let config = Config()
    let width: CGFloat
    let style: BannerAdStyle
    @Binding var adHeight: CGFloat
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        let adSize = adSize(for: width)
        let bannerView = GADBannerView(adSize: adSize)
        
        bannerView.adUnitID = config.productionAdId
        bannerView.rootViewController = UIApplication.shared.getRootViewController()
        bannerView.delegate = context.coordinator
        context.coordinator.lastWidth = width
        
        bannerView.load(GADRequest())
        
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        if style == .mediumRectangle {
            return
        }

        guard abs(context.coordinator.lastWidth - width) > 1 else {
            return
        }
        
        context.coordinator.lastWidth = width
        let newAdSize = adSize(for: width)
        uiView.adSize = newAdSize
        
        uiView.load(GADRequest())
    }
    
    func adSize(for width: CGFloat) -> GADAdSize {
        switch style {
        case .adaptive:
            return GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width)
        case .mediumRectangle:
            return GADAdSizeMediumRectangle
        }
    }

    private func targetHeight(for adSize: GADAdSize) -> CGFloat {
        if style == .mediumRectangle {
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
            let receivedHeight = parent.style == .mediumRectangle ? 250 : bannerView.adSize.size.height
            guard receivedHeight > 0, parent.adHeight != receivedHeight else {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.adHeight = receivedHeight
            }
        }
        
        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }
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
        guard let screen = self.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}
