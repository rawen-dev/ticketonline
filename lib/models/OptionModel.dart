import 'package:ticketonline/models/OptionGroup.dart';

class OptionModel{
  static const String optionTable = "options";
  static const String idColumn = "id";
  static const String nameColumn = "name";
  static const String priceColumn = "price";
  static const String optionGroupColumn = "option_group";

  int? id;
  String? name;
  int? price;
  OptionGroupModel? optionGroup;

  OptionModel({
    this.id,
    this.name,
    this.price,
    this.optionGroup,
  });

  static OptionModel fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json[idColumn],
      name: json[nameColumn],
      price: json[priceColumn],
      optionGroup: json[optionGroupColumn],
    );
  }

  @override
  String toString(){
    return name??"";
  }
}