//
//  SwiftUIView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import SwiftUI
import GoogleMobileAds

struct BannerAd: UIViewRepresentable {
    
    @ObservedObject var config = Config()
    
    var width = UIScreen.main.bounds.width - 80
        
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> GADBannerView {
        
        let adview = GADBannerView(adSize: GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width), origin: .zero)
        
        adview.adUnitID = config.productionAdId
//        adview.adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(width)
        adview.rootViewController = UIApplication.shared.getRootViewController()
        adview.delegate = context.coordinator
        adview.load(GADRequest())
        
        return adview
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        
    }
    
    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("bannerViewDidReceiveAd")
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
          print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
          print("bannerViewDidRecordImpression")
        }

        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
          print("bannerViewWillPresentScreen")
        }

        func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
          print("bannerViewWillDIsmissScreen")
        }

        func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
          print("bannerViewDidDismissScreen")
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        BannerAd()
            .frame(height: 100)
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
