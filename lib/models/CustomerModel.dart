class CustomerModel{
  static const String customerTable = "customers";
  static const String idColumn = "id";
  static const String createdAtColumn = "created_at";
  static const String nameColumn = "name";
  static const String surnameColumn = "surname";
  static const String emailColumn = "email";
  static const String sexColumn = "sex";

  int? id;
  DateTime? createdAt;
  String? email;
  String? name;
  String? surname;
  String? sex;

  CustomerModel({
    this.id,
    this.createdAt,
    this.email,
    this.name,
    this.surname,
    this.sex
  });

  static CustomerModel fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json[idColumn],
      createdAt: json[createdAtColumn] != null ? DateTime.parse(json[createdAtColumn]) : null,
      email: json[emailColumn],
      name: json[nameColumn],
      surname: json[surnameColumn],
      sex: json[sexColumn],
    );
  }

  Map<String, dynamic> toJson() {
    var map = {
      emailColumn: email,
      nameColumn: name,
      surnameColumn: surname,
      sexColumn: sex
    };
    if(id != null)
    {
      map[idColumn] = id.toString();
    }
    return map;
  }

  @override
  String toString() => "${name} ${surname} (${email})";
}