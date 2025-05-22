//
//  MicrophoneService.swift
//  Kinemator
//
//  Created by Nikola Ristic on 22. 5. 2025..
//

import AVFoundation
import Combine

class MicrophoneService: ObservableObject {
    private var engine = AVAudioEngine()
    
    @Published var leftLevel: Float = 0.0
    @Published var rightLevel: Float = 0.0

    func start() {
        let inputNode = engine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
            guard let self = self else { return }
            guard let channelData = buffer.floatChannelData else { return }
            let frameLength = Int(buffer.frameLength)
            
            if inputFormat.channelCount >= 2 {
                let leftChannel = channelData[0]
                let rightChannel = channelData[1]

                let leftRMS = self.rms(from: leftChannel, frameLength: frameLength)
                let rightRMS = self.rms(from: rightChannel, frameLength: frameLength)
                
                let normLeft = normalizedLevel(from: leftRMS)
                let normRight = normalizedLevel(from: rightRMS)

                DispatchQueue.main.async {
                    self.leftLevel = normLeft
                    self.rightLevel = normRight
                }
            } else if inputFormat.channelCount == 1 {
                let mono = channelData[0]
                let rms = self.rms(from: mono, frameLength: frameLength)
                DispatchQueue.main.async {
                    self.leftLevel = rms
                    self.rightLevel = rms
                }
            }
        }
        
        do {
            try engine.start()
        } catch {
            print("Engine start error: \(error)")
        }
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
    }

    private func rms(from data: UnsafePointer<Float>, frameLength: Int) -> Float {
        let buffer = UnsafeBufferPointer(start: data, count: frameLength)
        let sum = buffer.reduce(0) { $0 + ($1 * $1) }
        let mean = sum / Float(frameLength)
        return min(sqrt(mean) * 20, 1.0)
    }
    
    private func normalizedLevel(from rawLevel: Float) -> Float {
        let clampedLevel = max(0.000_001, rawLevel)
        let db = 20 * log10(clampedLevel)
        let minDb: Float = -30
        let maxDb: Float = 130
        let normalized = (db - minDb) / (maxDb - minDb)
        return min(max(normalized, 0), 1)
    }

}
