//
//  EventStandingsView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/18/23.
//

import SwiftUI

struct WatchStandingsListView: View {
    @StateObject var standingsApi = StandingsApi()
        
    let event: StandingsEvent
    
    var body: some View {
        Group {
            if standingsApi.loading {
                WatchLogoLoader()
            } else {
                ForEach(standingsApi.standings, id: \.place) { position in
                    HStack {
                        Text(position.place.string)
                        
                        VStack(alignment: .leading) {
                            Text(position.name)
                            
                            Text(position.earnings.currencyABS)
                        }
                    }
                }
            }
        }
    }
}

struct WatchStandingsListView_Previews: PreviewProvider {
    static var previews: some View {
        WatchStandingsListView(event: .aa)
    }
}
