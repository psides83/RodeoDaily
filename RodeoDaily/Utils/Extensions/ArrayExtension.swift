//
//  ArrayExtension.swift
//  RodeoDaily
//
//  Created by Payton Sides on 7/7/25.
//

extension Array {
    func unique<T: Hashable>(by key: (Element) -> T) -> [Element] {
        var seen = Set<T>()
        return self.filter { element in
            let identifier = key(element)
            if seen.contains(identifier) {
                return false
            } else {
                seen.insert(identifier)
                return true
            }
        }
    }
}


