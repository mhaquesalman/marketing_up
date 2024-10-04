import 'package:geolocator/geolocator.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/helper/database_helper.dart';
import 'package:marketing_up/models/location_model.dart';
import 'package:marketing_up/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() async {
  Workmanager().executeTask((taskName, inputData) async {
    print("workmanager name: ${taskName}");
    print("workmanager input data: ${inputData}");
    print("worker running");
    Position position = await Utils().getCurrentLocation();
    String address = await Utils().getPlacemarks(position.latitude, position.longitude);
    print("workmanager position: $position");

    LocationModel lm = LocationModel(
        areaName: address,
        companyId: inputData?[Constants.FirebaseCompanyId],
        createdBy: inputData?[Constants.FirebaseUserId],
        createdTime: DateTime.now(),
        latPosition: position.latitude.toString(),
        lonPosition: position.longitude.toString(),
        streetAddress: address,
        online: false
    );
    print("locationmodel: $lm");

    try {
    // final result = await DatabaseHelper.getInstance().insertLocation(lm);
    print("worker running after insertion: ");
    return Future.value(true);
    } catch (err) {
      return Future.value(false);
    }

  });

}