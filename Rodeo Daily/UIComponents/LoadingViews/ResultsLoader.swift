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
        VStack {
            ForEach(1..<7) { block in
                LazyVStack(alignment: .leading) {
                    HStack {
                        
                        Text(block.string)
                            .font(.headline)
                        
                        Image("noimage")
                            .resizable()
                            .opacity(opacity)
                            .frame(width: 48, height: 48)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading) {
                            
                            RoundedRectangle(cornerRadius: 2).fill(Color.appPrimary.opacity(opacity))
                                .frame(width: 105, height: 18)
                            
                            RoundedRectangle(cornerRadius: 2).fill(Color.appTertiary.opacity(opacity))
                                .frame(width: 80, height: 8)
                        }
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                            .frame(width: 36, height: 10)
                        
                        RoundedRectangle(cornerRadius: 2).fill(Color.primary.opacity(opacity))
                            .frame(width: 70, height: 10)
                            .padding(.leading)
                        
                    }
                }
                .padding(.top)
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
