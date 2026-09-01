//
//  AdPlacementPolicy.swift
//  RodeoDaily
//
//  Created by Codex on 5/17/26.
//

import Foundation

enum AdPlacementPolicy {
    static let defaultFirstListAdAfter = 10
    static let defaultListAdRepeatEvery = 10

    static func shouldShowListAd(
        beforeItemAt index: Int,
        firstAfter: Int = defaultFirstListAdAfter,
        repeatEvery: Int = defaultListAdRepeatEvery
    ) -> Bool {
        guard index >= firstAfter else { return false }
        if index == firstAfter { return true }
        return (index - firstAfter).isMultiple(of: repeatEvery)
    }

    static func shouldShowBottomAd(itemCount: Int, minimumItems: Int = 3) -> Bool {
        itemCount >= minimumItems
    }
}
