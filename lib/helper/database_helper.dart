import 'dart:io';

import 'package:marketing_up/constants.dart';
import 'package:marketing_up/imagemodel.dart';
import 'package:marketing_up/models/location_model.dart';
import 'package:marketing_up/visitmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();
  static Database? _db;
  static DatabaseHelper getInstance() => _databaseHelper;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<bool> dbExist() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}marketing_up.db';
    bool exist = await databaseExists(path);
    return exist;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}marketing_up.db';
    final visitListDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return visitListDb;
  }

  static const ColLocationId= 'id';
  static const ColLocationCompanyId = 'company_id';
  static const ColLocationAreaName = 'area_name';
  static const ColLocationCreatedBy = 'created_by';
  static const ColLocationCreatedTime = 'created_time';
  static const ColLocationLatPosition = 'lat_position';
  static const ColLocationLonPosition = 'long_position';
  static const ColLocationStreetAddress = 'street_address';
  static const ColLocationOnline = 'online';

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE ${Constants.LocationTable}('
            '${Constants.ColLocationId} INTEGER PRIMARY KEY AUTOINCREMENT, '
            '${Constants.ColLocationCompanyId} TEXT,'
            '${Constants.ColLocationAreaName} TEXT, '
            '${Constants.ColLocationCreatedBy} TEXT, '
            '${Constants.ColLocationCreatedTime} TEXT, '
            '${Constants.ColLocationLatPosition} TEXT, '
            '${Constants.ColLocationLonPosition} TEXT, '
            '${Constants.ColLocationStreetAddress} TEXT, '
            '${Constants.ColLocationOnline} INTEGER'
            ')'
    );
  }

  Future<int> insertLocation(LocationModel locationModel) async {
    Database db = await this.db;
    final int result = await db.insert(Constants.LocationTable, locationModel.toMapLocal());
    return result;
  }

  Future<List<Map<String, dynamic>>> _getLocationListMap(String companyId) async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(
      Constants.LocationTable,
      where: "${Constants.FirebaseCompanyId} = ?",
      whereArgs: [companyId]
    );
    return result;
  }

  Future<List<LocationModel>> getLocationList(String companyId) async {
    final List<Map<String, dynamic>> locationListMap = await _getLocationListMap(companyId);
    final List<LocationModel> locationList = [];
    locationListMap.forEach((locationMap) {
      locationList.add(LocationModel.fromMapLocal(locationMap));
    });
    // visitList.sort((visitA, visitB) => visitB.date.compareTo(visitA.date));
    return locationList;
  }

  Future<int> deleteAllLocation() async {
    Database db = await this.db;
    int result = await db.delete(Constants.LocationTable, where: null);
    return result;
  }

}