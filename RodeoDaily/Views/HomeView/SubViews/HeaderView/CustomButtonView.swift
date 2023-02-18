//
//  CustomButtonView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/16/22.
//

import SwiftUI

extension HomeView {
    //    MARK: - Custom Button
    @ViewBuilder
    func CustomButton(symbolImage: Image, title: String, action: @escaping() -> ()) -> some View {
        // Fading out as soon as the navbar animates
        let progress = -(offSetY / 40) > 1 ? -1 : (offSetY > 0 ? 0 : (offSetY / 40))
        
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                
                symbolImage
                    .fontWeight(.semibold)
                    .foregroundColor(.appPrimary)
                    .frame(width: 35, height: 35)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                    }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .opacity(1 + progress)
            // MARK: Display Alternative Icon
            .overlay {
                symbolImage
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .opacity(-progress)
                    .offset(y: -10)
            }
        }
    }
}
