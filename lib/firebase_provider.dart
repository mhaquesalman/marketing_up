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

  FirebaseFirestore firebaseFirestore;
  FirebaseAuth firebaseAuth;

  FirebaseProvider(
      {required this.firebaseFirestore, required this.firebaseAuth});

  Future<UserModel?> registerUser(
      UserModel userModel, String plainPassword) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference userRef =
          firebaseFirestore.collection(Constants.FirebaseUserCollection);

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
          : DateTime.now().microsecondsSinceEpoch.toString();
      print("credential: ${userCredential.user!.uid}");
      UserModel userModelWithId = userModel.copyWith(id: userRefDocId);
      userRef.doc(userRefDocId).set(userModelWithId.toMap());
      _status = Status.Success;
      notifyListeners();
      return userModel;
    } catch (err) {
      if (err is FirebaseAuthException) {
        /// `foo@bar.com` has already been registered.
        print("platform error: ${err.code}");
        _status = Status.Fail;
        notifyListeners();
        return null;
      } else {
        print("error: ${err.toString()}");
        _status = Status.Error;
        notifyListeners();
        return null;
      }
    }
  }
}
