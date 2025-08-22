//
//  HealthKitManager.swift
//  watchdata-app
//
//  Created by Zack Lacanna on 8/21/25.
//

import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var isHealthKitAuthorized = false
    @Published var isHealthKitAvailable = false
    
    init() {
        checkHealthKitAvailability()
    }
    
    private func checkHealthKitAvailability() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestHealthKitPermissions() {
        guard isHealthKitAvailable else {
            print("HealthKit is not available on this device")
            return
        }
        
        // Define the types of data we want to read
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        // Define the types of data we want to write
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]
        
        // Request authorization
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isHealthKitAuthorized = true
                    print("HealthKit authorization granted")
                } else {
                    print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func readUserProfile() -> (height: Double?, weight: Double?, age: Int?, gender: HKBiologicalSex?) {
        var height: Double?
        var weight: Double?
        var age: Int?
        var gender: HKBiologicalSex?
        
        let group = DispatchGroup()
        
        // Read height
        if let heightType = HKQuantityType.quantityType(forIdentifier: .height) {
            group.enter()
            let heightQuery = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    height = sample.quantity.doubleValue(for: .meter())
                }
                group.leave()
            }
            healthStore.execute(heightQuery)
        }
        
        // Read weight
        if let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            group.enter()
            let weightQuery = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: nil) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    weight = sample.quantity.doubleValue(for: .gramUnit(with: .kilo))
                }
                group.leave()
            }
            healthStore.execute(weightQuery)
        }
        
        // Read age
        do {
            let birthDate = try healthStore.dateOfBirthComponents()
            if let birthDate = birthDate.date {
                let calendar = Calendar.current
                let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
                age = ageComponents.year
            }
        } catch {
            print("Failed to read date of birth: \(error)")
        }
        
        // Read gender
        do {
            let biologicalSex = try healthStore.biologicalSex()
            gender = biologicalSex.biologicalSex
        } catch {
            print("Failed to read biological sex: \(error)")
        }
        
        return (height: height, weight: weight, age: age, gender: gender)
    }
    
    func saveUserProfile(height: Double?, weight: Double?) {
        guard isHealthKitAuthorized else {
            print("HealthKit not authorized")
            return
        }
        
        let group = DispatchGroup()
        
        // Save height
        if let height = height, let heightType = HKQuantityType.quantityType(forIdentifier: .height) {
            group.enter()
            let heightQuantity = HKQuantity(unit: .meter(), doubleValue: height)
            let heightSample = HKQuantitySample(type: heightType, quantity: heightQuantity, start: Date(), end: Date())
            
            healthStore.save(heightSample) { success, error in
                if success {
                    print("Height saved successfully")
                } else {
                    print("Failed to save height: \(error?.localizedDescription ?? "Unknown error")")
                }
                group.leave()
            }
        }
        
        // Save weight
        if let weight = weight, let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) {
            group.enter()
            let weightQuantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: weight)
            let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: Date(), end: Date())
            
            healthStore.save(weightSample) { success, error in
                if success {
                    print("Weight saved successfully")
                } else {
                    print("Failed to save weight: \(error?.localizedDescription ?? "Unknown error")")
                }
                group.leave()
            }
        }
    }
}
