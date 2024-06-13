import 'package:geolocator/geolocator.dart';

Future<double> calculateDistance(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude) async {
  double distanceInMeters = await Geolocator.distanceBetween(
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
  );
  return distanceInMeters;
}
