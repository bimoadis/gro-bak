import 'dart:async';
import 'package:geolocator/geolocator.dart';

// Callback untuk posisi
typedef PositionCallback = Function(Position position);

class GPS {
  late StreamSubscription<Position> _positionSubscription;
  // Properti untuk stream posisi pengguna
  late Stream<Position> positionStream;

  GPS() {
    // Inisialisasi stream posisi
    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );
  }

  // Memeriksa apakah izin lokasi telah diberikan
  bool isAccessGranted(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Meminta izin lokasi dari pengguna
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (isAccessGranted(permission)) {
      return true;
    }

    permission = await Geolocator.requestPermission();
    return isAccessGranted(permission);
  }

  // Memulai stream posisi dengan callback
  Future<void> startPositionStream(PositionCallback callback) async {
    bool permissionGranted = await requestPermission();
    if (!permissionGranted) {
      throw Exception("User did not grant the location permission.");
    }

    // Mulai mendengarkan stream posisi dengan callback
    _positionSubscription = positionStream.listen(callback);
  }

  // Menghentikan stream posisi
  Future<void> stopPositionStream() async {
    if (_positionSubscription != null) {
      await _positionSubscription.cancel();
    }
  }
}
