//
//  AthleteNotificationRoute.swift
//  Rodeo Daily
//

import Foundation

struct AthleteNotificationRoute: Hashable {
    let athleteId: Int
    let preferredInfoTypeRawValue: String?
    let preferredEvent: String?
}
