//
//  GameBuilderView.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/9/24.
//

import SwiftUI

struct GameBuilderView: View {
    @State private var isShowingCamera = false
    @State private var detectedObjects = [String]()
    @State private var isDetectingObjects = false
        
    var body: some View {
        if false {
            return ObjectsListView(detectedObjects: detectedObjects).format()
        } else {
            return EnvironmentCaptureView().format()
        }
    }
    
}

#Preview {
    GameBuilderView()
}
