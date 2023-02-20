//
//  WatchLogo.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/20/23.
//

import SwiftUI

struct WatchLogo: View {
    let size: CGFloat
    
    var body: some View {
        Image.appLogo
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
    }
}

struct WatchLogo_Previews: PreviewProvider {
    static var previews: some View {
        WatchLogo(size: 24)
    }
}
