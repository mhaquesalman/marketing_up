import 'dart:io';

import 'package:dropdown_below/dropdown_below.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../firebase_provider.dart';
import '../imagepicker_widget.dart';
import '../models/user_model.dart';
import '../utils.dart';
import 'package:marketing_up/widgets/gradient_background.dart';

class AddEmployeeScreen extends StatefulWidget {
  UserModel? userModel;
  AddEmployeeScreen({super.key, this.userModel});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final formKey = GlobalKey<FormState>();
  final dropDownFormKey = GlobalKey<FormFieldState>();
  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode activeStatusFocusNode = FocusNode();
  TextEditingController activeController = TextEditingController();
  bool isObscured = true;
  bool clearImagePicker = false;
  String email = "";
  String fullname = "";
  String phone = "";
  String password = "";
  String? activeStatus;
  String? activeStatus2;
  var selectedActiveItem;
  List<String> activeLabelList = ["YES", "NO"];
  List activeLabelList2 = [
    {"label": "YES", "value": true},
    {"label": "NO", "value": false}
  ];
  List<File> image = [];
  List<DropdownMenuItem<Object?>> dropDownItems = [];
  late FirebaseProvider firebaseProvider;
  UserModel? createdUserModel;

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
              activeStatus: activeStatus == "YES" ? true : false,
              companyUserLimit: Constants.DefaultCompanyUserLimit,
              companyId: widget.userModel?.companyId ?? "0",
              companyVisitLimit: Constants.DefaultCompanyVisitLimit,
              createdBy: widget.userModel?.id ?? "",
              email: email,
              fullName: fullname,
              phoneNumber: phone,
              password: securedPass,
              userPhoto: convertImage,
              userType: Constants.DefaultEmployeeType,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now()
          );

          createdUserModel =
          await firebaseProvider.registerUser(userModel, password);
          // print("createdUser: ${createdUserModel}");

          if (createdUserModel != null) {
            formKey.currentState!.reset();
            dropDownFormKey.currentState!.reset();
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
    firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
    // dropDownItems = buildDropdownTestItems(activeLabelList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Status status = context
        .watch<FirebaseProvider>()
        .status;
    String responseMsg = Provider
        .of<FirebaseProvider>(context)
        .responseMsg;

    // to show snackbar we have to use inside addpostframecallback
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (status == Status.Success && createdUserModel != null) {
        Utils.showSnackbar(context, responseMsg);
      } else if (status == Status.Fail) {
        Utils.showSnackbar(context, responseMsg);
      } else if (status == Status.Error) {
        Utils.showSnackbar(context, responseMsg);
      }
    });

    return Scaffold(
      appBar: appBarWidget(context),
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
                )
                    : SizedBox.shrink(),
                buildTextField("fullname", "Fullname is required!", nameFocusNode),
                buildTextField("email", "Email is required!", emailFocusNode),
                buildTextField("phone", "Phone must be 8 digit!", phoneFocusNode),
                buildTextField("password", "Password length must be 6", passwordFocusNode),
                // buildDropDownMenu(context, "Active"),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     Text("Employee Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                //
                //   ],
                // ),
                buildDropDownMenu(),
                buildTextFieldForPopUpMenu("Active", "", activeStatusFocusNode),
                // buildPopUpMenu(),
                buildRegisterButton(context, status),
                ImagePickerWidget(
                  clearImage: clearImagePicker,
                  singleImage: true,
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
    );
  }

  Widget buildDropDownMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: DropdownButtonFormField(
          key: dropDownFormKey,
          items: activeLabelList.map((item) =>
              DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(
                      color: Colors.black,
                      fontSize: 16
                  ),)
              )).toList(),
          icon: Icon(Icons.arrow_drop_down_circle),
          decoration: InputDecoration(
            labelText: "employee active",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          value: activeStatus,
          validator: (input) => activeStatus == null ? "Please select status" : null,
          onChanged: (value) {
            setState(() {
              activeStatus = value!;
            });
          },
        ),
    );
  }

  Widget buildPopUpMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.arrow_downward),
      offset: Offset(0, 40),
        itemBuilder: (context) {
          return activeLabelList2.map((item) =>
              PopupMenuItem(value: item['value'],
                  child: Text(item['label'])
              ),
          ).toList();
        },
      onSelected: (value) {
          selectedActiveItem = value;
          activeController.text = selectedActiveItem['label'];
      },
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
          status == Status.Loading ? "Please wait" : "Register Employee",
          style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontFamily: GoogleFonts
                  .poppins()
                  .fontFamily
          ),
        ),
        onPressed: () {
          if (status == Status.Loading) return;
          submitData();
        },
      ),
    );
  }

  Widget buildTextField(String label, String errMsg, FocusNode focusNode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: TextFormField(
        obscureText: label == "password" ? isObscured : false,
        focusNode: focusNode,
        keyboardType: label == "phone" ? TextInputType.phone : label == "email"
            ? TextInputType.emailAddress
            : null,
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

  Widget buildTextFieldForPopUpMenu(String label, String errMsg, FocusNode focusNode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: TextFormField(
        controller: activeController,
        readOnly: true,
        onTap: () {
          buildPopUpMenu();
        },
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 18.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            suffixIcon: buildPopUpMenu(),
        ),
        validator: (input) => activeStatus2 == null ? "Please select active status" : null,
        onSaved: (value) {
          activeStatus2 = activeController.text;
        },
      ),
    );
  }

  Widget buildCustomDropDownMenu() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownBelow(
        isDense: true,
        itemWidth: 150,
        itemTextstyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black),
        boxTextstyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white54),
        boxPadding: EdgeInsets.all(12),
        boxWidth: 150,
        boxHeight: 60,
        boxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent,
          border: Border.all(width: 1, color: Colors.black38,),
        ),
        icon: Icon(Icons.arrow_downward,),
        hint: Text(
          'Active',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        value: selectedActiveItem,
        items: dropDownItems,
        onChanged: (selected) {
          setState(() {
            selectedActiveItem = selected;
          });
          print("selected: ${selectedActiveItem['value']}");
        },
      ),
    );
  }


  // List<DropdownMenuItem<Object?>> buildDropdownTestItems(List activeLabelList) {
  //   List<DropdownMenuItem<Object?>> items = [];
  //   for (var i in activeLabelList) {
  //     items.add(
  //       DropdownMenuItem(
  //         value: i,
  //         child: Text(
  //           i['label'],
  //           style: TextStyle(color: Colors.black),
  //         ),
  //       ),
  //     );
  //   }
  //   return items;
  // }
}

