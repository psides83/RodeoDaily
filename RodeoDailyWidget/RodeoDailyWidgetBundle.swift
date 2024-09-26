//
//  RodeoDailyWidgetBundle.swift
//  RodeoDailyWidget
//
//  Created by Payton Sides on 2/3/23.
//

import WidgetKit
import SwiftUI

@main
struct RodeoDailyWidgetBundle: WidgetBundle {
    var body: some Widget {
        StandingsWidgetSmall()
        StandingsWidgetLarge()
        PhoneStandingsARWidget()
        FavoriteWidgetLarge()
        FavoriteWidgetSmall()
    }
}
