import SwiftUI

public struct GaugeView: View {

    let score: Int // 0 to 100
    let isSuccess: Bool

    public init(score: Int, isSuccess: Bool) {
        self.score = score
        self.isSuccess = isSuccess
    }

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // 1. Inner Background 3D Disc Face
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(white: 0.94), Color(white: 0.88)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 176, height: 176)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

                // 2. Outer Segmented Ring Arc (Red -> Orange -> Green)
                GaugeRingArc()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color(red: 0.92, green: 0.22, blue: 0.22), location: 0.38),  // Red
                                .init(color: Color(red: 0.95, green: 0.55, blue: 0.22), location: 0.52),  // Orange
                                .init(color: Color(red: 0.18, green: 0.78, blue: 0.42), location: 0.65),  // Green
                                .init(color: Color(red: 0.18, green: 0.78, blue: 0.42), location: 0.95)
                            ]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 196, height: 196)

                // 3. Center Needle & Pivot Hub Assembly
                ZStack {
                    // Needle Pointer
                    GaugePointerShape()
                        .fill(Color(red: 0.18, green: 0.24, blue: 0.32)) // Slate dark gray
                        .frame(width: 14, height: 60)
                        .offset(y: -30)

                    // Center Pivot Hub Cap
                    Circle()
                        .fill(Color(red: 0.18, green: 0.24, blue: 0.32))
                        .frame(width: 22, height: 22)
                }
                .rotationEffect(.degrees(needleRotationDegrees))
                .animation(.spring(response: 1.0, dampingFraction: 0.75), value: needleRotationDegrees)
            }
            .frame(width: 220, height: 210)

            // 4. Score Number
            Text("\(score)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)

            // 5. Subtitle "Your Score is Good / Bad"
            HStack(spacing: 4) {
                Text("Your Score is")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(UIColor.darkGray))
                Text(isSuccess ? "Good" : "Bad")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(isSuccess ? Color(red: 0.18, green: 0.78, blue: 0.42) : Color(red: 0.92, green: 0.22, blue: 0.22))
            }
        }
    }

    private var needleRotationDegrees: Double {
        let clamped = Double(max(0, min(100, score)))
        // 0%   -> -135 degrees (pointing down-left at start of red arc)
        // 50%  -> 0 degrees (pointing straight up at top)
        // 100% -> +135 degrees (pointing down-right at end of green arc)
        return -135.0 + (clamped / 100.0) * 270.0
    }
}

// 270-degree Gauge Arc Shape
struct GaugeRingArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(135),
            endAngle: .degrees(405),
            clockwise: false
        )
        return path
    }
}

// Tapered Pointer Shape
struct GaugePointerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Sharp top tip
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
