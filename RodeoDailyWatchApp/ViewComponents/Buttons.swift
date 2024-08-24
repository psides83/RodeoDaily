//
//  Buttons.swift
//  RodeoDailyWatch
//
//  Created by Payton Sides on 2/19/23.
//

import SwiftUI

struct Buttons: View {
//    var backgroundColor: Color
//    var circleColor: Color
//    var lineColor: Color
    
    @State private var loading = false
    
    var body: some View {
        VStack {
            
//            Button {
//                
//            } label: {
//                Text("Stetson Wright")
//            }
//            .buttonStyle(.borderless)
            
//            if loading {
//                LogoLoader()
//            }
//
            LoadMoreButton(loading: loading) {
                withAnimation {
                    loading = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
                    withAnimation {
                        loading = false
                    }
                }
            }
        }
    }
}

struct LoadMoreButton: View {
    
    let loading : Bool
    var action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            HStack(spacing: 8) {
                if loading {
                    ProgressView()
                }
                Text(loading ? "Loading..." : "Load More")
            }
        }
        .buttonStyle(.loadingButton(loading))
        .disabled(loading)
    }
}

struct Buttons_Previews: PreviewProvider {
    static var previews: some View {
        Buttons()
    }
}

struct LoadingButtonStyle: ButtonStyle {
    let loading: Bool
    
    var color = Color.rdGreen
    
    func makeBody(configuration: Configuration) -> some View {
        
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.subheadline.weight(.semibold))
            .textCase(.none)
            .foregroundColor(.white)
            .padding(6)
            .background(isPressed ? Color.rdGreen.opacity(0.6) : loading ? Color.rdGray.opacity(0.8) : Color.rdGreen)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
    }
}

extension ButtonStyle where Self == LoadingButtonStyle {
    static func loadingButton(_ loading: Bool) -> Self {
        return .init(loading: loading)
    }
}

struct SelecttionActionButton: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.subheadline.weight(.semibold))
            .textCase(.none)
            .foregroundColor(.white)
            .padding(5)
            .background(isPressed ? color.opacity(0.2) : color.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
            .padding(.trailing)
    }
}

struct CircleButton: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .font(.subheadline.weight(.semibold))
            .textCase(.none)
            .foregroundColor(.white)
            .padding(6)
            .background(isPressed ? color.opacity(0.2) : color.opacity(0.6))
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
    }
}

struct ContactButton: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
//            .padding()
            .frame(width: 85, height: 60, alignment: .center)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .shadow(color: configuration.isPressed ? Color.white : Color.gray.opacity(0.4), radius: 3)
            .foregroundColor(.blue)
            .overlay(
                Color.black
                    .opacity(configuration.isPressed ? 0.3 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            )
    }
}

struct CloseButtonStyle: ButtonStyle {
//    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(.all, 8)
//            .background(Color.black.opacity(0.6))
            .clipShape(Circle())
    }
}
