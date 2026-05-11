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
        VStack(alignment: .leading, spacing: AppSpace.md) {
            HStack(alignment: .top, spacing: AppSpace.md) {
                VStack(alignment: .leading, spacing: AppSpace.xs) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appPrimary.opacity(opacity))
                        .frame(width: 180, height: 20)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.appTertiary.opacity(opacity))
                        .frame(width: 210, height: 14)
                    
                    Capsule()
                        .fill(Color.appSecondary.opacity(opacity * 0.7))
                        .frame(width: 72, height: 22)
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(Color.appPrimary.opacity(opacity))
                    .frame(width: 92, height: 92)
            }
            
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.appPrimary.opacity(opacity))
                    .frame(width: 120, height: 14)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.appTertiary.opacity(opacity))
                    .frame(width: 44, height: 10)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.appTertiary.opacity(opacity))
                    .frame(width: 72, height: 10)
            }
            
            ForEach(0..<3, id: \.self) { index in
                if index != 0 {
                    Divider()
                        .overlay(Color.appTertiary.opacity(0.25))
                }
                
                HStack(alignment: .center, spacing: AppSpace.sm) {
                    VStack(alignment: .leading, spacing: AppSpace.xxs) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.appPrimary.opacity(opacity))
                            .frame(width: 190, height: 14)
                        
                        HStack(spacing: AppSpace.xs) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appTertiary.opacity(opacity))
                                .frame(width: 72, height: 10)
                            
                            Circle()
                                .fill(Color.appSecondary.opacity(opacity))
                                .frame(width: 4, height: 4)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appTertiary.opacity(opacity))
                                .frame(width: 64, height: 10)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: AppSpace.md) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.appPrimary.opacity(opacity))
                            .frame(width: 56, height: 12)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.appPrimary.opacity(opacity))
                            .frame(width: 92, height: 12)
                    }
                }
            }
        }
        .appCardStyle()
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
