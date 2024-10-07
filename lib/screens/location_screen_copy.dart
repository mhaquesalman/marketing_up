import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/models/location_model.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/screens/locations/list_screen.dart';
import 'package:marketing_up/screens/locations/map_screen.dart';
import 'package:marketing_up/utils.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';
import 'package:marketing_up/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class LocationScreenCopy extends StatefulWidget {
  UserModel? userModel;

  LocationScreenCopy({super.key, this.userModel});

  @override
  State<LocationScreenCopy> createState() => _LocationScreenCopyState();
}

class _LocationScreenCopyState extends State<LocationScreenCopy> {

  // Initial Selected Value
  String dropdownvalue = 'Item 1';

  // List of items in our dropdown menu
  var items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
    'Item 6',
    'Item 7',
    'Item 8',
    'Item 9',
    'Item 10',
    'Item 11',
    'Item 12',
    'Item 13',
    'Item 14',
    'Item 15',
    'Item 16',
    'Item 17',
    'Item 18',
    'Item 19',
    'Item 20',
    'Item 21',
    'Item 22',
    'Item 23',
    'Item 24',
    'Item 25',
    'Item 26',
    'Item 27',
    'Item 28',
    'Item 29',
  ];

  late String userType;
  late String createdBy;
  late String id;
  late String companyId;
  FirebaseProvider? firebaseProvider;
  List<UserModel>? employees;
  List<LocationModel>? locations;
  List<LocationModel>? locationsByEmployee;
  List<Map<String, dynamic>> employeeNames = [];
  List<Map<String, dynamic>> dates = [];
  // DateFormat dateFormat = DateFormat("dd - MMM - yy");
  DateFormat dateFormat = DateFormat("MMMM dd,yyyy");
  String selectedId = "";
  DateTime? selectedDate;
  final dropDownFormKeyForName = GlobalKey<FormFieldState>();
  final dropDownFormKeyForDate = GlobalKey<FormFieldState>();
  FocusNode employeeNameFocusNode = FocusNode();
  FocusNode dateFocusNode = FocusNode();
  DateTime dateTime = DateTime.now();
  TextEditingController dateController = TextEditingController();
  int activeIndex = 0;


  Future<DateTime?> pickDate() => showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(2024),
      lastDate: DateTime(2034)
  );

  void handleDateTimePicker() async {
    final DateTime? date = await pickDate();
    if(date == null) return;

    final newDateTime = DateTime(
        date.year,
        date.month,
        date.day,
    );

    if (newDateTime != dateTime) {
      setState(() {
        selectedDate = newDateTime;
      });
      dateController.text = dateFormat.format(newDateTime);
    }
  }

  Future<void> fetchData() async {
    employees = firebaseProvider!.listOfEmployees;
    locations = await firebaseProvider!.fetchLocations(userType, companyId);
    // print("locations: $locations");
    // print("employees: $employees");
  }


  void submitData() async {
    // dropDownFormKeyForName.currentState!.save();
    // dropDownFormKeyForDate.currentState!.save();
    if (selectedId.isNotEmpty && selectedDate != null) {
      locationsByEmployee = await firebaseProvider!.getLocationsByCreatedByAndCreatedTime(
          selectedId, selectedDate!
      );
      if (locationsByEmployee != null) {
/*        dropDownFormKeyForName.currentState!.reset();
        dropDownFormKeyForDate.currentState!.reset();
        employeeNameFocusNode.unfocus();
        dateFocusNode.unfocus();
        setState(() {
          selectedId = "";
          selectedDate = null;
        });*/
      }

    } else {
      Future.delayed(Duration.zero).then((value) {
        Utils.showSnackbar(context, "Fields are empty");
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firebaseProvider = context.read<FirebaseProvider>();
      fetchData().then((value) {
        setState(() {
          employeeNames = employees!.map((user) => {"label": user.fullName, "value": user.id}).toList();
          dates = locations!.map((location) {
            final label = dateFormat.format(location.createdTime);
            final value = location.createdTime;
           return  {"label": label, "value": value};
          }).toList();
        });
      });
    });
    userType = widget.userModel!.userType;
    createdBy = widget.userModel!.createdBy;
    id = widget.userModel!.id!;
    companyId = widget.userModel!.companyId;
    // dateController.text = dateFormat.format(dateTime);
    // selectedDate = dateTime;
    // print("usermodel: ${widget.userModel!.userType}");

    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Status status = context.watch<FirebaseProvider>().status;
    // print("status location screen: $status");


    return Scaffold(
      appBar: appBarWidget(context),
      drawer: DrawerWidget(userModel: widget.userModel,),
      body: Column(
        children: [
          SizedBox(height: 14,),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: DropdownButtonFormField(
                    key: dropDownFormKeyForName,
                    focusNode: employeeNameFocusNode,
                    items: employeeNames.map((e) =>
                        DropdownMenuItem(
                            value: e,
                            child: Text(e["label"], style: TextStyle(
                                color: Colors.black,
                                fontSize: 16
                            ),)
                        )).toList(),
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 30,
                    iconEnabledColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      labelText: "Employee",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      // print("select employee: $value");
                      selectedId = value!['value'];
                    },
                  ),
                ),
              ),
              // Expanded(
              //   child: Padding(
              //     padding: EdgeInsets.all(10,),
              //     child: DropdownButtonFormField(
              //       key: dropDownFormKeyForDate,
              //       focusNode: dateFocusNode,
              //       items: dates.map((e) =>
              //           DropdownMenuItem(
              //               value: e,
              //               child: Text(e["label"], style: TextStyle(
              //                   color: Colors.black,
              //                   fontSize: 16
              //               ),)
              //           )).toList(),
              //       icon: Icon(Icons.arrow_drop_down),
              //       iconEnabledColor: Theme.of(context).primaryColor,
              //       decoration: InputDecoration(
              //         labelText: "Date",
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(10.0),
              //         ),
              //       ),
              //       onChanged: (value) {
              //         // print("select date: $value");
              //         selectedDate = value!['value'];
              //       },
              //     ),
              //   ),
              // ),
              Expanded(
                child: buildDateField(),
              )
            ],
          ),
          buildGoButton(status),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(50),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    bottom: TabBar(
                      onTap: (index) {
                        setState(() {
                          activeIndex = index;
                          // print('activeIndex: $activeIndex');
                        });
                      },
                      tabs: const [
                        Tab(text: "List View",),
                        Tab(text: "Map View",)
                      ],
                    ),
                  ),
                ),
                body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Consumer<FirebaseProvider>(
                      builder: (context, provider, child) {
                        if (provider.status == Status.Loading) {
                          return Center(child: CircularProgressIndicator(),);
                        } else if (provider.status == Status.Error) {
                          return Center(child: Text(provider.responseMsg),);
                        } else if (provider.status == Status.Fail) {
                          return Center(child: Text(provider.responseMsg),);
                        } else {
                          if (locationsByEmployee == null)
                            return Center(child: Text("No data is loaded"),);
                          else
                            return ListScreen(locations: locationsByEmployee);

                        }
                      },
                    ),
                    Consumer<FirebaseProvider>(
                      builder: (context, provider, child) {
                        if (provider.status == Status.Loading) {
                          return Center(child: CircularProgressIndicator(),);
                        } else if (provider.status == Status.Error) {
                          return Center(child: Text(provider.responseMsg),);
                        } else if (provider.status == Status.Fail) {
                          return Center(child: Text(provider.responseMsg),);
                        } else {
                          if (locationsByEmployee == null)
                            return Center(child: Text("No data is loaded"),);
                          else
                            return MapScreen(locations: locationsByEmployee);

                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  Widget buildDateField() {
    return Padding(
      padding: EdgeInsets.all(8.0,),
      child: TextFormField(
        readOnly: true,
        controller: dateController,
        style: TextStyle(fontSize: 18.0),
        onTap: handleDateTimePicker,
        decoration: InputDecoration(
          suffixIconColor: Theme.of(context).primaryColor,
          suffixIcon: Icon(Icons.calendar_month),
          labelText: 'Date',
          labelStyle: TextStyle(fontSize: 18.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  Widget buildGoButton(Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0,),
      height: 50.0,
      width: MediaQuery.of(context).size.width / 4,
      decoration: BoxDecoration(
        gradient: gradientBackground(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading ? "Wait" : "Find",
          style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontFamily: GoogleFonts.roboto().fontFamily
          ),
        ),
        onPressed: activeIndex == 0 ? () {
          if (status == Status.Loading) return;
          submitData();
        } : null,
      ),
    );
  }
}
