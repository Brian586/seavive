import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:seavive/config.dart';
import 'package:seavive/widgets/ProgressWidget.dart';

import '../commonFunctions/locationAPI.dart';
import '../models/Vive.dart';
import '../models/locationInfo.dart';

class MapsDisplay extends StatefulWidget {
  const MapsDisplay({Key? key}) : super(key: key);

  @override
  State<MapsDisplay> createState() => _MapsDisplayState();
}

class _MapsDisplayState extends State<MapsDisplay> {
  bool loading = false;
  Completer<GoogleMapController> _controller = Completer();
  LatLng latLng = LatLng(-4.0443339, 39.6590738);
  // created empty list of markers
  final List<Marker> _markers = <Marker>[];

  // created list of coordinates of various locations
  // final List<LatLng> _latLens = List.generate(vives.length, (index)
  //      => LatLng(vives[index].latitude!, vives[index].longitude!));


  @override
  void initState() {
    super.initState();

    getUserLocation();
  }

  // created method for displaying custom markers according to index
  loadData() async{
    for (var vive in vives) {
      _markers.add(Marker(
        // given marker id
        markerId: MarkerId(vive.id!),
        onTap: ()=> _animateToPosition(vive.latitude!, vive.longitude!),
        // given marker icon
        //icon: BitmapDescriptor.fromBytes(markIcons),
        // given position
        position: LatLng(vive.latitude!, vive.longitude!),
        infoWindow: InfoWindow(
          // given title for marker
          title: "Vive No. " + vive.id!,
          snippet: "Sea Temperature: ${vive.temperature} \u2103, Estimated Fish Population: ${vive.population}"
        ),
      ));
    }
  }

  Future<void> getUserLocation() async {
    setState(() {
      loading = true;
    });

    await loadData();

    try {
      Position position = await LocationAPI().determinePosition();

      // int timestamp = DateTime.now().millisecondsSinceEpoch;
      //
      // LocationInfo locationInfo = LocationInfo(
      //   locationID: timestamp.toString(),
      //   latitude: position.latitude,
      //   longitude: position.longitude,
      //   timestamp: timestamp,
      // );
      //
      // String userID =
      // Provider.of<SeaVive>(context, listen: false).account.userID!;
      //
      // await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc(userID)
      //     .collection("location")
      //     .doc(locationInfo.locationID)
      //     .set(locationInfo.toMap())
      //     .then((value) =>
      //     print("Location: ${position.latitude}, ${position.longitude}"));

      setState(() {
        loading = false;
        latLng = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "ERROR: Could not get location");

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "SeaVive",
          style: GoogleFonts.pacifico(color: Colors.white ),
        ),
      ),
      body: loading ? circularProgress() : SizedBox(
        height: size.height,
        width: size.width,
        child: GoogleMap(
          mapType: MapType.hybrid,
          markers: Set<Marker>.of(_markers),
          initialCameraPosition: CameraPosition(
            target: latLng,
            zoom: 14.4746,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }

  void _animateToPosition(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;

    CameraPosition _newPosition = CameraPosition(
        target: LatLng(lat, long),
        zoom: 15);

    controller.animateCamera(CameraUpdate.newCameraPosition(_newPosition));
  }
}
