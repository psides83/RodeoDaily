//
//  OnboardingView.swift
//  CalfRopingDaily
//
//  Created by Payton Sides on 12/15/22.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
        ZStack {
            HomeView()
            VStack {
                Rectangle()
                    .fill(Color.rdGray.opacity(0.6))
            }
            .ignoresSafeArea(.all)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
