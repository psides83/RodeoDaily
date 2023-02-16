//
//  Logo.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/12/22.
//

import SwiftUI

struct Logo: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let size: CGFloat
    
    var body: some View {
        Image.appLogo
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
    }
}

struct Logo_Previews: PreviewProvider {
    static var previews: some View {
        Logo(size: 3)
    }
}
