import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketing_up/constants.dart';

class VisitModel {
  final String? id;
  final String companyName;
  final String companyId;
  final String contactEmail;
  final String contactNumber;
  final String createdBy;
  final DateTime createdTime;
  final DateTime nextVisitDate;
  final String nextVisitPurpose;
  final List<String>? photos;
  final String position;
  final DateTime visitDate;
  final String visitingPerson;

  VisitModel(
      {this.id,
      required this.companyName,
      required this.companyId,
      required this.contactEmail,
      required this.contactNumber,
        required this.createdBy,
      required this.createdTime,
      required this.nextVisitDate,
      required this.nextVisitPurpose,
      required this.photos,
      required this.position,
      required this.visitDate,
      required this.visitingPerson});


  VisitModel.withId(
      this.id,
      this.companyName,
      this.companyId,
      this.contactEmail,
      this.contactNumber,
      this.createdBy,
      this.createdTime,
      this.nextVisitDate,
      this.nextVisitPurpose,
      this.photos,
      this.position,
      this.visitingPerson,
      this.visitDate);

  VisitModel copyWith({
    String? id,
    String? companyName,
    String? companyId,
    String? contactEmail,
    String? contactNumber,
    String? createdBy,
    DateTime? createdTime,
    DateTime? nextVisitDate,
    String? nextVisitPurpose,
    List<String>? photos,
    String? position,
    DateTime? visitDate,
    String? visitingPerson
}) {
    return VisitModel(
        id: id ?? this.id,
        companyName: companyName ?? this.companyName,
        companyId: companyId ?? this.companyId,
        contactEmail: contactEmail ?? this.contactEmail,
        contactNumber: contactNumber ?? this.contactNumber,
        createdBy: createdBy ?? this.createdBy,
        createdTime: createdTime ?? this.createdTime,
        nextVisitDate: nextVisitDate ?? this.nextVisitDate,
        nextVisitPurpose: nextVisitPurpose ?? this.nextVisitPurpose,
        photos: photos ?? this.photos,
        position: position ?? this.position,
        visitDate: visitDate ?? this.visitDate,
        visitingPerson: visitingPerson ?? this.visitingPerson
    );
  }

  factory VisitModel.from(DocumentSnapshot doc) {
    return VisitModel(
        id: doc.get(Constants.FirebaseVisitId) ?? "",
        companyName: doc.get(Constants.FirebaseVisitCompanyName),
        companyId: doc.get(Constants.FirebaseVisitCompanyId),
        contactEmail: doc.get(Constants.FirebaseVisitContactEmail),
        contactNumber: doc.get(Constants.FirebaseVisitContactNumber),
        createdBy: doc.get(Constants.FirebaseVisitCreatedBy),
        createdTime: (doc.get(Constants.FirebaseVisitCreatedTime) as Timestamp).toDate(),
        nextVisitDate: (doc.get(Constants.FirebaseVisitNextVisitDate) as Timestamp).toDate(),
        nextVisitPurpose: doc.get(Constants.FirebaseVisitNextVisitPurpose),
        photos: doc.get(Constants.FirebaseVisitPhotos) is Iterable ?
        List.from(doc.get(Constants.FirebaseVisitPhotos)) : null,
        position: doc.get(Constants.FirebaseVisitPosition),
        visitDate: (doc.get(Constants.FirebaseVisitDate) as Timestamp).toDate(),
        visitingPerson: doc.get(Constants.FirebaseVisitPerson)
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map[Constants.FirebaseVisitId] = id;
    map[Constants.FirebaseVisitCompanyName] = companyName;
    map[Constants.FirebaseVisitCompanyId] = companyId;
    map[Constants.FirebaseVisitContactEmail] = contactEmail;
    map[Constants.FirebaseVisitContactNumber] = contactNumber;
    map[Constants.FirebaseVisitCreatedBy] = createdBy;
    map[Constants.FirebaseVisitCreatedTime] = Timestamp.fromDate(createdTime);
    map[Constants.FirebaseVisitNextVisitDate] = Timestamp.fromDate(nextVisitDate);
    map[Constants.FirebaseVisitNextVisitPurpose] = nextVisitPurpose;
    map[Constants.FirebaseVisitPhotos] = photos;
    map[Constants.FirebaseVisitPosition] = position;
    map[Constants.FirebaseVisitDate] = Timestamp.fromDate(visitDate);
    map[Constants.FirebaseVisitPerson] = visitingPerson;
    return map;
  }

  @override
  String toString() {
    return 'VisitModel{id: $id, companyName: $companyName, companyId: $companyId, '
        'contactEmail: $contactEmail, contactNumber: $contactNumber, createdBy: $createdBy, '
        'createdTime: $createdTime, nextVisitDate: $nextVisitDate, nextVisitPurpose: $nextVisitPurpose, '
        'photos: ${photos!.length}, position: $position, visitDate: $visitDate, visitingPerson: $visitingPerson}';
  }
}