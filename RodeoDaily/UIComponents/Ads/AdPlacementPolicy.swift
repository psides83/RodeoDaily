//
//  AdPlacementPolicy.swift
//  RodeoDaily
//
//  Created by Codex on 5/17/26.
//

import Foundation

enum AdPlacementPolicy {
    static func shouldShowListAd(beforeItemAt index: Int, firstAfter: Int = 5, repeatEvery: Int = 5) -> Bool {
        guard index >= firstAfter else { return false }
        if index == firstAfter { return true }
        return (index - firstAfter).isMultiple(of: repeatEvery)
    }

    static func shouldShowBottomAd(itemCount: Int, minimumItems: Int = 3) -> Bool {
        itemCount >= minimumItems
    }
}
