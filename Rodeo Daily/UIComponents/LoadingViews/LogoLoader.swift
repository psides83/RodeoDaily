//
//  Logo.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/12/22.
//

import SwiftUI

struct LogoLoader: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    //    let display: Bool
    let color: Color = .rdGreen
    let size = 2.5
    
    @State private var endAmount: CGFloat = 0
    @State private var dotCount = 0
    
    var strokeColor: Color {
        if color == .rdGreen {
            return colorScheme == .dark ? Color.white : Color.rdYellow
        }
        
        if color == .white {
            return colorScheme == .dark ? Color.rdGreen : Color.rdYellow
        }
        
        return Color.rdGreen
    }
    
    var body: some View {
        VStack {
            ShapeView(bezier: UIBezierPath.rdLogo)
                .trim(from: 0, to: endAmount)
                .stroke(strokeColor.gradient, style: .init(lineWidth: size * 5, lineCap: .round))
                .overlay(color.gradient, in: ShapeView(bezier: UIBezierPath.rdLogo))
                .frame(width: size * 100, height: size * 100)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .offset(x: -2)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        endAmount = 1
                    }
                }
            
            loadingText
//            Text("Loading...")
//                .foregroundColor(strokeColor)
//                .font(.system(.largeTitle, weight: .semibold))
//                .padding(.top, -42)
        }
        .background(Color.clear.blur(radius: 6))
    }
    
    var loadingText: some View {
        HStack {
            Text("Loading\(String(repeating: ".", count: dotCount % 4))")
                .foregroundColor(strokeColor)
                .font(.system(.largeTitle, weight: .semibold))
                .padding(.top, -42)
                .frame(width: 150, alignment: .leading)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                self.dotCount += 1
            }
        }
    }
}

struct LogoLoader_Previews: PreviewProvider {
    static var previews: some View {
        LogoLoader()
    }
}
