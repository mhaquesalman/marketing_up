import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<Position> _position;
  late WebViewController controller;
  
  Future<void> openMap(String lat, String lon) async {
    String mapUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lon";
    await canLaunchUrlString(mapUrl)
        ? await launchUrlString(mapUrl)
        : throw "Could not launch";
  }

  @override
  void initState() {
    _position = context.read<AppProvider>().getCurrentLocation();
    controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder<Position>(
      future: _position,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          double lat = snapshot.data?.latitude ?? 0.0000;
          double lon = snapshot.data?.longitude ?? 0.0000;
          String mapUrl =
              "https://www.google.com/maps/search/?api=1&query=$lat,$lon";

          controller.loadRequest(Uri.parse(mapUrl));

          return Expanded(child: WebViewWidget(controller: controller));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("error: ${snapshot.error.toString()}"),
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }
}
