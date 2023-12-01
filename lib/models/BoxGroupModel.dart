import 'package:ticketonline/models/BoxModel.dart';

class BoxGroupModel{
  static const String boxGroupsTable = "box_groups";
  static const String idColumn = "id";
  static const String occasionColumn = "occasion";
  static const String nameColumn = "name";
  static const String roomColumn = "room";

  int? id;
  int? occasion;
  String? name;
  int? room;
  List<BoxModel>? boxes = [];

  BoxGroupModel({
    this.id,
    this.occasion,
    this.name,
    this.room,
  });

  static BoxGroupModel fromJson(Map<String, dynamic> json) {
    return BoxGroupModel(
      id: json[idColumn],
      occasion: json[occasionColumn],
      name: json[nameColumn],
      room: json[roomColumn],
    );
  }

  Map<String, dynamic> toJson() {
    var map = {
      occasionColumn: occasion,
      nameColumn: name,
      roomColumn: room,
    };
    if(id != null)
    {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  toString()
  {
    return "${name}";
  }
  List<String> alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  String getNextBoxName()
  {
    return alphabet[boxes!.length];
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override bool operator ==(Object other) {
    if(other is BoxGroupModel)
    {
      return id == other.id;
    }
    return false;
  }
}