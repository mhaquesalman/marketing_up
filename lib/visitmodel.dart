class VisitModel {
  final int? id;
  final String company;
  final String person;
  final String phone;
  final DateTime date;

  VisitModel({this.id,
    required this.company,
    required this.person,
    required this.phone,
    required this.date});

  // VisitModel.withId(this.id, this.company, this.person, this.phone, this.date);

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['company'] = company;
    map['person'] = person;
    map['phone'] = phone;
    map['date'] = date.toIso8601String();
    return map;
  }

  factory VisitModel.fromMap(Map<String, dynamic> map) {
    return VisitModel(
      id: map['id'],
      company: map['company'],
      person: map['person'],
      phone: map['phone'],
      date: DateTime.parse(map['date']),
    );
  }

  @override
  String toString() {
    return 'VisitModel{company: $company, person: $person, phone: $phone, date: $date }';
  }
}