import SwiftUI

public struct FaceWireframeView: View {
    public init() {}
    
    public var body: some View {
        if let uiImage = SprintCheckAsset.uiImage(named: "face") {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            ZStack {
                // Face Outline
                Path { path in
                    path.addEllipse(in: CGRect(x: 10, y: 10, width: 140, height: 180))
                }
                .stroke(Color.black, lineWidth: 2)
                
                // Geometric Wireframe Mesh Lines & Landmark Nodes
                Group {
                    // Eyebrow lines
                    Path { p in
                        p.move(to: CGPoint(x: 35, y: 65))
                        p.addLine(to: CGPoint(x: 65, y: 60))
                        p.addLine(to: CGPoint(x: 80, y: 65))
                        p.addLine(to: CGPoint(x: 95, y: 60))
                        p.addLine(to: CGPoint(x: 125, y: 65))
                    }
                    .stroke(Color.black.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    
                    // Nose Bridge & Triangles
                    Path { p in
                        p.move(to: CGPoint(x: 80, y: 65))
                        p.addLine(to: CGPoint(x: 70, y: 95))
                        p.addLine(to: CGPoint(x: 80, y: 110))
                        p.addLine(to: CGPoint(x: 90, y: 95))
                        p.closeSubpath()
                    }
                    .stroke(Color.black.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    
                    // Cheek & Chin Mesh Lines
                    Path { p in
                        p.move(to: CGPoint(x: 35, y: 65))
                        p.addLine(to: CGPoint(x: 50, y: 105))
                        p.addLine(to: CGPoint(x: 80, y: 145))
                        p.addLine(to: CGPoint(x: 110, y: 105))
                        p.addLine(to: CGPoint(x: 125, y: 65))
                        
                        p.move(to: CGPoint(x: 50, y: 105))
                        p.addLine(to: CGPoint(x: 70, y: 125))
                        p.addLine(to: CGPoint(x: 90, y: 125))
                        p.addLine(to: CGPoint(x: 110, y: 105))
                        
                        p.move(to: CGPoint(x: 70, y: 125))
                        p.addLine(to: CGPoint(x: 80, y: 145))
                        p.addLine(to: CGPoint(x: 90, y: 125))
                    }
                    .stroke(Color.black.opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    
                    // Mouth Outline
                    Path { p in
                        p.move(to: CGPoint(x: 60, y: 135))
                        p.addLine(to: CGPoint(x: 80, y: 130))
                        p.addLine(to: CGPoint(x: 100, y: 135))
                        p.addLine(to: CGPoint(x: 80, y: 142))
                        p.closeSubpath()
                    }
                    .stroke(Color.black, lineWidth: 1.5)
                }
                
                // Facial Landmark Nodes (Dots)
                Group {
                    NodeDot(x: 80, y: 65)  // Forehead center
                    NodeDot(x: 50, y: 62)  // Left eye inner
                    NodeDot(x: 110, y: 62) // Right eye inner
                    NodeDot(x: 35, y: 65)  // Left temple
                    NodeDot(x: 125, y: 65) // Right temple
                    
                    NodeDot(x: 70, y: 95)  // Left nostril
                    NodeDot(x: 90, y: 95)  // Right nostril
                    NodeDot(x: 80, y: 110) // Nose tip
                    
                    NodeDot(x: 50, y: 105) // Left cheek
                    NodeDot(x: 110, y: 105)// Right cheek
                    
                    NodeDot(x: 60, y: 135) // Left mouth corner
                    NodeDot(x: 100, y: 135)// Right mouth corner
                    NodeDot(x: 80, y: 145) // Lower lip
                    NodeDot(x: 80, y: 170) // Chin tip
                }
                .frame(width: 160, height: 200)
            }
        }
    }
    
    struct NodeDot: View {
        let x: CGFloat
        let y: CGFloat
        
        var body: some View {
            Circle()
                .fill(Color.black)
                .frame(width: 4, height: 4)
                .position(x: x, y: y)
        }
    }
}
