//
//  RodeoCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/9/22.
//

import SwiftUI

struct RodeoCell: View {
    
    let rodeo: RodeoData
    let event: Events.CodingKeys
        
    @State private var isShowingResults = false
    @State private var rotationAngle: Double = 0
    
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
                    Button {
                        withAnimation {
                            isShowingResults.toggle()
                            rotationAngle = rotationAngle == 0 ? 90 : 0
                        }
                    } label: {
                        Text(rodeo.name)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.appPrimary)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
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
                
                Button {
                    withAnimation {
                        isShowingResults.toggle()
                        rotationAngle = rotationAngle == 0 ? 90 : 0
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(Angle(degrees: rotationAngle))
                        .accentColor(Color.appSecondary)
                }
                .buttonStyle(.clearButton)
            }
            
            if isShowingResults {
                ResultsBlock(rodeo: rodeo, event: event)
            }
        }
        .padding(.top)
        .onChange(of: event) { newValue in
            isShowingResults = false
            rotationAngle = 0
        }
    }
}

struct RodeoCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
