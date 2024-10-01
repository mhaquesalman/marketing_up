import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/database_helper.dart';
import 'package:marketing_up/drawer_widget.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/imagemodel.dart';
import 'package:marketing_up/imagepicker_widget.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/models/visit_model.dart';
import 'package:marketing_up/utils.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';
import 'package:marketing_up/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

class AddVisitScreenCopy extends StatefulWidget {
  UserModel? userModel;
  bool? isEdit;
  VisitModel? visitModel;

  AddVisitScreenCopy(
      {super.key, required this.userModel, this.isEdit, this.visitModel});

  @override
  State<AddVisitScreenCopy> createState() => _AddVisitScreenCopyState();
}

class _AddVisitScreenCopyState extends State<AddVisitScreenCopy> {
  final formKey = GlobalKey<FormState>();
  String company = "";
  String visitingPerson = "";
  String email = "";
  String phone = "";
  String position = "";
  String visitingPurpose = "";
  List<File> images = [];
  List<String> base64Image = [];
  bool isDeleteing = false;
  bool clearImagePicker = false;
  DateTime dateTime = DateTime.now();
  DateTime createdTime = DateTime.now();
  DateTime visitDate = DateTime.now();
  DateTime nextVisitDate = DateTime.now();
  DateFormat dateFormat = DateFormat("MMM dd - yyyy, h:mm a");
  FocusNode focusNode = FocusNode();
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
      lastDate: DateTime(2034));

  Future<TimeOfDay?> pickTime() => showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute));

  void handleDateTimePicker(
      TextEditingController dtController, String id) async {
    final DateTime? date = await pickDate();
    if (date == null) return;

    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final newDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    if (newDateTime != dateTime) {
      if (id == "visit_date") {
      setState(() {
        visitDate = newDateTime;
      });

      } else {
        setState(() {
          nextVisitDate = newDateTime;
        });
      }
      dtController.text = dateFormat.format(newDateTime);
    }

    // print("visit date: ${visitDate}");
    // print("next visit date: ${nextVisitDate}");
  }

  void submitData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      focusNode.unfocus();
      if (company.isNotEmpty &&
          visitingPerson.isNotEmpty &&
          phone.isNotEmpty &&
          email.isNotEmpty &&
          visitingPurpose.isNotEmpty &&
          position.isNotEmpty) {
        if (widget.isEdit == true) {
          if (images.isEmpty && base64Image.isEmpty) {
            Future.delayed(Duration.zero).then((value) =>
                Utils.showSnackbar(context, "Please at least add an image"));
          } else {
            if (images.isNotEmpty) {
              base64Image.clear();
              for (int i = 0; i < images.length; i++) {
                String convertImage =
                    await Utils.convertImageToBase64(images[i]);
                base64Image.add(convertImage);
              }
            }
            VisitModel visitModel = VisitModel(
                id: widget.visitModel!.id,
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
                visitingPerson: visitingPerson);

            // print("visitmodel: $visitModel");
            createdUpdatedVisitModel =
                await firebaseProvider!.updateVisit(visitModel);
            // print("updatedvisit: ${createdUpdatedVisitModel}");
            if (createdUpdatedVisitModel != null) {
              clearFields();
            }
          }
        } else {
          if (images.isNotEmpty) {
            for (int i = 0; i < images.length; i++) {
              String convertImage = await Utils.convertImageToBase64(images[i]);
              base64Image.add(convertImage);
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
                visitingPerson: visitingPerson);

            print("visitmodel: $visitModel");
            print("date: $visitDate");
            createdUpdatedVisitModel =
                await firebaseProvider!.insertVisit(visitModel);
            // print("createdvisit: ${createdUpdatedVisitModel}");
            if (createdUpdatedVisitModel != null) {
              clearFields();
            }
          } else {
            Future.delayed(Duration.zero).then((value) =>
                Utils.showSnackbar(context, "Please at least add an image"));
          }
        }
      }
    }
  }

  void clearFields() {
    formKey.currentState!.reset();
    visitDateController.clear();
    nextVisitDateController.clear();
    images.clear();
    base64Image.clear();
    setState(() {
      clearImagePicker = true;
      company = "";
      visitingPerson = "";
      email = "";
      phone = "";
      position = "";
      visitingPurpose = "";
    });
  }

  void deleteVisit() async {
    if (widget.isEdit == true)
      await firebaseProvider!.deleteVisit(widget.visitModel!.id!);
  }

  @override
  void initState() {
    Future.microtask(() {
      firebaseProvider = context.read<FirebaseProvider>();
    });
    // print("from drawer: ${widget.userModel.toString()}");
    if (widget.isEdit == true && widget.visitModel != null) {
      company = widget.visitModel!.companyName;
      visitingPerson = widget.visitModel!.visitingPerson;
      email = widget.visitModel!.contactEmail;
      phone = widget.visitModel!.contactNumber;
      position = widget.visitModel!.position;
      createdTime = widget.visitModel!.createdTime;
      visitDate = widget.visitModel!.visitDate;
      nextVisitDate = widget.visitModel!.nextVisitDate;
      visitingPurpose = widget.visitModel!.nextVisitPurpose;
      base64Image = widget.visitModel!.photos!;
      visitDateController.text = dateFormat.format(visitDate);
      nextVisitDateController.text = dateFormat.format(nextVisitDate);
    } else {
      visitDateController.text = dateFormat.format(visitDate);
      nextVisitDateController.text = dateFormat.format(nextVisitDate);
    }
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
                    child: Text(
                      "OK",
                      style: TextStyle(fontSize: 18),
                    ))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // final hours = dateTime.hour.toString().padLeft(2, '0');
    // final minutes = dateTime.hour.toString().padLeft(2, '0');
    Status status = context.watch<FirebaseProvider>().status;
    String responseMsg = context.watch<FirebaseProvider>().responseMsg;
    CurrentPage currentPage = context.watch<AppProvider>().currentPage;

    print("add screen: $status");
    // to show snackbar we have to use inside addpostframecallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentPage == CurrentPage.AddVisitScreen || currentPage == CurrentPage.EditVisitScreen) {
        if (status == Status.Success) {
          if (createdUpdatedVisitModel != null) {
            Utils.showSnackbar(context, responseMsg,);
          } else {
              Utils.showSnackbar(context, responseMsg);
          }
          clearFields();
        } else if (status == Status.Fail) {
          Utils.showSnackbar(context, responseMsg);
        } else if (status == Status.Error) {
          Utils.showSnackbar(context, responseMsg);
        }
        firebaseProvider!.resetStatus();
      }
    });

    return WillPopScope(
      onWillPop: () async {
        final showPop = await showMyDialog();
        return showPop ?? false;
        // return false;
      },
      child: Scaffold(
        appBar: appBarWidget(context),
        drawer: DrawerWidget(userModel: widget.userModel,),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [

                  buildTextField(
                      "company", "Company name is required", company),
                  buildTextField(
                      "person", "Person name is required", visitingPerson),
                  buildTextField("email", "Email is required", email),
                  buildTextField("phone", "Phone must be 8 digit", phone),
                  buildTextField("position", "Position is required", position),
                  buildTextField(
                      "purpose", "Write your purpose", visitingPurpose),
                  buildDateTimeField(
                      "visit date", visitDateController, visitDate, "visit_date"),
                  buildDateTimeField("next visit date", nextVisitDateController,
                      nextVisitDate, "next_visit_date"),
                  widget.isEdit == null
                      ? buildSubmitButton(status)
                      : Row(
                          children: [
                            Expanded(child: buildSubmitButton(status)),
                            Expanded(child: buildDeleteVisitButton(status))
                          ],
                        ),
                  status == Status.Loading
                      ? Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: LinearProgressIndicator(),
                  )
                      : SizedBox.shrink(),
                  ImagePickerWidget(
                    clearImage: clearImagePicker,
                    singleImage: false,
                    isEdit: widget.isEdit,
                    imageFromFirestore:
                        widget.isEdit == true ? base64Image : [],
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

  Widget buildDateTimeField(
      String label, TextEditingController dtController, DateTime dt, String id) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        focusNode: id == "next_visit_date" ? focusNode : null,
        readOnly: true,
        controller: dtController,
        style: TextStyle(fontSize: 18.0),
        onTap: () => handleDateTimePicker(dtController, id),
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

  Widget buildTextField(String label, String errMsg, String initialValue) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        key: createdUpdatedVisitModel != null ? UniqueKey() : null,
        style: TextStyle(fontSize: 18.0),
        keyboardType: label == "email" ? TextInputType.emailAddress : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 18.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        initialValue: widget.isEdit == true ? initialValue : null,
        validator: (input) {
          if (label == "phone") {
            if (input!.trim().length < 8)
              return errMsg;
            else
              return null;
          } else {
            if (input!.trim().isEmpty)
              return errMsg;
            else
              return null;
          }
        },
        onSaved: (value) {
          if (label == "phone" && value != null)
            phone = value;
          else if (label == "company" && value != null)
            company = value;
          else if (label == "email" && value != null)
            email = value;
          else if (label == "person" && value != null)
            visitingPerson = value;
          else if (label == "purpose" && value != null)
            visitingPurpose = value;
          else if (label == "position" && value != null) position = value;
        },
      ),
    );
  }

  Widget buildSubmitButton(Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      width: widget.isEdit == null ? double.infinity : null,
      height: widget.isEdit == null ? 60 : null,
      decoration: BoxDecoration(
        gradient: gradientBackground(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading && !isDeleteing
              ? "Please Wait"
              : widget.isEdit == null
                  ? "Add Visit"
                  : "Update Visit",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: GoogleFonts.poppins().fontFamily),
          textAlign: widget.isEdit == true ? TextAlign.center : null,
        ),
        onPressed: () {
          if (status == Status.Loading) return;
          submitData();
          setState(() {
            isDeleteing = false;
          });
        },
      ),
    );
  }

  Widget buildDeleteVisitButton(Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      decoration: BoxDecoration(
        gradient: gradientBackground(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading && isDeleteing
              ? "Please wait"
              : "Delete Visit",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: GoogleFonts.poppins().fontFamily),
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          if (status == Status.Loading) return;
          deleteVisit();
          setState(() {
            isDeleteing = true;
          });
        },
      ),
    );
  }
}
