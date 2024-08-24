//
//  AthleteAPI.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/10/22.
//

import Foundation
import SwiftUI

class BioApi: ObservableObject {
    @ObservedObject var apiUrls = ApiUrls()
    
    @Published var bio: BioData = BioData()
    @Published var loading = true
        
    func getBio(for athleteId: Int) async {
        
        let url = apiUrls.bioUrl(for: athleteId)
        
        do {
                self.bio = try await APIService.fetchBio(from: url).data
                self.endLoading()
        } catch {
            self.endLoading()
            print("Error decoding: ", error)
        }
    }
    
    func setLoading() {
        DispatchQueue.main.async {
            self.loading = true
        }
    }
    
    func endLoading() {
        DispatchQueue.main.async {
            self.loading = false
            print("loading ended")
        }
    }
}
