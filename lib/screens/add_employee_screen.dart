import 'dart:io';

import 'package:dropdown_below/dropdown_below.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';

import 'package:marketing_up/constants.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/imagepicker_widget.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/utils.dart';
import 'package:marketing_up/widgets/gradient_background.dart';

class AddEmployeeScreen extends StatefulWidget {
  UserModel? userModel;
  bool? isEdit;
  Future<void> Function()? refetch;

  AddEmployeeScreen({super.key, this.userModel, this.isEdit, this.refetch});

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
  bool isDeleting = false;
  bool clearImagePicker = false;
  String email = "";
  String fullname = "";
  String phone = "";
  String password = "";
  String createdBy = "";
  String createdAt = "";
  bool? activeStatus;
  String? activeStatus2;
  var selectedActiveItem;
  List<String> activeLabelList = ["YES", "NO"];
  List activeStatusDropDownList = [
    {"label": "YES", "value": true},
    {"label": "NO", "value": false}
  ];
  List<File> image = [];
  List<DropdownMenuItem<Object?>> dropDownItems = [];
  late FirebaseProvider firebaseProvider;
  UserModel? createdUpdatedUserModel;
  DateTime dateTime = DateTime.now();
  DateFormat dateFormat = DateFormat("MMM dd - yyyy, h:mm a");
  TextEditingController dateCreateController = TextEditingController();
  TextEditingController dateUpdateController = TextEditingController();

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
      // dateController.text = dateFormat.format(newDateTime);
    }
  }

  void submitData() async {
    if (formKey.currentState!.validate()) {
      print("form: $fullname | $email | $phone | $password | $activeStatus | ${image.length}");
      formKey.currentState!.save();
      dropDownFormKey.currentState!.save();
      activeStatusFocusNode.unfocus();
      if (fullname.isNotEmpty &&
          email.isNotEmpty &&
          phone.isNotEmpty &&
          password.isNotEmpty && activeStatus != null) {
        if (image.isEmpty && widget.isEdit == null) {
          Utils.showSnackbar(context, "must add an image");
        } else {
          UserModel mUserModel;
          String convertImage;
          String securedPass;
          if (widget.isEdit == true) {
            if (image.isEmpty) {
              convertImage = widget.userModel!.userPhoto;
            } else {
              convertImage = await Utils.convertImageToBase64(image[0]);
            }
            securedPass = widget.userModel!.password;
            mUserModel = UserModel(
                id: widget.userModel!.id!,
                activeStatus: activeStatus!,
                companyUserLimit: Constants.DefaultCompanyUserLimit,
                companyId: widget.userModel?.companyId ?? "0",
                companyVisitLimit: Constants.DefaultCompanyVisitLimit,
                createdBy: createdBy,
                email: email,
                fullName: fullname,
                phoneNumber: phone,
                password: securedPass,
                userPhoto: convertImage,
                userType: Constants.DefaultEmployeeType,
                createdAt: widget.userModel!.createdAt,
                updatedAt: DateTime.now()
            );

            createdUpdatedUserModel = await firebaseProvider.updateEmployee(mUserModel);
          } else {
            convertImage = await Utils.convertImageToBase64(image[0]);
            securedPass = Utils.encryptPassword(password);
            mUserModel = UserModel(
                activeStatus: activeStatus!,
                companyUserLimit: Constants.DefaultCompanyUserLimit,
                companyId: widget.userModel?.companyId ?? "0",
                companyVisitLimit: Constants.DefaultCompanyVisitLimit,
                createdBy: createdBy,
                email: email,
                fullName: fullname,
                phoneNumber: phone,
                password: securedPass,
                userPhoto: convertImage,
                userType: Constants.DefaultEmployeeType,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()
            );

            createdUpdatedUserModel = await firebaseProvider.registerUser(mUserModel, password);
          }
          // print("createdUpdatedUser: ${createdUpdatedUserModel}");

          if (createdUpdatedUserModel != null && widget.isEdit == null) {
            formKey.currentState!.reset();
            dropDownFormKey.currentState!.reset();
            setState(() {
              clearImagePicker = true;
            });
          } else {
            formKey.currentState!.reset();
            dropDownFormKey.currentState!.reset();
            dateCreateController.clear();
            dateUpdateController.clear();
            setState(() {
              clearImagePicker = true;
              fullname = "";
              email = "";
              phone = "";
            });
          }
        }
      }
    }
  }

  void deleteEmployee() async {
    if (widget.isEdit == true)
      await firebaseProvider.deleteEmployee(widget.userModel!.id!);
  }

  @override
  void initState() {
    firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
    // dropDownItems = buildDropdownTestItems(activeLabelList);
    if (widget.isEdit == true) {
      fullname = widget.userModel!.fullName;
      email = widget.userModel!.email;
      phone = widget.userModel!.phoneNumber;
      activeStatus = widget.userModel!.activeStatus;
      password = widget.userModel!.password;
      createdBy = widget.userModel!.createdBy;
      dateCreateController.text = dateFormat.format(widget.userModel!.createdAt);
      dateUpdateController.text = dateFormat.format(widget.userModel!.updatedAt);
      selectedActiveItem = {
        "label": widget.userModel!.activeStatus ? "YES" : "NO", "value": widget.userModel!.activeStatus
      };
    } else {
      createdBy = widget.userModel!.id!;
    }
    super.initState();
  }

  @override
  void dispose() {
    dateCreateController.dispose();
    dateUpdateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Status status = context.watch<FirebaseProvider>().status;
    String responseMsg = Provider.of<FirebaseProvider>(context).responseMsg;

    // to show snackbar we have to use inside addpostframecallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (status == Status.Success) {
        if (createdUpdatedUserModel != null) {
          Utils.showSnackbar(context, responseMsg,);
          // firebaseProvider.resetStatus();
          widget.refetch!();
          Navigator.pop(context);
        } else {
          Utils.showSnackbar(context, responseMsg);
          // firebaseProvider.resetStatus();
          widget.refetch!();
          Navigator.pop(context);
        }
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
                buildTextField(
                    label: "fullname", errMsg: "Fullname is required!",
                    focusNode: nameFocusNode,
                    initialValue: widget.isEdit == true ? fullname : null),
                buildTextField(label: "email", errMsg: "Email is required!",
                    focusNode: emailFocusNode,
                    initialValue: widget.isEdit == true ? email : null),
                buildTextField(
                    label: "phone", errMsg: "Phone must be 8 digit!",
                    focusNode: phoneFocusNode,
                    initialValue: widget.isEdit == true ? phone : null),
                widget.isEdit == null ? buildTextField(
                    label: "password", errMsg: "Password length must be 6", focusNode: passwordFocusNode
                ) : SizedBox(height: 0,),
                // buildDropDownMenu(context, "Active"),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     Text("Employee Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                //
                //   ],
                // ),
                // widget.isEdit == true ? buildDateTimeField("Created At", dateCreateController) : SizedBox(height: 0,),
                // widget.isEdit == true ? buildDateTimeField("Updated At", dateUpdateController) : SizedBox(height: 0,),
                buildDropDownMenu(),
                widget.isEdit == null ? buildRegisterButton(context, status) : Row(
                  children: [
                    Expanded(child: buildRegisterButton(context, status)),
                    Expanded(child: buildDeleteEmployeeButton(context, status))
                  ],
                ),
                // widget.isEdit == true ? buildDeleteEmployeeButton(context, status) : SizedBox(height: 0,),
                ImagePickerWidget(
                  clearImage: clearImagePicker,
                  singleImage: true,
                  isEdit: widget.isEdit,
                  imageFromFirestore: widget.isEdit == true ? [widget.userModel!.userPhoto] : [],
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

  Widget buildDateTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: TextFormField(
        readOnly: true,
        controller: controller,
        style: TextStyle(fontSize: 18.0),
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

  Widget buildDropDownMenu() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: DropdownButtonFormField(
        focusNode: activeStatusFocusNode,
        key: dropDownFormKey,
        items: activeStatusDropDownList
            .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item['label'],
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ))
        ).toList(),
        icon: Icon(Icons.arrow_drop_down_circle),
        decoration: InputDecoration(
          labelText: "employee active",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        hint: widget.isEdit == true && createdUpdatedUserModel == null ? Text(activeStatus == true ? "YES" : "NO") : null,
        validator: (input) =>
            selectedActiveItem == null ? "Please select status" : null,
        onChanged: (value) {
          setState(() {
            selectedActiveItem = value;
            activeStatus = selectedActiveItem['value'];
          });
          // print("select: $selectedActiveItem");
          // print("active: $activeStatus");
        },
      ),
    );
  }

  // Widget buildPopUpMenu() {
  //   return PopupMenuButton(
  //     icon: Icon(Icons.arrow_downward),
  //     offset: Offset(0, 40),
  //     itemBuilder: (context) {
  //       return activeStatusDropDownList
  //           .map(
  //             (item) => PopupMenuItem(
  //                 value: item['value'], child: Text(item['label'])),
  //           )
  //           .toList();
  //     },
  //     onSelected: (value) {
  //       selectedActiveItem = value;
  //       activeController.text = selectedActiveItem['label'];
  //     },
  //   );
  // }

  Widget buildRegisterButton(BuildContext context, Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      width: widget.isEdit == null ? double.infinity : null,
      height: widget.isEdit == null ? 60 : null,
      decoration: BoxDecoration(
        gradient: gradientBackground(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading && !isDeleting
              ? "Please wait"
              : widget.isEdit == true ? "Update Employee" : "Register Employee",
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
            isDeleting = false;
          });
        },
      ),
    );
  }

  Widget buildDeleteEmployeeButton(BuildContext context, Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      decoration: BoxDecoration(
        gradient: gradientBackground(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading && isDeleting ? "Please wait" : "Delete Employee",
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: GoogleFonts.poppins().fontFamily),
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          if (status == Status.Loading) return;
          deleteEmployee();
          setState(() {
            isDeleting = true;
          });
        },
      ),
    );
  }

  Widget buildTextField(
      {required String label,
      required String errMsg,
      required FocusNode focusNode,
      String? initialValue}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
      child: TextFormField(
        obscureText: label == "password" ? isObscured : false,
        focusNode: focusNode,
        keyboardType: label == "phone"
            ? TextInputType.phone
            : label == "email"
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
        initialValue: initialValue,
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

  // Widget buildTextFieldForPopUpMenu(String label, String errMsg, FocusNode focusNode) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
  //     child: TextFormField(
  //       controller: activeController,
  //       readOnly: true,
  //       onTap: () {
  //         buildPopUpMenu();
  //       },
  //       decoration: InputDecoration(
  //         labelText: label,
  //         labelStyle: TextStyle(fontSize: 18.0),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(10.0),
  //         ),
  //         suffixIcon: buildPopUpMenu(),
  //       ),
  //       validator: (input) =>
  //           activeStatus2 == null ? "Please select active status" : null,
  //       onSaved: (value) {
  //         activeStatus2 = activeController.text;
  //       },
  //     ),
  //   );
  // }

  // Widget buildCustomDropDownMenu() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: DropdownBelow(
  //       isDense: true,
  //       itemWidth: 150,
  //       itemTextstyle: TextStyle(
  //           fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
  //       boxTextstyle: TextStyle(
  //           fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white54),
  //       boxPadding: EdgeInsets.all(12),
  //       boxWidth: 150,
  //       boxHeight: 60,
  //       boxDecoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         color: Colors.transparent,
  //         border: Border.all(
  //           width: 1,
  //           color: Colors.black38,
  //         ),
  //       ),
  //       icon: Icon(
  //         Icons.arrow_downward,
  //       ),
  //       hint: Text(
  //         'Active',
  //         style: TextStyle(
  //           color: Colors.black,
  //         ),
  //       ),
  //       value: selectedActiveItem,
  //       items: dropDownItems,
  //       onChanged: (selected) {
  //         setState(() {
  //           selectedActiveItem = selected;
  //         });
  //         print("selected: ${selectedActiveItem['value']}");
  //       },
  //     ),
  //   );
  // }

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
