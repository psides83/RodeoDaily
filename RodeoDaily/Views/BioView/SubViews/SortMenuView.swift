//
//  SortMenuView.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import SwiftUI

struct SortMenuView: View {
    
    var action: (_ keyPath: BioResult.SortingKeyPath) -> Void
    
    // MARK: - Body
    var body: some View {
        Menu(content: menuContent, label: menuIcon)
    }
    
    func menuIcon() -> some View {
        VStack {
            Image.sort
                .imageScale(.large)
                .foregroundColor(.appPrimary)
            
            
            Text("Sort")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    func menuContent() -> some View {
        ForEach(BioResult.SortingKeyPath.allCases) { keyPath in
            Button {
                action(keyPath)
            } label: {
                Text(keyPath.title)
            }
        }
    }
}
