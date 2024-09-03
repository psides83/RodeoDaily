//
//  BioHeadingView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct BioHeadingView: View {
    
    let event: StandingsEvent
    let bio: BioData
    
    @Binding var infoType: BioView.BioInfoType
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(bio.name)
                    .foregroundColor(.appSecondary)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(alignment: .center, spacing: 4) {
                HStack {
                    Text(bio.careerEarnings)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.vertical, 2)
                    
                    Spacer()
                }
                
                Divider()
                    .frame(minHeight: 2, alignment: .center)
                    .overlay(Color.appTertiary)
                
                HStack {
                    Text(bio.nfrQuals)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Divider()
                        .frame(width: 2, height: 14, alignment: .center)
                        .overlay(Color.appSecondary)
                    
                    Spacer()
                    
                    Text(bio.worldTitlesCount)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Divider()
                        .frame(width: 2, height: 14, alignment: .center)
                        .overlay(Color.appSecondary)
                    
                    Spacer()
                    
                    Text(bio.athleteAge + NSLocalizedString(" Years old", comment: ""))
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
            
            HStack {
                HStack {
                    Spacer()
                    
                    Picker("", selection: $infoType) {
                        ForEach(BioView.BioInfoType.allCases, id: \.self) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .frame(minWidth: 280, alignment: .leading)
            }
            .frame(minHeight: 40)
        }
        .environment(\.colorScheme, .dark)
        .padding()
        .background(Color.rdGreen)
    }
}
