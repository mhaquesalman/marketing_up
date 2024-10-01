import 'package:flutter/material.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';

class LocationScreenCopy extends StatefulWidget {
  LocationScreenCopy({super.key});

  @override
  State<LocationScreenCopy> createState() => _LocationScreenCopyState();
}

class _LocationScreenCopyState extends State<LocationScreenCopy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      drawer: DrawerWidget(),
      body: Column(
        children: [
          
        ],
      ),
    );
  }
}
