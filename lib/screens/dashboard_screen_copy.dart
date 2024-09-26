import 'package:flutter/material.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/login_screen_copy.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/screens/add_employee_screen.dart';
import 'package:marketing_up/screens/register_screen.dart';
import 'package:marketing_up/visitmodel.dart';
import 'package:marketing_up/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class DashboardScreenCopy extends StatefulWidget {
  final UserModel? userModel;
  DashboardScreenCopy({super.key, this.userModel});

  @override
  State<DashboardScreenCopy> createState() => _DashboardScreenCopyState();
}

class _DashboardScreenCopyState extends State<DashboardScreenCopy> {

  late String userType = widget.userModel?.userType ?? "";

  @override
  void initState() {
    print("usermodel: ${widget.userModel}");
    super.initState();
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
              onPressed: () {
                context.read<FirebaseProvider>().logout(userType);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreenCopy()),
                        (Route<dynamic> route) => false);
              },
              icon: Icon(Icons.logout)
          )
        ],
      ),
      drawer: DrawerWidget(),
      floatingActionButton: userType == Constants.DefaultUserType ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddEmployeeScreen(userModel: widget.userModel,)
          ));
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ) : null,
      body: Column(
        children: [
          Text("${widget.userModel?.companyUserLimit}"),
          Text("${widget.userModel?.companyVisitLimit}")
        ],
      ),
    );
  }
}


