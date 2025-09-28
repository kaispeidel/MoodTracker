import SwiftUI

struct PixelButton: View {
    var label: String = "RESET"
    var width: CGFloat = 200
    var height: CGFloat = 56
    var isPressed: Bool = false
    
    var body: some View {
        Text(label)
            .font(.custom("Matrix Sans Print", size: 20))
            .foregroundColor(Color(red: 30/255, green: 40/255, blue: 80/255))
            .frame(width: width, height: height)
            .background(
                ZStack {
                    // Black outer border (thickest)
                    Rectangle()
                        .fill(Color(red: 20/255, green: 30/255, blue: 45/255))
                    
                    // Main button area (inset)
                    Rectangle()
                        .fill(Color(red: 160/255, green: 185/255, blue: 205/255))
                        .frame(width: width - 6, height: height - 6)
                    
                    // Top-left highlight strip (white/light)
                    Rectangle()
                        .fill(Color(red: 220/255, green: 235/255, blue: 250/255))
                        .frame(width: width - 12, height: 4)
                        .offset(x: -3, y: -height/2 + 8)
                    
                    Rectangle()
                        .fill(Color(red: 220/255, green: 235/255, blue: 250/255))
                        .frame(width: 4, height: height - 12)
                        .offset(x: -width/2 + 8, y: -3)
                    
                    // Bottom-right shadow strips (dark)
                    Rectangle()
                        .fill(Color(red: 80/255, green: 100/255, blue: 125/255))
                        .frame(width: width - 12, height: 4)
                        .offset(x: 3, y: height/2 - 8)
                    
                    Rectangle()
                        .fill(Color(red: 80/255, green: 100/255, blue: 125/255))
                        .frame(width: 4, height: height - 12)
                        .offset(x: width/2 - 8, y: 3)
                    
                    // Inner dark border
                    Rectangle()
                        .fill(Color(red: 110/255, green: 130/255, blue: 155/255))
                        .frame(width: width - 16, height: 2)
                        .offset(y: height/2 - 12)
                    
                    Rectangle()
                        .fill(Color(red: 110/255, green: 130/255, blue: 155/255))
                        .frame(width: 2, height: height - 16)
                        .offset(x: width/2 - 12)
                }
            )
            .drawingGroup() // Prevents anti-aliasing for crisp pixel edges
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.05), value: isPressed)
    }
}

struct IconPixelButton: View {
    var systemName: String = "play.fill"
    var size: CGFloat = 56
    var isPressed: Bool = false
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(Color(red: 45/255, green: 60/255, blue: 85/255))
            .frame(width: size, height: size)
            .background(
                ZStack {
                    // Main button body
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(red: 185/255, green: 205/255, blue: 220/255), location: 0.0),
                                    .init(color: Color(red: 150/255, green: 175/255, blue: 195/255), location: 0.5),
                                    .init(color: Color(red: 135/255, green: 160/255, blue: 180/255), location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Top highlight
                    Rectangle()
                        .fill(Color(red: 220/255, green: 235/255, blue: 245/255))
                        .frame(height: 2)
                        .offset(y: -size/2 + 3)
                    
                    // Left highlight
                    Rectangle()
                        .fill(Color(red: 200/255, green: 220/255, blue: 235/255))
                        .frame(width: 2)
                        .offset(x: -size/2 + 3)
                    
                    // Bottom shadow
                    Rectangle()
                        .fill(Color(red: 65/255, green: 85/255, blue: 105/255))
                        .frame(height: 2)
                        .offset(y: size/2 - 3)
                    
                    // Right shadow
                    Rectangle()
                        .fill(Color(red: 75/255, green: 95/255, blue: 115/255))
                        .frame(width: 2)
                        .offset(x: size/2 - 3)
                    
                    // Border
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(red: 45/255, green: 65/255, blue: 85/255), lineWidth: 2)
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        PixelButton(label: "LOG MOOD")
        PixelButton(label: "OVERVIEW")
    }
    .padding()
}
