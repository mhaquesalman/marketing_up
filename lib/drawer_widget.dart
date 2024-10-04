import 'package:flutter/material.dart';
import 'package:marketing_up/add_visit_screen.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/dashboard_screen.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/location_screen.dart';
import 'package:marketing_up/login_screen.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/screens/add_visit_screen_copy.dart';
import 'package:marketing_up/screens/dashboard_screen_copy.dart';
import 'package:marketing_up/screens/login_screen_copy.dart';
import 'package:marketing_up/screens/visit_list_screen_copy.dart';
import 'package:marketing_up/visit_list_screen.dart';
import 'package:marketing_up/webview_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'location_screen_copy.dart';

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

  void goToScreen(BuildContext context, String screen) {
    context.read<FirebaseProvider>().resetStatus();
    Navigator.pop(context);
    switch (screen) {
      case "add": {
        context.read<AppProvider>().setCurrentPage(CurrentPage.AddVisitScreen);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AddVisitScreenCopy(userModel: widget.userModel,))
        );
        break;
      }
      case "lists": {
        context.read<AppProvider>().setCurrentPage(CurrentPage.VisitListScreen);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => VisitListScreenCopy(userModel: widget.userModel,))
        );
        break;
      }
      case "dashboard": {
        context.read<AppProvider>().setCurrentPage(CurrentPage.DashboardScreen);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DashboardScreenCopy(userModel: widget.userModel,))
        );
        break;
      }
      case "location": {
        context.read<AppProvider>().setCurrentPage(CurrentPage.LocationScreen);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => LocationScreenCopy())
        );
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
    String userType = context.watch<AppProvider>().userType;
    CurrentPage currentPage = context.watch<AppProvider>().currentPage;
    print("current page: ${currentPage}");

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Jon Doe"),
            accountEmail: Text("XYZ@gmail.com"),
            currentAccountPicture: CircleAvatar(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  url,
                  height: 150,
                  width: 150,
                ),
              ),
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor
            ),
          ),
          ListTile(
            title: Text("Dashboard"),
            textColor: currentPage == CurrentPage.DashboardScreen ? Colors.redAccent : Colors.black,
            onTap:  () {
              if (currentPage == CurrentPage.DashboardScreen) return;
              goToScreen(context, "dashboard");
            },
          ),
          ListTile(
            title: Text("Visit List"),
            textColor: currentPage == CurrentPage.VisitListScreen ? Colors.redAccent : Colors.black,
            onTap: () {
              if (currentPage == CurrentPage.VisitListScreen) return;
              goToScreen(context, "lists");
            },
          ),
          ListTile(
            title: Text(currentPage == CurrentPage.EditVisitScreen ? "Edit Visit" : "Add Visit"),
            textColor: currentPage == CurrentPage.AddVisitScreen || currentPage == CurrentPage.EditVisitScreen
                ? Colors.redAccent : Colors.black,
            onTap: () {
              if (currentPage == CurrentPage.AddVisitScreen || currentPage == CurrentPage.EditVisitScreen) return;
              goToScreen(context, "add");
            },
          ),
          userType == "ADMIN" ? ListTile(
            title: Text("Locations"),
            textColor: currentPage == CurrentPage.LocationScreen ? Colors.redAccent : Colors.black,
            onTap: () {
              if (currentPage == CurrentPage.LocationScreen) return;
              // goToScreen(context, "location");
            },
          ) : SizedBox.shrink(),
          ListTile(
            title: Text("Logout"),
            onTap: () {
              context.read<FirebaseProvider>().resetStatus();
              context.read<FirebaseProvider>().logout(widget.userModel!.userType);
              context.read<AppProvider>().setCurrentPage(CurrentPage.LoginScreen);
              // Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreenCopy()),
                      (Route<dynamic> route) => false);
            },
          )
        ],
      ),
    );
  }
}