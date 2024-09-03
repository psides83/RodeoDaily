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
//        PhoneStandingsARWidget(event: .bb)
//        PhoneStandingsARWidget(event: .sw)
//        PhoneStandingsARWidget(event: .hd)
//        PhoneStandingsARWidget(event: .hl)
//        PhoneStandingsARWidget(event: .sb)
//        PhoneStandingsARWidget(event: .td)
//        PhoneStandingsARWidget(event: .gb)
//        PhoneStandingsARWidget(event: .br)
//        PhoneStandingsARWidget(event: .lb)
//        PhoneStandingsARWidget(event: .sr)
//        StandingsARWidget()
//        ResultsWidget()
        FavoriteWidget()
    }
}
