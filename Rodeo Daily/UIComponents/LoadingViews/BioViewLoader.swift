//
//  BioViewLoader.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/13/22.
//

import SwiftUI

struct BioViewLoader: View {
    
    let loading: Bool
        
    @State private var opacity = 0.2
    
    var body: some View {
//        ZStack {
            
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                        .frame(width: 130, height: 12)
                    
                    Spacer()
                }
                
                
                Divider()
                    .frame(minHeight: 2, alignment: .center)
                    .background(Color.rdGray.opacity(0.6))
                    .padding(.vertical, 4)
                
                HStack {
                    RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                        .frame(width: 50, height: 12)
                    
                    Spacer()
                    
                    Divider()
                        .frame(width: 2, height: 14, alignment: .center)
                        .background(Color.rdYellow.opacity(0.8))
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                        .frame(width: 80, height: 12)
                    
                    Spacer()
                    
                    Divider()
                        .frame(width: 2, height: 14, alignment: .center)
                        .background(Color.rdYellow.opacity(0.8))
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                        .frame(width: 80, height: 12)
                }
            }
            .frame(width: 300)
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever()) {
                    self.opacity = 0.4
                }
            }
            
//            BioView(athleteId: 70406, isShowingBio: true)
//        }
    }
}

struct BioViewLoader_Previews: PreviewProvider {
    static var previews: some View {
        BioViewLoader(loading: true)
    }
}
