import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gro_bak/view/list_menu_pembeli.dart';

class RutePedagang extends StatefulWidget {
  final List<dynamic> seluruhRute;
  final List<dynamic> menu;
  final String namaUsaha;
  final String namaPemilik;
  final String uidPedagang;
  final String uidPembeli;

  const RutePedagang(
      {Key? key,
      required this.menu,
      required this.seluruhRute,
      required this.namaUsaha,
      required this.namaPemilik,
      required this.uidPedagang,
      required this.uidPembeli})
      : super(key: key);

  @override
  State<RutePedagang> createState() => _RutePedagangState();
}

class _RutePedagangState extends State<RutePedagang> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  List<Polyline> _polylines = [];
  Map<String, dynamic>? _merchantData;
  Timer? _timer;

  // Ikon kustom
  BitmapDescriptor? shoppingCartIcon;
  BitmapDescriptor? martIcon;

  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcons();
    _loadMerchantData();

    _addMarkers(widget.seluruhRute);
    // _startPeriodicDataLoad();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicDataLoad() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _loadMerchantData();
    });
  }

  Future<void> _loadMerchantData() async {
    try {
      DocumentSnapshot merchantDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uidPedagang)
          .get();

      if (merchantDoc.exists) {
        if (mounted) {
          setState(() {
            _merchantData = merchantDoc.data() as Map<String, dynamic>;
          });
          print(
              'User latitude and longitude: ${_merchantData?['latitude']}, ${_merchantData?['longitude']}');
          _updateInitialMarker(
              _merchantData!['latitude'], _merchantData!['longitude']);
        }
      }
    } catch (e) {
      print('Error fetching merchant data: $e');
    }
  }

  Future<void> _setCustomMarkerIcons() async {
    shoppingCartIcon =
        await _createCustomMarkerIcon('assets/images/shopping_cart.png');
    martIcon = await _createCustomMarkerIcon('assets/images/mart.png');
    if (mounted) {
      setState(() {});
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 100, // Ukuran ikon yang diinginkan
      targetHeight: 100,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? resizedData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);

    if (resizedData != null) {
      final Uint8List resizedBytes = resizedData.buffer.asUint8List();
      return BitmapDescriptor.fromBytes(resizedBytes);
    } else {
      return BitmapDescriptor.defaultMarker;
    }
  }

  void _updateInitialMarker(double latitude, double longitude) {
    LatLng newPosition = LatLng(latitude, longitude);
    Marker marker = Marker(
      markerId: MarkerId('initial_position'),
      position: newPosition,
      icon: shoppingCartIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    if (mounted) {
      setState(() {
        _markers.removeWhere(
            (marker) => marker.markerId.value == 'initial_position');
        _markers.add(marker);
      });

      _moveCamera(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    double? latitude = _merchantData?['latitude'];
    double? longitude = _merchantData?['longitude'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Rute Pedagang"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: latitude != null && longitude != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude, longitude),
                      zoom: 15,
                    ),
                    markers: Set<Marker>.from(_markers),
                    polylines: Set<Polyline>.of(_polylines),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      _addInitialMarker(latitude, longitude);
                      _fetchAndAddPolylines(latitude, longitude);
                    },
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    compassEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          _buildDetailsContainer()
        ],
      ),
    );
  }

  void _addInitialMarker(double latitude, double longitude) {
    LatLng initialPosition = LatLng(latitude, longitude);
    Marker marker = Marker(
      markerId: MarkerId('initial_position'),
      position: initialPosition,
      icon: shoppingCartIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    if (mounted) {
      setState(() {
        _markers.add(marker);
      });
    }

    _moveCamera(initialPosition);
  }

  void _moveCamera(LatLng position) async {
    if (_controller.isCompleted) {
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 18,
          ),
        ),
      );
    }
  }

  void _addMarkers(List<dynamic> seluruhRute) {
    Set<Marker> markers = Set<Marker>();

    for (var route in seluruhRute) {
      if (route['latitude'] != null && route['longitude'] != null) {
        LatLng coordinate = LatLng(route['latitude'], route['longitude']);
        Marker marker = Marker(
          markerId: MarkerId(coordinate.toString()),
          position: coordinate,
          icon: martIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue), // Gunakan ikon kustom
        );
        markers.add(marker);
      }
    }

    if (mounted) {
      setState(() {
        _markers.addAll(markers);
      });
    }
  }

  Future<List<LatLng>> _fetchPolylinePoints(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyAtpOTREuiLvV0d1i627qgDPyvElEdogLs', // Replace with your Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(endLatitude, endLongitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    return polylineCoordinates;
  }

  Future<void> _fetchAndAddPolylines(double latitude, double longitude) async {
    for (var route in widget.seluruhRute) {
      if (route['latitude'] != null && route['longitude'] != null) {
        List<LatLng> polylineCoordinates = await _fetchPolylinePoints(
            latitude, longitude, route['latitude'], route['longitude']);
        _addPolyline(polylineCoordinates);
      }
    }
  }

  void _addPolyline(List<LatLng> polylineCoordinates) {
    Polyline polyline = Polyline(
      polylineId: PolylineId(polylineCoordinates.toString()),
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );

    if (mounted) {
      setState(() {
        _polylines.add(polyline);
      });
    }
  }

  Widget _buildDetailsContainer() {
    return Expanded(
      flex: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34.0), // Set top-left corner radius
          topRight: Radius.circular(34.0), // Set top-right corner radius
        ),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Detail Pedagang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Card(
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/bakso.jpeg',
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            widget.namaPemilik,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            widget.namaUsaha,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ListMenuPesanan(
                                          menu: widget.menu,
                                          uidPedagang: widget.uidPedagang,
                                          uidPembeli: widget.uidPembeli,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Color(0xFFFEC901),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    padding:
                                        EdgeInsets.zero, // Removing all padding
                                    minimumSize:
                                        Size(50, 30), // Set a minimum size
                                    tapTargetSize: MaterialTapTargetSize
                                        .shrinkWrap, // Shrink wrap the tap target size
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0,
                                        vertical:
                                            4.0), // Add padding inside the child
                                    child: Text(
                                      'Menu',
                                      style: TextStyle(
                                        color: Color(0xFF060100),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
