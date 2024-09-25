import 'package:flutter/material.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/visitmodel.dart';
import 'package:provider/provider.dart';


import 'database_helper.dart';

class DashboardScreen extends StatefulWidget {
  final String? type;
  DashboardScreen({super.key, this.type});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<VisitModel>> _visitList;

  void getVisitList() {
    _visitList = DatabaseHelper.getInstance().getVisitList();
  }

  @override
  void initState() {
    getVisitList();
    // execute after loading first frame
    // context available in such case
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        if (widget.type != null) context.read<AppProvider>().setUserType(widget.type!);
      }
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    // String userType = context.watch<AppProvider>().userType;
    // print("type from provider: ${userType}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: DrawerWidget(),
      body: FutureBuilder<List<VisitModel>>(
        future: _visitList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
            child: CircularProgressIndicator()
            );
          }

          if(snapshot.hasError) {
            Center(
              child: Text("Somwthing Wrong"),
            );
          }

          return Center(
            child: Text("Total ${snapshot.data!.length} Visit", style: TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}


