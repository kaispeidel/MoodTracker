import SwiftUI

struct LogMoodView: View {
    @State private var selectedMood: String? = nil
    @State private var selectedDate = Date()
    @State private var moodLog: [String: String] = [:]
    @State private var isPresentingPixelArt = false
    
    private let moodOptions = [
        "grounded", "sad", "angry", "connected",
        "lucky", "love", "chaos", "grateful", "own"
    ]
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Date Picker
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("date")
                                .font(.custom("Matrix Sans Print", size: 18))
                                .foregroundColor(.blue)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                .accentColor(.blue)
                                .font(.custom("Matrix Sans Print", size: 18))
                                .onChange(of: selectedDate) {
                                    loadMoodForSelectedDate()
                                }
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    
                    // Mood Grid
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(moodOptions, id: \.self) { mood in
                            Button(action: {
                                if mood.lowercased() == "own" {
                                    isPresentingPixelArt = true
                                } else {
                                    selectedMood = mood
                                    saveMood()
                                }
                            }) {
                                VStack(spacing: 10) {
                                    ZStack {
                                        Rectangle()
                                            .fill(selectedMood == mood ? Color.blue.opacity(0.15) : Color.clear)
                                            .frame(width: 85, height: 85)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedMood == mood ? Color.blue : Color.blue.opacity(0.4),
                                                        lineWidth: selectedMood == mood ? 3 : 2
                                                    )
                                            )
                                            // pulse animation on selection
                                            .scaleEffect(selectedMood == mood ? 1.08 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: selectedMood)
                                        
                                        Group {
                                            if mood.lowercased() == "own", let custom = loadCustomMoodImage(for: selectedDate) {
                                                Image(uiImage: custom)
                                                    .resizable()
                                            } else if mood.lowercased() == "own" {
                                                Image("meditation")
                                                    .resizable()
                                            } else if UIImage(named: mood) != nil {
                                                Image(mood)
                                                    .resizable()
                                            } else {
                                                Image(systemName: sfSymbolForMood(mood))
                                                    .resizable()
                                            }
                                        }
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 55, height: 55)
                                        .foregroundColor(.blue)
                                        .opacity(selectedMood == mood ? 1.0 : 0.8)
                                    }
                                    
                                    Text(mood.uppercased())
                                        .font(.custom("Matrix Sans Print", size: 15))
                                        .foregroundColor(selectedMood == mood ? .blue : .blue.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                    
                    // Current mood for selected date
                    if let currentMood = getMoodForDate(selectedDate) {
                        VStack(spacing: 10) {
                            Text("mood for \(formatDateSimple(selectedDate)):")
                                .font(.custom("Matrix Sans Print", size: 14))
                                .foregroundColor(.blue.opacity(0.7))
                            
                            HStack(spacing: 12) {
                                Group {
                                    if currentMood.lowercased() == "own", let custom = loadCustomMoodImage(for: selectedDate) {
                                        Image(uiImage: custom)
                                            .resizable()
                                    } else if currentMood.lowercased() == "own" {
                                        Image("meditation")
                                            .resizable()
                                    } else if UIImage(named: currentMood) != nil {
                                        Image(currentMood)
                                            .resizable()
                                    } else {
                                        Image(systemName: sfSymbolForMood(currentMood))
                                            .resizable()
                                    }
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                                .foregroundColor(.blue)
                                
                                Text(currentMood.uppercased())
                                    .font(.custom("Matrix Sans Print", size: 16))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 50)
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .onAppear {
            loadMoodForSelectedDate()
        }
        .sheet(isPresented: $isPresentingPixelArt) {
            PixelArtMoodView { image in
                saveCustomMoodImage(image, for: selectedDate)
                selectedMood = "own"
                saveMood()
            }
        }
    }
    
    func saveMood() {
        guard let mood = selectedMood else { return }
        let dateKey = dateKeyFormatter.string(from: selectedDate)
        moodLog[dateKey] = mood
        UserDefaults.standard.set(mood, forKey: "mood_\(dateKey)")
    }
    
    func loadMoodForSelectedDate() {
        let dateKey = dateKeyFormatter.string(from: selectedDate)
        selectedMood = UserDefaults.standard.string(forKey: "mood_\(dateKey)")
    }
    
    func getMoodForDate(_ date: Date) -> String? {
        let dateKey = dateKeyFormatter.string(from: date)
        return UserDefaults.standard.string(forKey: "mood_\(dateKey)")
    }
    
    func sfSymbolForMood(_ mood: String) -> String {
        switch mood.lowercased() {
        case "happy": return "face.smiling"
        case "sad": return "face.dashed"
        case "angry": return "flame"
        case "excited": return "star.circle"
        case "calm": return "leaf"
        case "anxious": return "heart.fill"
        case "tired": return "moon.zzz"
        case "energetic": return "bolt.fill"
        case "neutral": return "circle"
        case "own": return "paintpalette"
        default: return "questionmark.circle"
        }
    }
    
    func formatDateSimple(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private var dateKeyFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    func saveCustomMoodImage(_ image: UIImage, for date: Date) {
        let dateKey = dateKeyFormatter.string(from: date)
        if let data = image.pngData() {
            UserDefaults.standard.set(data, forKey: "moodImage_\(dateKey)")
        }
    }

    func loadCustomMoodImage(for date: Date) -> UIImage? {
        let dateKey = dateKeyFormatter.string(from: date)
        if let data = UserDefaults.standard.data(forKey: "moodImage_\(dateKey)"),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}

#Preview {
    LogMoodView()
}
