import 'dart:math';

class FakeLocation {
  final String name;
  final double latitude;
  final double longitude;

  const FakeLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Ho Chi Minh City coordinates (starting point)
  static const hoChiMinhCity = FakeLocation(
    name: 'Ho Chi Minh City',
    latitude: 10.8231,
    longitude: 106.6297,
  );

  // List of destinations
  static const destinations = [
    FakeLocation(name: 'Hanoi', latitude: 21.0285, longitude: 105.8542),
    FakeLocation(name: 'Da Nang', latitude: 16.0544, longitude: 108.2022),
    FakeLocation(name: 'Nha Trang', latitude: 12.2388, longitude: 109.1967),
    FakeLocation(name: 'Can Tho', latitude: 10.0452, longitude: 105.7469),
    FakeLocation(name: 'Vung Tau', latitude: 10.3460, longitude: 107.0843),
  ];
}

/// Fake GPS drift service to simulate GPS position errors when standing still
class FakeLocationService {
  // Simulate GPS drift: add 0.5-2 meters of random movement every 5 seconds
  // This simulates GPS position errors when the device is stationary
  static double simulateGpsDrift() {
    final random = Random();
    // Generate random drift between 0.5m and 2.0m every 5 seconds
    return 0.5 + random.nextDouble() * 1.5;
  }
  
  // Calculate distance in meters using Haversine formula
  static double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    const earthRadiusM = earthRadiusKm * 1000; // Convert to meters

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusM * c;
  }
  // Calculate distance in kilometers using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  // Calculate distance from Ho Chi Minh City to destination
  static double getDistanceToDestination(FakeLocation destination) {
    return calculateDistance(
      FakeLocation.hoChiMinhCity.latitude,
      FakeLocation.hoChiMinhCity.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  // Calculate average speed in km/h (for demo, we use fake instant movement)
  static double calculateAverageSpeed(double distanceKm, Duration duration) {
    if (duration.inSeconds == 0) return 0.0;
    
    final hours = duration.inSeconds / 3600.0;
    if (hours == 0) return 0.0;
    
    return distanceKm / hours;
  }

  // Simple calorie calculation based on distance and body weight
  static double calculateCalories(
    double distanceKm,
    double weightKg,
    bool isMale,
  ) {
    // Basic formula: calories = distance * weight * calorie factor
    // Factor: 0.65 for running (average)
    final calorieFactor = 0.65;
    return distanceKm * weightKg * calorieFactor;
  }
}
