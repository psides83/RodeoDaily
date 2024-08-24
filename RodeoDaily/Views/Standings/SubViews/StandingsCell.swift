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
    
    // matched the position event to a StandingsEvent to be passed into the BioView
    var standingEvent: StandingsEvent {
        let event = StandingsEvent.allCases.filter({ $0.rawValue == position.event})
        
        guard event.count > 0 else { return .aa }
        
        return event[0]
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(position.place.string)
                    .foregroundColor(.appSecondary)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(width: 30)
                
                position.image
                    .overlay(Color.appTertiary.opacity(0.96)).mask(position.image)
                
                VStack(alignment: .leading, spacing: 1) {
                    
                    HStack {
                        Button {
                            withAnimation {
                                isShowingBio.toggle()
                            }
                        } label: {
                            Text(position.name)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.appPrimary)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, -6)
                        }
                        .buttonStyle(.clearTextButton)
                        
                        Spacer()
                    }
                    
                    HStack{
                        Text(position.earnings.currency)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.leading, 7)
                        
                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                        
                        Text(position.hometownDisplay)
                            .font(.caption)
                            .foregroundColor(.appTertiary)
                    }
                }
                Spacer()
                
                if position.hasBio {
                    NavigationLink {
                        BioView(athleteId: position.id, event: standingEvent)
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.appSecondary)
                    }
                    .buttonStyle(.clearButton)
                }
            }
            if isShowingBio && position.id != 0 {
                BioCellView(athleteId: position.id, event: StandingsEvent(rawValue: position.event) ?? .aa, isShowingBio: isShowingBio)
            }
        }
    }
}

struct StandingsCell_Previews: PreviewProvider {
    static var previews: some View {
//        let position = Position(id: 70406, firstName: "Caleb", lastName: "Smidt", event: "td", type: "", hometown: "Somewhere, TX", nickName: "Caleb", imageUrl: "", earnings: 15635.45, points: 15635.45, place: 6, standingId: 123, seasonYear: 2023, tourId: nil, circuitId: nil)
//
        ContentView()
    }
}
