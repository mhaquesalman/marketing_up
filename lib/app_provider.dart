import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketing_up/drawer_widget.dart';

const String ADMIN_EMAIL = "admin@hrsoftbd.com";

class AppProvider with ChangeNotifier {
  String _userType = "";
  String get userType => _userType;
  CurrentPage currentPage = CurrentPage.DashboardScreen;

  void setUserType(String type) {
    _userType = type;
    notifyListeners();
  }

  void setCurrentPage(CurrentPage currentPage) {
    this.currentPage = currentPage;
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error("Location is disabled");

    LocationPermission locationPermission =
        await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error("Permission is denied");
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error("Can not access location");
    }

    return await Geolocator.getCurrentPosition();
  }
  
}