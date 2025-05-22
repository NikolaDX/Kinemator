//
//  StereoVisualizerView.swift
//  Kinemator
//
//  Created by Nikola Ristic on 22. 5. 2025..
//

import SwiftUI

import SwiftUI

struct StereoVisualizerView: View {
    @StateObject private var microphoneService = MicrophoneService()
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 12) {
                LevelBarView(level: microphoneService.leftLevel, label: "L")
                    .frame(height: geo.size.height)
                LevelBarView(level: microphoneService.rightLevel, label: "R")
                    .frame(height: geo.size.height)
            }
            .frame(height: geo.size.height)
            .background(Color.black)
        }
        .onAppear { microphoneService.start() }
        .onDisappear { microphoneService.stop() }
    }
}
