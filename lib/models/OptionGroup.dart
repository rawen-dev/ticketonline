import 'OptionModel.dart';

class OptionGroupModel{
  static const String optionGroupTable = "option_groups";
  static const String idColumn = "id";
  static const String nameColumn = "name";
  static const String codeColumn = "code";

  int? id;
  String? name;
  String? code;
  List<OptionModel>? options;

  OptionGroupModel({
    this.id,
    this.name,
    this.code,
    this.options,
  });

  static OptionGroupModel fromJson(Map<String, dynamic> json) {
    var optionGroup = OptionGroupModel(
      id: json[idColumn],
      name: json[nameColumn],
      code: json[codeColumn],
      options: json[OptionModel.optionTable] != null ? List<OptionModel>.from(json[OptionModel.optionTable].map(
              (e)=>OptionModel.fromJson(e))
      )
      : null
    );

    //backreference
    if(optionGroup.options != null)
    {
      for(var o in optionGroup.options!)
      {
        o.optionGroup = optionGroup;
      }
    }
    return optionGroup;
  }

  @override
  String toString(){
    return name??"";
  }
}