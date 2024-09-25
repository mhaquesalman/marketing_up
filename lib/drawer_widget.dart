import 'package:flutter/material.dart';
import 'package:marketing_up/add_visit_screen.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/dashboard_screen.dart';
import 'package:marketing_up/location_screen.dart';
import 'package:marketing_up/login_screen.dart';
import 'package:marketing_up/visit_list_screen.dart';
import 'package:marketing_up/webview_screen.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'location_screen_copy.dart';

const url =
    "https://static.vecteezy.com/system/resources/thumbnails/002/002/403/small/man-with-beard-avatar-character-isolated-icon-free-vector.jpg";

enum CurrentPage {
  DashboardScreen,
  AddVisitScreen,
  VisitListScreen,
  LocationScreen
}

class DrawerWidget extends StatefulWidget {
  DrawerWidget({super.key,});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  // late CurrentPage currentPage;

  void goToScreen(BuildContext context, String screen) {
    Navigator.pop(context);
    switch (screen) {
      case "add": {
        context.read<AppProvider>().setCurrentPage(CurrentPage.AddVisitScreen);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddVisitScreen())
        );
        break;
      }
      case "lists": {
        context.read<AppProvider>().setCurrentPage(CurrentPage.VisitListScreen);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => VisitListScreen())
        );
        break;
      }
      case "dashboard": {
        context.read<AppProvider>().setCurrentPage(CurrentPage.DashboardScreen);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DashboardScreen())
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
            title: Text("Add Visit"),
            textColor: currentPage == CurrentPage.AddVisitScreen ? Colors.redAccent : Colors.black,
            onTap: () {
              if (currentPage == CurrentPage.AddVisitScreen) return;
              goToScreen(context, "add");
            },
          ),
          userType == "ADMIN" ? ListTile(
            title: Text("Locations"),
            textColor: currentPage == CurrentPage.LocationScreen ? Colors.redAccent : Colors.black,
            onTap: () {
              if (currentPage == CurrentPage.LocationScreen) return;
              goToScreen(context, "location");
            },
          ) : SizedBox.shrink(),
          ListTile(
            title: Text("Setting"),
            onTap: () {},
          ),
          ListTile(
            title: Text("Logout"),
            onTap: () {
              // Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false);
            },
          )
        ],
      ),
    );
  }
}