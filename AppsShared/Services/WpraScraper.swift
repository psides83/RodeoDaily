//
//  WpraScraper.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/24/23.
//

import Foundation
import SwiftSoup
import SwiftUI

enum WpraScraper {
    static func scrape(event: StandingsEvent, type: StandingType, year: String, circuit: Circuit) async throws -> [Position] {
        
        var url: URL? {
            if event == .gb && type == .world {
                return URL(string: "https://archived.wpra.com/index.php/standings-group-season?group=Pro%20Rodeo%20-%20World&season=\(year)&standing=\(year)%20Pro%20Rodeo%20World%20Standings")!
            }
            
            if event == .gb && type == .rookie {
                return URL(string: "https://archived.wpra.com/index.php/standings-group-season?group=Rookie%20Standings&season=\(year)&standing=\(year)%20Rookie%20Standings")!
            }
            
            if event == .gb && type == .circuit {
                return URL(string:  "https://archived.wpra.com/index.php/standings-group-season?group=Pro%20Rodeo-Circuit&season=\(year)&standing=\(year)%20Pro%20Rodeo%20\(circuit.convertToWpra)%20Circuit%20Standings")!
            }
            
            if event == .lb && type == .world {
                return URL(string: "https://archived.wpra.com/index.php/standings-group-season?group=Roping%20Standings&season=\(year)&standing=\(year)%20Pro%20Rodeo%20Breakaway%20World%20Standings")!
            }
            
            if event == .lb && type == .circuit {
                return URL(string: "https://archived.wpra.com/index.php/standings-group-season?group=Roping%20Standings&season=\(year)&standing=\(year)%20Pro%20Rodeo%20Breakaway%20\(circuit.convertToWpra)%20Circuit%20Standings")!
            }
            
            return nil
        }
        
        guard url != nil else { return [] }
        
        var titles: ArraySlice<Position> = []
        
        do {
            let content = try String(contentsOf: url!)
            let doc: Document = try SwiftSoup.parse(content)
            
            print(doc)
            
            let table = try? doc.select("table").first()
            
            if let table {
                let rows = try table.select("tr")
                
                let title = try rows.map { row throws -> Position in
                    let placeRaw = try row.select("td:nth-child(1)").text()
                    let nameRaw = try row.select("td:nth-child(2)").text().replacingOccurrences(of: " (G)", with: "").replacingOccurrences(of: "(R)", with: "")
                    let hometown = try row.select("td:nth-child(3)").text()
                    let earningsRaw = try row.select("td:nth-child(4)").text()
                    
                    let nameComponents = nameRaw.components(separatedBy: " ").filter({ $0 != "" })
                    
                    print(nameComponents)
                    
                    var lastName: String {
                        if nameComponents.isEmpty {
                            return ""
                        } else if nameComponents.count == 3 {
                            return nameComponents[2]
                        } else if nameComponents.count == 2 {
                            return nameComponents[1]
                        } else {
                            return ""
                        }
                    }
                    
                    let firstName = nameComponents.count > 1 ? nameComponents[0] : ""
                    
                    let place = placeRaw.replacingOccurrences(of: " (T)", with: "").replacingOccurrences(of: "Rank", with: "0").int
                    let earnings = earningsRaw.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "").double
                    
                    
                    return Position(
                        id: place,
                        firstName: firstName,
                        lastName: lastName,
                        event: event.rawValue,
                        type: type.rawValue,
                        hometown: hometown,
                        nickName: firstName,
                        imageUrl: nil,
                        earnings: earnings,
                        points: earnings,
                        place: place,
                        standingId: 0,
                        seasonYear: year.int,
                        tourId: nil,
                        circuitId: nil
                    )
                }
                    .filter({ $0.place != 0}).prefix(50)
                
                titles = title
            } else {
                return []
            }
        } catch {
            return []
        }
        return Array(titles)
    }
}
