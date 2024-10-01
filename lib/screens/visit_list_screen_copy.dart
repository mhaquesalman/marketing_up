import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/models/visit_model.dart';
import 'package:marketing_up/screens/add_visit_screen_copy.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';

class VisitListScreenCopy extends StatefulWidget {
  UserModel? userModel;

  VisitListScreenCopy({super.key, this.userModel});

  @override
  State<VisitListScreenCopy> createState() => _VisitListScreenCopyState();
}

class _VisitListScreenCopyState extends State<VisitListScreenCopy> {

  late String createdBy;
  late String id;
  late String userType;
  late String companyId;
  List<VisitModel>? visits;
  DateFormat dateFormat = DateFormat("MMM dd - yyyy, h:mm a");

  Future<void> fetchData() async {
    if (userType == Constants.DefaultEmployeeType) {
      visits = await context.read<FirebaseProvider>().fetchVisits(id, companyId, userType);
    } else {
      visits = await context.read<FirebaseProvider>().fetchVisits(createdBy, companyId, userType);
    }
    print("visits: ${visits!.length}");
  }

  @override
  void initState() {
    userType = widget.userModel!.userType;
    createdBy = widget.userModel!.createdBy;
    id = widget.userModel!.id!;
    companyId = widget.userModel!.companyId;
    // print("usermodel: ${widget.userModel}");
    // ideal for calling provider from initstate
    Future.microtask(() => fetchData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print("visit screen: ${context.watch<FirebaseProvider>().status}");

    return Scaffold(
      appBar: appBarWidget(context),
      drawer: DrawerWidget(userModel: widget.userModel,),
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
                        return Center(child: Text(provider.responseMsg),);
                    } else {
                      if (visits == null) return Center(child: Text(provider.responseMsg),);
                      return ListView.builder(
                        itemCount: visits!.length,
                        itemBuilder: (ctx, index) {
                          VisitModel visitData = visits![index];
                          return buildVisitList(visitData, provider);
                        },
                      );
                    }
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildVisitList(VisitModel visitModel, FirebaseProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
      child: InkWell(
        onTap: () {
          provider.resetStatus();
          context.read<AppProvider>().setCurrentPage(CurrentPage.EditVisitScreen);
          if (userType == Constants.DefaultEmployeeType) return;
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddVisitScreenCopy(userModel: widget.userModel, isEdit: true ,visitModel: visitModel,))
          );
        },
        child: Card(
          color: Colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Company: ${visitModel.companyName}"),
                Text("Visited To: ${visitModel.visitingPerson}",),
                Text("Position: ${visitModel.position}"),
                Text("Phone: ${visitModel.contactNumber}"),
                Text("Email: ${visitModel.contactEmail}"),
                Text("Purpose: ${visitModel.nextVisitPurpose}"),
                Text("Visited on: ${dateFormat.format(visitModel.visitDate)}"),
                Text("Next Visit: ${dateFormat.format(visitModel.nextVisitDate)}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
