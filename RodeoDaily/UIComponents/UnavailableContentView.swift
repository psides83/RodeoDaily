//
//  UnavailableContentView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 9/3/24.
//

import SwiftUI

struct UnavailableContentView: View {
    var imageName: String
    var title: String
    var description: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            if let description = description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

//#Preview {
//    UnavailableContentView()
//}
