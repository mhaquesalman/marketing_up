
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketing_up/constants.dart';

class LocationModel {
  String? id;
  String areaName;
  String companyId;
  String createdBy;
  DateTime createdTime;
  String latPosition;
  String lonPosition;
  String streetAddress;
  bool online;

  LocationModel({this.id, required this.areaName, required this.companyId, required this.createdBy,
    required this.createdTime, required this.latPosition, required this.lonPosition,
    required this.streetAddress, required this.online});


  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[Constants.FirebaseLocationAreaName] = areaName;
    map[Constants.FirebaseLocationCompanyId] = companyId;
    map[Constants.FirebaseLocationCreatedBy] = createdBy;
    map[Constants.FirebaseLocationCreatedTime] = createdTime;
    map[Constants.FirebaseLocationLatPosition] = latPosition;
    map[Constants.FirebaseLocationLonPosition] = lonPosition;
    map[Constants.FirebaseLocationStreetAddress] = streetAddress;
    map[Constants.FirebaseLocationOnline] = online;

    return map;
  }

  factory LocationModel.from(DocumentSnapshot doc) {
    return LocationModel(
        id: doc.get(Constants.FirebaseLocationId) ?? "",
        areaName: doc.get(Constants.FirebaseLocationAreaName),
        companyId: doc.get(Constants.FirebaseLocationCompanyId),
        createdBy: doc.get(Constants.FirebaseLocationCreatedBy),
        createdTime: (doc.get(Constants.FirebaseLocationCreatedTime) as Timestamp).toDate(),
        latPosition: doc.get(Constants.FirebaseLocationLatPosition),
        lonPosition: doc.get(Constants.FirebaseLocationLonPosition),
        streetAddress: doc.get(Constants.FirebaseLocationStreetAddress),
        online: doc.get(Constants.FirebaseLocationOnline),
    );
  }

  LocationModel copyWith({
    String? id,
    String? areaName,
    String? companyId,
    String? createdBy,
    DateTime? createdTime,
    String? latPosition,
    String? lonPosition,
    String? streetAddress
}) {
    return LocationModel(
        id: id ?? this.id,
        areaName: areaName ?? this.areaName,
        companyId: companyId ?? this.companyId,
        createdBy: createdBy ?? this.companyId,
        createdTime: createdTime ?? this.createdTime,
        latPosition: latPosition ?? this.latPosition,
        lonPosition: lonPosition ?? this.lonPosition,
        streetAddress: streetAddress ?? this.streetAddress
    );
  }

  @override
  String toString() {
    return 'LocationModel{id: $id, areaName: $areaName, companyId: $companyId, createdBy: $createdBy, createdTime: $createdTime, latPosition: $latPosition, lonPosition: $lonPosition, streetAddress: $streetAddress}';
  }
}