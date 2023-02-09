//
//  StandingsCell.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/11/22.
//

import Foundation
import SwiftUI

struct StandingsCell: View {
//    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest var favorites: FetchedResults<Favorite>
    
    let position: Position
    
    init(position: Position) {
        self.position = position
        
//        _favorites = FetchRequest<Favorite>(
//            entity: Favorite.entity(),
//            sortDescriptors: [NSSortDescriptor(keyPath: \Favorite.timestamp, ascending: true)],
//            predicate: NSPredicate(format: "id = %d", position.id),
//            animation: .default)
    }
    
    @State private var isShowingBio = false
    
//    var favorite: Favorite? {
//        if favorites.count > 0 {
//            return favorites[0]
//        } else {
//            return nil
//        }
//    }
    
//    var isFavorite: Bool {
//        guard favorite != nil else { return false }
//
//        return true
//    }
    
    var body: some View {
        
        VStack {
            HStack {
                Text(position.place.string)
                    .foregroundColor(.appSecondary)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .frame(width: 30)
//                    .padding(.horizontal, 10)
                
                position.image
//                    .blur(radius: 0.5)
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
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                        }
                        
//                        Spacer()
                        
//                        Button {
//                            if isFavorite {
//                                deleteFavorite()
//                            } else {
//                                setFavorite()
//                            }
//                        } label: {
//                            Image(systemName: isFavorite ? "star.fill" : "star")
//                                .foregroundColor(.rdYellow)
//                        }
                    }
                    
                    HStack{
                        
                        Text(position.earnings.currency)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.leading, 10)
                        
                        Circle().fill(Color.appSecondary).frame(width: 4, height: 4)
                        
                        Text(position.hometown ?? "")
                            .font(.caption)
                            .foregroundColor(.appTertiary)
                    }
                    
                }
                Spacer()
            }
            if isShowingBio && position.id != 0 {
                BioView(athleteId: position.id, isShowingBio: isShowingBio)
            }
        }
    }
    
//    func setFavorite() {
//        withAnimation {
//            let newFavorite = Favorite(context: viewContext)
//            newFavorite.id = Int32(position.id)
//            newFavorite.firstName = position.firstName
//            newFavorite.lastName = position.lastName
//            
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
//    private func deleteFavorite() {
//        withAnimation {
//            guard favorite != nil else { return }
//            
//            viewContext.delete(favorite!)
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

struct StandingsCell_Previews: PreviewProvider {
    static var previews: some View {
//        let position = Position(id: 70406, firstName: "Caleb", lastName: "Smidt", event: "td", type: "", hometown: "Somewhere, TX", nickName: "Caleb", imageUrl: "", earnings: 15635.45, points: 15635.45, place: 6, standingId: 123, seasonYear: 2023, tourId: nil, circuitId: nil)
//
        ContentView()
    }
}
