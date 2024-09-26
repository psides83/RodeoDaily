//
//  EventFilterView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import SwiftUI

struct EventFilterView: View {
    
    let events: [String]
    @Binding var selectedEvent: String?
        
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent, label: menuIcon)
    }
    
    func menuIcon() -> some View {
//        VStack {
//            Image.calendar
//                .imageScale(.large)
//                .foregroundColor(.appPrimary)
            
        Text(selectedEvent?.eventDisplay ?? "Select an Event")
                .font(.caption)
                .fontWeight(.medium)
//        }
    }
    
    func menuContent() -> some View {
        ForEach(events, id: \.self) { event in
            Button {
                selectedEvent = event
            } label: {
                Text(event.eventDisplay)
            }
        }
    }
    
//    func eventDisplay(for event: String) -> String {
//        switch event {
//        case "BB": return "Bareback"
//        case "SW": return "Steer Wrestling"
//        case "TR": return "Team Roping"
//        case "SB": return "Saddle Bronc"
//        case "TD": return "Tie-Down Roping"
//        case "BR": return "Bull Riding"
//        case "SR": return "Steer Roping"
//        default: return ""
//        }
//    }
}
