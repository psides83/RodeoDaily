//
//  StandingsLoader.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/13/22.
//

import SwiftUI

struct StandingsLoader: View {
    
    @State private var opacity = 0.2
    
    var body: some View {
        LazyVStack(spacing: AppSpace.lg) {
            ForEach(0..<8, id: \.self) { _ in
                ZStack {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpace.sm) {
                            Capsule(style: .continuous)
                                .fill(Color.appSecondary.opacity(opacity))
                                .frame(width: 52, height: 24)
                            
                            VStack(alignment: .leading, spacing: AppSpace.xs) {
                                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                    .fill(Color.appPrimary.opacity(opacity))
                                    .frame(width: 160, height: 18)
                                
                                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                    .fill(Color.appTertiary.opacity(opacity))
                                    .frame(width: 118, height: 12)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: AppSpace.xs) {
                            HStack {
                                Circle()
                                    .fill(Color.appSecondary.opacity(opacity))
                                    .frame(width: 12, height: 12)
                                
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(Color.appSecondary.opacity(opacity))
                                    .frame(width: 7, height: 10)
                            }
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .fill(Color.appTertiary.opacity(opacity))
                                .frame(width: 58, height: 10)
                            
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .fill(Color.appPrimary.opacity(opacity))
                                .frame(width: 98, height: 14)
                        }
                    }
                    .padding(.vertical, 26)
//                    .appCardStyle()
                    
                    Image("noimage")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .opacity(opacity + 0.18)
                        .scaleEffect(2.5)
                        .offset(x: 25, y: -19)
                        .padding(.trailing, AppSpace.xs)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                self.opacity = 0.4
            }
        }
    }
}

struct StandingsLoader_Previews: PreviewProvider {
    static var previews: some View {
        StandingsLoader()
    }
}
