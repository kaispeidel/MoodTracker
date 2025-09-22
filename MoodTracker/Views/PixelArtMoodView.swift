import SwiftUI

struct PixelArtMoodView: View {
    let onSave: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var gridSize: Int = 16
    @State private var pixels: [[Color]] = Array(repeating: Array(repeating: .clear, count: 16), count: 16)
    @State private var selectedColor: Color = .blue
    @State private var isDrawing: Bool = false
    @State private var backgroundColor: Color = .white
    @State private var showGrid: Bool = true

    private let palette: [Color] = [.black, .gray, .white, .red, .orange, .yellow, .green, .mint, .teal, .blue, .indigo, .purple, .pink, .brown]

    init(onSave: @escaping (UIImage) -> Void) {
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                canvas
                paletteView
            }
            .padding()
            .navigationTitle("Draw your mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let image = renderImage()
                        onSave(image)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }

    private var canvas: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cell = size / CGFloat(gridSize)

            ZStack {
                Rectangle()
                    .fill(backgroundColor)

                // pixels
                ForEach(0..<gridSize, id: \.self) { y in
                    ForEach(0..<gridSize, id: \.self) { x in
                        let color = pixels[y][x]
                        if color.opacity > 0 { // skip clear
                            Rectangle()
                                .fill(color)
                                .frame(width: cell, height: cell)
                                .position(x: CGFloat(x) * cell + cell/2, y: CGFloat(y) * cell + cell/2)
                        }
                    }
                }

                // grid overlay
                if showGrid {
                    Path { path in
                        for i in 0...gridSize {
                            let p = CGFloat(i) * cell
                            path.move(to: CGPoint(x: p, y: 0))
                            path.addLine(to: CGPoint(x: p, y: size))
                            path.move(to: CGPoint(x: 0, y: p))
                            path.addLine(to: CGPoint(x: size, y: p))
                        }
                    }
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }
            }
            .frame(width: size, height: size)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    isDrawing = true
                    paint(at: value.location, in: CGSize(width: size, height: size))
                }
                .onEnded { _ in
                    isDrawing = false
                }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.3)))
    }

    private var paletteView: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(palette.indices, id: \.self) { idx in
                        let color = palette[idx]
                        Circle()
                            .fill(color)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle().stroke(Color.blue, lineWidth: selectedColor == color ? 3 : 1)
                            )
                            .onTapGesture { selectedColor = color }
                    }
                }
                .padding(.horizontal)
            }

            HStack(spacing: 16) {
                Button {
                    pixels = Array(repeating: Array(repeating: .clear, count: gridSize), count: gridSize)
                } label: {
                    Label("Clear", systemImage: "trash")
                }

                Toggle(isOn: $showGrid) {
                    Label("Grid", systemImage: "square.grid.3x3")
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))

                ColorPicker("Background", selection: $backgroundColor)
                    .labelsHidden()
            }
            .font(.custom("Matrix Sans Print", size: 16))
        }
    }

    private func paint(at point: CGPoint, in size: CGSize) {
        let cellSize = min(size.width, size.height) / CGFloat(gridSize)
        let x = Int(point.x / cellSize)
        let y = Int(point.y / cellSize)
        guard x >= 0, y >= 0, x < gridSize, y < gridSize else { return }
        pixels[y][x] = selectedColor
    }

    private func renderImage(scale: CGFloat = 8) -> UIImage {
        let dimension = CGFloat(gridSize) * scale
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: dimension, height: dimension))
        return renderer.image { ctx in
            // background
            ctx.cgContext.setFillColor(UIColor(backgroundColor).cgColor)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: dimension, height: dimension))

            for y in 0..<gridSize {
                for x in 0..<gridSize {
                    let color = UIColor(pixels[y][x])
                    if color.cgColor.alpha > 0 {
                        let rect = CGRect(x: CGFloat(x) * scale, y: CGFloat(y) * scale, width: scale, height: scale)
                        ctx.cgContext.setFillColor(color.cgColor)
                        ctx.cgContext.fill(rect)
                    }
                }
            }
        }
    }
}

#Preview {
    PixelArtMoodView { _ in }
}
