import 'package:flutter/material.dart';
import 'package:marketing_up/dashboard_screen.dart';
import 'package:marketing_up/firebase_provider.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/screens/dashboard_screen_copy.dart';
import 'package:marketing_up/screens/register_screen.dart';
import 'package:marketing_up/widgets/appbar_widget.dart';
import 'package:marketing_up/widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreenCopy extends StatefulWidget {
  const LoginScreenCopy({super.key});

  @override
  State<LoginScreenCopy> createState() => _LoginScreenCopyState();
}

class _LoginScreenCopyState extends State<LoginScreenCopy> {
  UserModel? userModel;
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String email = "";
  String password = "";
  bool isObscured = true;
  bool fieldsError = false;
  bool retry = false;
  late FirebaseProvider firebaseProvider;

  void showSnackbar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void submitLoginData() async {
    email = emailController.text;
    password = passwordController.text;
    if (email.isNotEmpty && password.isNotEmpty) {
      Map<String, dynamic>? userInfo =
          await firebaseProvider.loginUser(email, password);
      if (userInfo != null) {
        userModel = UserModel.fromMap(userInfo);
      }
    } else {
      showSnackbar(context, "Fields are empty please fill up");
    }
  }

  void goDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => DashboardScreenCopy(
                  userModel: userModel,
                )),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    firebaseProvider = context.read<FirebaseProvider>();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Status status = context.watch<FirebaseProvider>().status;
    String responseMsg = Provider.of<FirebaseProvider>(context).responseMsg;

    print("login: $status");

    // to show snackbar we have to use inside addpostframecallback
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (status == Status.Success && userModel != null) {
        // showSnackbar(context, responseMsg);
        goDashboard();
      } else if (status == Status.Fail && !retry) {
        showSnackbar(context, responseMsg);
      } else if (status == Status.Error && !retry) {
        showSnackbar(context, responseMsg);
      }
    });

    return Scaffold(
        appBar: appBarWidget(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              status == Status.Loading
                  ? Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: LinearProgressIndicator(),
                    )
                  : SizedBox.shrink(),
              Container(
                height: 300,
                width: 300,
                child: Image.asset("images/login_bg-one.png"),
              ),
              SizedBox(
                height: 10,
              ),
              buildTextField("email", emailController, status),
              buildTextField("password", passwordController, status),
              buildLoginButton(context, status),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RegisterScreen()));
                      },
                      child: Text(
                        "Register Here",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                            fontFamily: GoogleFonts.poppins().fontFamily
                        ),
                      ))
                ],
              )
            ],
          ),
        ));
  }

  Container buildLoginButton(BuildContext context, Status status) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
      height: 60.0,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradientBackground(),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: TextButton(
        child: Text(
          status == Status.Loading ? "Please wait" : "Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: GoogleFonts.roboto().fontFamily
          ),
        ),
        onPressed: () {
          setState(() {
            fieldsError = emailController.text.isEmpty || passwordController.text.isEmpty;
            retry = false;
          });
          if (status == Status.Loading) return;
          submitLoginData();
        },
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, Status status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 14),
      child: TextField(
        controller: controller,
        obscureText: label == "password" ? isObscured : false,
        style: TextStyle(fontSize: 16.0),
        decoration: InputDecoration(
            labelText: label,
            errorText: fieldsError ? "Fields can't be empty" : null,
            labelStyle: TextStyle(fontSize: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            hintText: label == "password" ? "Password" : "Email",
            prefixIcon:
                label == "password" ? Icon(Icons.lock) : Icon(Icons.person),
            suffixIcon: label == "password"
                ? IconButton(
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
                : null
        ),
      ),
    );
  }
}
