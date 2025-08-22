//
//  FitnessDataView.swift
//  watchdata-app
//
//  Created by Zack Lacanna on 8/21/25.
//

import SwiftUI
import HealthKit

struct FitnessDataView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var watchConnectivityManager = WatchConnectivityManager()
    @State private var showingWorkoutPicker = false
    @State private var selectedWorkoutType = "Running"
    
    let workoutTypes = ["Running", "Walking", "Cycling", "Swimming", "Strength Training", "Yoga"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Watch connectivity status
                    WatchStatusCard(watchConnectivityManager: watchConnectivityManager)
                    
                    // Real-time fitness data
                    FitnessMetricsGrid(
                        heartRate: watchConnectivityManager.currentHeartRate,
                        steps: watchConnectivityManager.currentSteps,
                        activeEnergy: watchConnectivityManager.currentActiveEnergy,
                        distance: watchConnectivityManager.currentDistance
                    )
                    
                    // Workout controls
                    WorkoutControlCard(
                        watchConnectivityManager: watchConnectivityManager,
                        showingWorkoutPicker: $showingWorkoutPicker,
                        selectedWorkoutType: $selectedWorkoutType,
                        workoutTypes: workoutTypes
                    )
                    
                    // HealthKit data summary
                    HealthKitSummaryCard(healthKitManager: healthKitManager)
                }
                .padding()
            }
            .navigationTitle("Fitness Data")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                watchConnectivityManager.requestCurrentData()
            }
            .sheet(isPresented: $showingWorkoutPicker) {
                WorkoutPickerView(
                    selectedWorkoutType: $selectedWorkoutType,
                    workoutTypes: workoutTypes,
                    isPresented: $showingWorkoutPicker
                )
            }
        }
    }
}

struct WatchStatusCard: View {
    @ObservedObject var watchConnectivityManager: WatchConnectivityManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "applewatch")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Apple Watch Status")
                    .font(.headline)
                
                Spacer()
                
                if watchConnectivityManager.isWatchReachable {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                StatusRow(
                    title: "Watch App Installed",
                    isActive: watchConnectivityManager.isWatchAppInstalled
                )
                
                StatusRow(
                    title: "Watch Reachable",
                    isActive: watchConnectivityManager.isWatchReachable
                )
                
                if watchConnectivityManager.workoutSessionActive {
                    StatusRow(
                        title: "Active Workout",
                        isActive: true,
                        subtitle: watchConnectivityManager.workoutType ?? "Unknown"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatusRow: View {
    let title: String
    let isActive: Bool
    var subtitle: String?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            Image(systemName: isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isActive ? .green : .red)
                .font(.caption)
        }
    }
}

struct FitnessMetricsGrid: View {
    let heartRate: Double?
    let steps: Int?
    let activeEnergy: Double?
    let distance: Double?
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Heart Rate",
                value: heartRate != nil ? "\(Int(heartRate!))" : "--",
                unit: "BPM",
                icon: "heart.fill",
                color: .red
            )
            
            MetricCard(
                title: "Steps",
                value: steps != nil ? "\(steps!)" : "--",
                unit: "steps",
                icon: "figure.walk",
                color: .green
            )
            
            MetricCard(
                title: "Active Energy",
                value: activeEnergy != nil ? String(format: "%.1f", activeEnergy!) : "--",
                unit: "kcal",
                icon: "flame.fill",
                color: .orange
            )
            
            MetricCard(
                title: "Distance",
                value: distance != nil ? String(format: "%.2f", distance!) : "--",
                unit: "km",
                icon: "location.fill",
                color: .blue
            )
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WorkoutControlCard: View {
    @ObservedObject var watchConnectivityManager: WatchConnectivityManager
    @Binding var showingWorkoutPicker: Bool
    @Binding var selectedWorkoutType: String
    let workoutTypes: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Workout Controls")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                Button(action: {
                    showingWorkoutPicker = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Select Workout")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                if watchConnectivityManager.workoutSessionActive {
                    Button(action: {
                        watchConnectivityManager.stopWorkoutSession()
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    Button(action: {
                        watchConnectivityManager.startWorkoutSession(workoutType: selectedWorkoutType)
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            
            if watchConnectivityManager.workoutSessionActive {
                Text("Current: \(selectedWorkoutType)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct HealthKitSummaryCard: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("HealthKit Data")
                    .font(.headline)
                
                Spacer()
                
                if healthKitManager.isHealthKitAuthorized {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.orange)
                }
            }
            
            if healthKitManager.isHealthKitAuthorized {
                Text("HealthKit is authorized and ready to sync data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Tap the HealthKit button in Settings to enable data access")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WorkoutPickerView: View {
    @Binding var selectedWorkoutType: String
    let workoutTypes: [String]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(workoutTypes, id: \.self) { workoutType in
                Button(action: {
                    selectedWorkoutType = workoutType
                    isPresented = false
                }) {
                    HStack {
                        Text(workoutType)
                        Spacer()
                        if workoutType == selectedWorkoutType {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    FitnessDataView()
}
