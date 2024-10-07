import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:marketing_up/constants.dart';
import 'package:marketing_up/models/location_model.dart';
import 'package:marketing_up/models/user_model.dart';
import 'package:marketing_up/models/visit_model.dart';
import 'package:marketing_up/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status { Initial, Loading, Success, Fail, Error }

class FirebaseProvider with ChangeNotifier {
  Status _status = Status.Initial;
  Status get status => _status;

  void resetStatus() {
    _status = Status.Initial;
    notifyListeners();
  }

  String responseMsg = "";

  List<UserModel> _listOfEmployees = [];
  List<UserModel> get listOfEmployees => _listOfEmployees;

  void setListOfEmployees(List<UserModel>? list) {
    _listOfEmployees.clear();
    _listOfEmployees.addAll(list ?? []);
  }

  UserModel? _loggedInUserModel;
  UserModel? get loggedInUserModel => _loggedInUserModel;

  void setLoggedInUserModel(UserModel userModel) {
    _loggedInUserModel = userModel;
  }

  FirebaseFirestore firebaseFirestore;
  FirebaseAuth firebaseAuth;
  SharedPreferences preferences;

  FirebaseProvider(
      {required this.firebaseFirestore, required this.firebaseAuth, required this.preferences});

  String? getEmployeeFromSharedPref() => preferences.getString(Constants.SharedPrefSavedEmployee);
  String? getEmployeeLoggedInExpiredFromSharedPref() => preferences.getString(Constants.SharedPrefEmployeeLoginExpired);
  String? getEmployeeLoginTimeFromSharedPref() => preferences.getString(Constants.SharedPrefEmployeeLoginTime);
  String? getLocationSavedTimeFromSharedPref() => preferences.getString(Constants.SharedPrefLocationSavedTime);

  void saveLocationTime(String savedTime) async {
    await preferences.setString(Constants.SharedPrefLocationSavedTime, savedTime);
  }

  bool isEmployeeLoggedIn() {
    bool isLoginNotExpired = false;
    if (getEmployeeLoggedInExpiredFromSharedPref() != null) {
      DateTime expiredTime = DateTime.parse(getEmployeeLoggedInExpiredFromSharedPref()!);
      isLoginNotExpired = DateTime.now().isBefore(expiredTime);
    }
    bool isEmployeeSaved = getEmployeeFromSharedPref() != null;
    return isEmployeeSaved && isLoginNotExpired;
  }

