//
//  VideoHighlightsView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import SwiftUI

struct VideoHighlightsView: View {
    @ObservedObject var viewModel: BioViewModel
//    var bio: BioData
    
    @State private var index: Int = 0
    
    var body: some View {
        ScrollView {
            if viewModel.bio.videoHighlights != nil {
                Text("Highlights for \(viewModel.bio.name)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding()
                
                VimeoPlayer(video: videoArray[index])
                    .frame(height: videoHeight)
                
                HStack {
                    Button { index -= 1 } label: {
                        HStack {
                            Image(systemName: "chevron.backward.2")
                            Text("Previous")
                        }
                    }
                    .tint(.appSecondary)
                    .disabled(index == 0)
                    
                    Spacer()
                    
                    Button { index += 1 } label: {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.forward.2")
                        }
                    }
                    .tint(.appSecondary)
                    .disabled(index == videoArray.count - 1)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                BannerAd()
                    .frame(height: 400)
            } else {
                VStack {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView {
                            Label("No Highlights Available", systemImage: "video.slash.fill")
                        } description: {
                            Text("\(viewModel.bio.name) doesn't have any highlights available. Videos will be added as they become available")
                        }
                    } else {
                        UnavailableContentView(
                            imageName: "video.slash.fill",
                            title: "No Highlights Available",
                            description: "\(viewModel.bio.name) doesn't have any highlights available. Videos will be added as they become available"
                        )
                    }
                    
                    BannerAd()
                        .frame(height: 400)
                }
            }
            
            Spacer()
        }
    }
    
    var videoArray: [String] {
        if let videos = viewModel.bio.videoHighlights {
            let array = videos
                .components(separatedBy: ",")
                .map { $0.replacingOccurrences(of: "/videos", with: "/video") }
                .sorted(by: { $0 > $1 })
            
            print(array)
            
            return array
        }
        
        return []
    }
    
    var videoHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let ratioedWidth = screenWidth / 16
        
        return ratioedWidth * 9
    }
}

//#Preview {
//    VideoHighlightsView(videos: "/videos/616167433,/videos/592307353,/videos/589029084,/videos/578101682,/videos/538856928,/videos/517334763,/videos/516810358,/videos/516810315,/videos/513577571,/videos/513577551,/videos/513577165,/videos/513577122,/videos/513577036,/videos/473205419,/videos/396547910,/videos/653123088,/videos/653123111,/videos/653567010,/videos/653560025,/videos/672423026,/videos/693148942,/videos/693158431,/videos/704337215,/videos/719917687,/videos/726085527,/videos/731042552,/videos/744734127,/videos/748859686")
//}
