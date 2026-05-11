//
//  RodeosLoader.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/13/22.
//

import SwiftUI

struct RodeosLoader: View {
    
    @State private var opacity = 0.2
    
    var body: some View {
        LazyVStack(spacing: AppSpace.lg) {
            ForEach(0..<6, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    HStack(alignment: .top, spacing: AppSpace.sm) {
                        VStack(alignment: .leading, spacing: AppSpace.xs) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.appPrimary.opacity(opacity))
                                .frame(height: 22)
                            
                            HStack(spacing: AppSpace.xs) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.appPrimary.opacity(opacity))
                                    .frame(width: 94, height: 11)
                                
                                Circle()
                                    .fill(Color.appSecondary.opacity(opacity))
                                    .frame(width: 4, height: 4)
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.appTertiary.opacity(opacity))
                                    .frame(width: 74, height: 11)
                                
                                Capsule()
                                    .fill(Color.appSecondary.opacity(opacity * 0.8))
                                    .frame(width: 78, height: 20)
                            }
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.appSecondary.opacity(opacity))
                            .frame(width: 8, height: 10)
                    }
                }
                .appCardStyle()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                self.opacity = 0.4
            }
        }
    }
}

struct RodeosLoader_Previews: PreviewProvider {
    static var previews: some View {
        RodeosLoader()
    }
}
