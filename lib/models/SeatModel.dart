class SeatModel{
  static const String customerTable = "seats";
  static const String idColumn = "id";
  static const String occasionColumn = "occasion";
  static const String nameColumn = "name";
  static const String tableColumn = "table";

  String? id;
  int? occasion;
  String? name;
  String? table;

  SeatModel({
    this.id,
    this.occasion,
    this.name,
    this.table,
  });

  static SeatModel fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json[idColumn],
      occasion: json[occasionColumn],
      name: json[nameColumn],
      table: json[tableColumn],
    );
  }
}