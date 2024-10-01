import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';


const String ADMIN_EMAIL = "admin@hrsoftbd.com";
enum CurrentPage {
  LoginScreen,
  RegisterScreen,
  EditEmployeeScreen,
  DashboardScreen,
  AddVisitScreen,
  EditVisitScreen,
  VisitListScreen,
  LocationScreen,
  LogoutScreen,
}


class AppProvider with ChangeNotifier {
  String _userType = "";
  String get userType => _userType;
  Position? _position;
  Position? get position => _position;
  CurrentPage currentPage = CurrentPage.LoginScreen;

  void setUserType(String type) {
    _userType = type;
    notifyListeners();
  }

  void setCurrentPage(CurrentPage currentPage) {
    this.currentPage = currentPage;
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

    Position pos = await Geolocator.getCurrentPosition();
    _position = pos;
    return pos;
  }
  
}