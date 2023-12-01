class BoxGroupModel{
  static const String boxGroupsTable = "box_groups";
  static const String idColumn = "id";
  static const String occasionColumn = "occasion";
  static const String nameColumn = "name";
  static const String roomColumn = "room";

  int? id;
  int? occasion;
  String? name;
  int? seatGroup;

  BoxGroupModel({
    this.id,
    this.occasion,
    this.name,
    this.seatGroup,
  });

  static BoxGroupModel fromJson(Map<String, dynamic> json) {
    return BoxGroupModel(
      id: json[idColumn],
      occasion: json[occasionColumn],
      name: json[nameColumn],
      seatGroup: json[roomColumn],
    );
  }

  @override
  toString()
  {
    return "${name}";
  }
}