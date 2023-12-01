
import 'package:ticketonline/models/BoxGroupModel.dart';

class RoomModel{
  static const String roomTable = "rooms";
  static const String idColumn = "id";
  static const String nameColumn = "name";
  static const String occasionColumn = "occasion";
  static const String heightColumn = "height";
  static const String widthColumn = "width";

  int? id;
  String? name;
  int? occasion;
  int? width;
  int? height;
  List<BoxGroupModel>? seatGroups;

  RoomModel({
    this.id,
    this.name,
    this.occasion,
    this.height,
    this.width,
  });

  static RoomModel fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json[idColumn],
      name: json[nameColumn],
      occasion: json[occasionColumn],
      height: json[heightColumn],
      width: json[widthColumn],
    );
  }

  Map<String, dynamic> toJson() {
    var map = {
      nameColumn: name,
      occasionColumn: occasion,
      heightColumn: height,
      widthColumn: width,
    };
    if(id != null)
    {
      map[idColumn] = id.toString();
    }
    return map;
  }
}