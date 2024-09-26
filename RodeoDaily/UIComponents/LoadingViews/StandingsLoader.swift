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
        VStack {
            ForEach(1..<13) { block in
                VStack {
                    HStack {
                        Text(block.string)
                            .foregroundColor(.appSecondary)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(width: 30)
                            .padding(.trailing, 10)
                        
                        Image("noimage")
                            .resizable()
                            .opacity(opacity)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        
                        VStack(alignment: .leading, spacing: 1) {
                            
                            RoundedRectangle(cornerRadius: 2).fill(Color.appPrimary.opacity(opacity))
                                .frame(width: 105, height: 18)
                                .padding(.horizontal, 10)
                            
                            HStack{
                                RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                                    .frame(width: 58, height: 10)
                                    .padding(.leading, 10)
                                
                                Circle().fill(Color.appTertiary.opacity(0.4)).frame(width: 4, height: 4)
                                
                                RoundedRectangle(cornerRadius: 2).fill(Color.appTertiary.opacity(opacity))
                                    .frame(width: 80, height: 8)
                            }
                            .padding(.top,6)
                        }
                        Spacer()
                    }
                    
                    Divider()
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).repeatForever()) {
                        self.opacity = 0.4
                    }
                }
            }
        }
    }
}

struct StandingsLoader_Previews: PreviewProvider {
    static var previews: some View {
        StandingsLoader()
    }
}
