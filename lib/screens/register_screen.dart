import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_up/app_provider.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/utils.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';
import 'package:marketing_up/widgets/gradient_background.dart';
import 'package:provider/provider.dart';

import '../imagepicker_widget.dart';

class RegisterScreen extends StatefulWidget {

  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  bool isObscured = true;
  bool clearImagePicker = false;
  String email = "";
  String fullname = "";
  String phone = "";
  String password = "";
  bool retry = false;
  List<File> image = [];
  late FirebaseProvider firebaseProvider;
  UserModel? createdUserModel;


  void showAlertDialog(String msg) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: Text(msg),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "OK",
                      style: TextStyle(fontSize: 18),
                    ))
              ],)
    );
  }

  void submitData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (fullname.isNotEmpty &&
          email.isNotEmpty &&
          phone.isNotEmpty &&
          password.isNotEmpty) {
        if (image.isEmpty) {
          Utils.showSnackbar(context, "must add an image");
        } else {
          String convertImage = await Utils.convertImageToBase64(image[0]);
          String securedPass = Utils.encryptPassword(password);

          UserModel userModel = UserModel(
              activeStatus: Constants.DefaultActiveStatus,
              companyUserLimit: Constants.DefaultCompanyUserLimit,
              companyId: Constants.DefaultCompanyId,
              companyVisitLimit: Constants.DefaultCompanyVisitLimit,
              createdBy: Constants.DefaultCreatedBy,
              email: email,
              fullName: fullname,
              phoneNumber: phone,
              password: securedPass,
              userPhoto: convertImage,
              userType: Constants.DefaultUserType,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()
          );

          createdUserModel = await firebaseProvider.registerUser(userModel, password);
          // print("createdUser: ${createdUserModel}");

          if (createdUserModel != null) {
            formKey.currentState!.reset();
            setState(() {
              clearImagePicker = true;
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    firebaseProvider = context.read<FirebaseProvider>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CurrentPage currentPage = context.watch<AppProvider>().currentPage;
    Status status = context.watch<FirebaseProvider>().status;
    String responseMsg = Provider.of<FirebaseProvider>(context).responseMsg;
    // print("status: $status");

    // to show snackbar we have to use inside addpostframecallback
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (currentPage == CurrentPage.RegisterScreen || currentPage == CurrentPage.EditEmployeeScreen) {
        if (status == Status.Success && createdUserModel != null) {
          Utils.showSnackbar(context, responseMsg);
          firebaseProvider.resetStatus();
        } else if (status == Status.Fail) {
          if (responseMsg.contains("9999"))
            showAlertDialog(responseMsg);
          else
            Utils.showSnackbar(context, responseMsg);
          firebaseProvider.resetStatus();
        } else if (status == Status.Error) {
          Utils.showSnackbar(context, responseMsg);
          firebaseProvider.resetStatus();
        }
      }
    });

    return Scaffold(
        appBar: appBarWidget(context),
        body: WillPopScope(
          onWillPop: () async {
            if (currentPage == CurrentPage.RegisterScreen)
              context.read<AppProvider>().setCurrentPage(CurrentPage.LoginScreen);
            else if (currentPage == CurrentPage.EditEmployeeScreen)
              context.read<AppProvider>().setCurrentPage(CurrentPage.DashboardScreen);
            return true;
          },
          child: Form(
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
                          )
                        : SizedBox.shrink(),
                    buildTextField(
                        "fullname", "Fullname is required!", nameFocusNode, status),
                    buildTextField("email", "Email is required!", emailFocusNode, status),
                    buildTextField(
                        "phone", "Phone must be 8 digit!", phoneFocusNode, status),
                    buildTextField("password", "Password length must be 6",
                        passwordFocusNode, status),
                    buildRegisterButton(context, status),
                    ImagePickerWidget(
                      clearImage: clearImagePicker,
                      singleImage: true,
                      imageFromFirestore: [],
                      savedImages: (files) {
                        image.clear();
                        image.addAll(files);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

  Widget buildRegisterButton(BuildContext context, Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      height: 60.0,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradientBackground(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading ? "Please wait" : "Register",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: GoogleFonts.poppins().fontFamily
          ),
        ),
        onPressed: () {
          setState(() {
            retry = false;
          });
          if (status == Status.Loading) return;
          submitData();
        },
      ),
    );
  }

  Widget buildTextField(String label, String errMsg, FocusNode focusNode, Status status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: TextFormField(
        obscureText: label == "password" ? isObscured : false,
        focusNode: focusNode,
        keyboardType: label == "phone" ? TextInputType.phone : null,
        style: TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 18.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: label == "password"
                ? IconButton(
                    padding: EdgeInsetsDirectional.only(end: 10),
                    icon: isObscured
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off),
                    onPressed: () {
                      if (status == Status.Fail || status == Status.Error)
                        retry = true;
                      else
                        retry = false;
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                  )
                : null),
        validator: (input) {
          if (label == "password") {
            if (input!.trim().length < 6) {
              passwordFocusNode.requestFocus();
              return errMsg;
            } else
              return null;
          }
          if (label == "fullname") {
            if (input!.trim().isEmpty) {
              focusNode.requestFocus();
              return errMsg;
            } else
              return null;
          }
          if (label == "email") {
            if (input!.trim().isEmpty) {
              focusNode.requestFocus();
              return errMsg;
            } else if (!input.trim().contains("@")) {
              focusNode.requestFocus();
              return "Valid email address must contain @";
            } else
              return null;
          }

          if (label == "phone") {
            if (input!.trim().length < 10)
              return errMsg;
            else
              return null;
          }

          return null;
        },
        onSaved: (value) {
          if (label == "password") {
            if (value != null) password = value;
          }
          if (label == "fullname") {
            if (value != null) fullname = value;
          }
          if (label == "email") {
            if (value != null) email = value;
          }
          if (label == "phone") {
            if (value != null) phone = value;
          }
        },
      ),
    );
  }
}
