//
//  CameraPreviewView.swift
//  Kinemator
//
//  Created by Nikola Ristic on 17. 5. 2025..
//

import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var cameraService: CameraService
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        if let previewLayer = cameraService.previewLayer {
            previewLayer.frame = UIScreen.main.bounds
            view.layer.addSublayer(previewLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let previewLayer = cameraService.previewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}
