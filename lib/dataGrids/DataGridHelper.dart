import 'package:flutter/material.dart';
import 'package:ticketonline/models/OptionModel.dart';

class DataGridHelper
{
  static String GetValueFromFormatted(dynamic value) {
    final startIndex = value.indexOf(":");
    if(startIndex == -1)
    {
      return value;
    }
    var result = value.substring(startIndex+1);
    return result;
  }

  static String returnQuestionMarkOnInvalid(dynamic value, List<String> allValues) {
    if(!allValues.contains(value))
    {
      return "???";
    }
    return value;
  }

  static int? GetIdFromFormatted(String value) {
    final startIndex = value.indexOf(":");
    if(startIndex == -1)
    {
      return null;
    }
    var result = value.substring(0, startIndex);
    var res = int.parse(result);
    return res;
  }

  static Widget checkBoxRenderer(rendererContext, String idString) {
    var value = rendererContext.cell.value == "true" ? "true" : "false";
    return Checkbox(
      value: bool.parse(value),
      onChanged: (bool? value) {
        var cell = rendererContext.row.cells[idString]!;
        rendererContext.stateManager.changeCellValue(cell, value.toString(), force: true);
        rendererContext.cell.value = value.toString();
        },
    );}


  static Widget idRenderer(rendererContext) {
    var value = rendererContext.cell.value == -1 ? "" : rendererContext.cell.value.toString();
    return Text(value);
  }

  static Widget ticketOptionRenderer(rendererContext) {
    OptionModel? value = rendererContext.cell.value;
    if(value!=null) {
      String str = value.name!;
      if(value.price!=null && value.price! > 0)
        {
          //str+=" (${value.price})";
        }
      return Text(str);
    }
    return const Text("");
  }
}