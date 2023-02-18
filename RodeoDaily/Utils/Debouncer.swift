//
//  Debounce.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/16/23.
//

import Foundation
import Combine

class Debouncer<T>: ObservableObject {
    @Published var input: T
    @Published var output: T

    private var debounce: AnyCancellable?

    init(initialValue: T, delay: Double = 1) {
        self.input = initialValue
        self.output = initialValue

        debounce = $input
            .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.output = $0
            }
    }
}
