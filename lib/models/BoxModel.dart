import 'package:ticketonline/models/BoxGroupModel.dart';
import 'package:ticketonline/SeatReservationComponent/utils/seat_state.dart';

class BoxModel{
  static const String soldType = "sold";
  static const String selectedType = "selected";
  static const String blackType = "black";
  static const String availableType = "available";

  static const String boxTable = "boxes";

  static const String typeColumn = "type";
  static const String idColumn = "id";
  static const String occasionColumn = "occasion";
  static const String nameColumn = "name";
  static const String boxGroupColumn = "box_group";
  static const String roomColumn = "room";
  static const String xColumn = "x";
  static const String yColumn = "y";

  int? id;
  int? occasion;
  String? name;
  String? type;
  int? boxGroupId;
  BoxGroupModel? boxGroup;
  int? room;
  int? x;
  int? y;

  BoxModel({
    this.id,
    this.occasion,
    this.name,
    this.type,
    this.boxGroupId,
    this.boxGroup,
    this.room,
    this.x,
    this.y
  });

  static BoxModel fromJson(Map<String, dynamic> json) {

    var groupModel = json[BoxGroupModel.boxGroupsTable] != null ? BoxGroupModel.fromJson(json[BoxGroupModel.boxGroupsTable]) : null;
    var model =  BoxModel(
      id: json[idColumn],
      occasion: json[occasionColumn],
      name: json[nameColumn],
      type: json[typeColumn],
      room: json[roomColumn],
      x: json[xColumn],
      y: json[yColumn],
      boxGroupId: json[boxGroupColumn]??groupModel?.id,
      boxGroup: groupModel,
    );
    return model;
  }

  Map<String, dynamic> toJson() {
    var map = {
      occasionColumn: occasion,
      nameColumn: name,
      typeColumn: type,
      boxGroupColumn: boxGroupId,
      roomColumn: room,
      xColumn: x,
      yColumn: y
    };
    if(id != null)
    {
      map[idColumn] = id;
    }
    return map;
  }

  SeatState getState() {
    return States.entries.firstWhere((element) => element.value==type!).key;
  }

  static Map<SeatState, String> States = {
    SeatState.black: blackType,
    SeatState.available: availableType,
    SeatState.selected: selectedType,
    SeatState.sold: soldType,
  };

  @override
  toString()
  {
    return "stůl ${boxGroup}, sedadlo ${name}";
  }

  toShortString()
  {
    return "${boxGroup??""}${name??""}";
  }
}