
import 'package:flutter/material.dart';
import 'package:marketing_up/dashboard_screen.dart';
import 'package:marketing_up/screens/register_screen.dart';

class LoginScreenCopy extends StatefulWidget {
  const LoginScreenCopy({super.key});

  @override
  State<LoginScreenCopy> createState() => _LoginScreenCopyState();
}

class _LoginScreenCopyState extends State<LoginScreenCopy> {

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
      body: SingleChildScrollView(
        child: Column(
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
            buildLoginButton(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?"),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen()));
                    },
                    child: Text("Register Here",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),)
                )
              ],
            )
          ],
        ),
      )
    );
  }

  Container buildLoginButton(BuildContext context) {
    return Container(
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
            height: 60.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: TextButton(
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              onPressed: () => goDashboard(context, "admin".toUpperCase()),
            ),
          );
  }

  Widget buildTextField(String label, String errMsg) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 14),
      child: TextFormField(
        obscureText: label == "password" ? isObscured : false,
        focusNode: label == "password" ? passwordFocusNode : emailFocusNode,
        style: TextStyle(fontSize: 16.0),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: label == "password" ? "Password" : "Email",
            prefixIcon: label == "password" ? Icon(Icons.lock) : Icon(Icons.person),
            suffixIcon: label == "password" ? IconButton(
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

