import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_up/add_visit_screen.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/dashboard_screen.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/location_screen.dart';
import 'package:marketing_up/login_screen.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/screens/add_visit_screen_copy.dart';
import 'package:marketing_up/screens/dashboard_screen_copy.dart';
import 'package:marketing_up/screens/location_screen_copy.dart';
import 'package:marketing_up/screens/login_screen_copy.dart';
import 'package:marketing_up/screens/visit_list_screen_copy.dart';
import 'package:marketing_up/visit_list_screen.dart';
import 'package:marketing_up/webview_screen.dart';
import 'package:marketing_up/widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';



const url =
    "https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg";

class DrawerWidget extends StatefulWidget {
  UserModel? userModel;

  DrawerWidget({super.key, this.userModel});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  // late CurrentPage currentPage;

  void goToScreen(String screen, CurrentPage currentPage) {
    context.read<FirebaseProvider>().resetStatus();
    Navigator.pop(context);
    switch (screen) {
      case "add": {
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => AddVisitScreenCopy(userModel: widget.userModel,))
        // );
        if (currentPage != CurrentPage.DashboardScreen){
          // Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AddVisitScreenCopy(userModel: widget.userModel,))
          );
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) =>
                  AddVisitScreenCopy(userModel: widget.userModel,))
          );
        }
        context.read<AppProvider>().setCurrentPage(CurrentPage.AddVisitScreen);
        break;
      }
      case "lists": {
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => VisitListScreenCopy(userModel: widget.userModel,))
        // );
        if (currentPage != CurrentPage.DashboardScreen) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => VisitListScreenCopy(userModel: widget.userModel,))
          );
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) =>
                  VisitListScreenCopy(userModel: widget.userModel,))
          );
        }
        context.read<AppProvider>().setCurrentPage(CurrentPage.VisitListScreen);
        break;
      }
      case "dashboard": {
        // Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => DashboardScreenCopy(userModel: widget.userModel,))
        // );
        Navigator.popUntil(context, ModalRoute.withName("dashboard"));
        context.read<AppProvider>().setCurrentPage(CurrentPage.DashboardScreen);
        break;
      }
      case "logout": {
        // Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreenCopy()),
                (Route<dynamic> route) => false);
        context.read<AppProvider>().setCurrentPage(CurrentPage.LoginScreen);
        break;
      }
      case "location": {
        if (currentPage != CurrentPage.DashboardScreen) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LocationScreenCopy(userModel: widget.userModel,))
          );
        } else {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) =>
                  LocationScreenCopy(userModel: widget.userModel,))
          );
        }
        context.read<AppProvider>().setCurrentPage(CurrentPage.LocationScreen);
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String userType = widget.userModel!.userType;
    CurrentPage currentPage = context.watch<AppProvider>().currentPage;
    UserModel? loggedInUser = context.read<FirebaseProvider>().loggedInUserModel;

    print("current page: ${currentPage}");

    return SafeArea(
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(loggedInUser?.fullName ?? ""),
              accountEmail: Text(loggedInUser?.email ?? ""),
              currentAccountPicture: CircleAvatar(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: loggedInUser?.userPhoto != null
                      ? Image.memory(
                    base64Decode(loggedInUser?.userPhoto ?? ""),
                    height: 150,
                    width: 150,
                  ) : Image.network(
                    url,
                    height: 150,
                    width: 150,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                  gradient: gradientBackground(),
                  borderRadius:BorderRadius.only(topRight: Radius.circular(10))
              ),
            ),
            ListTile(
              title: Text("Dashboard".toUpperCase(), style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
              textColor: currentPage == CurrentPage.DashboardScreen ? Colors.redAccent : Colors.black,
              onTap:  () {
                if (currentPage == CurrentPage.DashboardScreen) return;
                goToScreen("dashboard", currentPage);
              },
            ),
            ListTile(
              title: Text("Visit List".toUpperCase(), style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
              textColor: currentPage == CurrentPage.VisitListScreen ? Colors.redAccent : Colors.black,
              onTap: () {
                if (currentPage == CurrentPage.VisitListScreen) return;
                goToScreen("lists", currentPage);
              },
            ),
            ListTile(
              title: Text(currentPage == CurrentPage.EditVisitScreen ? "Edit Visit".toUpperCase() : "Add Visit".toUpperCase(),
                  style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
              textColor: currentPage == CurrentPage.AddVisitScreen || currentPage == CurrentPage.EditVisitScreen
                  ? Colors.redAccent : Colors.black,
              onTap: () {
                if (currentPage == CurrentPage.AddVisitScreen || currentPage == CurrentPage.EditVisitScreen) return;
                goToScreen("add", currentPage);
              },
            ),
            userType == Constants.DefaultUserType ? ListTile(
              title: Text("Locations".toUpperCase(),
                style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
              textColor: currentPage == CurrentPage.LocationScreen ? Colors.redAccent : Colors.black,
              onTap: () {
                if (currentPage == CurrentPage.LocationScreen) return;
                goToScreen("location", currentPage);
              },
            ) : SizedBox.shrink(),
            ListTile(
              title: Text("Logout".toUpperCase(), style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
              onTap: () {
                context.read<FirebaseProvider>().resetStatus();
                context.read<FirebaseProvider>().logout(loggedInUser!.userType);
                goToScreen("logout", currentPage);
              },
            )
          ],
        ),
      ),
    );
  }
}