class ImageModel {
  final int? id;
  final String image;
  final int companyId;

  ImageModel({this.id, required this.image, required this.companyId});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['image'] = image;
    map['company_id'] = companyId;
    return map;
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'],
      image: map['image'],
      companyId: map['company_id'],
    );
  }


  @override
  String toString() {
    return 'Image{id: $id, image: $image, company_id: $companyId}';
  }
}