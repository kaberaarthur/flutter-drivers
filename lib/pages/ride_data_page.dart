import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDataPage extends StatefulWidget {
  const RideDataPage({Key? key}) : super(key: key);

  @override
  _RideDataPageState createState() => _RideDataPageState();
}

class _RideDataPageState extends State<RideDataPage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchRideData();
  }

  void _fetchRideData() async {
    try {
      final DocumentSnapshot rideData = await FirebaseFirestore.instance
          .collection('rides')
          .doc('kdcXfX6ah6wYKcNwZPT7')
          .get();

      if (rideData.exists) {
        final Map<String, dynamic>? rideDataMap =
            rideData.data() as Map<String, dynamic>?;
        if (rideDataMap != null) {
          final rideOrigin = rideDataMap['rideOrigin'];
          final rideDestination = rideDataMap['rideDestination'];
          if (rideOrigin != null && rideDestination != null) {
            // Add markers for origin and destination
            _markers.add(Marker(
              markerId: MarkerId('origin'),
              position: LatLng(
                rideOrigin[0]['location']['lat'],
                rideOrigin[0]['location']['lng'],
              ),
              infoWindow: InfoWindow(title: 'Origin'),
            ));
            _markers.add(Marker(
              markerId: MarkerId('destination'),
              position: LatLng(
                rideDestination[0]['location']['lat'],
                rideDestination[0]['location']['lng'],
              ),
              infoWindow: InfoWindow(title: 'Destination'),
            ));

            // Move camera to the origin
            _mapController.moveCamera(CameraUpdate.newLatLng(
              LatLng(
                rideOrigin[0]['location']['lat'],
                rideOrigin[0]['location']['lng'],
              ),
            ));
          }
        }
      }
    } catch (error) {
      debugPrint('Error fetching ride data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Data'),
        backgroundColor: Colors.amber[700],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0), // Initial center of the map
              zoom: 10, // Initial zoom level of the map
            ),
            markers: _markers,
            polylines: {
              const Polyline(
                polylineId: PolylineId('path'),
                color: Colors.black,
                points: [
                  LatLng(0, 0), // Origin (placeholder)
                  LatLng(0, 0), // Destination (placeholder)
                ],
              ),
            },
          ),
          if (_markers.isEmpty)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
