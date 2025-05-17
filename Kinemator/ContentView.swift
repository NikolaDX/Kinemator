//
//  ContentView.swift
//  Kinemator
//
//  Created by Nikola Ristic on 17. 5. 2025..
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var cameraService = CameraService()
    
    var body: some View {
        CameraPreviewView(cameraService: cameraService)
            .onAppear {
                cameraService.startSession()
            }
            .onDisappear {
                cameraService.stopSession()
            }
    }
}

#Preview {
    ContentView()
}
