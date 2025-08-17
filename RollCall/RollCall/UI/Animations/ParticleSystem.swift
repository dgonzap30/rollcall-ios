//
// ParticleSystem.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
struct ParticleSystem: View {
    let isActive: Bool
    let particleCount: Int = 4

    @State private var time: TimeInterval = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                guard self.isActive else { return }

                let currentTime = timeline.date.timeIntervalSinceReferenceDate

                for index in 0..<self.particleCount {
                    let particle = self.calculateParticle(
                        index: index,
                        time: currentTime,
                        canvasSize: size
                    )

                    let particlePath = if particle.isCircle {
                        Path(ellipseIn: CGRect(
                            x: particle.position.x - particle.size / 2,
                            y: particle.position.y - particle.size / 2,
                            width: particle.size,
                            height: particle.size
                        ))
                    } else {
                        Path(
                            roundedRect: CGRect(
                                x: particle.position.x - particle.size / 2,
                                y: particle.position.y - particle.size / 2,
                                width: particle.size,
                                height: particle.size
                            ),
                            cornerRadius: 2
                        )
                    }

                    context.fill(
                        particlePath,
                        with: .color(particle.color.opacity(particle.opacity))
                    )

                    if particle.opacity < 0.5 {
                        context.addFilter(.blur(radius: 2))
                    }
                }
            }
            .frame(width: 200, height: 200)
            .allowsHitTesting(false)
            .onChange(of: timeline.date) { newDate in
                self.time = newDate.timeIntervalSinceReferenceDate
            }
        }
    }

    private struct ParticleData {
        let position: CGPoint
        let size: CGFloat
        let opacity: Double
        let color: Color
        let isCircle: Bool
    }

    private func calculateParticle(index: Int, time: TimeInterval, canvasSize: CGSize) -> ParticleData {
        let seed = Double(index)
        let duration = 2.0 + seed.truncatingRemainder(dividingBy: 2.0)
        let delay = seed.truncatingRemainder(dividingBy: 1.0)
        let progress = ((time + delay).truncatingRemainder(dividingBy: duration)) / duration

        let startX = canvasSize.width / 2 + CGFloat(sin(seed * 2.0) * 60)
        let startY = canvasSize.height / 2 + CGFloat(cos(seed * 3.0) * 60)

        let endX = startX + CGFloat(sin(seed * 4.0) * 100)
        let endY = startY - CGFloat(50 + seed * 50)

        let xPos = startX + (endX - startX) * CGFloat(progress)
        let yPos = startY + (endY - startY) * CGFloat(progress)

        let opacity = progress < 0.1 ? progress * 10 : (1.0 - progress) * 1.1
        let scale = progress < 0.5 ? progress * 2 : 1.0

        let isCircle = index.isMultiple(of: 2)
        let color = isCircle ? Color.rcPink500 : Color.rcSalmon300
        let size: CGFloat = isCircle ? 8 : 6

        return ParticleData(
            position: CGPoint(x: xPos, y: yPos),
            size: size * CGFloat(scale),
            opacity: opacity * (isCircle ? 0.2 : 0.15),
            color: color,
            isCircle: isCircle
        )
    }
}
