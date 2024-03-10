//
//  ObjectDetector.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/9/24.
//

import SwiftUI

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: CameraView

    init(parent: CameraView) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            detectObjectsInImage(image)
        }
        parent.isPresented = false
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.isPresented = false
    }

    func detectObjectsInImage(_ image: UIImage) {
//        let options = VisionObjectDetectorOptions()
//        options.shouldEnableClassification = true
//        options.shouldEnableMultipleObjects = true
//
//        let objectDetector = Vision.vision().objectDetector(options: options)
//        let visionImage = VisionImage(image: image)
//
//        objectDetector.process(visionImage) { objects, error in
//            guard error == nil, let objects = objects else {
//                print("Error detecting objects:", error?.localizedDescription ?? "")
//                return
//            }
//
//            var detectedObjects = [String]()
//            for object in objects {
//                let name = object.labels.first?.text ?? "Unknown"
//                detectedObjects.append(name)
//            }
        self.parent.detectedObjects = ["TODO"]//detectedObjects
    }
}
