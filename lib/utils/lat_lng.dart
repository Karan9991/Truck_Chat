import 'package:chat/utils/constants.dart';
import 'package:location/location.dart';

Future<Map<String, double>> getLocation() async {
  Location location = Location();
  LocationData? currentLocation;

  // Request location permission
  PermissionStatus? permissionStatus;
  permissionStatus = await location.requestPermission();
  if (permissionStatus != PermissionStatus.granted) {
    // Handle permission not granted
    throw Exception('Location permission not granted');
  }

  // Fetch current location
  try {
    currentLocation = await location.getLocation();
    double latitude = currentLocation.latitude!;
    double longitude = currentLocation.longitude!;
    return {Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude};
  } catch (e) {
    // Handle location fetch error
    throw Exception('Error fetching location: $e');
  }
}
