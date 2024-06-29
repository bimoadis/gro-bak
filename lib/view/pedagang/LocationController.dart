import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  GoogleMapController? mapController;
  var selectedPosition = const LatLng(0, 0).obs;
  var userPosition = const LatLng(0, 0).obs;
  var addressMaps = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void getCurrentLocation(LatLng lokasiPesanan) async {
    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    this.userPosition.value =
        LatLng(userPosition.latitude, userPosition.longitude);

    while (mapController == null) {
      await Future.delayed(Duration(seconds: 1));
    }
    print('${latitude.value} ${longitude.value}');
    mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 18,
        target: LatLng(lokasiPesanan.latitude, lokasiPesanan.longitude))));
  }

  void onMapTapped(LatLng position) async {
    selectedPosition.value = position;
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    print('${latitude.value} ${longitude.value}');
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    addressMaps.value =
        '${placemarks.first.name}, ${placemarks.first.street}, ${placemarks.first.locality},${placemarks.first.subAdministrativeArea}';
  }
}
