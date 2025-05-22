//
//  ContentView.swift
//  Kinemator
//
//  Created by Nikola Ristic on 17. 5. 2025..
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var cameraService = CameraService()
    @State private var showAlert = false
    @State private var isSessionReady = false
    @State private var orientation = UIDevice.current.orientation
    
    var body: some View {
        ZStack {
            CameraPreviewView(previewLayer: cameraService.getPreviewLayer())
            
            HStack {
                StereoVisualizerView()
                    .frame(maxHeight: .infinity)
                
                Spacer()
                
                VStack(spacing: 30) {
                    if cameraService.isRecording {
                        Button(action: {
                            cameraService.stopRecording()
                        }) {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)
                        }
                    } else {
                        Button(action: {
                            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
                            cameraService.startRecording(to: tempURL)
                        }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 70, height: 70)
                        }
                    }
                }
            }
        }
        .onAppear {
            cameraService.configureSession()
            isSessionReady = true
            cameraService.startSession()
        }
        .onDisappear {
            cameraService.stopSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientation = UIDevice.current.orientation
        }
    }
}

#Preview {
    ContentView()
}
