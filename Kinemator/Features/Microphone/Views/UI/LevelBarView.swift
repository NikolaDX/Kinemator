//
//  LevelBarView.swift
//  Kinemator
//
//  Created by Nikola Ristic on 22. 5. 2025..
//

import SwiftUI

struct LevelBarView: View {
    var level: Float
    var label: String

    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(levelColor(for: level))
                        .frame(height: CGFloat(level) * geo.size.height)
                        .animation(.easeOut(duration: 0.1), value: level)
                }
            }
            .frame(width: 20)
            
            Text(label)
        }
        .frame(maxHeight: .infinity)
    }

    private func levelColor(for value: Float) -> Color {
        switch value {
        case ..<0.4: return .green
        case ..<0.7: return .yellow
        default: return .red
        }
    }
}
