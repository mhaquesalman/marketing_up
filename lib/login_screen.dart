
import 'package:flutter/material.dart';
import 'package:marketing_up/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  void goDashboard(BuildContext context, String type) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => DashboardScreen(type: type)),
        (Route<dynamic> route) => false);
  }

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  String email = "";
  String password = "";
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marketing Up"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            width: 300,
            child: Image.asset("images/login_bg-one.png"),
          ),
          SizedBox(height: 10,),
          buildTextField("email", "Email is required!"),
          buildTextField("password", "Password length must be 6"),
          SizedBox(height: 10,),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
            height: 60.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: TextButton(
              child: Text(
                "Login as Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              onPressed: () => goDashboard(context, "admin".toUpperCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text("OR",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
            height: 60.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: TextButton(
              child: Text(
                "Login as Employee",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              onPressed: () => goDashboard(context, "employee".toLowerCase()),
            ),
          ),
        ],
      )
    );
  }

  Widget buildTextField(String label, String errMsg) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: TextFormField(
        obscureText: label == "password" ? isObscured : false,
        focusNode: label == "password" ? passwordFocusNode : emailFocusNode,
        style: TextStyle(fontSize: 18.0),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 18.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: label == "password" ? "Password" : "Email",
          icon: label == "password" ? Icon(Icons.lock) : Icon(Icons.person),
          suffixIcon: label == "password" ? IconButton(
            padding: EdgeInsetsDirectional.only(end: 10),
            icon: isObscured ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                isObscured = !isObscured;
              });
            },
          ) : null
        ),
        validator: (input) {
          if (label == "password") {
            if (input!.trim().length < 6) {
              passwordFocusNode.requestFocus();
              return errMsg;
            } else return null;
          } else {
            if(input!.trim().isEmpty) {
              emailFocusNode.requestFocus();
              return errMsg;
            } else if (!input.trim().contains("@")) {
              emailFocusNode.requestFocus();
              return "Valid email address must contain @";
            } else return null;
          }
        },
        onSaved: (value) {
          if (label == "password") {
            if (value != null) password = value;
          } else {
            if (value != null) email = value;
          }
        },
      ),
    );
  }
}

