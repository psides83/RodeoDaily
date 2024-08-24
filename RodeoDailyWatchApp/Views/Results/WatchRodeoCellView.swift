//
//  WatchRodeoCellView.swift
//  RodeoDailyWatchApp
//
//  Created by Payton Sides on 3/5/23.
//

import SwiftUI

struct WatchRodeoCellView: View {
    
    let rodeo: RodeoData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(rodeo.name)
                .font(.headline)
            
            Text(rodeo.location)
                .font(.caption)
        }
    }
}

struct WatchRodeoCellView_Previews: PreviewProvider {
    static var previews: some View {
        WatchRodeosListView()
    }
}
