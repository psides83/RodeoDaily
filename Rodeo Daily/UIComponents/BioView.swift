//
//  BioView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import SwiftUI

struct BioView: View {
    
    let athleteId: Int
    let isShowingBio: Bool
    
    @ObservedObject var bioAPI = BioAPI()
    
    var body: some View {
        let bio = bioAPI.bio
        let loading = bioAPI.loading
        
        VStack {
            if loading {
                BioViewLoader(loading: loading)
            } else {
                VStack(alignment: .center, spacing: 4) {
                    HStack {
                        Text(bio.careerEarnings)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 2)
                            .redacted(reason: loading ? .placeholder : .privacy)
                        
                        Spacer()
                    }
                    
                    
                    Divider()
                        .frame(minHeight: 2, alignment: .center)
                        .overlay(Color.appTertiary)
                    
                    HStack {
                        Text(bio.nfrQuals)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .redacted(reason: loading ? .placeholder : .privacy)
                        
                        Spacer()
                        
                        Divider()
                            .frame(width: 2, height: 14, alignment: .center)
                            .overlay(Color.appSecondary)
                        
                        Spacer()
                        
                        Text(bio.worldTitlesCount)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .redacted(reason: loading ? .placeholder : .privacy)
                        
                        Spacer()
                        
                        Divider()
                            .frame(width: 2, height: 14, alignment: .center)
                            .overlay(Color.appSecondary)
                        
                        Spacer()
                        
                        Text("\(bio.athleteAge) Years old")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .redacted(reason: loading ? .placeholder : .privacy)
                    }
                }
                .frame(width: 300)
            }
        }
        .task {
            if isShowingBio {
                await bioAPI.getBio(for: athleteId)
            }
        }
    }
}

struct BioView_Previews: PreviewProvider {
    static var previews: some View {
        BioView(athleteId: 70406, isShowingBio: true)
    }
}
