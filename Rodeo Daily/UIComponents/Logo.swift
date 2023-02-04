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
        Image("rodeo-daily-logo-white")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 48)
//        ShapeView(bezier: UIBezierPath.rdLogo)
//            .stroke(Color.white.gradient, style: .init(lineWidth: size * 2.5, lineCap: .round))
//            .overlay(.white.gradient, in: ShapeView(bezier: UIBezierPath.rdLogo))
//            .frame(width: size * 100, height: size * 100)
//            .offset(x: -2)
    }
}

struct Logo_Previews: PreviewProvider {
    static var previews: some View {
        Logo(size: 3)
    }
}
