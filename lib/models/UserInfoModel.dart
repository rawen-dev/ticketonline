import 'package:pluto_grid/pluto_grid.dart';
import 'package:ticketonline/dataGrids/PlutoAbstract.dart';

class UserInfoModel extends IPlutoRowModel {
  String? id;
  String? email;
  String? name;
  String? surname;
  String? phone;

  static const String idColumn = "id";
  static const String emailReadonlyColumn = "email_readonly";
  static const String nameColumn = "name";
  static const String surnameColumn = "surname";
  static const String phoneColumn = "phone";
  static const String userInfoTable = "user_info";
  static const String userOccasionTable = "user_occasion";
  static const String userOccasionUserColumn = "user";
  static const String userOccasionOccasionColumn = "occasion";



  UserInfoModel({
     this.id,
     this.email,
     this.name,
     this.surname,
     this.phone});

  static UserInfoModel fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json[idColumn],
      email: json[emailReadonlyColumn],
      name: json[nameColumn],
      surname: json[surnameColumn],
      phone: json[phoneColumn],
    );
  }

  static UserInfoModel fromPlutoJson(Map<String, dynamic> json) {
      return UserInfoModel(
        id: json[idColumn]?.isEmpty == true ? null : json[idColumn],
        email: json[emailReadonlyColumn]?.trim().isEmpty ? null : json[emailReadonlyColumn]?.trim(),
        name: json[nameColumn]?.trim().isEmpty ? null : json[nameColumn]?.trim(),
        surname: json[surnameColumn]?.trim().isEmpty ? null : json[surnameColumn]?.trim(),
        phone: json[phoneColumn]?.trim().isEmpty ? null : json[phoneColumn]?.trim(),
      );
    }

  @override
  PlutoRow toPlutoRow() {
    return PlutoRow(cells: {
      idColumn: PlutoCell(value: id),
      emailReadonlyColumn: PlutoCell(value: email ?? ""),
      nameColumn: PlutoCell(value: name ?? ""),
      surnameColumn: PlutoCell(value: surname ?? ""),
      phoneColumn: PlutoCell(value: phone ?? ""),
    });
  }

  @override
  Future<void> deleteMethod() async {
  }

  @override
  Future<void> updateMethod() async {
  }

  @override
  String toBasicString() => email??"";

  @override
  String toString() => toFullNameString();

  String toFullNameString() => "${name??""} ${surname??""}".trim();

  String shortNameToString() {
    return "$name ${(surname!=null && surname!.isNotEmpty) ? "${surname![0]}." : "-"}";
  }

  bool isSignedIn = false;



  bool importedEquals(Map<String, dynamic> u) {
    return 
        u[emailReadonlyColumn].toString().trim().toLowerCase() == email
        && u[nameColumn].toString().trim() == name
        && u[surnameColumn].toString().trim() == surname
        && u[phoneColumn].toString().trim() == phone;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override bool operator ==(Object other) {
    if(other is UserInfoModel)
    {
      return id == other.id;
    }
    return false;
  }
}