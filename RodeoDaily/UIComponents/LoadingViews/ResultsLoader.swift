//
//  ResultsLoader.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/14/22.
//

import SwiftUI

struct ResultsLoader: View {
    
    @State private var opacity = 0.2
    
    var body: some View {
        VStack(spacing: AppSpace.md) {
            ForEach(0..<2, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppSpace.sm) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.appSecondary.opacity(opacity))
                            .frame(width: 96, height: 16)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.appTertiary.opacity(opacity))
                            .frame(width: 44, height: 10)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.appTertiary.opacity(opacity))
                            .frame(width: 74, height: 10)
                    }
                    
                    ForEach(0..<4, id: \.self) { row in
                        if row != 0 {
                            Divider()
                                .overlay(Color.appTertiary.opacity(0.25))
                        }
                        
                        HStack(alignment: .center, spacing: AppSpace.xs) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appSecondary.opacity(opacity))
                                .frame(width: 24, height: 14)
                            
                            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                .fill(Color.appPrimary.opacity(opacity))
                                .frame(width: 44, height: 44)
                            
                            VStack(alignment: .leading, spacing: AppSpace.xxs) {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.appPrimary.opacity(opacity))
                                    .frame(width: 120, height: 14)
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.appTertiary.opacity(opacity))
                                    .frame(width: 94, height: 10)
                            }
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appPrimary.opacity(opacity))
                                .frame(width: 56, height: 12)
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appPrimary.opacity(opacity))
                                .frame(width: 80, height: 12)
                        }
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

struct ResultsLoader_Previews: PreviewProvider {
    static var previews: some View {
        ResultsLoader()
    }
}
