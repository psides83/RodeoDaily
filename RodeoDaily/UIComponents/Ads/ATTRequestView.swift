//
//  ATTRequestView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/17/22.
//

import SwiftUI

// MARK: Pre-ATT Alert View
/// This view proceeds the ATT alert and explains why the app is asking to track
struct ATTRequestView: View {
    
//    let requestTracking: () -> Void
    @StateObject var attHandler = ATTHandler()
    
    @State private var isShowingAlert =  false
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Spacer()
                        Image.appLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .padding(.vertical, -42)
                        Spacer()
                    }
                    
                    Text("Allow tracking in the following alert for:")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundColor(.rdGreen)
                            .padding(8)
                            .background(.white)
                            .clipShape(Circle())
                        
                        Text("Advertisements that match your interests")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("You can change this option later in the Settings app.")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                    
                        Button {
                            isShowingAlert = true
                            attHandler.requestTracking()
                        } label: {
                            HStack {
                                Spacer()
                                
                                Text("Continue")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.rdGreen)
                                    .padding(.vertical)
                                
                                Spacer()
                            }
                            .background(RoundedRectangle(cornerRadius: 12))
                            .tint(.white)
                        }
                        .opacity(isShowingAlert ? 0 : 1)
                }
                .padding(.horizontal, 24)
                .offset(y: -proxy.safeAreaInsets.top / 2)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(Color.rdGreen.gradient)
        }
    }
}

//struct ATTRequestView_Previews: PreviewProvider {
//    static var previews: some View {
//        ATTRequestView()
//    }
//}
