//
//  ApiUrls.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

class ApiUrls: ObservableObject {
    // MARK: Base Url
    let baseUrl = "https://d1kfpvgfupbmyo.cloudfront.net/services/pro_rodeo.ashx/"
    let wpraBaseUrl = "https://psides83.github.io/wpra-json/"
    
    // MARK: URL for loading athlete Bio data
    func bioUrl(for athleteId: Int) -> URL {
        let urlString = baseUrl + "athlete?id=" + athleteId.string
        
        guard let url = URL(string: urlString) else { fatalError("Missing URL") }
        
        return url
    }
    
    // MARK: URL for loading results data
    func resultsUrl(for rodeoId: Int) -> URL {
        let urlString = baseUrl + "results?rodeoid=" + rodeoId.string
        
        guard let url = URL(string: urlString) else { fatalError("Missing URL") }
        
        return url
    }
    
    // MARK: URL for loading results data
    func rodeosUrl(with index: Int, searchText: String, dateParams: String) -> URL {
        let searchString = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString =
        baseUrl
        + "schedule?type=results&page_size=24&index="
        + index.string
        + "&active=true&search_term="
        + searchString
        + "&search_type=&tourId=&circuitId=&combine_results=true"
        + dateParams
        
        guard let url = URL(string: urlString) else { fatalError("Missing URL") }
        
        return url
    }
    
    // MARK: URL for loading standings data
    func standingsUrl(event: StandingsEvent, type: StandingType, circuit: Circuit, selectedYear: String) -> URL {
        var id: String {
            if type == .circuit {
                return circuit.id.string
            } else if type == .xBulls  {
                return Tour.xBulls.id.string
            } else if type == .xBroncs {
                return Tour.xBroncs.id.string
            } else if type == .legacySteerRoping {
                return Tour.legacySteerRoping.id.string
            } else {
                return ""
            }
        }
        
        var finalType: String {
            if type == .xBulls || type == .xBroncs || type == .legacySteerRoping {
                return "tour"
            } else {
                return type.rawValue
            }
        }
        
        var finalEvent: StandingsEvent {
            if type == .xBulls || type == .xBroncs || type == .legacySteerRoping {
                return .aa
            } else {
                return event
            }
        }
        
        var character: String {
            if finalEvent == .gb || finalEvent == .lb {
                return "-"
            } else {
                return "?"
            }
        }
//        let gbUrlString = wpraBaseUrl + "br_\(finalType)_\(selectedYear)_\(type == .circuit ? circuit.convertToGit : "").json"
//        let lbUrlString = wpraBaseUrl + "lb_\(finalType)_\(selectedYear)_\(type == .circuit ? circuit.convertToGit : "").json"
        let urlFilters = "standings\(character)year=\(selectedYear)&type=\(finalType)&id=\(id)&event=\(finalEvent.rawValue)"
        
        var url: URL {
            if finalEvent == .gb || finalEvent == .lb {
                print(wpraBaseUrl + urlFilters + ".json")
                guard let url = URL(string: wpraBaseUrl + urlFilters + ".json") else { fatalError("Missing URL") }
            
                return url
            } else {
                print(urlFilters)
                guard let url = URL(string: baseUrl + urlFilters) else { fatalError("Missing URL") }
            
                return url
            }
        }
        
//        guard let url = dynamicUrl else { fatalError("Missing URL") }
        
        return url
    }
    
    func athleteSearchUrl(from searchText: String) -> URL {
        let searchUrl = "athletes?event_type=&letter=&page_size=10&index=1&search_term=\(searchText)&search_type=&exact_search=null"
        
        var url: URL {
            guard let url = URL(string: baseUrl + searchUrl) else { fatalError("Missing URL") }
            
            return url
        }
        
        return url
    }
    
    func searchSuggetionsUrl(from searchText: String) -> URL {
        let searchUrl = "autocomplete?searchText=\(searchText)&searchType=contestant"
        
        var url: URL {
            guard let url = URL(string: baseUrl + searchUrl) else { fatalError("Missing URL") }
            
            return url
        }
        
        return url
    }
}
