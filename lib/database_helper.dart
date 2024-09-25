import 'dart:io';

import 'package:marketing_up/imagemodel.dart';
import 'package:marketing_up/visitmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();
  static Database? _db;

  static DatabaseHelper getInstance() => _databaseHelper;

  String visitTable = "visit_table";
  String colId = 'id';
  String colCompany= 'company';
  String colDate = 'date';
  String colPerson = 'person';
  String colPhone = 'phone';

  String imageTable = "image_table";
  String colImageId = "id";
  String colImage = "image";
  String colCompanyId = "company_id";

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }
  
  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}visit_list.db';
    final visitListDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return visitListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $visitTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$colCompany TEXT, $colDate TEXT, '
            '$colPerson TEXT, $colPhone TEXT)'
    );

    await db.execute(
        'CREATE TABLE $imageTable($colImageId INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$colImage TEXT, $colCompanyId INTEGER)'
    );
  }


  Future<List<Map<String, dynamic>>> getVisitListMap() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(visitTable);
    return result;
  }

  Future<List<VisitModel>> getVisitList() async {
    final List<Map<String, dynamic>> visitMapList = await getVisitListMap();
    //final List<Task> taskList = List<Task>();
    final List<VisitModel> visitList = [];
    visitMapList.forEach((visitMap) {
      visitList.add(VisitModel.fromMap(visitMap));
    });
    // visitList.sort((visitA, visitB) => visitB.date.compareTo(visitA.date));
    return visitList;
  }

  Future<int> insertVisit(VisitModel visitModel) async {
    Database db = await this.db;
    final int result = await db.insert(visitTable, visitModel.toMap());
    return result;
  }

  Future<int> updateVisit(VisitModel visitModel) async {
    Database db = await this.db;
    final int result = await db.update(
      visitTable,
      visitModel.toMap(),
      where: '$colId = ?',
      whereArgs: [visitModel.id],
    );
    return result;
  }

  Future<int> deleteVisit(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      visitTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  Future<int> insertImage(ImageModel imageModel) async {
    Database db = await this.db;
    final int result = await db.insert(imageTable, imageModel.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>> getImageListMap() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(imageTable);
    return result;
  }

  Future<List<ImageModel>> getImageList() async {
    final List<Map<String, dynamic>> imageMapList = await getImageListMap();
    final List<ImageModel> imageList = [];
    imageMapList.forEach((imageMAp) {
      imageList.add(ImageModel.fromMap(imageMAp));
    });
    return imageList;
  }

  Future<Map<String, dynamic>> getVisitListWithImage() async {
    final map = Map<String, dynamic>();
    final visits = await getVisitList();
    final images = await getImageList();
    map['visits'] = visits;
    map['images'] = images;
    return map;
  }
}