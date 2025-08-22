//
//  WatchConnectivityManager.swift
//  watchdata-app
//
//  Created by Zack Lacanna on 8/21/25.
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
    private let session: WCSession
    
    @Published var isWatchAppInstalled = false
    @Published var isWatchReachable = false
    
    // Watch data
    @Published var currentHeartRate: Double?
    @Published var currentSteps: Int?
    @Published var currentActiveEnergy: Double?
    @Published var currentDistance: Double?
    @Published var workoutSessionActive = false
    @Published var workoutType: String?
    
    override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    func sendMessageToWatch(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)? = nil, errorHandler: ((Error) -> Void)? = nil) {
        guard isWatchReachable else {
            print("Watch is not reachable")
            return
        }
        
        session.sendMessage(message, replyHandler: replyHandler, errorHandler: errorHandler)
    }
    
    func startWorkoutSession(workoutType: String) {
        let message: [String: Any] = [
            "action": "startWorkout",
            "workoutType": workoutType
        ]
        
        sendMessageToWatch(message) { reply in
            DispatchQueue.main.async {
                if let success = reply["success"] as? Bool, success {
                    self.workoutSessionActive = true
                    self.workoutType = workoutType
                }
            }
        } errorHandler: { error in
            print("Failed to start workout: \(error.localizedDescription)")
        }
    }
    
    func stopWorkoutSession() {
        let message: [String: Any] = [
            "action": "stopWorkout"
        ]
        
        sendMessageToWatch(message) { reply in
            DispatchQueue.main.async {
                if let success = reply["success"] as? Bool, success {
                    self.workoutSessionActive = false
                    self.workoutType = nil
                }
            }
        } errorHandler: { error in
            print("Failed to stop workout: \(error.localizedDescription)")
        }
    }
    
    func requestCurrentData() {
        let message: [String: Any] = [
            "action": "getCurrentData"
        ]
        
        sendMessageToWatch(message) { reply in
            DispatchQueue.main.async {
                self.updateDataFromWatch(reply)
            }
        } errorHandler: { error in
            print("Failed to get current data: \(error.localizedDescription)")
        }
    }
    
    private func updateDataFromWatch(_ data: [String: Any]) {
        if let heartRate = data["heartRate"] as? Double {
            self.currentHeartRate = heartRate
        }
        
        if let steps = data["steps"] as? Int {
            self.currentSteps = steps
        }
        
        if let activeEnergy = data["activeEnergy"] as? Double {
            self.currentActiveEnergy = activeEnergy
        }
        
        if let distance = data["distance"] as? Double {
            self.currentDistance = distance
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("WCSession activation failed: \(error.localizedDescription)")
            } else {
                print("WCSession activated successfully")
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        // Reactivate for future use
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            self.updateDataFromWatch(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async {
            self.updateDataFromWatch(message)
            
            // Send acknowledgment
            replyHandler(["received": true])
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
}
