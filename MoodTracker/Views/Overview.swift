import SwiftUI
import UIKit

struct OverviewView: View {
    private let calendar = Calendar.current
    private let currentYear = Calendar.current.component(.year, from: Date())
    @State private var selectedDate: Date? = nil
    @State private var showingMoodDetail = false
    
    var today: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    var daysLeftInYear: Int {
        let startOfNextYear = calendar.dateInterval(of: .year, for: Date())?.end ?? Date()
        let daysRemaining = calendar.dateComponents([.day], from: Date(), to: startOfNextYear).day ?? 0
        return daysRemaining
    }
    
    var moodStats: (total: Int, percentage: Double) {
        let allDays = allDaysInYear()
        let moodDays = allDays.filter { getMoodForDate($0) != nil }.count
        let percentage = allDays.isEmpty ? 0.0 : Double(moodDays) / Double(allDays.count) * 100
        return (moodDays, percentage)
    }
            
    var body: some View {
        ZStack {
            // Subtle gradient background
            LinearGradient(
                colors: [Color.white, Color.blue.opacity(0.015)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 35) {
                    // Enhanced Header Section
                    VStack(spacing: 15) {
                        Text("\(daysLeftInYear) days left this year")
                            .font(.custom("Matrix Sans Print", size: 20))
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        
                        Text("go outside and make memories")
                            .font(.custom("Matrix Sans Print", size: 16))
                            .foregroundColor(.blue.opacity(0.7))
                        

                        .padding(.top, 10)
                    }
                    .padding(.top, 40)
                    
                    // Original single grid layout - all dots for the year
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 20), spacing: 10) {
                        ForEach(allDaysInYear(), id: \.self) { date in
                            EnhancedDotCell(
                                date: date,
                                mood: getMoodForDate(date),
                                onTap: {
                                    selectedDate = date
                                    showingMoodDetail = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer(minLength: 30)
                }
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingMoodDetail) {
            if let selectedDate = selectedDate {
                MoodDetailSheet(date: selectedDate, mood: getMoodForDate(selectedDate))
            }
        }
    }
    

    
    func allDaysInYear() -> [Date] {
        let startOfYear = calendar.dateInterval(of: .year, for: Date())?.start ?? Date()
        var dates: [Date] = []
        
        let daysInYear = calendar.range(of: .day, in: .year, for: Date())?.count ?? 365
        
        for dayOffset in 0..<daysInYear {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfYear) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    func getMoodForDate(_ date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: date)
        return UserDefaults.standard.string(forKey: "mood_\(dateKey)")
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.custom("Matrix Sans Print", size: 12))
                .foregroundColor(.blue.opacity(0.6))
            
            Text(value)
                .font(.custom("Matrix Sans Print", size: 18))
                .foregroundColor(.blue)
                .fontWeight(.medium)
            
            Text(subtitle)
                .font(.custom("Matrix Sans Print", size: 10))
                .foregroundColor(.blue.opacity(0.5))
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct MonthNavigator: View {
    let scrollTo: () -> Void
    
    var body: some View {
        HStack {
            Button(action: scrollTo) {
                HStack(spacing: 5) {
                    Image(systemName: "calendar.circle")
                        .font(.system(size: 14))
                    Text("Go to Today")
                        .font(.custom("Matrix Sans Print", size: 12))
                }
                .foregroundColor(.blue.opacity(0.7))
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct MonthSection: View {
    let monthRange: (month: String, days: [Date])
    let getMoodForDate: (Date) -> String?
    let onDateTap: (Date) -> Void
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header
            HStack {
                Text(monthRange.month)
                    .font(.custom("Matrix Sans Print", size: 16))
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(monthRange.days.filter { getMoodForDate($0) != nil }.count)/\(monthRange.days.count)")
                    .font(.custom("Matrix Sans Print", size: 12))
                    .foregroundColor(.blue.opacity(0.6))
            }
            
            // Days grid for this month
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 18), spacing: 8) {
                ForEach(monthRange.days, id: \.self) { date in
                    EnhancedDotCell(
                        date: date,
                        mood: getMoodForDate(date),
                        onTap: { onDateTap(date) }
                    )
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct MoodDetailSheet: View {
    let date: Date
    let mood: String?
    @Environment(\.dismiss) private var dismiss
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(dateString)
                    .font(.custom("Matrix Sans Print", size: 18))
                    .foregroundColor(.blue)
                
                if let mood = mood {
                    VStack(spacing: 15) {
                        // Mood icon/image (larger version)
                        Group {
                            if let image = UIImage(named: mood) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                            } else {
                                Image(systemName: sfSymbolForMood(mood))
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("Mood: \(mood.capitalized)")
                            .font(.custom("Matrix Sans Print", size: 16))
                            .foregroundColor(.blue)
                    }
                } else {
                    Text("No mood logged for this day")
                        .font(.custom("Matrix Sans Print", size: 14))
                        .foregroundColor(.blue.opacity(0.6))
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    private func sfSymbolForMood(_ mood: String) -> String {
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
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Enhanced Dot Cell
struct EnhancedDotCell: View {
    let date: Date
    let mood: String?
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let mood = mood {
                    // Show mood icon as dot
                    Group {
                        if mood.lowercased() == "own", let custom = loadCustomMoodImage(for: date) {
                            Image(uiImage: custom)
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
                    .frame(width: 12, height: 12)
                    .foregroundColor(.blue)
                } else {
                    // Empty dot for days without moods
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 8, height: 8)
                }
                
                // Today indicator with pulsing animation
                if calendar.isDateInToday(date) {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(.blue, lineWidth: 2)
                        .frame(width: 22, height: 22)
                        .scaleEffect(1.1)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: calendar.isDateInToday(date))
                }
            }
            .frame(width: 20, height: 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sfSymbolForMood(_ mood: String) -> String {
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
        default: return "questionmark.circle"
        }
    }
    
    private func loadCustomMoodImage(for date: Date) -> UIImage? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: date)
        if let data = UserDefaults.standard.data(forKey: "moodImage_\(dateKey)"),
           let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}

#Preview {
    OverviewView()
}
