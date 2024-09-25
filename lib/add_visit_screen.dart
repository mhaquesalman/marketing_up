
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/database_helper.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/imagemodel.dart';
import 'package:marketing_up/visitmodel.dart';

import 'imagepicker_widget.dart';

class AddVisitScreen extends StatefulWidget {

  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final formKey = GlobalKey<FormState>();
  String company ="";
  String person = "";
  String phone = "";
  List<File> images = [];
  bool isSubmit = false;
  bool clearImagePicker = false;
  DateTime dateTime = DateTime.now();
  DateFormat dateFormat = DateFormat("MMM dd - yy, h:mm a");
  TextEditingController dateController = TextEditingController();

  Future<DateTime?> pickDate() => showDatePicker(
  context: context,
  initialDate: dateTime,
  firstDate: DateTime(2024),
  lastDate: DateTime(2034)
  );

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));

  void handleDateTimePicker() async {
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
        dateTime = newDateTime;
      });
      dateController.text = dateFormat.format(newDateTime);
    }
  }

  void submitData() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (company.isNotEmpty && person.isNotEmpty && phone.isNotEmpty ) {
        setState(() {
          isSubmit = true;
          clearImagePicker = false;
        });
        VisitModel visitModel = VisitModel(
          company: company,
          person: person,
          phone: phone,
          date: dateTime
        );
        // print("visit: ${visitModel.toString()}");
        // print("images: ${images.length}");
        DatabaseHelper.getInstance().insertVisit(visitModel)
        .then((visitResult) {
          // print("result $visitResult");
          if (visitResult != -1) {
            if (images.isNotEmpty) {
              images.forEach((image) async {
                String convertImage = await convertImageToBase64(image);
                ImageModel imageModel = ImageModel(image: convertImage, companyId: visitResult);
                final imageResult = await DatabaseHelper.getInstance().insertImage(imageModel);
                if (imageResult != - 1) {
                  setState(() {
                    isSubmit = false;
                    clearImagePicker = true;
                  });
                  formKey.currentState!.reset();
                  dateController.text = "";
                  images.clear();
                  Future.delayed(Duration.zero)
                      .then((value) => showSnackbar(context, "Successfully saved"));
                } else {
                  setState(() {
                    isSubmit = false;
                  });
                  Future.delayed(Duration.zero)
                      .then((value) => showSnackbar(context, "Something wrong"));
                }
              });
            } else {
              setState(() {
                isSubmit = false;
              });
              formKey.currentState!.reset();
              dateController.text = "";
              Future.delayed(Duration.zero)
                  .then((value) => showSnackbar(context, "Successfully saved"));
            }
          } else {
            setState(() {
              isSubmit = false;
            });
            Future.delayed(Duration.zero)
                .then((value) => showSnackbar(context, "Something wrong"));
          }
        });
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
  void dispose() {
    dateController.dispose();
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
                  buildTextField("Company", "Company name is required"),
                  buildTextField("Person", "Person name is required"),
                  buildTextField("Phone", "Phone must be 8 digit"),
                  buildDateTimeField(),
                  buildSubmitButton(context),
                  ImagePickerWidget(
                    clearImage: clearImagePicker,
                    singleImage: false,
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

  Widget buildDateTimeField() {
    return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                readOnly: true,
                controller: dateController,
                style: TextStyle(fontSize: 18.0),
                onTap: handleDateTimePicker,
                decoration: InputDecoration(
                  labelText: 'Date',
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
                  if(label == "Phone") {
                    if (input!.trim().length < 8) return errMsg;
                    else return null;
                  } else {
                    if(input!.trim().isEmpty) return errMsg;
                    else return null;
                  }
                },
                onSaved: (value) {
                  if (label == "Phone" && value != null) phone = value;
                  else if (label == "Company" && value != null) company = value;
                  else if (label == "Person" && value != null) person = value;
                },
              ),
            );
  }

  Widget buildSubmitButton(BuildContext context) {
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
          isSubmit ? "Please Wait" : "Submit",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        ),
        onPressed: isSubmit ? null : () => submitData(),
      ),
    );
  }
  
}
