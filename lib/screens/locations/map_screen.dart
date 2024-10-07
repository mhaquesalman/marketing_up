import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marketing_up/models/location_model.dart';

class MapScreen extends StatefulWidget {

  List<LocationModel>? locations;

  MapScreen({super.key, this.locations});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const place = LatLng(23.737789, 90.401332);
  LatLng? firstPlace;
  Iterable markers = [];

  @override
  void initState() {

    if (widget.locations != null) {
      firstPlace = LatLng(
        double.parse(widget.locations![0].latPosition),
        double.parse(widget.locations![0].lonPosition),
      );

      markers = Iterable.generate(widget.locations!.length, (index) {
        return Marker(
            markerId: MarkerId(widget.locations![index].id!),
            icon: BitmapDescriptor.defaultMarker,
            position: LatLng(
              double.parse(widget.locations![index].latPosition),
              double.parse(widget.locations![index].lonPosition),
            ),
            infoWindow: InfoWindow(
                title: widget.locations![index].areaName)
        );
      });

    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: firstPlace ?? place,
          zoom: 13
        ),
      markers: widget.locations != null ?  Set.from(markers)
      : {
        const Marker(
            markerId: MarkerId("marker_id"),
            icon: BitmapDescriptor.defaultMarker,
            position: place,
            infoWindow: InfoWindow(title: "This is marker")
        )
      },
    );
  }
}
