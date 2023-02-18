//
//  SearchBarView.swift
//  Rural Sales Pro
//
//  Created by Payton Sides on 5/25/20.
//  Copyright © 2020 Payton Sides. All rights reserved.
//

import SwiftUI

struct ExpandingSearchBar: View {
    
    @Namespace var namespace
    let openButton = "openButton"
    let container = "container"
    
    @FocusState var focused
    
    @Binding var showing: Bool
    @Binding var text: String
    
    //    @State var isShowingSearchField: Bool = false
    //    @State var searcText: String = ""
    
    // MARK: - Body
    var body: some View {
        HStack {
            Spacer()
            
            HStack {
                if showing {
                    Button(action: toggleSearch, label: searchIcon)
                    
                    TextField("search rodeos or times...", text: $text)
                        .foregroundColor(.primary)
                        .transition(.scale(scale: 0, anchor: .trailing))
                        .focused($focused)
                        .submitLabel(.search)
                        .toolbar { ToolbarItemGroup(placement: .keyboard, content: keyboardToolbar) }
                    
                    Button(action: clearSearch, label: clearButton)
                }
                
                if !showing {
                    Button(action: toggleSearch, label: searchIcon)
                }
            }
            .matchedGeometryEffect(id: container, in: namespace)
            .frame(maxWidth: showing ? .infinity : 20, alignment: .trailing)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(showing ? Color.appBgOpp.opacity(0.15) : Color.clear).cornerRadius(50)
            
        }
    }
    
    // MARK: - View Methods
    func searchIcon() -> some View {
        Image.search
            .imageScale(.large)
            .matchedGeometryEffect(id: openButton, in: namespace)
            .foregroundColor(.appPrimary)
            .fontWeight(.semibold)
    }
    
    func cancelButton() -> some View {
        Text("Cancel")
            .foregroundColor(.appSecondary)
    }
    
    func doneButton() -> some View {
        Text("Done")
            .foregroundColor(.appSecondary)
    }
    
    func clearButton() -> some View {
        Image.clearField
            .foregroundColor(.appTertiary)
    }
    
    func keyboardToolbar() -> some View {
            Group {
                Spacer()
                
                Button(action: cancelSearch, label: cancelButton)
                
                Button(action: removeSearchFocus, label: doneButton)
            }
    }
    
    // MARK: - Action Methods
    func toggleSearch() {
        withAnimation {
            showing.toggle()
        }
    }
    
    func removeSearchFocus() {
        focused = false
    }
    
    func cancelSearch() {
        withAnimation {
            focused = false
            showing = false
            text = ""
        }
    }
    
    func clearSearch() {
        withAnimation {
            text = ""
        }
    }
}

//struct ExpandingSearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpandingSearchBar()
//    }
//}
