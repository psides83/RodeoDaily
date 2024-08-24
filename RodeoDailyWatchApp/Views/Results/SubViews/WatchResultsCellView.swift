//
//  WatchResultsCellView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/20/23.
//

import SwiftUI

struct WatchResultsCellView: View {
    // MARK: - Properties
    let winner: Winner
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(winner.placeDisplay)
                .font(.title3)
                .padding(.trailing, 6)
            
            VStack(alignment: .leading) {
                Text(winner.name)
                
                HStack {
                    Text(winner.result)
                    
                    Spacer()
                    
                    Text(winner.earningsABS)
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
