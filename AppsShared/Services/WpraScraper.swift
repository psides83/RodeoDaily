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
        let wpraUrls = URL(string:"https://psides83.github.io/rodeo-daily-resources/wpra-urls.json")!
        
        func url() async throws -> URL? {
            guard let urls = try? await APIService.fetchWpraUrl(from: wpraUrls) else { return nil }
            
            if event == .gb && type == .world {
                let url = URL(string: urls.gbWorld.replacingOccurrences(of: "{selectedYear}", with: year))!
                
                print(url)
                
                return url
            }
            
            if event == .gb && type == .rookie {
                let url = URL(string: urls.gbRookie)!
                
                print(url)
                
                return url
            }
            
            if event == .gb && type == .circuit {
                let url = URL(string:
                                (
                                    urls.gbCircuit.replacingOccurrences(of: "{circuit}", with: circuit.convertToWpra)),
                               )!
                
                print(url)
                
                return url
            }
            
            if event == .lb && type == .world {
                return URL(string: urls.lbWorld.replacingOccurrences(of: "{selectedYear}", with: year))!
            }
            
            if event == .lb && type == .rookie {
                return URL(string: urls.lbRookie)!
            }
            
            if event == .lb && type == .circuit {
                return URL(string:
                            (
                                urls.lbCircuit.replacingOccurrences(of: "{circuit}", with: circuit.convertToWpra))
                           )!
            }
            
            return nil
        }
        
        guard ((await (try? url() != nil)) != nil) else { return [] }
        
        var titles: ArraySlice<Position> = []
        
        do {
            let content = try await String(contentsOf: url()!)
            let doc: Document = try SwiftSoup.parse(content)
            
//                        print(doc)
            
            let table = try? doc.select("table")[1]
            
//            print(table)
            
            if let table {
                let rows = try table.select("tr")
                
                let title = try rows.map { row throws -> Position in
                    let placeRaw = try row.select("td:nth-child(1)").text()
                    let nameRaw = try row.select("td:nth-child(2)").text().replacingOccurrences(of: " (G)", with: "").replacingOccurrences(of: "(R)", with: "")
                    let hometown = try row.select("td:nth-child(3)").text()
                    let earningsRaw = try row.select("td:nth-child(4)").text()
                    
                    let nameComponents = nameRaw.components(separatedBy: " ").filter({ $0 != "" })
                    
//                                        print(nameRaw)
                    
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
                print("result failed")
                return []
            }
        } catch {
            print("result failed")
            return []
        }
        return Array(titles)
    }
}
