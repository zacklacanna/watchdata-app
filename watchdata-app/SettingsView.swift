//
//  SettingsView.swift
//  watchdata-app
//
//  Created by Zack Lacanna on 8/21/25.
//

import SwiftUI
import HealthKit
import CoreLocation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var locationManager = LocationManager()
    
    @State private var height = ""
    @State private var weight = ""
    @State private var age = ""
    @State private var gender = ""
    @State private var showingHealthKitAlert = false
    
    let genderOptions = ["Male", "Female"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("in", text: $height)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("pound", text: $weight)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("years", text: $age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Health & Location")) {
                    Button(action: {
                        healthKitManager.requestHealthKitPermissions()
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("HealthKit Permissions")
                            Spacer()
                            if healthKitManager.isHealthKitAuthorized {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Button(action: {
                        locationManager.requestLocationPermission()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Location Services")
                            Spacer()
                            if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Save Settings") {
                        saveSettings()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("HealthKit Access Required", isPresented: $showingHealthKitAlert) {
            Button("OK") { }
        } message: {
            Text("Please enable HealthKit access in Settings to use all features of this app.")
        }
    }
    
    private func saveSettings() {
        // TODO: Save user settings to UserDefaults or Core Data
        // TODO: Sync with HealthKit if authorized
        
        // For now, just dismiss the view
        dismiss()
    }
}

#Preview {
    SettingsView()
}
