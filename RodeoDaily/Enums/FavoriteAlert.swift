//
//  AlertType.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/16/24.
//

import AlertKit
import SwiftUI
import UIKit

enum FavoriteAlert {
    case added(String)
    case removed(String)
    case followAdded(String)
    case followRemoved(String)
    case followSaveFailed
    
//    func alert(title: String, subtitle: String, icon: UIImage) -> AlertAppleMusic16View {
//        let alert = AlertAppleMusic16View(title: title, subtitle: subtitle, icon: .custom(icon))
//        alert.titleLabel?.textColor = .appPrimary
//        alert.subtitleLabel?.textColor = .appPrimary
//        alert.duration = 1.5
//        alert.haptic = .success
//        alert.backgroundColor = .bgcolor
//        alert.iconView?.tintColor = .appSecondary
//        
//        return alert
//    }
    
    var present: () {
        switch self {
        case .added:
            AlertKitAPI.present(
                title: text.title,
                subtitle: text.subtitle,
                icon: .custom(.favoriteStar!),
                style: .iOS16AppleMusic, haptic: .success
            )
        case .removed:
            AlertKitAPI.present(
                title: text.title,
                subtitle: text.subtitle,
                icon: .custom(.favoriteStar!),
                style: .iOS16AppleMusic, haptic: .success
            )
        case .followAdded:
            AlertKitAPI.present(
                title: text.title,
                subtitle: text.subtitle,
                icon: .custom(.favoriteStar!),
                style: .iOS16AppleMusic, haptic: .success
            )
        case .followRemoved:
            AlertKitAPI.present(
                title: text.title,
                subtitle: text.subtitle,
                icon: .custom(.favoriteStar!),
                style: .iOS16AppleMusic, haptic: .success
            )
        case .followSaveFailed:
            AlertKitAPI.present(
                title: text.title,
                subtitle: text.subtitle,
                icon: .custom(.favoriteStar!),
                style: .iOS16AppleMusic,
                haptic: .error
            )
        }
    }
    
    private var text: (title: String, subtitle: String) {
        switch self {
        case .added(let value):
            return (
                title: "Added to Favorites",
                subtitle: "\(value) is now available to select in the Favorite Athlete Widget."
            )
        case .removed(let value):
            return (
                title: "Removed from Favorites",
                subtitle: "\(value) was removed from Favorite Athlete Widget available selections."
            )
        case .followAdded(let value):
            return (
                title: "Following Athlete",
                subtitle: "You will now get alerts for \(value)."
            )
        case .followRemoved(let value):
            return (
                title: "Stopped Following",
                subtitle: "\(value) follow alerts were turned off."
            )
        case .followSaveFailed:
            return (
                title: "Follow Not Saved",
                subtitle: "Please try again."
            )
        }
    }
}
