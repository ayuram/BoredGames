//
//  ObjectsListView.swift
//  BoredGames
//
//  Created by Ayush Raman on 3/9/24.
//

import SwiftUI
import Neumorphic

struct ObjectsListView: View {
    @State var detectedObjects: [String]
    @State private var showAlert = false
    @State private var deletionIndex: IndexSet?

    var body: some View {
        VStack {
            List {
                ForEach(detectedObjects, id: \.self) { object in
                    Text(object.capitalized)
                }
                .onDelete(perform: promptDeletion)
            }
            .navigationTitle("Detected Objects")
            .navigationBarItems(trailing: EditButton())
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Object"),
                    message: Text("Are you sure you want to delete this object?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let indexSet = deletionIndex {
                            deleteObject(at: indexSet)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            Button("Generate Game") {
                
            }
            .softButtonStyle(RoundedRectangle(cornerRadius: 25.0))
        }
    }
    
    private func deleteObject(at offsets: IndexSet) {
        detectedObjects.remove(atOffsets: offsets)
    }
    
    private func promptDeletion(at indexSet: IndexSet) {
        showAlert = true
        deletionIndex = indexSet
    }
}

#Preview {
    ObjectsListView(detectedObjects: ["yogurt cups", "ping pong ball", "table"])
}
