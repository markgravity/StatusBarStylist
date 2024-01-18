//
//  Interposed.swift
//  
//
//  Created by MarkG on 18/01/2024.
//

import SwiftUI

enum Interposed {

    case pending
    case successful
    case failed
}

struct InterposedKey: EnvironmentKey {

    static let defaultValue: Interposed = .pending
}

extension EnvironmentValues {

    var interposed: Interposed {
        get { self[InterposedKey.self] }
        set { self[InterposedKey.self] = newValue }
    }
}
