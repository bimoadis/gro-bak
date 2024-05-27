import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RutePedagang extends StatefulWidget {
  final List<dynamic> seluruhRute;
  final double longitude;
  final double latitude;
  final String namaUsaha;
  final String namaPemilik;

  const RutePedagang(
      {Key? key,
      required this.seluruhRute,
      required this.longitude,
      required this.latitude,
      required this.namaUsaha,
      required this.namaPemilik})
      : super(key: key);

  @override
  State<RutePedagang> createState() => _RutePedagangState();
}

class _RutePedagangState extends State<RutePedagang> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  List<Polyline> _polylines = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rute Pedagang"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitude),
                zoom: 15,
              ),
              markers: Set<Marker>.from(_markers),
              polylines: Set<Polyline>.of(_polylines),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _addInitialMarker();
                _fetchAndAddPolylines();
              },
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              compassEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          _buildDetailsContainer()
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _addMarkers(widget.seluruhRute);
  }

  void _addInitialMarker() {
    LatLng initialPosition = LatLng(widget.latitude, widget.longitude);
    Marker marker = Marker(
      markerId: MarkerId('initial_position'),
      position: initialPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers.add(marker);
    });

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
          icon: BitmapDescriptor.defaultMarker,
        );
        markers.add(marker);
      }
    }

    setState(() {
      _markers.addAll(markers);
    });
  }

  Future<List<LatLng>> _fetchPolylinePoints(
      double latitude, double longitude) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyAtpOTREuiLvV0d1i627qgDPyvElEdogLs', // Replace with your Google Maps API Key
      PointLatLng(widget.latitude, widget.longitude),
      PointLatLng(latitude, longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    return polylineCoordinates;
  }

  Future<void> _fetchAndAddPolylines() async {
    for (var route in widget.seluruhRute) {
      if (route['latitude'] != null && route['longitude'] != null) {
        List<LatLng> polylineCoordinates =
            await _fetchPolylinePoints(route['latitude'], route['longitude']);
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

    setState(() {
      _polylines.add(polyline);
    });
  }

  Widget _buildDetailsContainer() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
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
                          height: 40,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          widget.namaPemilik,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          widget.namaUsaha,
                          style: TextStyle(
                            fontSize: 11,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Do something with the entire route data
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                child: Text('Track'),
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
    );
  }
}
