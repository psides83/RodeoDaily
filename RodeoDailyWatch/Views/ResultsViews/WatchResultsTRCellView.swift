//
//  WatchResultsTRCellView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/20/23.
//

import SwiftUI

struct WatchResultsTRCellView: View {
    
    let index: Int
    let winners: [Winner]
    
    var body: some View {
        HStack {
            Text(winners[index].place.string)
            
                VStack(alignment: .leading) {
                    Text(winners[index].name)
                    
                    Text(winners[index + 1].name)
                    
                    HStack {
                        Text(winners[index].result)
                        
                        Spacer()
                        
                        Text(winners[index].payoff == 0 ? "" : winners[index].payoff.currencyABS)
                    }
                }
        }
    }
}

struct WatchResultsTRCellView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRodeoResultsView(rodeoId: 12867, rodeoName: "", event: .tr)
    }
}
