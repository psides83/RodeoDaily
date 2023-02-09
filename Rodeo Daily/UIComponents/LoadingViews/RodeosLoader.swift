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
        ZStack{
            VStack {
                ForEach(0..<7) { _ in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                
                                RoundedRectangle(cornerRadius: 2).fill(Color.appPrimary.opacity(opacity))
                                    .frame(width: 230, height: 28)
                                
                                HStack {
                                    RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                                        .frame(width: 80, height: 12)
                                    
                                    Circle().fill(Color.appSecondary.opacity(0.4)).frame(width: 4, height: 4)
                                    
                                    RoundedRectangle(cornerRadius: 2).fill(Color.appTertiary.opacity(opacity))
                                        .frame(width: 80, height: 12)
                                }
                                .padding(.bottom, 8)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color.appTertiary)
                        }
                        .padding(.bottom, 10)
                        
                        Divider()
                    }
                    .padding(.top)
                }
            }
            
            LogoLoader()
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
