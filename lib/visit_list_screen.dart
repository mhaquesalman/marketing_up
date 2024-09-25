import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/Visit_details_screen.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/database_helper.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/imagemodel.dart';
import 'package:marketing_up/visitmodel.dart';
import 'package:provider/provider.dart';

class VisitListScreen extends StatefulWidget {
  const VisitListScreen({super.key});

  @override
  State<VisitListScreen> createState() => _VisitListScreenState();
}

class _VisitListScreenState extends State<VisitListScreen> {
  late Future<Map<String, dynamic>> _visitListWithImage;
  final DateFormat dateFormat = DateFormat("MMM dd - yy, h:mm a");

  void getVisitListWithImage() {
    _visitListWithImage = DatabaseHelper.getInstance().getVisitListWithImage();
    // print("visitListWithImage: ${_visitListWithImage}");
  }

  @override
  void initState() {
    getVisitListWithImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        // return false stay on page
        return false;
        // return true pop page
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        drawer: DrawerWidget(),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _visitListWithImage,
          builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {

            if (snapshot.hasError) {
              return Center(
                child: Text("Somwthing Wrong..."),
              );
            }

            if (snapshot.hasData) {
              final List<VisitModel> visits = snapshot.data?['visits'] as List<VisitModel>;
              final List<ImageModel> images = snapshot.data?['images'] as List<ImageModel>;
              return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  itemCount: 1 + visits.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visit List',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                'Total Visits ${visits.length}',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          )
                      );
                    }
                    return buildVisitList(visits[index - 1], images);
                  }
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },

        ),
      ),
    );
  }


  Widget buildVisitList(VisitModel visitModel, List<ImageModel> images) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              final imageList = images.where((image) => image.companyId == visitModel.id).toList();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => VisitDetailsScreen(
                      visitModel: visitModel, imageModels: imageList))
              );
            },
            leading: Text("${visitModel.id}"),
            title: Text(dateFormat.format(visitModel.date).split(",")[0]),
            subtitle: Text(visitModel.person),
            trailing: Column(
              children: [
                Text(dateFormat.format(visitModel.date).split(",")[1]),
                Text(visitModel.company)
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

}

