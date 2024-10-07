
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

  // LocationModel.withId({this.id, required this.areaName, required this.companyId, required this.createdBy,
  //   required this.createdTime, required this.latPosition, required this.lonPosition,
  //   required this.streetAddress, required this.online});


  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[Constants.FirebaseLocationId] = id;
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
    String? streetAddress,
    bool? online
}) {
    return LocationModel(
        id: id ?? this.id,
        areaName: areaName ?? this.areaName,
        companyId: companyId ?? this.companyId,
        createdBy: createdBy ?? this.createdBy,
        createdTime: createdTime ?? this.createdTime,
        latPosition: latPosition ?? this.latPosition,
        lonPosition: lonPosition ?? this.lonPosition,
        streetAddress: streetAddress ?? this.streetAddress,
        online: online ?? this.online,
    );
  }


  Map<String, dynamic> toMapLocal() {
    final map = <String, dynamic>{};
    if (id != null) {
      map[Constants.ColLocationId] = id;
    }
    map[Constants.ColLocationAreaName] = areaName;
    map[Constants.ColLocationCompanyId] = companyId;
    map[Constants.ColLocationCreatedBy] = createdBy;
    map[Constants.ColLocationCreatedTime] = createdTime.toIso8601String();
    map[Constants.ColLocationLatPosition] = latPosition;
    map[Constants.ColLocationLonPosition] = lonPosition;
    map[Constants.ColLocationStreetAddress] = streetAddress;
    map[Constants.ColLocationOnline] = online == true ? 1 : 0;
    return map;
  }

  factory LocationModel.fromMapLocal(Map<String, dynamic> map) {
    return LocationModel(
        id: (map[Constants.ColLocationId]).toString(),
        areaName: map[Constants.ColLocationAreaName],
        companyId: map[Constants.ColLocationCompanyId],
        createdBy: map[Constants.ColLocationCreatedBy],
        createdTime:  DateTime.parse(map[Constants.ColLocationCreatedTime]),
        latPosition: map[Constants.ColLocationLatPosition],
        lonPosition: map[Constants.ColLocationLonPosition],
        streetAddress: map[Constants.ColLocationStreetAddress],
        online: map[Constants.ColLocationOnline] == 1 ? true : false
    );
  }

  @override
  String toString() {
    return 'LocationModel{id: $id, areaName: $areaName, companyId: $companyId, createdBy: $createdBy, createdTime: $createdTime, latPosition: $latPosition, lonPosition: $lonPosition, streetAddress: $streetAddress}';
  }
}