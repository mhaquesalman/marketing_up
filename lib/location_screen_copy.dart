import 'package:flutter/material.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/map_screen.dart';

class LocationScreenCopy extends StatefulWidget {
  const LocationScreenCopy({super.key});

  @override
  State<LocationScreenCopy> createState() => _LocationScreenCopyState();
}

class _LocationScreenCopyState extends State<LocationScreenCopy> {

  final names = [
    "Apple",
    "Samsung",
    "Microsoft"
  ];

  String lat = "";
  String long = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: DrawerWidget(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: DropdownButtonFormField(
              items: names.map((e) =>
                  DropdownMenuItem(
                    value: e,
                      child: Text(e, style: TextStyle(
                        color: Colors.black,
                        fontSize: 16
                      ),)
                  )).toList(),
              icon: Icon(Icons.arrow_drop_down_circle),
              iconSize: 20,
              iconEnabledColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                labelText: "Company",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
              },
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    bottom: TabBar(
                      tabs: [
                        Tab(text: "List View",),
                        Tab(text: "Map View",)
                      ],
                    ),
                  ),
                ),
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Center(child: Text("A"),),
                    MapScreen(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
