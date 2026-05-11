//
//  RodeoCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/9/22.
//

import SwiftUI

struct RodeoCell: View {
    
    let rodeo: RodeoData
    
    var inProgress: String {
        if rodeo.inProgress {
            return "In Progress"
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(rodeo.name)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.appPrimary)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(rodeo.location)
                            .font(.subheadline)
                        
                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                        
                        Text(rodeo.endDate.medium)
                            .foregroundColor(.appTertiary)
                            .font(.subheadline)
                        
                        if rodeo.inProgress {
                            Text(inProgress)
                                .foregroundColor(.appBg)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 50).fill(Color.appSecondary))
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.appSecondary)
            }
        }
        .appCardStyle()
    }
}

struct RodeoCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
