import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/models/user_model.dart';

enum Status { Initial, Loading, Success, Fail, Error }

class FirebaseProvider with ChangeNotifier {
  Status _status = Status.Initial;

  Status get status => _status;
  String responseMsg = "";

  FirebaseFirestore firebaseFirestore;
  FirebaseAuth firebaseAuth;

  FirebaseProvider(
      {required this.firebaseFirestore, required this.firebaseAuth});

  Future<UserModel?> registerUser(UserModel userModel,
      String plainPassword) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference userRef = firebaseFirestore.collection(
          Constants.FirebaseUserCollection);

      // QuerySnapshot snapshots = await userRef.where('email', isEqualTo: userModel.email).get();
      // List<DocumentSnapshot> documents = snapshots.docs;

      // String userRefDocId = userRef.doc().id;
      // UserModel userModelWithId = userModel.copyWith(id: userRefDocId);
      // add a new doc with post generated random id
      // DocumentReference documentReference = await userRef.add(userModelWithId.toMap());
      // set a new doc with pre generated random id
      UserCredential userCredential =
      await firebaseAuth.createUserWithEmailAndPassword(
          email: userModel.email, password: plainPassword);

      String userRefDocId = userCredential.user != null
          ? userCredential.user!.uid
          : DateTime
          .now()
          .microsecondsSinceEpoch
          .toString();
      // print("credential: ${userCredential.user!.uid}");
      UserModel userModelWithId = userModel.copyWith(id: userRefDocId);
      userRef.doc(userRefDocId).set(userModelWithId.toMap());
      responseMsg = "Registration is completed successfully";
      _status = Status.Success;
      notifyListeners();
      return userModel;
    } catch (err) {
      if (err is FirebaseAuthException) {
        /// `foo@bar.com` has already been registered.
        print("platform error: ${err.code}");
        if (err.code == "email-already-in-use")
          responseMsg = "This email is already registered";
        else if (err.code == "invalid-email")
          responseMsg = "Email address is not valid try with valid address";
        else if (err.code == "weak-password")
          responseMsg = "Password is weak try strong one";
        _status = Status.Fail;
        notifyListeners();
        return null;
      } else {
        print("error: ${err.toString()}");
        responseMsg = "Something wrong!";
        _status = Status.Error;
        notifyListeners();
        return null;
      }
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email,
      String plainPassword) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      // DocumentSnapshot documentSnapshot = await userRef.doc(userModel.id).get();

      CollectionReference userRef = firebaseFirestore.collection(
          Constants.FirebaseUserCollection);
      QuerySnapshot snapshots = await userRef.where('email', isEqualTo: email).get();
      List<DocumentSnapshot> documents = snapshots.docs;

      if (documents.length == 1) {
        DocumentSnapshot documentSnapshot = documents[0];
        UserModel userModel = UserModel.from(documentSnapshot);
        bool isActive = userModel.activeStatus;

        if (isActive) {
          UserCredential userCredential = await firebaseAuth
              .signInWithEmailAndPassword(
              email: userModel.email, password: plainPassword);
          String idToken = await userCredential.user?.getIdToken() ?? "";
          // print("user login info: ${userCredential.user}");
          // print("user login token: $idToken");
          Map<String, dynamic> mapUserModel = userModel.toMap();
          if (userCredential.user != null) {
            Map<String, dynamic> userModelWithCredential =
            {
              ...mapUserModel,
              Constants.FirebaseToken: idToken
            };
            responseMsg = "Successfully logged in";
            _status = Status.Success;
            notifyListeners();
            return userModelWithCredential;
          } else
            return mapUserModel;
        } else {
          responseMsg = "Account is not active, contact in 9999";
          _status = Status.Fail;
          notifyListeners();
          return null;
        }
      } else {
        responseMsg = "User not exist!";
        _status = Status.Fail;
        notifyListeners();
        return null;
      }
    } catch (err) {
      if (err is FirebaseAuthException) {
        print("auth error: ${err.code}");
        if (err.code == "invalid-credential")
          responseMsg = "Email and password doesn't match";
        else if (err.code == "invalid-email")
          responseMsg = "Email is not valid";
        else if (err.code == "user-not-found")
          responseMsg = "User not found";
        _status = Status.Fail;
        notifyListeners();
        return null;
      } else {
        print("error: ${err.toString()}");
        responseMsg = "Something wrong!";
        _status = Status.Error;
        notifyListeners();
        return null;
      }
    }
  }

  Future<void> logout() => firebaseAuth.signOut();
}
