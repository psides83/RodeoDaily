//
//  StandingsCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/11/22.
//

import Foundation
import SwiftUI

struct StandingsCell: View {
    
    let position: Position
    
    @State private var isShowingBio = false
    
    var body: some View {
        
        VStack {
            HStack {
                
                Text(position.place.string)
                    .foregroundColor(.rdGreen)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(width: 30)
                    .padding(.horizontal, 10)
                
                position.image
//                    .blur(radius: 0.5)
                    .overlay(Color.rdGray.opacity(0.96)).mask(position.image)
                
                VStack(alignment: .leading, spacing: 1) {
                    
                    Button {
                        withAnimation {
                            isShowingBio.toggle()
                        }
                    } label: {
                        Text(position.name)
                            .foregroundColor(.rdGreen)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                    }
                    
                    HStack{
                        
                        Text(position.earnings.currency)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.leading, 10)
                        
                        Circle().fill(Color.rdGray).frame(width: 4)
                        
                        Text(position.hometown)
                            .font(.caption)
                            .foregroundColor(.rdGray)
                    }
                    
                }
                Spacer()
            }
            if isShowingBio {
                BioView(athleteId: position.id, isShowingBio: isShowingBio)
            }
        }
    }
}
