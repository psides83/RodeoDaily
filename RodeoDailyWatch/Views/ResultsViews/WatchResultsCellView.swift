//
//  WatchResultsCellView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/20/23.
//

import SwiftUI

struct WatchResultsCellView: View {
    let winner: Winner
    
    var body: some View {
        HStack {
            Text(winner.place.string)
            
            VStack(alignment: .leading) {
                Text(winner.name)
                
                HStack {
                    Text(winner.result)
                    
                    Spacer()
                    
                    Text(winner.payoff == 0 ? "" : winner.payoff.currencyABS)
                }
            }
        }
    }
}

struct WatchResultsCellView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRodeoResultsView(rodeoId: 12867, rodeoName: "", event: .td)
    }
}
