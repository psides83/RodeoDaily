//
//  AthleteCellViewLoader.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/25/24.
//

import SwiftUI

struct AthleteCellViewLoader: View {
    @State private var opacity = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text("Shad Mayfield")
                    .redacted(reason: .placeholder)
                    .opacity(opacity)
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text("#1 in TD Roping with $246,722")
                .redacted(reason: .placeholder)
                .opacity(opacity)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Text("Latest Results")
                .foregroundColor(.appSecondary)
                .font(.system(size: 16, weight: .semibold))
                .environment(\.colorScheme, .dark)
                .opacity(opacity)
            
            ForEach(1..<5) { _ in
                VStack(alignment: .leading, spacing: 4) {
                    
                    Divider()
                        .overlay(Color.appSecondary)
                        .environment(\.colorScheme, .dark)
                    
                    HStack(alignment: .center, spacing: 6) {
                        Text("Cheyennem, WY")
                            .redacted(reason: .placeholder)
                            .opacity(opacity)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                            .opacity(opacity)
                        
                        Text("Sep 22, 2024")
                            .redacted(reason: .placeholder)
                            .opacity(opacity)
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Round 1")
                            .redacted(reason: .placeholder)
                            .opacity(opacity)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 20) {
                        Text("1st")
                            .redacted(reason: .placeholder)
                            .opacity(opacity)
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            .frame(width: 40, alignment: .leading)
                        
                        Spacer()
                        
                        Text("7.8")
                            .redacted(reason: .placeholder)
                            .opacity(opacity)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 40)
                        
                        Spacer()
                        
                        Text("$5,250")
                            .redacted(reason: .placeholder)
                            .opacity(opacity)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 100, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.rdGreen)
                .shadow(radius: 4, x: 0, y: 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                self.opacity = 0.4
            }
        }
    }
}

#Preview {
    AthleteCellViewLoader()
}
