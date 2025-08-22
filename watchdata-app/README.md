# Fitness AI App

A comprehensive fitness application that integrates with Apple Watch, HealthKit, and Location Services to provide AI-powered fitness insights.

## Features

### 🏃‍♂️ Real-time Fitness Tracking
- **Apple Watch Integration**: Direct communication with Apple Watch for live fitness data
- **HealthKit Sync**: Seamless integration with Apple's Health app
- **Location Services**: GPS tracking for outdoor workouts and route mapping

### 📊 Fitness Metrics
- **Heart Rate Monitoring**: Real-time heart rate data from Apple Watch
- **Step Counting**: Daily step tracking and goals
- **Active Energy**: Calorie burn tracking during workouts
- **Distance Tracking**: GPS-based distance calculation for outdoor activities

### ⚙️ User Profile Management
- **Personal Information**: Height, weight, age, and gender settings
- **Health Data Permissions**: Easy setup for HealthKit and Location access
- **Data Synchronization**: Automatic sync between app and Health app

### 🎯 Workout Management
- **Multiple Workout Types**: Running, Walking, Cycling, Swimming, Strength Training, Yoga
- **Workout Controls**: Start/stop workout sessions from iPhone
- **Real-time Monitoring**: Live tracking of workout metrics

## Setup Requirements

### Prerequisites
- iOS 15.0+ / watchOS 8.0+
- Xcode 13.0+
- Apple Watch (for full functionality)
- Health app access

### Required Permissions
1. **HealthKit**: Access to read/write health data
2. **Location Services**: GPS access for workout tracking
3. **Watch Connectivity**: Communication with Apple Watch

### Installation
1. Clone the repository
2. Open `watchdata-app.xcodeproj` in Xcode
3. Select your development team
4. Build and run on your device

## Architecture

### Core Components

#### HealthKitManager
- Manages HealthKit permissions and data access
- Handles reading/writing health data
- Syncs user profile information

#### LocationManager
- Manages location permissions and GPS access
- Tracks workout routes and calculates distances
- Provides location-based fitness insights

#### WatchConnectivityManager
- Establishes communication with Apple Watch
- Manages workout sessions
- Receives real-time fitness data

#### FitnessDataView
- Main dashboard for fitness metrics
- Real-time data visualization
- Workout control interface

## Apple Watch Integration

### Watch App Requirements
To fully utilize the Apple Watch features, you'll need to create a companion Watch app:

1. **Create Watch App Target**:
   - Add new Watch App target in Xcode
   - Implement `WCSessionDelegate` for communication
   - Handle workout sessions and data collection

2. **Watch App Features**:
   - Heart rate monitoring
   - Step counting
   - Workout session management
   - Data transmission to iPhone

### Data Flow
```
Apple Watch → WatchConnectivity → iPhone App → HealthKit → ML Model
```

## HealthKit Data Types

### Read Access
- Height, Weight, Age, Gender
- Step Count, Active Energy, Heart Rate
- Workout Data, Distance

### Write Access
- Height and Weight updates
- Custom workout sessions
- Fitness metrics

## Location Services

### Usage
- **When In Use**: During workout sessions
- **Background**: Continuous tracking for long workouts
- **Route Mapping**: GPS-based workout visualization

### Privacy
- Location data is only used for fitness tracking
- No location data is stored permanently
- User controls all location permissions

## Future Enhancements

### ML Model Integration
- Fitness prediction algorithms
- Personalized workout recommendations
- Performance analytics

### Advanced Features
- Social sharing and challenges
- Integration with fitness equipment
- Advanced workout analytics
- Nutrition tracking

## Troubleshooting

### Common Issues

1. **HealthKit Not Authorized**
   - Check Health app permissions
   - Ensure app has proper entitlements
   - Verify Info.plist settings

2. **Watch Not Connecting**
   - Ensure Watch app is installed
   - Check Watch connectivity settings
   - Restart both devices if needed

3. **Location Services Not Working**
   - Verify location permissions
   - Check device location settings
   - Ensure GPS is enabled

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository or contact the development team.
