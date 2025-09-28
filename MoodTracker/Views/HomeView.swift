//
//  HomeView.swift
//  MoodTracker
//
//  Created by Kai Speidel on 21.09.25.
//
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle gradient background instead of pure white
                LinearGradient(
                    colors: [Color.white, Color.blue.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section with better spacing
                    VStack(spacing: 20) {
                        Text("how are you feeling today?")
                            .font(.custom("Matrix Sans Print", size: 26))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 80)
                    
                    // Spacer to push content to center
                    Spacer()
                    
                    // Main content area - reserved space for animated character
                    VStack(spacing: 30) {
                        // Reserved space for animated character
                        Rectangle()
                            .fill(Color.blue.opacity(0.05))
                            .frame(width: 200, height: 160)
                            .cornerRadius(20)
                            .overlay(
                                Text("Animated Character\nComing Soon")
                                    .font(.custom("Matrix Sans Print", size: 12))
                                    .foregroundColor(.blue.opacity(0.4))
                                    .multilineTextAlignment(.center)
                            )
                        
                        // Button container with card-like styling
                        VStack(spacing: 20) {
                            NavigationLink(destination: LogMoodView()) {
                                EnhancedPixelButton(
                                    label: "LOG MOOD",
                                    width: 240,
                                    height: 55,
                                    isPrimary: true
                                )
                            }
                            
                            NavigationLink(destination: OverviewView()) {
                                EnhancedPixelButton(
                                    label: "OVERVIEW",
                                    width: 240,
                                    height: 55,
                                    isPrimary: false
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Bottom spacer
                    Spacer()
                    
                    // Footer with improved styling
                    VStack(spacing: 8) {
                        HStack {
                            Rectangle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 30, height: 1)
                            
                            Text("track your daily emotions")
                                .font(.custom("Matrix Sans Print", size: 13))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            Rectangle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 30, height: 1)
                        }
                        
                        // Optional: Add a subtle version indicator or date
                        Text("95 days left this year")
                            .font(.custom("Matrix Sans Print", size: 11))
                            .foregroundColor(.blue.opacity(0.4))
                    }
                    .padding(.bottom, 50)
                }
                .padding(.horizontal, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.light)
    }
}

// Enhanced button component with better visual hierarchy
struct EnhancedPixelButton: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    let isPrimary: Bool
    
    var body: some View {
        ZStack {
            // Button background with subtle depth
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: width, height: height)
                .shadow(color: .blue.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isPrimary ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2),
                            lineWidth: isPrimary ? 2 : 1
                        )
                )
            
            // Button text
            Text(label)
                .font(.custom("Matrix Sans Print", size: 16))
                .foregroundColor(isPrimary ? .blue : .blue.opacity(0.8))
                .fontWeight(isPrimary ? .medium : .regular)
        }
    }
}

#Preview {
    HomeView()
}
