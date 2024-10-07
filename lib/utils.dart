import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Utils {

  static void showSnackbar(BuildContext context, String text, {int duration = 3}) {
    final snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: duration),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<String> convertImageToBase64(File imageFile) async {
    Uint8List imagebytes = await imageFile.readAsBytes(); //convert to bytes
    String base64string =
    base64.encode(imagebytes); //convert bytes to base64 string
    // print(base64string);
    return base64string;
  }

  static String encryptPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<bool> checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      return true;
    } else {
      return false;
    }
  }

  StreamSubscription<ConnectivityResult> internetListener({required Function(ConnectivityResult result) onConnectionCheck} ) {
    return Connectivity().onConnectivityChanged.listen((result) {
      onConnectionCheck(result);
    });
  }


  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error("Location is disabled please enable location");

    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error("Permission is denied");
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error("Can not access location without permission");
    }

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return pos;
  }

  Future<Placemark?> getAddressFromLatLon(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      // print("List of places: $placemarks");
      return placemarks[0];
    } catch (err) {
      print("place error" + err.toString());
      return null;
    }
  }

  Future<String> getPlacemarks(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      var address = '';

      if (placemarks.isNotEmpty) {

        // Concatenate non-null components of the address
        var streets = placemarks.reversed
            .map((placemark) => placemark.street)
            .where((street) => street != null);

        // Filter out unwanted parts
        streets = streets.where((street) =>
        street!.toLowerCase() !=
            placemarks.reversed.last.locality!
                .toLowerCase()); // Remove city names
        streets =
            streets.where((street) => !street!.contains('+')); // Remove street codes

        address += streets.join(', ');

        address += ', ${placemarks.reversed.last.subLocality ?? ''}';
        address += ', ${placemarks.reversed.last.locality ?? ''}';
        address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
        address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
        // address += ', ${placemarks.reversed.last.postalCode ?? ''}';
        // address += ', ${placemarks.reversed.last.country ?? ''}';
      }

      print("Your Address for ($lat, $long) is: $address");

      return address;
    } catch (e) {
      print("Error getting placemarks: $e");
      return "No Address";
    }
  }

}