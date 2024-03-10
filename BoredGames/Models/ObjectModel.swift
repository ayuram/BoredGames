//
//  ObjectModel.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/9/24.
//

import Foundation

enum PropertyType {
    case INT(Int)
    case STRING(String)
    case BOOL(Bool)
}

class Object {
    @Published var state: PropertyType
    init(state: PropertyType) {
        self.state = state
    }
}
