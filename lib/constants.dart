class Constants {
  // users collection
  static const FirebaseUserCollection = "users";
  static const FirebaseUserId = "id";
  static const FirebaseActiveStatus = "active_status";
  static const FirebaseCompanyUserLimit = "company_user_limit";
  static const FirebaseCompanyId = "company_id";
  static const FirebaseCompanyVisitLimit = "company_visit_limit";
  static const FirebaseCreatedAt = "created_at";
  static const FirebaseCreatedBy = "created_by";
  static const FirebaseEmail = "email";
  static const FirebaseFullName = "full_name";
  static const FirebasePassword = "password";
  static const FirebasePhoneNumber = "phone_number";
  static const FirebaseUpdatedAt = "updated_at";
  static const FirebaseUserPhoto = "user_photo";
  static const FirebaseUserType = "user_type";
  static const FirebaseToken = "token";

  // default values
  static const DefaultActiveStatus = false;
  static const DefaultActiveStatusForEmployee = true;
  static const DefaultCompanyId = "0";
  static const DefaultCreatedBy = "rzroky";
  static const DefaultCompanyVisitLimit = "100";
  static const DefaultCompanyUserLimit = "5";
  static const DefaultUserType = "admin";
  static const DefaultEmployeeType = "employee";

  // Shared preferences values for employee
  static const SharedPrefEmployeeId = "pref_employee_id";
  static const SharedPrefEmployeeType = "pref_employee_Type";
  static const SharedPrefEmployeeLoginExpired = "pref_employee_login_expired";

  // visits collection
  static const FirebaseVisitCollection = "visits";
  static const FirebaseVisitId = "id";
  static const FirebaseVisitCompanyName = "company_name";
  static const FirebaseVisitCompanyId = "company_id";
  static const FirebaseVisitContactEmail = "contact_email";
  static const FirebaseVisitContactNumber = "contact_number";
  static const FirebaseVisitCreatedBy = "created_by";
  static const FirebaseVisitCreatedTime = "created_time";
  static const FirebaseVisitNextVisitDate = "next_visit_date";
  static const FirebaseVisitNextVisitPurpose = "next_visit_purpose";
  static const FirebaseVisitPhotos = "photos";
  static const FirebaseVisitPosition = "position";
  static const FirebaseVisitDate = "visit_date";
  static const FirebaseVisitPerson = "visiting_person";

  // location collection
static const FirebaseLocationCollection = "live_locations";
static const FirebaseLocationId = "id";
static const FirebaseLocationCompanyId = "company_id";
static const FirebaseLocationAreaName = "area_name";
static const FirebaseLocationCreatedBy = "created_by";
static const FirebaseLocationCreatedTime = "created_time";
static const FirebaseLocationLatPosition = "lat_position";
static const FirebaseLocationLonPosition = "long_position";
static const FirebaseLocationStreetAddress = "streat_address";
static const FirebaseLocationOnline = "online";

}
