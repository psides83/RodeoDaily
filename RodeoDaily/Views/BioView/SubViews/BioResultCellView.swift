//
//  BioResultCell.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/13/23.
//

import SwiftUI

struct BioResultCellView: View {
    
    let result: BioResult
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(result.rodeoName)
                    .fontWeight(.medium)
                
                HStack {
                    Text(result.location)
                        .font(.caption)
                    
                    Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                    
                    Text(result.endDate.medium)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(result.roundDisplay)
                        .font(.caption)
                }
            }
            
            
            HStack {
                Text(result.placeDisplay)
                    .font(.callout)
                    .frame(width: 40, alignment: .leading)
                
                Spacer()
                
                Text(result.resultDisplay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(width: 40)
                
                Spacer()
                
                Text(result.payoutDisplay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(width: 100, alignment: .trailing)
            }
        }
    }
}

struct BioResultCellView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BioView(athleteId: 59836, event: .hd)
                .tint(.appSecondary)
        }
    }
}
