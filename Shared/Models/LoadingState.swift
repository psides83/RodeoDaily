//
//  LoadingState.swift
//  RodeoDaily
//
//  Created by Codex on 5/15/26.
//

import Foundation

enum LoadingState<Value> {
    case idle(Value)
    case loading(Value)
    case loaded(Value)
    case failed(Value, message: String)

    var value: Value {
        switch self {
        case .idle(let value),
             .loading(let value),
             .loaded(let value),
             .failed(let value, _):
            return value
        }
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .failed(_, let message) = self {
            return message
        }
        return nil
    }
}

extension LoadingState where Value: RangeReplaceableCollection {
    static var idleEmpty: LoadingState<Value> {
        .idle(Value())
    }

    var isEmpty: Bool {
        value.isEmpty
    }
}
