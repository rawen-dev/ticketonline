import 'package:ticketonline/models/OptionGroupModel.dart';

class OptionModel{
  static const String optionTable = "options";
  static const String idColumn = "id";
  static const String nameColumn = "name";
  static const String priceColumn = "price";
  static const String optionGroupColumn = "option_group";
  static const String isHiddenColumn = "is_hidden";


  int? id;
  String? name;
  int? price;
  bool? isHidden;
  OptionGroupModel? optionGroup;

  OptionModel({
    this.id,
    this.name,
    this.price,
    this.isHidden,
    this.optionGroup,
  });

  static OptionModel fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json[idColumn],
      name: json[nameColumn],
      price: json[priceColumn],
      isHidden: json[isHiddenColumn],
      optionGroup: json[optionGroupColumn],
    );
  }

  @override
  String toString(){
    return name??"";
  }

  String toStringWithPrice(){
    return price !=null && price! > 0 ? "$name ($price Kč)": name.toString();
  }
}