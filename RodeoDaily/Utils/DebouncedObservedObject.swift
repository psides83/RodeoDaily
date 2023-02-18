//
//  DebouncedObservedObject.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/16/23.
//

import Combine
import Foundation

@propertyWrapper @dynamicMemberLookup
class DebouncedObservedObject<Wrapped: ObservableObject>: ObservableObject {
    var wrappedValue: Wrapped
    private var subscription: AnyCancellable?
    
    init(wrappedValue: Wrapped, delay: Double = 1) {
        self.wrappedValue = wrappedValue

        subscription = wrappedValue.objectWillChange
            .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }
    
    subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, Value>) -> Value {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
}
