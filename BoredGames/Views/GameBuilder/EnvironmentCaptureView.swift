//
//  EnvironmentCaptureView.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/10/24.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    
    @Binding var isPresented: Bool
    @Binding var detectedObjects: [String]
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct EnvironmentCaptureView: View {
    @State private var isShowingCamera = false
    @State private var detectedObjects = [String]()
    @State private var isDetectingObjects = false
        
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Please take a picture").font(.headline)
                    Spacer()
                }
                Spacer()
                Button("Take Picture") {
                    isShowingCamera.toggle()
                }
                .softButtonStyle(RoundedRectangle(cornerRadius: 25.0))
                .sheet(isPresented: $isShowingCamera) {
                    // Show the camera view when isShowingCamera is true
//                    CameraView(isPresented: $isShowingCamera, detectedObjects: $detectedObjects, isObjectsDetected: $isObjectsDetected)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
        }
    }
    
}

#Preview {
    EnvironmentCaptureView()
}
