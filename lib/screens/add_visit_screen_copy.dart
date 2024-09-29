
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/database_helper.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/imagemodel.dart';
import 'package:marketing_up/imagepicker_widget.dart';
import 'package:marketing_up/models/visit_model.dart';
import 'package:marketing_up/utils.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';


class AddVisitScreenCopy extends StatefulWidget {

  UserModel? userModel;
  bool? isEdit;

  AddVisitScreenCopy({super.key, required this.userModel, this.isEdit});

  @override
  State<AddVisitScreenCopy> createState() => _AddVisitScreenCopyState();
}

class _AddVisitScreenCopyState extends State<AddVisitScreenCopy> {
  final formKey = GlobalKey<FormState>();
  String company ="";
  String visitingPerson = "";
  String email = "";
  String phone = "";
  String position = "";
  String visitingPurpose = "";
  List<File> images = [];
  List<String> base64Image = [];
  bool isSubmit = false;
  bool clearImagePicker = false;
  DateTime dateTime = DateTime.now();
  DateTime createdTime = DateTime.now();
  DateTime visitDate = DateTime.now();
  DateTime nextVisitDate = DateTime.now();
  DateFormat dateFormat = DateFormat("MMM dd - yyyy, h:mm a");
  TextEditingController dateController = TextEditingController();
  TextEditingController createdTimeController = TextEditingController();
  TextEditingController visitDateController = TextEditingController();
  TextEditingController nextVisitDateController = TextEditingController();
  VisitModel? createdUpdatedVisitModel;
  FirebaseProvider? firebaseProvider;

  Future<DateTime?> pickDate() => showDatePicker(
  context: context,
  initialDate: dateTime,
  firstDate: DateTime(2024),
  lastDate: DateTime(2034)
  );

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));

  void handleDateTimePicker(TextEditingController dtController, DateTime dt) async {
    final DateTime? date = await pickDate();
    if(date == null) return;

    TimeOfDay? time = await pickTime();
    if(time == null) return;

    final newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute
    );

    if (newDateTime != dateTime) {
      setState(() {
        dt = newDateTime;
      });
      dtController.text = dateFormat.format(newDateTime);
    }
  }

  void submitData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (company.isNotEmpty && visitingPerson.isNotEmpty && phone.isNotEmpty
          && email.isNotEmpty && visitingPurpose.isNotEmpty && position.isNotEmpty) {
        if (images.isNotEmpty) {
          if (images.length != base64Image.length) {
            for (int i = 0; i < images.length; i ++) {
              String convertImage = await Utils.convertImageToBase64(images[i]);
              base64Image.add(convertImage);
            }
          }
          VisitModel visitModel = VisitModel(
              companyName: company,
              companyId: widget.userModel!.companyId,
              contactEmail: email,
              contactNumber: phone,
              createdBy: widget.userModel!.id!,
              createdTime: createdTime,
              nextVisitDate: nextVisitDate,
              nextVisitPurpose: visitingPurpose,
              photos: base64Image,
              position: position,
              visitDate: visitDate,
              visitingPerson: visitingPerson
          );

          // print("visitmodel: $visitModel");
          createdUpdatedVisitModel = await firebaseProvider!.insertVisit(visitModel);
          // print("createdvisit: ${createdUpdatedVisitModel}");
          if (createdUpdatedVisitModel != null) {
            formKey.currentState!.reset();
            visitDateController.clear();
            nextVisitDateController.clear();
            setState(() {
              clearImagePicker = true;
            });
            firebaseProvider!.resetStatus();
          }
        }
      }
    }
  }

  Future<String> convertImageToBase64(File imageFile) async {
    Uint8List imagebytes = await imageFile.readAsBytes(); //convert to bytes
    String base64string = base64.encode(imagebytes); //convert bytes to base64 string
    // print(base64string);
    return base64string;
  }
  
  void showSnackbar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    Future.microtask(() {
      firebaseProvider = context.read<FirebaseProvider>();
    });
    // print("from drawer: ${widget.userModel.toString()}");
    visitDateController.text = dateFormat.format(visitDate);
    nextVisitDateController.text = dateFormat.format(nextVisitDate);
    super.initState();

  }

  @override
  void dispose() {
    dateController.dispose();
    createdTimeController.dispose();
    visitDateController.dispose();
    nextVisitDateController.dispose();
    super.dispose();
  }

  Future<bool?> showMyDialog() {
    return showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Use Drawer for navigation"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("OK", style: TextStyle(
                  fontSize: 18
                ),)
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // final hours = dateTime.hour.toString().padLeft(2, '0');
    // final minutes = dateTime.hour.toString().padLeft(2, '0');

    Status status = context.read<FirebaseProvider>().status;
    String responseMsg = context.read<FirebaseProvider>().responseMsg;

    print("status: $status");
    // to show snackbar we have to use inside addpostframecallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (status == Status.Success) {
        if (createdUpdatedVisitModel != null) {
          Utils.showSnackbar(context, responseMsg,);
          firebaseProvider!.resetStatus();

        } else {
          // Utils.showSnackbar(context, responseMsg);
          // firebaseProvider.resetStatus();
        }
      } else if (status == Status.Fail) {
        Utils.showSnackbar(context, responseMsg);
      } else if (status == Status.Error) {
        Utils.showSnackbar(context, responseMsg);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        final showPop = await showMyDialog();
        return showPop ?? false;
        // return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        drawer: DrawerWidget(),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  status == Status.Loading
                      ? Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: LinearProgressIndicator(),
                  ) : SizedBox.shrink(),
                  buildTextField("company", "Company name is required"),
                  buildTextField("person", "Person name is required"),
                  buildTextField("email", "Email is required"),
                  buildTextField("phone", "Phone must be 8 digit"),
                  buildTextField("position", "Position is required"),
                  buildTextField("purpose", "Write your purpose"),
                  buildDateTimeField("visit date", visitDateController, visitDate),
                  buildDateTimeField("next visit date", nextVisitDateController, nextVisitDate),
                  buildSubmitButton(status),
                  ImagePickerWidget(
                    clearImage: clearImagePicker,
                    singleImage: false,
                    isEdit: false,
                    imageFromFirestore: [],
                    savedImages: (files) {
                      images.clear();
                      images.addAll(files);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateTimeField(String label, TextEditingController dtController, DateTime dt) {
    return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                readOnly: true,
                controller: dtController,
                style: TextStyle(fontSize: 18.0),
                onTap: () => handleDateTimePicker(dtController, dt),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(fontSize: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            );
  }

  Widget buildTextField(String label, String errMsg) {
    return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                style: TextStyle(fontSize: 18.0),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(fontSize: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (input) {
                  if(label == "phone") {
                    if (input!.trim().length < 8) return errMsg;
                    else return null;
                  } else {
                    if(input!.trim().isEmpty) return errMsg;
                    else return null;
                  }
                },
                onSaved: (value) {
                  if (label == "phone" && value != null) phone = value;
                  else if (label == "company" && value != null) company = value;
                  else if (label == "email" && value != null) email = value;
                  else if (label == "person" && value != null) visitingPerson = value;
                  else if (label == "purpose" && value != null) visitingPurpose = value;
                  else if (label == "position" && value != null) position = value;
                },
              ),
            );
  }

  Widget buildSubmitButton(Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 60.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading ? "Please Wait" : "Add Visit",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        ),
        onPressed: () {
          if (status == Status.Loading) return;
          submitData();
        },
      ),
    );
  }
  
}
