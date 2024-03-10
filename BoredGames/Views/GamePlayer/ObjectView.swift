//
//  ObjectView.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/10/24.
//

import SwiftUI
import Neumorphic

struct ObjectView: View {
    let object: Object
    var body: some View {
       foo()
    }
    
    func foo() -> AnyView {
        switch object.state {
        case .INT(let int):
            return Stepper("Incrementor", onIncrement: {}, onDecrement: {}).format()
        case .STRING(let string):
            return TextField(text: Binding(get: {""}, set: {_ in }), label: { Text("Okay") })
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 30).fill(.white)
                        .softInnerShadow(RoundedRectangle(cornerRadius: 30), darkShadow: .black, lightShadow: .gray, spread: 0.05, radius: 2)
                )
                .format()
        case .BOOL(let bool):
            return Toggle("okay", isOn: Binding(get: { true }, set: {_ in })).format()
        }
    }
}

#Preview {
    ObjectView(object: Object(state: .BOOL(false)))
}
