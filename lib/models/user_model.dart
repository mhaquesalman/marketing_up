import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketing_up/constants.dart';

class UserModel {
  final String? id;
  final bool activeStatus;
  final String companyUserLimit;
  final String companyId;
  final String companyVisitLimit;
  final String createdBy;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String password;
  final String userPhoto;
  final String userType;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? token;

  UserModel(
      {this.id,
      required this.activeStatus,
      required this.companyUserLimit,
      required this.companyId,
      required this.companyVisitLimit,
      required this.createdBy,
      required this.email,
      required this.fullName,
      required this.phoneNumber,
      required this.password,
      required this.userPhoto,
      required this.userType,
      required this.createdAt,
      required this.updatedAt});

  UserModel.withToken(
      {this.id, this.token,
        required this.activeStatus,
        required this.companyUserLimit,
        required this.companyId,
        required this.companyVisitLimit,
        required this.createdBy,
        required this.email,
        required this.fullName,
        required this.phoneNumber,
        required this.password,
        required this.userPhoto,
        required this.userType,
        required this.createdAt,
        required this.updatedAt});


  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[Constants.FirebaseUserId] = id;
    map[Constants.FirebaseActiveStatus] = activeStatus;
    map[Constants.FirebaseCompanyUserLimit] = companyUserLimit;
    map[Constants.FirebaseCompanyId] = companyId;
    map[Constants.FirebaseCompanyVisitLimit] = companyVisitLimit;
    map[Constants.FirebaseCreatedAt] = Timestamp.fromDate(createdAt);
    map[Constants.FirebaseCreatedBy] = createdBy;
    map[Constants.FirebaseEmail] = email;
    map[Constants.FirebaseFullName] = fullName;
    map[Constants.FirebasePassword] = password;
    map[Constants.FirebasePhoneNumber] = phoneNumber;
    map[Constants.FirebaseUpdatedAt] = Timestamp.fromDate(updatedAt);
    map[Constants.FirebaseUserPhoto] = userPhoto;
    map[Constants.FirebaseUserType] = userType;
    return map;
  }

  Map<String, dynamic> toMapForLocal() {
    final map = <String, dynamic>{};
    map[Constants.FirebaseUserId] = id;
    map[Constants.FirebaseActiveStatus] = activeStatus;
    map[Constants.FirebaseCompanyUserLimit] = companyUserLimit;
    map[Constants.FirebaseCompanyId] = companyId;
    map[Constants.FirebaseCompanyVisitLimit] = companyVisitLimit;
    map[Constants.FirebaseCreatedAt] = createdAt.toIso8601String();
    map[Constants.FirebaseCreatedBy] = createdBy;
    map[Constants.FirebaseEmail] = email;
    map[Constants.FirebaseFullName] = fullName;
    map[Constants.FirebasePassword] = password;
    map[Constants.FirebasePhoneNumber] = phoneNumber;
    map[Constants.FirebaseUpdatedAt] = updatedAt.toIso8601String();
    map[Constants.FirebaseUserPhoto] = "userPhoto";
    map[Constants.FirebaseUserType] = userType;
    return map;
  }

  factory UserModel.from(DocumentSnapshot doc) {
    return UserModel(
        id: doc.get(Constants.FirebaseUserId) ?? "",
        activeStatus: doc.get(Constants.FirebaseActiveStatus),
        companyUserLimit: doc.get(Constants.FirebaseCompanyUserLimit),
        companyId: doc.get(Constants.FirebaseCompanyId),
        companyVisitLimit: doc.get(Constants.FirebaseCompanyVisitLimit),
        createdBy: doc.get(Constants.FirebaseCreatedBy),
        email: doc.get(Constants.FirebaseEmail),
        fullName: doc.get(Constants.FirebaseFullName),
        phoneNumber: doc.get(Constants.FirebasePhoneNumber),
        password: doc.get(Constants.FirebasePassword),
        userPhoto: doc.get(Constants.FirebaseUserPhoto),
        userType: doc.get(Constants.FirebaseUserType),
        createdAt: (doc.get(Constants.FirebaseCreatedAt) as Timestamp).toDate(),
        updatedAt: (doc.get(Constants.FirebaseUpdatedAt) as Timestamp).toDate()
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel.withToken(
        id: map[Constants.FirebaseUserId],
        token: map[Constants.FirebaseToken],
        activeStatus: map[Constants.FirebaseActiveStatus],
        companyUserLimit: map[Constants.FirebaseCompanyUserLimit],
        companyId: map[Constants.FirebaseCompanyId],
        companyVisitLimit: map[Constants.FirebaseCompanyVisitLimit],
        createdBy: map[Constants.FirebaseCreatedBy],
        email: map[Constants.FirebaseEmail],
        fullName: map[Constants.FirebaseFullName],
        phoneNumber: map[Constants.FirebasePhoneNumber],
        password: map[Constants.FirebasePassword],
        userPhoto: map[Constants.FirebaseUserPhoto],
        userType: map[Constants.FirebaseUserType],
        createdAt: (map[Constants.FirebaseCreatedAt] as Timestamp).toDate(),
        updatedAt: (map[Constants.FirebaseUpdatedAt] as Timestamp).toDate()
    );
  }

  UserModel copyWith(
      {String? id,
      bool? activeStatus,
      String? companyUserLimit,
      String? companyId,
      String? companyVisitLimit,
      String? createdBy,
      String? email,
      String? fullName,
      String? phoneNumber,
      String? password,
      String? userPhoto,
      String? userType,
      DateTime? createdAt,
      DateTime? updatedAt}) {
    return UserModel(
        id: id ?? this.id,
        activeStatus: activeStatus ?? this.activeStatus,
        companyUserLimit: companyUserLimit ?? this.companyUserLimit,
        companyId: companyId ?? this.companyId,
        companyVisitLimit: companyVisitLimit ?? this.companyVisitLimit,
        createdBy: createdBy ?? this.createdBy,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        password: password ?? this.password,
        userPhoto: userPhoto ?? this.userPhoto,
        userType: userType ?? this.userType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  @override
  String toString() {
    return 'UserModel{id: $id, activeStatus: $activeStatus, companyUserLimit: $companyUserLimit, companyId: $companyId, companyVisitLimit: $companyVisitLimit, '
        'createdBy: $createdBy, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, userType: $userType, createdAt: $createdAt, '
        'updatedAt: $updatedAt, token: $token}';
  }
}