  Future<UserModel?> registerUser(UserModel userModel, String plainPassword,
      {String signupFor = Constants.DefaultUserType}) async {
    _status = Status.Loading;
    notifyListeners();
    try {

      // generating random id
      // String userRefDocId = userRef.doc().id;
      // UserModel userModelWithId = userModel.copyWith(id: userRefDocId);
      // add a new doc with post generated random id
      // DocumentReference documentReference = await userRef.add(userModelWithId.toMap());
      // set a new doc with pre generated random id
      // userRef.doc(userRefDocId).set(userModelWithId.toMap());

      CollectionReference userRef = firebaseFirestore.collection(Constants.FirebaseUserCollection);

      if (userModel.userType == Constants.DefaultEmployeeType) {
        QuerySnapshot snapshots = await userRef.where(Constants.FirebaseEmail, isEqualTo: userModel.email).get();
        List<DocumentSnapshot> documents = snapshots.docs;
        if (documents.length == 1) {
          _status = Status.Fail;
          responseMsg = "Employee is existed with this email";
          notifyListeners();
          return null;
        } else {
          String userRefDocId = DateTime.now().microsecondsSinceEpoch.toString();
          // print("credential: ${userCredential.user!.uid}");
          UserModel userModelWithId = userModel.copyWith(id: userRefDocId);
          await userRef.doc(userRefDocId).set(userModelWithId.toMap());
          responseMsg = "Employee registration is completed";
          _status = Status.Success;
          notifyListeners();
          return userModelWithId;
        }
      } else {
        UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: userModel.email, password: plainPassword);
        String userRefDocId = userCredential.user != null ? userCredential.user!.uid : DateTime.now().microsecondsSinceEpoch.toString();
        // print("credential: ${userCredential.user!.uid}");
        UserModel userModelWithId = userModel.copyWith(id: userRefDocId);
        await userRef.doc(userRefDocId).set(userModelWithId.toMap());
        responseMsg = "Registration is completed successfully";
        _status = Status.Success;
        notifyListeners();
        return userModelWithId;
      }

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

  Future<Map<String, dynamic>?> loginUser(String email, String plainPassword) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      // DocumentSnapshot documentSnapshot = await userRef.doc(userModel.id).get();

      CollectionReference userRef = firebaseFirestore.collection(Constants.FirebaseUserCollection);
      QuerySnapshot snapshots = await userRef.where(Constants.FirebaseEmail, isEqualTo: email).get();
      List<DocumentSnapshot> documents = snapshots.docs;

      if (documents.length == 1) {
        DocumentSnapshot documentSnapshot = documents[0];
        UserModel userModel = UserModel.from(documentSnapshot);
        bool isActive = userModel.activeStatus;
        String userType = userModel.userType;

        if (isActive && userType == Constants.DefaultUserType) {
          UserCredential userCredential = await firebaseAuth
              .signInWithEmailAndPassword(email: userModel.email, password: plainPassword);
          String idToken = await userCredential.user?.getIdToken() ?? "";
          print("user login info: ${userCredential.user}");
          // print("user login token: $idToken");
          Map<String, dynamic> mapUserModel = userModel.toMap();
          if (userCredential.user != null) {
            Map<String, dynamic> userModelWithCredential = {...mapUserModel, Constants.FirebaseToken: idToken};
            responseMsg = "Successfully logged in by admin";
            _status = Status.Success;
            setLoggedInUserModel(userModel);
            notifyListeners();
            return userModelWithCredential;
          } else return mapUserModel;
        } else {

          if (userType == Constants.DefaultEmployeeType) {
            String encryptPass = Utils.encryptPassword(plainPassword);
            if (encryptPass == userModel.password) {
              if (userModel.activeStatus) {
                DateTime loginTime = DateTime.now();
                DateTime loginWillExpire = loginTime.add(const Duration(days: 7));
                final jsonValue = jsonEncode(userModel.toMapForLocal());
                // print("json model: $jsonValue");
                // await preferences.setString(Constants.SharedPrefEmployeeLoginTime, loginTime.toIso8601String());
                // await preferences.setString(
                //     Constants.SharedPrefEmployeeId, userModel.id!);
                // await preferences.setString(
                //     Constants.SharedPrefEmployeeLoginExpired,
                //     loginWillExpire.toIso8601String());

                Map<String, dynamic> mapUserModel = userModel.toMap();
                Map<String, dynamic> userModelWithCredential = {...mapUserModel, Constants.FirebaseToken: ""};
                responseMsg = "Successfully logged in by employee";
                _status = Status.Success;
                setLoggedInUserModel(userModel);
                notifyListeners();
                return userModelWithCredential;
              } else {
                responseMsg = "Account is not active contact with your admin";
                _status = Status.Fail;
                notifyListeners();
                return null;
              }
            } else {
              responseMsg = "Email and password doesn't match";
              _status = Status.Fail;
              notifyListeners();
              return null;
            }
          } else {
            responseMsg = "Account is not active, contact in 9999";
            _status = Status.Fail;
            notifyListeners();
            return null;
          }
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

  Future<List<UserModel>?> getUsersByCreatedBy(String createdBy) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference userRef = firebaseFirestore.collection(Constants.FirebaseUserCollection);
      QuerySnapshot snapshots = await userRef
          .where(Constants.FirebaseCreatedBy, isEqualTo: createdBy)
          .orderBy(Constants.FirebaseCreatedAt, descending: true).get();
      print("users snapshots: ${snapshots.docs.length}");
      List<DocumentSnapshot> documents = snapshots.docs;
      List<UserModel> employees = [];
      if (documents.isNotEmpty) {
        documents.forEach((DocumentSnapshot documentSnapshot) {
          UserModel userModelOfEmployee = UserModel.from(documentSnapshot);
          employees.add(userModelOfEmployee);
        });
        responseMsg = "Employees loaded successfully";
        _status = Status.Success;
        notifyListeners();
        return employees;
      } else {
        responseMsg = "No employee available for this admin";
        _status = Status.Fail;
        notifyListeners();
        return employees;
      }
    } catch(err) {
      print("loadUsers Error: ${err.toString()}");
      responseMsg = "Something Wrong in fetching";
      _status = Status.Error;
      notifyListeners();
      return null;
    }
  }

  Future<UserModel?> updateEmployee(UserModel userModel) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference userRef = firebaseFirestore.collection(Constants.FirebaseUserCollection);
      await userRef.doc(userModel.id).update(userModel.toMap());
      _status = Status.Success;
      responseMsg = "Information updated successfully";
      notifyListeners();
      return userModel;
    } catch (err) {
      print("employee update err: ${err.toString()}");
      _status = Status.Error;
      responseMsg = "Update failed!";
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteEmployee(String userId) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference userRef = firebaseFirestore.collection(Constants.FirebaseUserCollection);
      await userRef.doc(userId).delete();
      _status = Status.Success;
      responseMsg = "Employee deleted successfully";
      notifyListeners();
    } catch(err) {
      print("employee delete err: ${err.toString()}");
      _status = Status.Error;
      responseMsg = "Delete failed!";
      notifyListeners();
    }
  }

  Future<VisitModel?> insertVisit(VisitModel visitModel) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference visitRef = firebaseFirestore.collection(Constants.FirebaseVisitCollection);
      String visitRefId = visitRef.doc().id;
      VisitModel visitModelWithId = visitModel.copyWith(id: visitRefId);
      await visitRef.doc(visitRefId).set(visitModelWithId.toMap());
      responseMsg = "New visit has been added";
      _status = Status.Success;
      notifyListeners();
      return visitModelWithId;
    } catch (err) {
      print("insert visit err: ${err.toString()}");
      responseMsg = "Error while creating";
      _status = Status.Error;
      notifyListeners();
      return null;
    }
  }

  Future<List<VisitModel>?> fetchVisits(String createdBy, String companyId, String userType) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference visitRef = firebaseFirestore.collection(Constants.FirebaseVisitCollection);
      if (userType == Constants.DefaultEmployeeType) {
        QuerySnapshot snapshots = await visitRef
            .where(Constants.FirebaseVisitCreatedBy, isEqualTo: createdBy)
            .orderBy(Constants.FirebaseVisitCreatedTime, descending: true)
            .get();
        print("visits snapshots for employee: ${snapshots.docs.length}");
        List<DocumentSnapshot> documents = snapshots.docs;
        List<VisitModel> visits = [];
        if (documents.isNotEmpty) {
          documents.forEach((DocumentSnapshot documentSnapshot) {
            VisitModel visitModelForEmployee = VisitModel.from(documentSnapshot);
            visits.add(visitModelForEmployee);
          });
          responseMsg = "Visits loaded successfully";
          _status = Status.Success;
          notifyListeners();
          return visits;
        } else {
          responseMsg = "No visits found";
          _status = Status.Fail;
          notifyListeners();
          return visits;
        }
      } else {
        QuerySnapshot snapshots = await visitRef
            .where(Constants.FirebaseVisitCompanyId, isEqualTo: companyId)
            .orderBy(Constants.FirebaseVisitCreatedTime, descending: true)
            .get();
        print("visits snapshots for admin: ${snapshots.docs.length}");
        List<DocumentSnapshot> documents = snapshots.docs;
        List<VisitModel> visits = [];
        if (documents.isNotEmpty) {
          documents.forEach((DocumentSnapshot documentSnapshot) {
            VisitModel visitModelForAdmin = VisitModel.from(documentSnapshot);
            visits.add(visitModelForAdmin);
          });
          responseMsg = "Visits loaded successfully";
          _status = Status.Success;
          notifyListeners();
          return visits;
        } else {
          responseMsg = "No visits found";
          _status = Status.Fail;
          notifyListeners();
          return visits;
        }
      }
    } catch (err) {
      print("fetch visits err: ${err.toString()}");
      responseMsg = "Error while fetching";
      _status = Status.Error;
      notifyListeners();
      return null;
    }
  }

  Future<VisitModel?> updateVisit(VisitModel visitModel) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference visitRef = firebaseFirestore.collection(Constants.FirebaseVisitCollection);
      await visitRef.doc(visitModel.id).update(visitModel.toMap());
      responseMsg = "Visit data has been updated";
      _status = Status.Success;
      notifyListeners();
      return visitModel;
    } catch (err) {
      print("update visit err: ${err.toString()}");
      responseMsg = "Error while updating";
      _status = Status.Error;
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteVisit(String visitId) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference visitRef = firebaseFirestore.collection(Constants.FirebaseVisitCollection);
      await visitRef.doc(visitId).delete();
      _status = Status.Success;
      responseMsg = "Visit has been deleted successfully";
      notifyListeners();
    } catch(err) {
      print("visit delete err: ${err.toString()}");
      _status = Status.Error;
      responseMsg = "Delete failed!";
      notifyListeners();
    }
  }

  Future<LocationModel?> insertLocation(LocationModel locationModel) async {
    // _status = Status.Loading;
    // notifyListeners();
    try {
      CollectionReference locationRef = firebaseFirestore.collection(Constants.FirebaseLocationCollection);
      // generate unique id using UniqueKey()
      String locationRefId = UniqueKey().hashCode.toString();
      LocationModel locationModelWithId = locationModel.copyWith(id: locationRefId);
      await locationRef.doc(locationRefId).set(locationModelWithId.toMap());
      // responseMsg = "New location has been added";
      // _status = Status.Success;
      // notifyListeners();
      return locationModelWithId;
    } catch (err) {
      print("insert location err: ${err.toString()}");
      // responseMsg = "Error while creating";
      // _status = Status.Error;
      // notifyListeners();
      return null;
    }
  }

  Future<void> deleteLocation(String createdBy) async {
    // _status = Status.Loading;
    // notifyListeners();
    try {
      CollectionReference locationRef = firebaseFirestore.collection(Constants.FirebaseLocationCollection);
      QuerySnapshot snapshots = await locationRef
          .where(Constants.FirebaseLocationCreatedBy, isEqualTo: createdBy).get();
      List<DocumentSnapshot> documents = snapshots.docs;
      if (documents.isNotEmpty) {
        documents.forEach((documentSnapshot) {
          LocationModel locationM = LocationModel.from(documentSnapshot);
          locationRef.doc(locationM.id).delete();
        });
      }
      // responseMsg = "New location has been added";
      // _status = Status.Success;
      // notifyListeners();
    } catch (err) {
      print("delete location err: ${err.toString()}");
      // responseMsg = "Error while creating";
      // _status = Status.Error;
      // notifyListeners();
    }
  }

  Future<List<LocationModel>?> fetchLocations(String userType, String companyId) async {
    // _status = Status.Loading;
    // notifyListeners();
    try {
      CollectionReference locationRef = firebaseFirestore.collection(Constants.FirebaseLocationCollection);
      if (userType == Constants.DefaultUserType) {
        QuerySnapshot snapshots = await locationRef
            .where(Constants.FirebaseCompanyId, isEqualTo: companyId)
            .orderBy(Constants.FirebaseLocationCreatedTime, descending: true)
            .get();
        // print("locations snapshots: ${snapshots.docs.length}");
        List<DocumentSnapshot> documents = snapshots.docs;
        List<LocationModel> locations = [];
        if (documents.isNotEmpty) {
          documents.forEach((DocumentSnapshot documentSnapshot) {
            LocationModel locationModel = LocationModel.from(documentSnapshot);
            locations.add(locationModel);
          });
          // responseMsg = "locations loaded successfully";
          // _status = Status.Success;
          // notifyListeners();
          return locations;
        } else {
          responseMsg = "No locations found";
          _status = Status.Fail;
          notifyListeners();
          return locations;
        }
      } else return null;
    } catch (err) {
      print("fetch locations err: ${err.toString()}");
      // responseMsg = "Error while fetching";
      // _status = Status.Error;
      // notifyListeners();
      return null;
    }
  }

  Future<List<LocationModel>?> getLocationsByCreatedByAndCreatedTime(String createdBy, DateTime createdTime) async {
    _status = Status.Loading;
    notifyListeners();
    try {
      CollectionReference locationRef = firebaseFirestore.collection(Constants.FirebaseLocationCollection);
      // DateFormat dateFormat = DateFormat("MMMM dd,yyyy");
      // String queryDate = dateFormat.format(DateTime.parse(createdTime));
      final dayAfter = createdTime.add(Duration(days: 1));
/*      QuerySnapshot snapshots = await locationRef
          .where(Constants.FirebaseLocationCreatedBy, isEqualTo: createdBy)
          .orderBy(Constants.FirebaseLocationCreatedTime, descending: true)
          .startAt([Timestamp.fromDate(createdTime)])
          .get();*/

      QuerySnapshot snapshots = await locationRef
          .where(Constants.FirebaseLocationCreatedBy, isEqualTo: createdBy)
          .where(Constants.FirebaseLocationCreatedTime, isGreaterThanOrEqualTo: Timestamp.fromDate(createdTime))
          .where(Constants.FirebaseLocationCreatedTime, isLessThan: Timestamp.fromDate(dayAfter))
          .get();

      print("locations by user: ${snapshots.docs.length}");
      List<DocumentSnapshot> documents = snapshots.docs;
      List<LocationModel> locations = [];
      if (documents.isNotEmpty) {
        documents.forEach((DocumentSnapshot documentSnapshot) {
          LocationModel locationModel = LocationModel.from(documentSnapshot);
          locations.add(locationModel);
        });
        responseMsg = "locations loaded successfully";
        _status = Status.Success;
        notifyListeners();
        return locations;
      } else {
        responseMsg = "No locations found";
        _status = Status.Fail;
        notifyListeners();
        return locations;
      }
    } catch (err) {
      print("fetch locations by user err: ${err.toString()}");
      responseMsg = "Error while fetching";
      _status = Status.Error;
      notifyListeners();
      return null;
    }
  }

  void logout(String userType) async {
    if (userType == Constants.DefaultUserType) {
      firebaseAuth.signOut();
    } else {
      await preferences.clear();
    }
  }

}
