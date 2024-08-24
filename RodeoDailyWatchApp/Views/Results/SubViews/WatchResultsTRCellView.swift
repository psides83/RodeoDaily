//
//  WatchResultsTRCellView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/20/23.
//

import SwiftUI

struct WatchResultsTRCellView: View {
    // MARK: - Properties
    let index: Int
    let winners: [Winner]
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(winners[index].placeDisplay)
                .font(.title3)
                .padding(.trailing, 6)
            
                VStack(alignment: .leading) {
                    Text(winners[index].name)
                    
                    Text(winners[index + 1].name)
                    
                    HStack {
                        Text(winners[index].result)
                        
                        Spacer()
                        
                        Text(winners[index].earningsABS)
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
