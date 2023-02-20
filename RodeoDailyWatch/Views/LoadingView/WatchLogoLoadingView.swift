//
//  WatchLogoLoadingView.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct WatchLogoLoader: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let color: Color = .appPrimary
    let size = 1.5
    
    @State private var endAmount: CGFloat = 0
    @State private var dotCount = 0
    
    var strokeColor: Color {
        if color == .appPrimary {
            return Color.appSecondary
        }
        
        if color == .white {
            return colorScheme == .dark ? Color.appPrimary : Color.appSecondary
        }
        
        return Color.appPrimary
    }
    
    var body: some View {
        VStack {
            ShapeView(bezier: UIBezierPath.rdLogo)
                .trim(from: 0, to: endAmount)
                .stroke(strokeColor.gradient, style: .init(lineWidth: size * 5, lineCap: .round))
                .overlay(color.gradient, in: ShapeView(bezier: UIBezierPath.rdLogo))
                .frame(width: size * 100, height: size * 100)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//                .offset(x: -2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        endAmount = 1
                    }
                }
            
            loadingText
        }
        .offset(y: -15)
    }
    
    var loadingText: some View {
        HStack {
            Text("Loading\(String(repeating: ".", count: dotCount % 4))")
                .foregroundColor(strokeColor)
                .font(.system(.title3, weight: .semibold))
                .padding(.top, -30)
                .frame(width: 90, alignment: .leading)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                self.dotCount += 1
            }
        }
    }
}

struct WatchLogoLoader_Previews: PreviewProvider {
    static var previews: some View {
        WatchLogoLoader()
    }
}
