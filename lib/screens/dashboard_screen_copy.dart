import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/screens/login_screen_copy.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/screens/add_employee_screen.dart';
import 'package:marketing_up/screens/register_screen.dart';
import 'package:marketing_up/utils.dart';
import 'package:marketing_up/visitmodel.dart';
import 'package:marketing_up/widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

class DashboardScreenCopy extends StatefulWidget {
  final UserModel? userModel;
  DashboardScreenCopy({super.key, this.userModel});

  @override
  State<DashboardScreenCopy> createState() => _DashboardScreenCopyState();
}

class _DashboardScreenCopyState extends State<DashboardScreenCopy> {

  late String userType;
  late String createdBy;
  late String id;
  List<UserModel>? employees;
  Position? position;
  List<Position> listOfPositions = [];
  Placemark? placemark;
  String address = "";
  String? loginTime;
  late StreamSubscription<Position> streamSubscription;
  DateFormat dateFormat = DateFormat("MMM dd - yyyy, h:mm a");

  Future<void> fetchData() async {
    employees = await context.read<FirebaseProvider>().getUsersByCreatedBy(id);
    print("employees: ${employees!.length}");
  }

  void trackLocation() async {
    position = await Utils().getCurrentLocation();
    print("position from main: $position");
    // placemark = await Utils().getAddressFromLatLon(position!.latitude, position!.longitude);
    // String address = await Utils().getPlacemarks(23.737789, 90.401332);
    address = await Utils().getPlacemarks(position!.latitude, position!.longitude);
    initWorkmanagerToFetchLocation();
    liveLocation();
  }

  void liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        // timeLimit: Duration(minutes: 10)
    );

    streamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position pos) {
          print("lat: ${pos.latitude}");
          print("lon: ${pos.longitude}");
          listOfPositions.add(pos);
          // workWithLatestPosition(pos);
    });

  }

  void workWithLatestPosition(Position pos) async {
    bool hasConnection = await Utils.checkInternet();
    if (hasConnection) {
      if (loginTime != null) {
        final loginTimeWithSixHoursExtra = DateTime.parse(loginTime!).add(const Duration(hours: 6));
        bool isTimeOver = DateTime.now().isAfter(loginTimeWithSixHoursExtra);
        if (isTimeOver) {
          // save in remote
          // save last 3 data if list is big
          final newList = listOfPositions.length > 3 ? listOfPositions.sublist(listOfPositions.length - 3) : listOfPositions;
          newList.forEach((element) {

          });
        } else {
          // save in local
        }
      } else {
        // save in remote
      }
    } else {
      // save in local
    }
  }

  void initWorkmanagerToFetchLocation() async {
    await Workmanager().registerPeriodicTask(
        Constants.LocationFetchUniqueName,
        Constants.LocationFetchTaskName,
        frequency: const Duration(minutes: 15),
        initialDelay: const Duration(seconds: 10),
        inputData: {Constants.FirebaseUserId: widget.userModel!.id,
          Constants.FirebaseCompanyId: widget.userModel!.companyId}
    );

    // await Workmanager().registerOneOffTask(
    //     Constants.LocationFetchUniqueName2,
    //     Constants.LocationFetchTaskName2,
    //     initialDelay: const Duration(seconds: 10),
    //     inputData: {"latitude": position?.latitude ?? 1.1, "longitude": position?.longitude ?? 2.2}
    // );
  }

  @override
  void initState() {
    loginTime = context.read<FirebaseProvider>().getEmployeeLoginTimeFromSharedPref();
    userType = widget.userModel!.userType;
    createdBy = widget.userModel!.createdBy;
    id = widget.userModel!.id!;
    // print("usermodel: ${widget.userModel}");
    // ideal for calling provider from initstate
    if (userType == Constants.DefaultEmployeeType) {
      trackLocation();
    }
    Future.microtask(() => fetchData());
    super.initState();
  }

  void cancelWorkmanager() async {
    print("workmanager canceled");
    await Workmanager().cancelByUniqueName(Constants.LocationFetchUniqueName);
  }
  @override
  void dispose() {
    cancelWorkmanager();
    streamSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // String userType = context.watch<AppProvider>().userType;
    // print("type from provider: ${userType}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              onPressed: () async {
                context.read<FirebaseProvider>().resetStatus();
                context.read<FirebaseProvider>().logout(userType);
                context.read<AppProvider>().setCurrentPage(CurrentPage.LoginScreen);
                await Workmanager().cancelByUniqueName(Constants.LocationFetchUniqueName);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreenCopy()),
                        (Route<dynamic> route) => false);
              },
              icon: Icon(Icons.logout)
          )
        ],
      ),
      drawer: DrawerWidget(userModel: widget.userModel,),
      floatingActionButton: userType == Constants.DefaultUserType ? FloatingActionButton(
        onPressed: () {
          goToEmployeeScreen(userM: widget.userModel);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ) : null,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer<FirebaseProvider>(
                  builder: (context, provider, child) {
                    if (provider.status == Status.Loading) {
                      return Center(child: CircularProgressIndicator(),);
                    } else if (provider.status == Status.Error) {
                      return Center(child: Text(provider.responseMsg),);
                    } else if (provider.status == Status.Fail) {
                      if (userType == Constants.DefaultUserType)
                        return Center(child: Text(provider.responseMsg),);
                      else
                        return Center(child: Text("Logged in as an employee"),);
                    } else {
                      if (employees == null) return Center(child: Text(provider.responseMsg),);
                      return ListView.builder(
                        itemCount: employees!.length,
                        itemBuilder: (ctx, index) {
                          UserModel employeeData = employees![index];
                          return buildEmployeeList(employeeData);
                        },
                      );
                    }
                  },
                ),
              )
            ],
          )
        ],
      )
    );
  }

  void goToEmployeeScreen({UserModel? userM, bool? edit}) {
    context.read<FirebaseProvider>().resetStatus();
    context.read<AppProvider>().setCurrentPage(CurrentPage.EditEmployeeScreen);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AddEmployeeScreen(userModel: userM, isEdit: edit, refetch: fetchData,)
    ));
  }

  buildEmployeeList(UserModel employeeModel) {
        return Container(
          margin: EdgeInsets.all(10),
          child: InkWell(
            onTap: () {
              goToEmployeeScreen(userM: employeeModel, edit: true);
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 60,
                  child: Padding(
                    padding: const EdgeInsets.all(8), // Border radius
                    child: ClipOval(child: Image.memory(base64Decode(employeeModel.userPhoto), fit: BoxFit.fill,),
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(
                            employeeModel.fullName,
                            style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                          ),
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            employeeModel.email,
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 1,
                          ),
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            employeeModel.phoneNumber,
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 1,
                          ),
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            employeeModel.activeStatus ? "Status:  Active" : "Status: Inactive",
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            maxLines: 1,
                          ),
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            dateFormat.format(employeeModel.createdAt),
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            maxLines: 1,
                          ),
                          margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );

  }
}


